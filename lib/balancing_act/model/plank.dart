import 'dart:math' as math;

import '../ba_shared_constants.dart';
import 'ba_enums.dart';
import 'ba_mass.dart';
import 'ba_vector2.dart';
import 'mass_force_vector.dart';

class _MassDistancePair {
  _MassDistancePair(this.mass, this.distance);
  final BaMass mass;
  final double distance;
}

/// Source: `js/common/model/Plank.ts` — faithful port of physics & snap.
class Plank {
  Plank({
    required BaVector2 position,
    required this.pivotPoint,
    required ColumnState Function() columnStateGetter,
    required List<BaMass> Function() userControlledMassesGetter,
  })  : _columnStateGetter = columnStateGetter,
        _userControlledMassesGetter = userControlledMassesGetter,
        bottomCenterPosition = position,
        unrotatedMinX = position.x - BaGeometry.plankLength / 2,
        unrotatedMaxY = position.y + BaGeometry.plankThickness,
        unrotatedMinY = position.y,
        maxTiltAngle = math.asin(position.y / (BaGeometry.plankLength / 2));

  final BaVector2 pivotPoint;
  final ColumnState Function() _columnStateGetter;
  final List<BaMass> Function() _userControlledMassesGetter;

  final double unrotatedMinX;
  final double unrotatedMaxY;
  final double unrotatedMinY;
  final double maxTiltAngle;

  double tiltAngle = 0;
  BaVector2 bottomCenterPosition;
  double angularVelocity = 0;
  double currentNetTorque = 0;

  final List<BaMass> massesOnSurface = [];
  final List<MassForceVector> forceVectors = [];
  final List<double> activeDropPositions = [];
  final List<_MassDistancePair> _massDistancePairs = [];

  ColumnState _lastColumnState = ColumnState.doubleColumns;

  /// Call when column state changes (mirrors Property.link).
  void onColumnStateChanged(ColumnState newState) {
    if (newState == ColumnState.singleColumn) {
      _forceToMaxAndStill();
    } else if (newState == ColumnState.doubleColumns) {
      _forceToLevelAndStill();
    }
    _lastColumnState = newState;
  }

  /// Source: `Plank.step` — exact update order.
  void step(double dt) {
    _syncColumnStateIfNeeded();
    updateNetTorque();

    var angularAcceleration = currentNetTorque / BaGeometry.momentOfInertia;
    angularAcceleration =
        angularAcceleration.abs() > BaGeometry.angularAccelerationEpsilon
            ? angularAcceleration
            : 0;
    // SOURCE TRUTH: ω += α  (NOT ω += α * dt)
    angularVelocity += angularAcceleration;
    angularVelocity = angularVelocity.abs() > BaGeometry.angularVelocityEpsilon
        ? angularVelocity
        : 0;

    final previousTiltAngle = tiltAngle;
    var newTiltAngle = tiltAngle + angularVelocity * dt;
    if (newTiltAngle.abs() > maxTiltAngle) {
      newTiltAngle = maxTiltAngle * (tiltAngle < 0 ? -1 : 1);
      angularVelocity = 0;
    } else if (newTiltAngle.abs() < BaGeometry.nearLevelAngleEpsilon) {
      newTiltAngle = 0;
    }
    tiltAngle = newTiltAngle;

    if (tiltAngle != previousTiltAngle) {
      updatePlank();
      updateMassPositions();
    }

    // Simulate friction — SOURCE TRUTH: per step, not ×dt
    angularVelocity *= BaGeometry.dampingFactor;

    _updateActiveDropPositions();
  }

  void _syncColumnStateIfNeeded() {
    final state = _columnStateGetter();
    if (state != _lastColumnState) {
      onColumnStateChanged(state);
    }
  }

  bool addMassToSurface(BaMass mass) {
    final closestOpenPosition = getOpenMassDroppedPosition(mass.position);
    if (isPointAbovePlank(mass.getMiddlePoint()) &&
        closestOpenPosition != null) {
      mass.position = closestOpenPosition;
      mass.onPlank = true;

      final surfaceCenter = getPlankSurfaceCenter();
      final distance = surfaceCenter.distance(mass.position) *
          (mass.position.x > surfaceCenter.x ? 1 : -1);
      _massDistancePairs.add(_MassDistancePair(mass, distance));

      forceVectors.add(MassForceVector(mass));
      massesOnSurface.add(mass);
      updateMassPositions();
      updateNetTorque();
      return true;
    }
    return false;
  }

  /// Source: `addMassToSurfaceAt`
  void addMassToSurfaceAt(BaMass mass, double distanceFromCenter) {
    if (distanceFromCenter.abs() > BaGeometry.plankLength / 2) {
      throw StateError(
        'Attempt to add mass at invalid distance from center',
      );
    }
    final vectorToPosition = getPlankSurfaceCenter()
        .plus(BaVector2.createPolar(distanceFromCenter, tiltAngle));
    mass.position = BaVector2(vectorToPosition.x, vectorToPosition.y + 0.01);
    addMassToSurface(mass);
  }

  void updateMassPositions() {
    for (final mass in massesOnSurface) {
      final vectorFromCenterToMass = BaVector2(
        getMassDistanceFromCenter(mass),
        0,
      ).rotated(tiltAngle);
      mass.rotationAngle = tiltAngle;
      mass.position = getPlankSurfaceCenter().plus(vectorFromCenterToMass);
    }
    for (final fv in forceVectors) {
      fv.update();
    }
  }

  void removeMassFromSurface(BaMass mass) {
    massesOnSurface.remove(mass);
    for (var i = 0; i < _massDistancePairs.length; i++) {
      if (identical(_massDistancePairs[i].mass, mass)) {
        _massDistancePairs.removeAt(i);
        break;
      }
    }
    mass.rotationAngle = 0;
    mass.onPlank = false;
    forceVectors.removeWhere((fv) => identical(fv.mass, mass));
    updateNetTorque();
  }

  void removeAllMasses() {
    final copy = List<BaMass>.from(massesOnSurface);
    for (final mass in copy) {
      removeMassFromSurface(mass);
    }
  }

  double getMassDistanceFromCenter(BaMass mass) {
    for (final pair in _massDistancePairs) {
      if (identical(pair.mass, mass)) {
        return pair.distance;
      }
    }
    return 0;
  }

  void updatePlank() {
    if (pivotPoint.y < unrotatedMinY) {
      throw StateError('Pivot point cannot be below the plank.');
    }
    var attachmentBarVector = BaVector2(0, unrotatedMinY - pivotPoint.y);
    attachmentBarVector = attachmentBarVector.rotated(tiltAngle);
    bottomCenterPosition = pivotPoint.plus(attachmentBarVector);
  }

  /// Public for tests — mirrors private `getOpenMassDroppedPosition`.
  BaVector2? getOpenMassDroppedPosition(BaVector2 position) {
    final validMassPositions = getSnapToPositions();
    if (BaGeometry.numSnapToPositions % 2 == 1) {
      // Remove center so users can't place on fulcrum.
      validMassPositions.removeAt(BaGeometry.numSnapToPositions ~/ 2);
    }

    final candidateOpenPositions = <BaVector2>[];
    for (final validPosition in validMassPositions) {
      var occupiedOrTooFar = false;
      if ((validPosition.x - position.x).abs() >
          BaGeometry.interSnapToMarkerDistance * 2) {
        occupiedOrTooFar = true;
      }
      for (var i = 0;
          i < massesOnSurface.length && !occupiedOrTooFar;
          i++) {
        if (massesOnSurface[i].position.distance(validPosition) <
            BaGeometry.interSnapToMarkerDistance / 10) {
          occupiedOrTooFar = true;
        }
      }
      if (!occupiedOrTooFar) {
        candidateOpenPositions.add(validPosition);
      }
    }

    BaVector2? closestOpenPosition;
    for (final candidate in candidateOpenPositions) {
      if ((candidate.x - position.x).abs() <=
          BaGeometry.interSnapToMarkerDistance) {
        if (closestOpenPosition == null ||
            candidate.distance(position) <
                closestOpenPosition.distance(position)) {
          closestOpenPosition = candidate;
        }
      }
    }
    return closestOpenPosition;
  }

  List<BaVector2> getSnapToPositions() {
    // Growable — caller may splice out the center slot.
    final snapToPositions = <BaVector2>[];
    for (var i = 0; i < BaGeometry.numSnapToPositions; i++) {
      final unrotatedPoint = BaVector2(
        unrotatedMinX + (i + 1) * BaGeometry.interSnapToMarkerDistance,
        unrotatedMaxY,
      );
      snapToPositions.add(_rotateAroundPivot(unrotatedPoint));
    }
    return snapToPositions;
  }

  BaVector2 _rotateAroundPivot(BaVector2 point) {
    final relative = point.minus(pivotPoint);
    return pivotPoint.plus(relative.rotated(tiltAngle));
  }

  void _forceToLevelAndStill() => _forceAngle(0);
  void _forceToMaxAndStill() => _forceAngle(maxTiltAngle);

  void _forceAngle(double angle) {
    angularVelocity = 0;
    tiltAngle = angle;
    updatePlank();
    updateMassPositions();
  }

  BaVector2 getPlankSurfaceCenter() {
    return bottomCenterPosition.plus(
      BaVector2.createPolar(
        BaGeometry.plankThickness,
        tiltAngle + math.pi / 2,
      ),
    );
  }

  double getSurfaceYValue(double xValue) {
    final m = math.tan(tiltAngle);
    final plankSurfaceCenter = getPlankSurfaceCenter();
    final b = plankSurfaceCenter.y - m * plankSurfaceCenter.x;
    return m * xValue + b;
  }

  bool isPointAbovePlank(BaVector2 p) {
    final plankSpan = BaGeometry.plankLength * math.cos(tiltAngle);
    final surfaceCenter = getPlankSurfaceCenter();
    return p.x >= surfaceCenter.x - (plankSpan / 2) &&
        p.x <= surfaceCenter.x + (plankSpan / 2) &&
        p.y > getSurfaceYValue(p.x);
  }

  /// Source: `isBalanced` — `|Σ m·d| < COMPARISON_TOLERANCE` (strict `<`).
  bool isBalanced() {
    var unCompensatedTorque = 0.0;
    for (final mass in massesOnSurface) {
      unCompensatedTorque +=
          mass.massValue * getMassDistanceFromCenter(mass);
    }
    return unCompensatedTorque.abs() < BaSharedConstants.comparisonTolerance;
  }

  void updateNetTorque() {
    currentNetTorque = 0;
    if (_columnStateGetter() == ColumnState.noColumns) {
      currentNetTorque += getTorqueDueToMasses();
      // Plank self-torque — no g
      currentNetTorque +=
          (pivotPoint.x - bottomCenterPosition.x) * BaGeometry.plankMass;
    }
  }

  /// SOURCE TRUTH literal: `pivotX - x * m` (operator precedence).
  double getTorqueDueToMasses() {
    var torque = 0.0;
    for (final mass in massesOnSurface) {
      torque += pivotPoint.x - mass.position.x * mass.massValue;
    }
    return torque;
  }

  void _updateActiveDropPositions() {
    final tempDropPositions = <double>[];
    for (final userControlledMass in _userControlledMassesGetter()) {
      if (isPointAbovePlank(userControlledMass.getMiddlePoint())) {
        final closest =
            getOpenMassDroppedPosition(userControlledMass.position);
        if (closest != null) {
          final plankSurfaceCenter = getPlankSurfaceCenter();
          final distanceFromCenter = closest.distance(plankSurfaceCenter) *
              (closest.x < 0 ? -1 : 1);
          tempDropPositions.add(distanceFromCenter);
        }
      }
    }
    activeDropPositions
      ..clear()
      ..addAll(tempDropPositions);
  }

  /// For tests: signed surface distance sum used by isBalanced.
  double uncompensatedTorqueForTest() {
    var t = 0.0;
    for (final mass in massesOnSurface) {
      t += mass.massValue * getMassDistanceFromCenter(mass);
    }
    return t;
  }
}

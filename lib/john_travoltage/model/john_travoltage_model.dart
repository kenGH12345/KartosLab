import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'arm.dart';
import 'electron.dart';
import 'john_travoltage_constants.dart';
import 'jt_geometry.dart';
import 'jt_vec2.dart';
import 'leg.dart';
import 'line_segment.dart';

/// Port of PhET `JohnTravoltageModel.js`.
class JohnTravoltageModel extends ChangeNotifier
    implements JohnTravoltageElectronHost {
  JohnTravoltageModel({math.Random? random})
      : random = random ?? math.Random() {
    arm = Arm();
    leg = Leg();
    _legAngleAtPreviousStep = leg.angle;

    for (final c in JohnTravoltageConstants.forceLineCoords) {
      forceLines.add(LineSegment(c.$1, c.$2, c.$3, c.$4));
    }

    final verts = JohnTravoltageConstants.bodyVertices;
    for (var i = 0; i < verts.length - 1; i++) {
      lineSegments.add(LineSegment.fromPoints(verts[i], verts[i + 1]));
    }
    lineSegments.add(LineSegment.fromPoints(verts.last, verts.first));

    _lastAngle = leg.angle;
  }

  @override
  final math.Random random;

  late final Arm arm;
  late final Leg leg;

  @override
  final List<Electron> electrons = [];

  @override
  final List<Electron> electronsToRemove = [];

  @override
  final List<LineSegment> forceLines = [];

  @override
  final List<LineSegment> lineSegments = [];

  final List<JtVec2> bodyVertices =
      List.unmodifiable(JohnTravoltageConstants.bodyVertices);

  bool sparkVisible = false;

  /// Dist to knob when spark path was created; cleared when spark ends.
  double? sparkCreationDistToKnob;

  /// Electrons that left the body in the last completed discharge event.
  int numberOfElectronsDischarged = 0;

  int _numberOfElectronsOnDischargeStart = 0;
  int _nextElectronId = 1;

  /// Accumulated |Δangle| while foot on carpet (internal, for tests).
  double accumulatedAngle = 0;
  double _lastAngle = 0;
  double _legAngleAtPreviousStep = 0;

  /// Absolute |Δangle| from the latest [setLegAngle] call.
  /// Reserved for Phase-4+ `FootDragSoundGenerator` (not used for charge).
  double lastLegAngleDelta = 0;

  final List<VoidCallback> _dischargeStartedListeners = [];
  final List<VoidCallback> _dischargeEndedListeners = [];
  final List<VoidCallback> _resetListeners = [];
  final List<void Function(double dt)> _stepListeners = [];

  int get electronCount => electrons.length;

  JtVec2 get fingerPosition => arm.getFingerPosition();

  bool get shoeOnCarpet => leg.shoeOnCarpet;

  JtVec2 get doorknobPosition => JohnTravoltageConstants.doorknobPosition;

  void addDischargeStartedListener(VoidCallback listener) =>
      _dischargeStartedListeners.add(listener);

  void removeDischargeStartedListener(VoidCallback listener) =>
      _dischargeStartedListeners.remove(listener);

  void addDischargeEndedListener(VoidCallback listener) =>
      _dischargeEndedListeners.add(listener);

  void removeDischargeEndedListener(VoidCallback listener) =>
      _dischargeEndedListeners.remove(listener);

  void addResetListener(VoidCallback listener) =>
      _resetListeners.add(listener);

  void removeResetListener(VoidCallback listener) =>
      _resetListeners.remove(listener);

  void addStepListener(void Function(double dt) listener) =>
      _stepListeners.add(listener);

  void removeStepListener(void Function(double dt) listener) =>
      _stepListeners.remove(listener);

  /// Set leg angle and apply carpet charge accumulation (lazyLink equivalent).
  void setLegAngle(double angle, {bool applyLimitRotation = false}) {
    final next =
        applyLimitRotation ? Leg.limitRotation(angle) : angle;
    final previous = leg.angle;
    leg.setAngle(next);
    if (leg.angle != previous) {
      lastLegAngleDelta = (leg.angle - previous).abs();
      _onLegAngleChanged(leg.angle);
      notifyListeners();
    } else {
      lastLegAngleDelta = 0;
    }
  }

  void setArmAngle(double angle) {
    final previous = arm.angle;
    arm.setAngle(angle);
    if (arm.angle != previous) {
      notifyListeners();
    }
  }

  void _onLegAngleChanged(double angle) {
    if (angle > JohnTravoltageConstants.footOnCarpetMinAngle &&
        angle < JohnTravoltageConstants.footOnCarpetMaxAngle &&
        electrons.length < JohnTravoltageConstants.maxElectrons) {
      accumulatedAngle += (angle - _lastAngle).abs();

      while (accumulatedAngle >
              JohnTravoltageConstants.accumulatedAngleThreshold &&
          electrons.length < JohnTravoltageConstants.maxElectrons) {
        createElectron();
        accumulatedAngle -=
            JohnTravoltageConstants.accumulatedAngleThreshold;
      }
    }
    _lastAngle = angle;
  }

  /// Create one electron on the spawn segment (electronGroup factory).
  Electron createElectron() {
    final segment = LineSegment.fromPoints(
      JohnTravoltageConstants.electronSpawnP0,
      JohnTravoltageConstants.electronSpawnP1,
    );
    final v = segment.vector;
    final rand = random.nextDouble() * v.magnitude;
    final point = segment.p0.plus(v.normalize().times(rand));
    final electron = Electron(
      x: point.x,
      y: point.y,
      model: this,
      id: _nextElectronId++,
    );
    electrons.add(electron);
    return electron;
  }

  /// Debug / test: inject an electron at an exact position.
  Electron debugAddElectronAt(JtVec2 point) {
    final electron = Electron(
      x: point.x,
      y: point.y,
      model: this,
      id: _nextElectronId++,
    );
    electrons.add(electron);
    return electron;
  }

  bool bodyContainsPoint(JtVec2 point) =>
      JtGeometry.polygonContainsPointSafe(bodyVertices, point);

  /// PhET `moveElectronInsideBody`.
  void moveElectronInsideBody(Electron electron) {
    final pt = electron.position;
    LineSegment? closestSegment;
    var best = double.infinity;
    for (final lineSegment in lineSegments) {
      final d = JtGeometry.distToSegmentSquared(
        pt,
        lineSegment.pre0,
        lineSegment.pre1,
      );
      if (d < best) {
        best = d;
        closestSegment = lineSegment;
      }
    }
    if (closestSegment == null) return;
    final vector = pt.minus(closestSegment.center);
    if (vector.dot(closestSegment.normal) > 0) {
      electron.position =
          closestSegment.center.plus(closestSegment.normal.times(-1));
    }
  }

  /// Main simulation step — PhET `JohnTravoltageModel.step`.
  void step(double dt) {
    if (dt > JohnTravoltageConstants.maxDt) {
      dt = JohnTravoltageConstants.maxDt;
    }

    final distToKnob = arm.getFingerPosition().distance(doorknobPosition);
    const actualMin = JohnTravoltageConstants.fingerKnobActualMin;
    final query = electrons.length / distToKnob;
    final threshold = JohnTravoltageConstants.dischargeThresholdNumerator /
        actualMin;

    final electronThresholdExceeded = query > threshold;
    if (electronThresholdExceeded) {
      sparkCreationDistToKnob = distToKnob;
      for (final e in electrons) {
        e.exiting = true;
      }
    } else {
      if (sparkCreationDistToKnob != null &&
          distToKnob >
              sparkCreationDistToKnob! +
                  JohnTravoltageConstants.sparkCancelExtraDistance) {
        for (final electron in electrons) {
          if (electron.position.distance(doorknobPosition) >
              JohnTravoltageConstants.sparkCancelElectronKnobDistance) {
            final wasExiting = electron.exiting;
            electron.exiting = false;
            electron.segment = null;
            electron.lastSegment = null;
            if (wasExiting) {
              moveElectronInsideBody(electron);
            }
          }
        }
      }
    }

    final length = electrons.length;
    for (var i = 0; i < length; i++) {
      electrons[i].step(dt);
    }

    final wasSpark = sparkVisible;
    if (electronsToRemove.isNotEmpty) {
      sparkVisible = true;
    }
    if (!wasSpark && sparkVisible) {
      _numberOfElectronsOnDischargeStart = electrons.length;
      for (final l in List<VoidCallback>.from(_dischargeStartedListeners)) {
        l();
      }
    }

    while (electronsToRemove.isNotEmpty) {
      final e = electronsToRemove.removeLast();
      electrons.remove(e);
    }

    final anyExiting = electrons.any((e) => e.exiting);
    if (electrons.isEmpty || !anyExiting) {
      if (wasSpark) {
        sparkVisible = false;
        sparkCreationDistToKnob = null;
        numberOfElectronsDischarged =
            _numberOfElectronsOnDischargeStart - electrons.length;
        for (final l in List<VoidCallback>.from(_dischargeEndedListeners)) {
          l();
        }
      }
    }

    leg.angularVelocity = (leg.angle - _legAngleAtPreviousStep) / dt;
    _legAngleAtPreviousStep = leg.angle;

    for (final l in List<void Function(double)>.from(_stepListeners)) {
      l(dt);
    }

    notifyListeners();
  }

  /// PhET `JohnTravoltageModel.reset`.
  void reset() {
    for (final l in List<VoidCallback>.from(_resetListeners)) {
      l();
    }

    sparkVisible = false;
    sparkCreationDistToKnob = null;
    arm.reset();
    leg.reset();
    electrons.clear();
    electronsToRemove.clear();

    _lastAngle = leg.initialAngle;
    accumulatedAngle = 0;
    lastLegAngleDelta = 0;
    numberOfElectronsDischarged = 0;
    _numberOfElectronsOnDischargeStart = 0;
    _legAngleAtPreviousStep = leg.angle;

    notifyListeners();
  }
}

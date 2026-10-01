import 'dart:math' as math;

import '../caf_constants.dart';
import 'charges_and_fields_model.dart';
import 'vec2.dart';

/// Equipotential line generator — port of ElectricPotentialLine.ts
class ElectricPotentialLine {
  ElectricPotentialLine(this.model, this.seedPosition) {
    rebuild();
  }

  final ChargesAndFieldsModel model;
  final CafVec2 seedPosition;

  late double electricPotential;
  late List<CafVec2> positionArray;
  bool isLineClosed = false;
  bool isEquipotentialLineTerminatingInsideBounds = true;

  /// Draggable voltage label position (model coords).
  late CafVec2 voltageLabelPosition;

  void rebuild() {
    electricPotential = model.getElectricPotential(seedPosition);
    voltageLabelPosition = seedPosition;
    isLineClosed = false;
    isEquipotentialLineTerminatingInsideBounds = true;
    final e = model.getElectricField(seedPosition);
    positionArray =
        e.magnitude != 0 ? _getEquipotentialPositionArray(seedPosition) : [];
  }

  CafVec2 _getNextAlongEquipotentialWithPotential(
    CafVec2 position,
    double targetPotential,
    double deltaDistance,
  ) {
    final initialElectricField = model.getElectricField(position);
    final electricPotentialNormalizedVector =
        initialElectricField.normalize().rotate(math.pi / 2);
    final midwayPosition =
        electricPotentialNormalizedVector.timesScalar(deltaDistance) + position;
    final midwayElectricField = model.getElectricField(midwayPosition);
    final midwayElectricPotential = model.getElectricPotential(midwayPosition);
    final deltaElectricPotential = midwayElectricPotential - targetPotential;
    final deltaPosition = midwayElectricField.timesScalar(
      deltaElectricPotential / midwayElectricField.magnitudeSquared,
    );

    if (deltaPosition.magnitude > deltaDistance.abs()) {
      return _getNextAlongEquipotentialWithRK4(position, deltaDistance);
    }
    return midwayPosition + deltaPosition;
  }

  CafVec2 _getNextAlongEquipotentialWithRK4(
    CafVec2 position,
    double deltaDistance,
  ) {
    final k1 = model
        .getElectricField(position)
        .normalize()
        .rotate(math.pi / 2);
    final k2 = model
        .getElectricField(position + k1.timesScalar(deltaDistance / 2))
        .normalize()
        .rotate(math.pi / 2);
    final k3 = model
        .getElectricField(position + k2.timesScalar(deltaDistance / 2))
        .normalize()
        .rotate(math.pi / 2);
    final k4 = model
        .getElectricField(position + k3.timesScalar(deltaDistance))
        .normalize()
        .rotate(math.pi / 2);
    final deltaDisplacement = CafVec2(
      deltaDistance * (k1.x + 2 * k2.x + 2 * k3.x + k4.x) / 6,
      deltaDistance * (k1.y + 2 * k2.y + 2 * k3.y + k4.y) / 6,
    );
    return position + deltaDisplacement;
  }

  List<CafVec2> _getEquipotentialPositionArray(CafVec2 position) {
    if (model.activeChargedParticles.isEmpty) return [];

    var stepCounter = 0;
    var currentClockwise = position;
    var currentCounterClockwise = position;
    final clockwise = <CafVec2>[];
    final counterClockwise = <CafVec2>[];

    var clockwiseEps = CafConstants.minEpsilonDistance;
    var counterClockwiseEps = -clockwiseEps;

    while ((stepCounter < CafConstants.maxEquipotentialSteps) &&
        !isLineClosed &&
        (isEquipotentialLineTerminatingInsideBounds ||
            stepCounter < CafConstants.minEquipotentialSteps)) {
      final nextCw = _getNextAlongEquipotentialWithPotential(
        currentClockwise,
        electricPotential,
        clockwiseEps,
      );
      final nextCcw = _getNextAlongEquipotentialWithPotential(
        currentCounterClockwise,
        electricPotential,
        counterClockwiseEps,
      );

      clockwise.add(nextCw);
      counterClockwise.add(nextCcw);
      currentClockwise = nextCw;
      currentCounterClockwise = nextCcw;
      stepCounter++;

      if (stepCounter > 3) {
        clockwiseEps =
            _adaptiveEpsilon(clockwiseEps, clockwise, isClockwise: true);
        counterClockwiseEps = _adaptiveEpsilon(
          counterClockwiseEps,
          counterClockwise,
          isClockwise: false,
        );

        final approach =
            currentClockwise.distance(currentCounterClockwise);
        if (approach < clockwiseEps + counterClockwiseEps.abs()) {
          clockwiseEps = approach / 3;
          counterClockwiseEps = -clockwiseEps;
          if (approach < 2 * CafConstants.minEpsilonDistance) {
            isLineClosed = true;
          }
        }
      }

      isEquipotentialLineTerminatingInsideBounds =
          model.enlargedBounds.containsPoint(currentClockwise) ||
              model.enlargedBounds.containsPoint(currentCounterClockwise);
    }

    if (!isLineClosed && isEquipotentialLineTerminatingInsideBounds) {
      const wee = CafVec2(0.00031415, 0.00027178);
      return _getEquipotentialPositionArray(position + wee);
    }

    final reversed = clockwise.reversed.toList();
    return [...reversed, position, ...counterClockwise];
  }

  double _adaptiveEpsilon(
    double epsilonDistance,
    List<CafVec2> positionArray, {
    required bool isClockwise,
  }) {
    final deflection = _rotationAngle(positionArray);
    var eps = epsilonDistance;
    if (deflection == 0) {
      eps = CafConstants.maxEpsilonDistance;
    } else {
      eps *= (2 * math.pi / 360) / deflection;
    }
    eps = eps.abs().clamp(
      CafConstants.minEpsilonDistance,
      CafConstants.maxEpsilonDistance,
    );
    return isClockwise ? eps : -eps;
  }

  double _rotationAngle(List<CafVec2> positionArray) {
    final length = positionArray.length;
    final newDelta =
        positionArray[length - 1] - positionArray[length - 2];
    final oldDelta =
        positionArray[length - 2] - positionArray[length - 3];
    return newDelta.angleBetween(oldDelta);
  }

  List<CafVec2> getPrunedPositionArray([List<CafVec2>? raw]) {
    final positionArray = raw ?? this.positionArray;
    final length = positionArray.length;
    if (length == 0) return [];

    final pruned = <CafVec2>[positionArray[0]];
    const maxOffset = CafConstants.pruneMaxOffset;
    var lastPushedIndex = 0;

    for (var i = 1; i < length - 1; i++) {
      final lastPushed = pruned.last;
      for (var j = lastPushedIndex; j < i + 1; j++) {
        final distance = _distanceFromLine(
          lastPushed,
          positionArray[j + 1],
          positionArray[i + 1],
        );
        if (distance > maxOffset) {
          pruned.add(positionArray[i]);
          lastPushedIndex = i;
          break;
        }
      }
    }
    pruned.add(positionArray[length - 1]);
    return pruned;
  }

  double _distanceFromLine(
    CafVec2 initialPoint,
    CafVec2 midwayPoint,
    CafVec2 finalPoint,
  ) {
    final midwayDisplacement = midwayPoint - initialPoint;
    final finalDisplacement = finalPoint - initialPoint;
    final m = finalDisplacement.magnitude;
    if (m == 0) return midwayDisplacement.magnitude;
    return midwayDisplacement
        .crossScalar(finalDisplacement.normalize())
        .abs();
  }
}

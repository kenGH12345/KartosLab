import 'dart:math' as math;

import '../caf_constants.dart';
import 'charged_particle.dart';
import 'electric_field_sensor.dart';
import 'electric_potential_line.dart';
import 'electric_potential_sensor.dart';
import 'measuring_tape.dart';
import 'vec2.dart';

/// Port of ChargesAndFieldsModel.ts — physics + element collections.
class ChargesAndFieldsModel {
  ChargesAndFieldsModel() {
    electricPotentialSensor =
        ElectricPotentialSensor(getElectricPotential);
    measuringTape = MeasuringTapeModel();
  }

  // Visibility / controls
  bool isElectricFieldVisible = true;
  bool isElectricFieldDirectionOnly = false;
  bool isElectricPotentialVisible = false;
  bool areValuesVisible = false;
  bool isGridVisible = false;
  bool snapToGrid = false;
  bool isPlayAreaCharged = false;

  bool allowNewPositiveCharges = true;
  bool allowNewNegativeCharges = true;
  bool allowNewElectricFieldSensors = true;

  bool isResetting = false;

  final CafBounds2 bounds = const CafBounds2(
    -CafConstants.width / 2,
    -CafConstants.height / 2,
    CafConstants.width / 2,
    CafConstants.height / 2,
  );

  final CafBounds2 enlargedBounds = const CafBounds2(
    -1.5 * CafConstants.width / 2,
    -CafConstants.height / 2,
    1.5 * CafConstants.width / 2,
    3 * CafConstants.height / 2,
  );

  CafBounds2 chargesAndSensorsEnclosureBounds = const CafBounds2(
    -1.25,
    -2.30,
    1.25,
    -1.70,
  );

  late CafBounds2 availableModelBounds = enlargedBounds;

  final List<ChargedParticle> chargedParticles = [];
  final List<ChargedParticle> activeChargedParticles = [];
  final List<ElectricFieldSensor> electricFieldSensors = [];
  final List<ElectricPotentialLine> electricPotentialLines = [];

  late final ElectricPotentialSensor electricPotentialSensor;
  late final MeasuringTapeModel measuringTape;

  bool Function()? isChargesAndSensorsPanelDisplayed;

  void Function()? onChanged;

  void notify() => onChanged?.call();

  ChargedParticle addPositiveCharge(CafVec2 initialPosition) =>
      _addCharge(1, initialPosition);

  ChargedParticle addNegativeCharge(CafVec2 initialPosition) =>
      _addCharge(-1, initialPosition);

  ChargedParticle _addCharge(int charge, CafVec2 initialPosition) {
    final particle = ChargedParticle(
      charge: charge,
      initialPosition: initialPosition,
    );
    particle.onReturnedToOrigin = () {
      removeChargedParticle(particle);
    };
    particle.onChanged = () {
      if (particle.isActive) {
        clearElectricPotentialLines();
        updateAllSensors();
      }
      updateIsPlayAreaCharged();
      notify();
    };
    chargedParticles.add(particle);
    notify();
    return particle;
  }

  void setParticleActive(ChargedParticle particle, bool active) {
    if (particle.isActive == active) return;
    particle.isActive = active;
    clearElectricPotentialLines();
    if (active) {
      if (!activeChargedParticles.contains(particle)) {
        activeChargedParticles.add(particle);
      }
    } else {
      activeChargedParticles.remove(particle);
    }
    updateIsPlayAreaCharged();
    updateAllSensors();
    notify();
  }

  void removeChargedParticle(ChargedParticle particle) {
    if (!chargedParticles.contains(particle)) return;
    final wasActive = particle.isActive;
    chargedParticles.remove(particle);
    activeChargedParticles.remove(particle);
    particle.dispose();
    if (wasActive && !isResetting) {
      clearElectricPotentialLines();
      updateAllSensors();
    }
    updateIsPlayAreaCharged();
    notify();
  }

  ElectricFieldSensor addElectricFieldSensor(CafVec2 initialPosition) {
    final sensor = ElectricFieldSensor(
      computeElectricField: getElectricField,
      initialPosition: initialPosition,
    );
    sensor.onReturnedToOrigin = () {
      removeElectricFieldSensor(sensor);
    };
    sensor.onChanged = notify;
    sensor.update();
    electricFieldSensors.add(sensor);
    notify();
    return sensor;
  }

  void removeElectricFieldSensor(ElectricFieldSensor sensor) {
    if (!electricFieldSensors.remove(sensor)) return;
    sensor.dispose();
    notify();
  }

  /// Electric field at [position] (V/m).
  CafVec2 getElectricField(CafVec2 position) {
    var ex = 0.0;
    var ey = 0.0;

    for (final chargedParticle in activeChargedParticles) {
      final distanceSquared =
          chargedParticle.position.distanceSquared(position);

      if (distanceSquared < CafConstants.minDistanceScale) {
        return const CafVec2(10 * CafConstants.maxEFieldMagnitude, 0);
      }

      final distancePowerCube = math.pow(distanceSquared, 1.5).toDouble();
      final q = chargedParticle.charge.toDouble();
      ex += (position.x - chargedParticle.position.x) * q / distancePowerCube;
      ey += (position.y - chargedParticle.position.y) * q / distancePowerCube;
    }

    return CafVec2(ex * CafConstants.kConstant, ey * CafConstants.kConstant);
  }

  /// Electric potential at [position] (V).
  double getElectricPotential(CafVec2 position) {
    if (!isPlayAreaCharged) return 0;

    final netChargeOnSite = _getCharge(position);
    if (netChargeOnSite > 0) return double.infinity;
    if (netChargeOnSite < 0) return double.negativeInfinity;

    var electricPotential = 0.0;
    for (final chargedParticle in activeChargedParticles) {
      final distance = chargedParticle.position.distance(position);
      if (distance > 0) {
        electricPotential += chargedParticle.charge / distance;
      }
    }
    return electricPotential * CafConstants.kConstant;
  }

  int _getCharge(CafVec2 position) {
    var charge = 0;
    for (final p in activeChargedParticles) {
      if (p.position.equals(position)) charge += p.charge;
    }
    return charge;
  }

  void updateIsPlayAreaCharged() {
    var netElectricCharge = 0;
    final n = activeChargedParticles.length;

    for (final p in activeChargedParticles) {
      netElectricCharge += p.charge;
    }

    if (netElectricCharge != 0) {
      isPlayAreaCharged = true;
    } else if (n == 0) {
      isPlayAreaCharged = false;
    } else if (n == 2) {
      final colocated = activeChargedParticles[1]
              .position
              .distance(activeChargedParticles[0].position) <
          CafConstants.minDistanceScale;
      isPlayAreaCharged = !colocated;
    } else if (n == 4) {
      final positives = <CafVec2>[];
      final negatives = <CafVec2>[];
      for (final p in activeChargedParticles) {
        if (p.charge == 1) {
          positives.add(p.position);
        } else {
          negatives.add(p.position);
        }
      }
      if (positives.length == 2 &&
          negatives.length == 2 &&
          ((negatives[0].equals(positives[0]) &&
                  negatives[1].equals(positives[1])) ||
              (negatives[0].equals(positives[1]) &&
                  negatives[1].equals(positives[0])))) {
        isPlayAreaCharged = false;
      } else {
        isPlayAreaCharged = true;
      }
    } else {
      isPlayAreaCharged = true;
    }
  }

  void updateAllSensors() {
    electricPotentialSensor.update();
    for (final s in electricFieldSensors) {
      s.update();
    }
  }

  bool canAddElectricPotentialLine(CafVec2 position) {
    if (!isPlayAreaCharged) return false;
    for (final p in activeChargedParticles) {
      if (p.position.distance(position) <
          CafConstants.equipotentialMinChargeDistance) {
        return false;
      }
    }
    return true;
  }

  ElectricPotentialLine? addElectricPotentialLine([CafVec2? position]) {
    final pos = position ?? electricPotentialSensor.position;
    if (!canAddElectricPotentialLine(pos)) return null;
    final line = ElectricPotentialLine(this, pos);
    electricPotentialLines.add(line);
    notify();
    return line;
  }

  void clearElectricPotentialLines() {
    if (electricPotentialLines.isEmpty) return;
    electricPotentialLines.clear();
    notify();
  }

  CafVec2 snapPosition(CafVec2 position) {
    if (!(snapToGrid && isGridVisible)) return position;
    final s = CafConstants.gridMinorSpacing;
    return position.dividedScalar(s).roundedSymmetric().timesScalar(s);
  }

  void snapAllElements() {
    for (final p in activeChargedParticles) {
      p.position = snapPosition(p.position);
    }
    for (final s in electricFieldSensors) {
      s.position = snapPosition(s.position);
    }
    electricPotentialSensor
        .setPosition(snapPosition(electricPotentialSensor.position));
    measuringTape.basePosition = snapPosition(measuringTape.basePosition);
    measuringTape.tipPosition = snapPosition(measuringTape.tipPosition);
    measuringTape.notify();
    notify();
  }

  void setSnapToGrid(bool value) {
    snapToGrid = value;
    if (value) snapAllElements();
    notify();
  }

  void tick(double dt) {
    for (final p in List<ChargedParticle>.from(chargedParticles)) {
      if (p.isAnimating) p.stepAnimation(dt);
    }
    for (final s in List<ElectricFieldSensor>.from(electricFieldSensors)) {
      if (s.isAnimating) s.stepAnimation(dt);
    }
  }

  bool handleChargeReleased(ChargedParticle particle) {
    particle.isUserControlled = false;
    final panelOk = isChargesAndSensorsPanelDisplayed?.call() ?? true;
    if (panelOk &&
        chargesAndSensorsEnclosureBounds.containsPoint(particle.position)) {
      setParticleActive(particle, false);
      particle.beginReturnAnimation();
      return true;
    }
    setParticleActive(particle, true);
    particle.position = snapPosition(particle.position);
    return false;
  }

  bool handleFieldSensorReleased(ElectricFieldSensor sensor) {
    sensor.isUserControlled = false;
    final panelOk = isChargesAndSensorsPanelDisplayed?.call() ?? true;
    if (panelOk &&
        chargesAndSensorsEnclosureBounds.containsPoint(sensor.position)) {
      sensor.isActive = false;
      sensor.beginReturnAnimation();
      return true;
    }
    sensor.isActive = true;
    sensor.position = snapPosition(sensor.position);
    return false;
  }

  void reset() {
    isResetting = true;

    isElectricFieldVisible = true;
    isElectricFieldDirectionOnly = false;
    isElectricPotentialVisible = false;
    areValuesVisible = false;
    isGridVisible = false;
    snapToGrid = false;
    isPlayAreaCharged = false;
    allowNewPositiveCharges = true;
    allowNewNegativeCharges = true;
    allowNewElectricFieldSensors = true;
    chargesAndSensorsEnclosureBounds = const CafBounds2(
      -1.25,
      -2.30,
      1.25,
      -1.70,
    );

    for (final p in List<ChargedParticle>.from(chargedParticles)) {
      p.dispose();
    }
    chargedParticles.clear();
    activeChargedParticles.clear();

    for (final s in List<ElectricFieldSensor>.from(electricFieldSensors)) {
      s.dispose();
    }
    electricFieldSensors.clear();
    electricPotentialLines.clear();
    electricPotentialSensor.reset();
    measuringTape.reset();

    isResetting = false;
    notify();
  }
}

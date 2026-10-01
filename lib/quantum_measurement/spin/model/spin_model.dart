/// Spin screen core math — mirrors SpinExperiment, SternGerlach, SpinModel bits.
library;

import 'dart:math' as math;

import '../../common/qm_random.dart';

enum SourceMode { single, continuous }

enum BlockingMode { noBlocker, blockUp, blockDown }

enum SpinDirection {
  zPlus,
  xPlus,
  zMinus;

  /// XZ plane unit vector for SG projection — mirrors SpinDirection.spinToVector.
  ({double x, double z}) toVector() {
    switch (this) {
      case SpinDirection.zPlus:
        return (x: 0, z: 1);
      case SpinDirection.zMinus:
        return (x: 0, z: -1);
      case SpinDirection.xPlus:
        return (x: 1, z: 0);
    }
  }
}

class SternGerlachSetting {
  const SternGerlachSetting({required this.isZOriented});
  final bool isZOriented;
}

/// Preset experiments — mirrors `SpinExperiment.ts` exactly.
enum SpinExperiment {
  experiment1,
  experiment2,
  experiment3,
  experiment4,
  experiment5,
  experiment6,
  custom;

  String get label {
    switch (this) {
      case SpinExperiment.experiment1:
        return 'Experiment 1 [SGz]';
      case SpinExperiment.experiment2:
        return 'Experiment 2 [SGx]';
      case SpinExperiment.experiment3:
        return 'Experiment 3 [SGz, SGx]';
      case SpinExperiment.experiment4:
        return 'Experiment 4 [SGz, SGz]';
      case SpinExperiment.experiment5:
        return 'Experiment 5 [SGx, SGz]';
      case SpinExperiment.experiment6:
        return 'Experiment 6 [SGx, SGx]';
      case SpinExperiment.custom:
        return 'Custom';
    }
  }

  /// Apparatus orientation chain (length 1 = single SG; length 3 = SG0 + SG1 + SG2).
  List<SternGerlachSetting> get experimentSetting {
    switch (this) {
      case SpinExperiment.experiment1:
        return const [SternGerlachSetting(isZOriented: true)];
      case SpinExperiment.experiment2:
        return const [SternGerlachSetting(isZOriented: false)];
      case SpinExperiment.experiment3:
        return const [
          SternGerlachSetting(isZOriented: true),
          SternGerlachSetting(isZOriented: false),
          SternGerlachSetting(isZOriented: false),
        ];
      case SpinExperiment.experiment4:
        return const [
          SternGerlachSetting(isZOriented: true),
          SternGerlachSetting(isZOriented: true),
          SternGerlachSetting(isZOriented: true),
        ];
      case SpinExperiment.experiment5:
        return const [
          SternGerlachSetting(isZOriented: false),
          SternGerlachSetting(isZOriented: true),
          SternGerlachSetting(isZOriented: true),
        ];
      case SpinExperiment.experiment6:
        return const [
          SternGerlachSetting(isZOriented: false),
          SternGerlachSetting(isZOriented: false),
          SternGerlachSetting(isZOriented: false),
        ];
      case SpinExperiment.custom:
        return const [
          SternGerlachSetting(isZOriented: false),
          SternGerlachSetting(isZOriented: true),
          SternGerlachSetting(isZOriented: true),
        ];
    }
  }

  bool get usingSingleApparatus => experimentSetting.length == 1;
}

class SternGerlachModel {
  SternGerlachModel({required this.isZOriented});

  bool isZOriented;
  BlockingMode blockingMode = BlockingMode.noBlocker;
  double upProbability = 0.5;
  int upCount = 0;
  int downCount = 0;

  double get downProbability => 1.0 - upProbability;

  /// P(up) = (incoming · measurement + 1) / 2
  /// measurement = (0,1) for SGz, (1,0) for SGx.
  double calculateProbability(({double x, double z}) incoming) {
    final mx = isZOriented ? 0.0 : 1.0;
    final mz = isZOriented ? 1.0 : 0.0;
    final dot = incoming.x * mx + incoming.z * mz;
    return (dot + 1.0) / 2.0;
  }

  void updateProbability(({double x, double z}) incoming) {
    upProbability = calculateProbability(incoming);
  }

  bool measure(({double x, double z}) incoming, QmRandom random) {
    updateProbability(incoming);
    final isUp = random.nextDouble() < upProbability;
    if (isUp) {
      upCount++;
    } else {
      downCount++;
    }
    return isUp;
  }

  /// After measurement, outgoing spin vector along SG axis.
  ({double x, double z}) outgoingState(bool isUp) {
    if (isZOriented) {
      return isUp ? (x: 0.0, z: 1.0) : (x: 0.0, z: -1.0);
    }
    return isUp ? (x: 1.0, z: 0.0) : (x: -1.0, z: 0.0);
  }

  void resetCounts() {
    upCount = 0;
    downCount = 0;
  }
}

class SpinModel {
  SpinModel({QmRandom? random}) : _random = random ?? SystemQmRandom() {
    sternGerlachs = [
      SternGerlachModel(isZOriented: true),
      SternGerlachModel(isZOriented: false),
      SternGerlachModel(isZOriented: false),
    ];
    applyExperiment(experiment);
  }

  final QmRandom _random;

  double alphaSquared = 1.0;
  double get betaSquared => 1.0 - alphaSquared;

  SpinDirection spinState = SpinDirection.zPlus;
  ({double x, double z}) customSpinState = (x: 0, z: 1);

  SpinExperiment experiment = SpinExperiment.experiment1;
  SourceMode sourceMode = SourceMode.single;
  bool expectedPercentageVisible = false;

  /// Continuous intensity [0,1] — ParticleSourceModel.particleAmountProperty.
  double particleAmount = 0.1;

  late final List<SternGerlachModel> sternGerlachs;

  /// Per-experiment remembered blocking (source defaults BLOCK_UP when multi+continuous).
  final Map<SpinExperiment, BlockingMode> blockingModeMap = {
    for (final e in SpinExperiment.values) e: BlockingMode.blockUp,
  };

  bool get isCustom => experiment == SpinExperiment.custom;

  ({double x, double z}) get preparedSpinVector {
    if (isCustom) return customSpinState;
    return spinState.toVector();
  }

  void setAlphaSquared(double value) {
    assert(value >= 0 && value <= 1);
    alphaSquared = value;
    if (isCustom) {
      // polarAngle = π * (1 - α²); vector (sin θ, cos θ) in XZ
      final polarAngle = math.pi * (1 - alphaSquared);
      customSpinState = (x: math.sin(polarAngle), z: math.cos(polarAngle));
    }
  }

  void applyExperiment(SpinExperiment exp) {
    experiment = exp;
    final settings = exp.experimentSetting;
    for (var i = 0; i < sternGerlachs.length; i++) {
      if (i < settings.length) {
        sternGerlachs[i].isZOriented = settings[i].isZOriented;
      }
    }
    // Multi-apparatus continuous: restore remembered blocker on SG0
    if (sourceMode != SourceMode.single && !exp.usingSingleApparatus) {
      sternGerlachs[0].blockingMode = blockingModeMap[exp]!;
    } else if (exp.usingSingleApparatus || sourceMode == SourceMode.single) {
      sternGerlachs[0].blockingMode = BlockingMode.noBlocker;
    }
    for (final sg in sternGerlachs) {
      sg.resetCounts();
    }
  }

  void setSourceMode(SourceMode mode) {
    sourceMode = mode;
    applyExperiment(experiment);
  }

  void setBlockingMode(BlockingMode mode) {
    if (experiment.usingSingleApparatus || sourceMode == SourceMode.single) {
      return;
    }
    sternGerlachs[0].blockingMode = mode;
    blockingModeMap[experiment] = mode;
  }

  void setSgOrientation(int index, bool isZOriented) {
    if (!isCustom) return;
    if (index < 0 || index >= sternGerlachs.length) return;
    sternGerlachs[index].isZOriented = isZOriented;
    if (index == 1 || index == 2) {
      // Custom single-particle: SG1 and SG2 share orientation via SG2 controls in source.
      if (sourceMode == SourceMode.single) {
        sternGerlachs[1].isZOriented = isZOriented;
        sternGerlachs[2].isZOriented = isZOriented;
      }
    }
  }

  /// Run one particle through SG0 (and optionally SG1/SG2). Returns path results.
  List<bool> fireSingleParticle() {
    final incoming = preparedSpinVector;
    final results = <bool>[];

    // Stage 1: SG0
    final sg0 = sternGerlachs[0];
    final up0 = sg0.measure(incoming, _random);
    results.add(up0);

    // Blocker: particle stopped if exit is blocked
    if (sg0.blockingMode == BlockingMode.blockUp && up0) return results;
    if (sg0.blockingMode == BlockingMode.blockDown && !up0) return results;

    if (experiment.usingSingleApparatus) return results;

    // Stage 2: SG1 (up path) or SG2 (down path)
    final next = up0 ? sternGerlachs[1] : sternGerlachs[2];
    final outgoing = sg0.outgoingState(up0);
    final up1 = next.measure(outgoing, _random);
    results.add(up1);
    return results;
  }

  void reset() {
    alphaSquared = 1.0;
    spinState = SpinDirection.zPlus;
    customSpinState = (x: 0, z: 1);
    sourceMode = SourceMode.single;
    expectedPercentageVisible = false;
    particleAmount = 0.1;
    experiment = SpinExperiment.experiment1;
    applyExperiment(experiment);
    for (final e in SpinExperiment.values) {
      blockingModeMap[e] = BlockingMode.blockUp;
    }
  }
}

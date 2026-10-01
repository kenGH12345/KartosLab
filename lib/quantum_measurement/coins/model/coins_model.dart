/// CoinsExperimentSceneModel -?mirrors `CoinsExperimentSceneModel.ts`.
library;

import '../../common/qm_random.dart';
import '../../common/system_type.dart';
import 'coin_set.dart';

class CoinsExperimentSceneModel {
  CoinsExperimentSceneModel({
    this.systemType = SystemType.classical,
    bool initiallyActive = false,
    double initialBias = 0.5,
    QmRandom? random,
  })  : active = initiallyActive,
        preparingExperiment = true,
        upProbability = initialBias,
        initialCoinState = systemType == SystemType.classical ? 'heads' : 'up',
        _random = random ?? SystemQmRandom() {
    final initialState = systemType == SystemType.classical ? 'heads' : 'up';
    singleCoin = Coin(
      coinType: systemType,
      initialState: initialState,
      initialBias: initialBias,
      random: _random,
    );
    coinSet = CoinSet(
      coinType: systemType,
      maxNumberOfActiveCoins: maxCoins,
      initialNumberOfActiveCoins: multiCoinExperimentQuantities[1], // 100
      initialFaceState: initialState,
      initialBias: initialBias,
      random: _random,
    );
  }

  final SystemType systemType;
  final QmRandom _random;

  bool active;
  bool preparingExperiment;
  String initialCoinState;
  double upProbability;

  late final Coin singleCoin;
  late final CoinSet coinSet;

  double get downProbability => 1.0 - upProbability;

  /// Sync bias onto both coin objects.
  void setUpProbability(double value) {
    assert(value >= 0 && value <= 1);
    upProbability = value;
    singleCoin.bias = value;
    coinSet.bias = value;
    if (systemType == SystemType.quantum) {
      if (value != 0.0 && value != 1.0) {
        initialCoinState = 'superposition';
      } else {
        initialCoinState = value == 1.0 ? 'up' : 'down';
      }
    }
  }

  void setInitialCoinState(String state) {
    initialCoinState = state;
    if (systemType == SystemType.classical) {
      // Indicator coin follows orientation selection (InitialCoinStateSelectorNode).
      singleCoin.setMeasurementValuesImmediate(state);
      coinSet.setMeasurementValuesImmediate(state);
    } else if (systemType == SystemType.quantum && state != 'superposition') {
      setUpProbability(state == 'up' ? 1.0 : 0.0);
    }
  }

  /// Start Measurement / New Coin toggle via preparingExperiment flag.
  void setPreparingExperiment(bool preparing) {
    preparingExperiment = preparing;
    if (preparing) {
      singleCoin.prepareNow();
      coinSet.prepareNow();
      if (systemType == SystemType.classical && !coinSet.initiallyHidden) {
        singleCoin.reveal();
        coinSet.reveal();
      }
    } else {
      final state =
          initialCoinState == 'superposition' ? 'up' : initialCoinState;
      singleCoin.setMeasurementValuesImmediate(state);
      coinSet.setMeasurementValuesImmediate(state);
    }
  }

  void reset() {
    preparingExperiment = true;
    initialCoinState = systemType == SystemType.classical ? 'heads' : 'up';
    upProbability = 0.5;
    singleCoin.bias = 0.5;
    coinSet.bias = 0.5;
    singleCoin.reset();
    coinSet.reset();
  }
}

/// Top-level Coins screen model -?mirrors `CoinsModel.ts`.
class CoinsModel {
  CoinsModel({QmRandom? random})
      : _random = random ?? SystemQmRandom(),
        experimentMode = SystemType.classical {
    classicalScene = CoinsExperimentSceneModel(
      systemType: SystemType.classical,
      initiallyActive: true,
      random: _random,
    );
    quantumScene = CoinsExperimentSceneModel(
      systemType: SystemType.quantum,
      initiallyActive: false,
      random: _random,
    );
    _syncActive();
  }

  final QmRandom _random;
  SystemType experimentMode;
  late final CoinsExperimentSceneModel classicalScene;
  late final CoinsExperimentSceneModel quantumScene;

  CoinsExperimentSceneModel get activeScene =>
      experimentMode == SystemType.classical ? classicalScene : quantumScene;

  void setExperimentMode(SystemType mode) {
    experimentMode = mode;
    _syncActive();
  }

  void _syncActive() {
    classicalScene.active = experimentMode == SystemType.classical;
    quantumScene.active = experimentMode == SystemType.quantum;
  }

  void reset() {
    classicalScene.reset();
    quantumScene.reset();
    experimentMode = SystemType.classical;
    _syncActive();
  }
}

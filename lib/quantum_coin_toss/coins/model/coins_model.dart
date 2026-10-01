// Copyright 2024-2026, University of Colorado Boulder
/// CoinsModel 是 Coins 屏幕的主模型
/// 包含经典和量子两个场景模型
///
/// 对应官方：js/coins/model/CoinsModel.ts
library;


import 'package:flutter/foundation.dart';
import '../../common/model/system_type.dart';
import 'coins_experiment_scene_model.dart';

class CoinsModel extends ChangeNotifier {
  // 实验模式：经典 or 量子
  final ValueNotifier<SystemType> experimentModeProperty;
  
  // 两个场景模型
  final CoinsExperimentSceneModel classicalCoinExperimentSceneModel;
  final CoinsExperimentSceneModel quantumCoinExperimentSceneModel;

  CoinsModel()
      : experimentModeProperty = ValueNotifier(SystemType.classical),
        classicalCoinExperimentSceneModel = CoinsExperimentSceneModel(
          systemType: SystemType.classical,
        ),
        quantumCoinExperimentSceneModel = CoinsExperimentSceneModel(
          systemType: SystemType.quantum,
        ) {
    // 监听实验模式切换，更新激活状态
    experimentModeProperty.addListener(_onExperimentModeChanged);
    _onExperimentModeChanged(); // 初始化激活状态
  }

  void _onExperimentModeChanged() {
    final mode = experimentModeProperty.value;
    classicalCoinExperimentSceneModel.activeProperty.value = 
        mode == SystemType.classical;
    quantumCoinExperimentSceneModel.activeProperty.value = 
        mode == SystemType.quantum;
  }

  void reset() {
    classicalCoinExperimentSceneModel.reset();
    quantumCoinExperimentSceneModel.reset();
    experimentModeProperty.value = SystemType.classical;
  }

  @override
  void dispose() {
    experimentModeProperty.removeListener(_onExperimentModeChanged);
    experimentModeProperty.dispose();
    classicalCoinExperimentSceneModel.dispose();
    quantumCoinExperimentSceneModel.dispose();
    super.dispose();
  }
}

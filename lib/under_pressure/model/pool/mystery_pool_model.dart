import 'dart:ui' show Color;

import 'package:kratos/under_pressure/model/pool/square_pool_model.dart';

/// Host callbacks for mystery scene (UnderPressureModel).
abstract class MysteryHost {
  String get sceneName;
  String get mysteryChoice; // 'fluidDensity' | 'gravity'
  double get gravity;
  set gravity(double v);
  double get fluidDensity;
  set fluidDensity(double v);
  void resetGravity();
  void resetFluidDensity();
  void setFluidColorDirect(Color color);
  void notifyFluidDensityListeners();
}

/// Source: `MysteryPoolModel.js` — square geometry + mystery presets.
class MysteryPoolModel extends SquarePoolModel {
  MysteryPoolModel({
    required this.host,
    required super.onVolumeChanged,
  });

  final MysteryHost host;

  /// Combo indices 0..2
  int customFluidDensityIndex = 0;
  int customGravityIndex = 0;

  /// Source fluidDensityChoices / gravityChoices — fixed, not random.
  static const List<double> fluidDensityChoices = [1700, 840, 1100];
  static const List<double> gravityChoices = [20, 14, 6.5];

  static final List<Color> fluidColors = [
    const Color.fromARGB(255, 113, 35, 136),
    const Color.fromARGB(255, 179, 115, 176),
    const Color.fromARGB(255, 60, 29, 71),
  ];

  double? _savedGravity;
  double? _savedFluidDensity;

  /// Called when global scene changes (source currentSceneProperty.link).
  void onSceneChanged(String scene, String? oldScene) {
    if (scene == 'mystery') {
      _savedGravity = host.gravity;
      _savedFluidDensity = host.fluidDensity;
      updateChoiceValue();
    } else if (oldScene == 'mystery') {
      if (_savedGravity != null) host.gravity = _savedGravity!;
      if (_savedFluidDensity != null) host.fluidDensity = _savedFluidDensity!;
    }
  }

  /// Called when mysteryChoice changes.
  void onMysteryChoiceChanged(String mysteryChoice) {
    if (mysteryChoice == 'fluidDensity') {
      host.resetGravity();
    } else if (mysteryChoice == 'gravity') {
      host.resetFluidDensity();
    }
    if (host.sceneName == 'mystery') {
      updateChoiceValue();
    }
  }

  void setCustomFluidDensityIndex(int index) {
    customFluidDensityIndex = index.clamp(0, 2);
    if (host.sceneName == 'mystery') {
      updateChoiceValue();
    }
  }

  void setCustomGravityIndex(int index) {
    customGravityIndex = index.clamp(0, 2);
    if (host.sceneName == 'mystery') {
      updateChoiceValue();
    }
  }

  void updateChoiceValue() {
    if (host.mysteryChoice == 'fluidDensity') {
      host.fluidDensity = fluidDensityChoices[customFluidDensityIndex];
      host.setFluidColorDirect(fluidColors[customFluidDensityIndex]);
    } else {
      host.gravity = gravityChoices[customGravityIndex];
      host.notifyFluidDensityListeners();
    }
  }

  @override
  void reset() {
    customFluidDensityIndex = 0;
    customGravityIndex = 0;
    super.reset();
  }
}

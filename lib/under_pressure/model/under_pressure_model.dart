import 'dart:ui' show Color, Offset;

import 'package:kratos/under_pressure/model/fluid/fluid_color_model.dart';
import 'package:kratos/under_pressure/model/pool/chamber_pool_model.dart';
import 'package:kratos/under_pressure/model/pool/mystery_pool_model.dart';
import 'package:kratos/under_pressure/model/pool/pool_scene_model.dart';
import 'package:kratos/under_pressure/model/pool/square_pool_model.dart';
import 'package:kratos/under_pressure/model/pool/trapezoid_pool_model.dart';
import 'package:kratos/under_pressure/model/sensor/pressure_sensor.dart';
import 'package:kratos/under_pressure/model/under_pressure_constants.dart';
import 'package:kratos/under_pressure/model/under_pressure_math.dart';
import 'package:kratos/under_pressure/model/under_pressure_units.dart';

/// Scene keys — source `currentSceneProperty`.
enum UnderPressureScene {
  square,
  trapezoid,
  chamber,
  mystery,
}

/// Source: `UnderPressureModel.js` — absolute-pressure physics core.
class UnderPressureModel implements ChamberHost, MysteryHost {
  UnderPressureModel() {
    fluidColorModel = FluidColorModel(
      getDensity: () => fluidDensity,
      densityMin: fluidDensityMin,
      densityMax: fluidDensityMax,
    );

    square = SquarePoolModel(onVolumeChanged: _onAnyFaucetPoolVolume);
    trapezoid = TrapezoidPoolModel(onVolumeChanged: _onAnyFaucetPoolVolume);
    chamber = ChamberPoolModel(host: this);
    mystery = MysteryPoolModel(
      host: this,
      onVolumeChanged: _onAnyFaucetPoolVolume,
    );

    for (var i = 0; i < UnderPressureConstants.numBarometers; i++) {
      barometers.add(
        PressureSensor(
          initialPosition: const Offset(
            UnderPressureConstants.barometerDockX,
            UnderPressureConstants.barometerDockY,
          ),
        )..value = null,
      );
    }

    // Mirror source: currentSceneModelProperty.link sets currentVolume.
    currentVolume = currentSceneModel.volume;
  }

  // --- Ranges (source Range) ---
  final double gravityMin = UnderPressureConstants.marsGravity;
  final double gravityMax = UnderPressureConstants.jupiterGravity;
  final double fluidDensityMin = UnderPressureConstants.gasolineDensity;
  final double fluidDensityMax = UnderPressureConstants.honeyDensity;

  // --- Shared properties ---
  bool isAtmosphere = true;
  bool isRulerVisible = false;
  bool isGridVisible = false;
  MeasureUnits measureUnits = MeasureUnits.metric;
  @override
  double gravity = UnderPressureConstants.earthGravity;
  double _fluidDensity = UnderPressureConstants.waterDensity;
  UnderPressureScene currentScene = UnderPressureScene.square;
  double currentVolume = 0;
  Offset rulerPosition = const Offset(
    UnderPressureConstants.rulerInitialX,
    UnderPressureConstants.rulerInitialY,
  );

  /// 'fluidDensity' | 'gravity'
  @override
  String mysteryChoice = 'fluidDensity';
  bool fluidDensityControlExpanded = true;
  bool gravityControlExpanded = true;

  late final FluidColorModel fluidColorModel;
  late final SquarePoolModel square;
  late final TrapezoidPoolModel trapezoid;
  late final ChamberPoolModel chamber;
  late final MysteryPoolModel mystery;
  final List<PressureSensor> barometers = [];

  @override
  double get fluidDensity => _fluidDensity;

  @override
  set fluidDensity(double value) {
    if (_fluidDensity == value) {
      fluidColorModel.markDensityChanged();
      return;
    }
    _fluidDensity = value;
    fluidColorModel.markDensityChanged();
  }

  // --- ChamberHost ---
  @override
  void notifyBarometersUpdate() {
    for (final b in barometers) {
      b.emitUpdate();
    }
    refreshSensorValues();
  }

  // --- MysteryHost ---
  @override
  String get sceneName => currentScene.name;

  PoolSceneModel get currentSceneModel {
    switch (currentScene) {
      case UnderPressureScene.square:
        return square;
      case UnderPressureScene.trapezoid:
        return trapezoid;
      case UnderPressureScene.chamber:
        return chamber;
      case UnderPressureScene.mystery:
        return mystery;
    }
  }

  void _onAnyFaucetPoolVolume(double volume) {
    // Source quirk: any faucet-pool volume Property.link writes currentVolume.
    currentVolume = volume;
  }

  /// Switch scene — restores mystery globals per source.
  void setScene(UnderPressureScene scene) {
    final old = currentScene;
    if (old == scene) return;
    currentScene = scene;
    mystery.onSceneChanged(scene.name, old.name);
    currentVolume = currentSceneModel.volume;
    refreshSensorValues();
  }

  void setMysteryChoice(String choice) {
    assert(choice == 'fluidDensity' || choice == 'gravity');
    mysteryChoice = choice;
    mystery.onMysteryChoiceChanged(choice);
  }

  // MysteryHost implementation — use explicit methods to avoid name clash
  @override
  void resetGravity() {
    gravity = UnderPressureConstants.earthGravity;
  }

  @override
  void resetFluidDensity() {
    _fluidDensity = UnderPressureConstants.waterDensity;
    fluidColorModel.markDensityChanged();
  }

  @override
  void setFluidColorDirect(Color color) {
    fluidColorModel.setColorDirect(color);
  }

  @override
  void notifyFluidDensityListeners() {
    fluidColorModel.markDensityChanged();
  }

  /// Source `getStandardAirPressure(height)`.
  static double getStandardAirPressure(double height) {
    return UnderPressureMath.linear(
      0,
      150,
      UnderPressureConstants.earthAirPressure,
      UnderPressureConstants.earthAirPressureAt500Ft,
      height,
    );
  }

  /// Source `getAirPressure(height)` — Pa.
  double getAirPressure(double height) {
    if (!isAtmosphere) return 0;
    return getStandardAirPressure(height) *
        gravity /
        UnderPressureConstants.earthGravity;
  }

  /// Source `getWaterPressure(height)` — Pa.
  double getWaterPressure(double height) {
    return height * gravity * fluidDensity;
  }

  /// Source `getPressureAtCoords(x, y)` — absolute Pa, or null outside pool.
  double? getPressureAtCoords(double x, double y) {
    if (y > 0) {
      return getAirPressure(y);
    }
    final model = currentSceneModel;
    if (model.isPointInsidePool(x, y)) {
      final waterHeight = model.getWaterHeightAboveY(x, y);
      if (waterHeight <= 0) {
        return getAirPressure(y);
      }
      return getAirPressure(waterHeight + y) + getWaterPressure(waterHeight);
    }
    return null;
  }

  /// Update all barometer readings.
  ///
  /// [tipDeltaY] is view→model tip offset (source: bottom − center). Model
  /// tests typically use 0 and place tip coords directly in [position].
  void refreshSensorValues({double tipDeltaY = 0}) {
    for (final sensor in barometers) {
      if (sensor.isDocked) {
        sensor.value = null;
      } else {
        sensor.value = getPressureAtCoords(
          sensor.position.dx,
          sensor.position.dy + tipDeltaY,
        );
      }
    }
  }

  String getPressureString(double pressurePa, [MeasureUnits? units]) {
    return UnderPressureUnits.getPressureString(
      pressurePa,
      units ?? measureUnits,
      abbreviated: false,
    );
  }

  String getGravityString() =>
      UnderPressureUnits.getGravityString(gravity, measureUnits);

  String getFluidDensityString() =>
      UnderPressureUnits.getFluidDensityString(fluidDensity, measureUnits);

  /// Source `UnderPressureModel.step(dt)`.
  void step(double dt) {
    fluidColorModel.step();
    currentSceneModel.step(dt);
    // Keep currentVolume in sync for chamber (no faucet link).
    if (currentScene == UnderPressureScene.chamber) {
      currentVolume = chamber.volume;
    } else {
      currentVolume = currentSceneModel.volume;
    }
    refreshSensorValues();
  }

  /// Source `UnderPressureModel.reset()`.
  void reset() {
    isAtmosphere = true;
    isRulerVisible = false;
    isGridVisible = false;
    measureUnits = MeasureUnits.metric;
    gravity = UnderPressureConstants.earthGravity;
    _fluidDensity = UnderPressureConstants.waterDensity;
    currentScene = UnderPressureScene.square;
    currentVolume = 0;
    rulerPosition = const Offset(
      UnderPressureConstants.rulerInitialX,
      UnderPressureConstants.rulerInitialY,
    );
    mysteryChoice = 'fluidDensity';
    fluidDensityControlExpanded = true;
    gravityControlExpanded = true;

    square.reset();
    trapezoid.reset();
    chamber.reset();
    mystery.reset();
    fluidColorModel.reset();

    for (final b in barometers) {
      b.reset();
    }

    currentVolume = currentSceneModel.volume;
    refreshSensorValues();
  }
}

import 'package:kratos/under_pressure/model/faucet/faucet_model.dart';
import 'package:kratos/under_pressure/model/pool/pool_scene_model.dart';

/// Callback when this pool's volume changes (mirrors axon Property.link).
typedef VolumeListener = void Function(double volume);

/// Source: `PoolWithFaucetsModel.js`
abstract class PoolWithFaucetsModel implements PoolSceneModel {
  PoolWithFaucetsModel({
    required this.inputFaucet,
    required this.outputFaucet,
    required this.maxVolume,
    required this.onVolumeChanged,
    double initialVolume = 1.5,
  }) : _volume = initialVolume {
    _applyVolume(_volume, notify: true);
  }

  final FaucetModel inputFaucet;
  final FaucetModel outputFaucet;
  final double maxVolume;
  final VolumeListener onVolumeChanged;

  double _volume;

  @override
  double get volume => _volume;

  void _applyVolume(double value, {required bool notify}) {
    _volume = value.clamp(0.0, maxVolume);
    inputFaucet.enabled = _volume < maxVolume;
    outputFaucet.enabled = _volume > 0;
    if (notify) {
      onVolumeChanged(_volume);
    }
  }

  void setVolume(double value) => _applyVolume(value, notify: true);

  @override
  void reset() {
    inputFaucet.reset();
    outputFaucet.reset();
    _applyVolume(1.5, notify: true);
  }

  @override
  void step(double dt) {
    addLiquid(dt);
    removeLiquid(dt);
  }

  void addLiquid(double dt) {
    final deltaVolume = inputFaucet.flowRate * dt;
    if (deltaVolume > 0) {
      _applyVolume(_volume + deltaVolume, notify: true);
    }
  }

  void removeLiquid(double dt) {
    final deltaVolume = outputFaucet.flowRate * dt;
    if (deltaVolume > 0) {
      _applyVolume(_volume - deltaVolume, notify: true);
    }
  }
}

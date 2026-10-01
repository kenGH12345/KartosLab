import 'dart:ui' show Offset;

/// Source: `fluid-pressure-and-flow/js/under-pressure/model/FaucetModel.js`
class FaucetModel {
  FaucetModel({
    required this.position,
    required this.maxFlowRate,
    required this.scale,
  }) : spoutWidth = 1.35 * scale;

  /// Center of output pipe (model meters).
  final Offset position;

  /// Max flow rate (source “L/sec”; numerically drives volume units).
  final double maxFlowRate;

  final double scale;

  /// Empirically determined spout width in model meters.
  final double spoutWidth;

  double flowRate = 0;
  bool _enabled = true;

  bool get enabled => _enabled;

  set enabled(bool value) {
    _enabled = value;
    if (!_enabled) {
      flowRate = 0;
    }
  }

  void reset() {
    flowRate = 0;
    _enabled = true;
  }
}

import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Input/drain faucet — PhET `Faucet.ts`.
class Faucet extends ChangeNotifier {
  Faucet({
    required this.position,
    required this.pipeMinX,
    this.spoutWidth = 45,
    this.maxFlowRate = 0.25,
    double flowRate = 0,
    bool enabled = true,
  })  : _flowRate = flowRate,
        _enabled = enabled;

  final Offset position;
  final double pipeMinX;
  final double spoutWidth;
  final double maxFlowRate;

  double _flowRate;
  bool _enabled;

  double get flowRate => _flowRate;
  bool get enabled => _enabled;

  set flowRate(double v) {
    final clamped = v.clamp(0.0, maxFlowRate);
    if (_flowRate == clamped) return;
    _flowRate = clamped;
    notifyListeners();
  }

  set enabled(bool v) {
    if (_enabled == v) return;
    _enabled = v;
    if (!_enabled) _flowRate = 0;
    notifyListeners();
  }

  void reset() {
    _flowRate = 0;
    _enabled = true;
    notifyListeners();
  }
}

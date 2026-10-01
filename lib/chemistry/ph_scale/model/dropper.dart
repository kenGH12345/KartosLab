import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'solute.dart';

/// Dropper with stock solute — PhET `Dropper.ts`.
class Dropper extends ChangeNotifier {
  Dropper({
    Solute? solute,
    List<Solute>? solutes,
    required this.position,
    this.maxFlowRate = 0.05,
    double flowRate = 0,
    bool dispensing = false,
    bool enabled = true,
    bool visible = true,
  })  : solutes = solutes ?? Solute.allAlphabetical,
        _solute = solute ?? Solute.water,
        _flowRate = flowRate,
        _isDispensing = dispensing,
        _enabled = enabled,
        _visible = visible;

  final Offset position;
  final List<Solute> solutes;
  final double maxFlowRate;

  Solute _solute;
  double _flowRate;
  bool _isDispensing;
  bool _enabled;
  bool _visible;

  /// Initial values for reset.
  final Solute _initialSolute = Solute.water;

  Solute get solute => _solute;
  double get flowRate => _flowRate;
  bool get isDispensing => _isDispensing;
  bool get enabled => _enabled;
  bool get visible => _visible;

  set solute(Solute v) {
    if (_solute == v) return;
    _solute = v;
    notifyListeners();
  }

  set isDispensing(bool v) {
    if (_isDispensing == v) return;
    _isDispensing = v;
    if (_enabled || !v) {
      _flowRate = v ? maxFlowRate : 0;
    }
    notifyListeners();
  }

  set enabled(bool v) {
    if (_enabled == v) return;
    _enabled = v;
    if (!_enabled) {
      _isDispensing = false;
      _flowRate = 0;
    }
    notifyListeners();
  }

  set visible(bool v) {
    if (_visible == v) return;
    _visible = v;
    notifyListeners();
  }

  /// Autofill overrides flow rate without going through [isDispensing] max.
  void setFlowRateDirect(double rate) {
    _flowRate = rate;
    notifyListeners();
  }

  void reset() {
    _solute = _initialSolute;
    _isDispensing = false;
    _enabled = true;
    _flowRate = 0;
    // visibleProperty is intentionally NOT reset in PhET Dropper.reset()
    notifyListeners();
  }
}

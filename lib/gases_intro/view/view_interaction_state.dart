import 'package:flutter/material.dart';

import '../gases_intro_constants.dart';
import '../model/hold_constant.dart';
import '../model/ideal_gas_law_model.dart';

/// View-only instrumentation / accordion / oops state (IdealGasLawViewProperties +
/// gauge/thermometer unitsProperty + OopsDialog triggers).
///
/// Does **not** modify Physics/Solver. May mutate public container.lidWidth for
/// LidDragListener parity, then [notifyListeners] so the shell rebuilds.
class ViewInteractionState extends ChangeNotifier {
  /// IdealGasLawViewProperties.particlesExpandedProperty default **false**.
  bool particlesExpanded = false;

  /// PressureGauge.unitsProperty default atmospheres.
  PressureUnits pressureUnits = PressureUnits.atmospheres;

  /// Thermometer.unitsProperty default kelvin.
  TemperatureUnits temperatureUnits = TemperatureUnits.kelvin;

  String? pendingOopsMessage;
  bool _suppressPressureOops = false;

  int _prevN = 0;
  double? _prevT;
  HoldConstant _prevHold = HoldConstant.nothing;

  void setParticlesExpanded(bool v) {
    if (particlesExpanded == v) return;
    particlesExpanded = v;
    notifyListeners();
  }

  void setPressureUnits(PressureUnits u) {
    if (pressureUnits == u) return;
    pressureUnits = u;
    notifyListeners();
  }

  void setTemperatureUnits(TemperatureUnits u) {
    if (temperatureUnits == u) return;
    temperatureUnits = u;
    notifyListeners();
  }

  void dismissOops() {
    if (pendingOopsMessage == null) return;
    pendingOopsMessage = null;
    notifyListeners();
  }

  void showOops(String message) {
    pendingOopsMessage = message;
    notifyListeners();
  }

  /// LidDragListener: set lidWidth from opening-left model X.
  void setLidWidthFromOpeningLeft(IdealGasLawModel model, double openingLeftModelX) {
    final c = model.container;
    if (!c.lidIsOn) return;
    double next;
    if (openingLeftModelX >= c.getOpeningRight()) {
      next = c.maxLidWidth;
    } else {
      final openingWidth = c.getOpeningRight() - openingLeftModelX;
      next = (c.maxLidWidth - openingWidth).clamp(c.minLidWidth, c.maxLidWidth);
    }
    if ((next - c.lidWidth).abs() < 1e-6) return;
    c.lidWidth = next;
    notifyListeners();
  }

  /// Hold Constant UI entry — mirrors IdealScreenView oops listeners.
  void requestHoldConstant(IdealGasLawModel model, HoldConstant value) {
    if (value == HoldConstant.nothing) {
      _suppressPressureOops = true;
      model.setHoldConstant(value);
      return;
    }
    if (value == HoldConstant.temperature && model.container.isOpen) {
      model.setHoldConstant(value); // model refuses → nothing
      showOops(OopsMessages.temperatureOpen);
      return;
    }
    if (model.numberOfParticles == 0 &&
        (value == HoldConstant.temperature ||
            value == HoldConstant.pressureT ||
            value == HoldConstant.pressureV)) {
      model.setHoldConstant(value);
      showOops(value == HoldConstant.temperature
          ? OopsMessages.temperatureEmpty
          : OopsMessages.pressureEmpty);
      return;
    }
    model.setHoldConstant(value);
  }

  /// After model notify: detect pressureV clamp oops + max temperature erase.
  void syncFromModel(IdealGasLawModel model) {
    final n = model.numberOfParticles;
    final t = model.temperatureK;
    final hold = model.holdConstant;

    // pressureV / pressureT emptied while holding
    if (_prevN > 0 &&
        n == 0 &&
        (_prevHold == HoldConstant.pressureV ||
            _prevHold == HoldConstant.pressureT ||
            _prevHold == HoldConstant.temperature)) {
      if (_prevHold == HoldConstant.temperature) {
        // may also be max-T erase — prefer max-T if prev T huge
        if ((_prevT ?? 0) >= GasesIntroConstants.maxTemperatureK) {
          showOops(OopsMessages.maximumTemperature);
        } else {
          showOops(OopsMessages.temperatureEmpty);
        }
      } else {
        showOops(OopsMessages.pressureEmpty);
      }
    } else if (_prevN > 0 &&
        n == 0 &&
        (_prevT ?? 0) >= GasesIntroConstants.maxTemperatureK) {
      showOops(OopsMessages.maximumTemperature);
    }

    // Hold Constant pressureV aborted during compensate (width out of range)
    if (!_suppressPressureOops &&
        _prevHold == HoldConstant.pressureV &&
        hold == HoldConstant.nothing &&
        n > 0) {
      try {
        final idealV = model.computeIdealVolume();
        final idealW = idealV / (model.container.height * model.container.depth);
        if (idealW > GasesIntroConstants.widthMax) {
          showOops(OopsMessages.pressureLarge);
        } else if (idealW < GasesIntroConstants.widthMin) {
          showOops(OopsMessages.pressureSmall);
        }
      } catch (_) {}
    }
    _suppressPressureOops = false;

    _prevN = n;
    _prevT = t;
    _prevHold = hold;
  }

  void reset() {
    particlesExpanded = false;
    pressureUnits = PressureUnits.atmospheres;
    temperatureUnits = TemperatureUnits.kelvin;
    pendingOopsMessage = null;
    _prevN = 0;
    _prevT = null;
    _prevHold = HoldConstant.nothing;
    notifyListeners();
  }
}

enum PressureUnits { atmospheres, kilopascals }

enum TemperatureUnits { kelvin, celsius }

/// English strings from gas-properties-strings_en.json (Oops! …).
class OopsMessages {
  static const temperatureEmpty =
      'Oops!\n\nTemperature cannot be held constant\nwhen the container is empty.';
  static const temperatureOpen =
      'Oops!\n\nTemperature cannot be held constant\nwhen the container is open.';
  static const pressureEmpty =
      'Oops!\n\nPressure cannot be held constant\nwhen the container is empty.';
  static const pressureLarge =
      'Oops!\n\nPressure cannot be held constant.\nVolume would be too large.';
  static const pressureSmall =
      'Oops!\n\nPressure cannot be held constant.\nVolume would be too small.';
  static const maximumTemperature =
      'Oops!\n\nMaximum temperature reached.';
}

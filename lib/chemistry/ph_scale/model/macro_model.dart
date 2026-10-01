import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'ph_chemistry.dart';
import 'ph_model.dart';
import 'ph_scale_constants.dart';

/// Macro pH meter probe state — PhET `MacroPHMeter.ts` + view collision.
///
/// Immersion / displayed value is decided by the view via [updateDisplayedPH].
class MacroPhMeter extends ChangeNotifier {
  MacroPhMeter({
    required this.bodyPosition,
    required Offset probePosition,
  }) : _probePosition = probePosition;

  final Offset bodyPosition;
  Offset _probePosition;

  /// Displayed pH; `null` → blank / dash.
  PhValue displayedPH;

  Offset get probePosition => _probePosition;

  set probePosition(Offset v) {
    if (_probePosition == v) return;
    _probePosition = v;
    notifyListeners();
  }

  void updateDisplayedPH(PhValue value) {
    if (displayedPH == value) return;
    displayedPH = value;
    notifyListeners();
  }

  void reset({required Offset probePosition}) {
    displayedPH = null;
    _probePosition = probePosition;
    notifyListeners();
  }
}

/// Macro screen model — PhET `MacroModel.ts`.
class MacroModel extends PhModel {
  MacroModel({super.autoFillEnabled = true}) {
    final drainX = drainFaucet.position.dx;
    final body = Offset(drainX - 300, 75);
    final probe = Offset(body.dx + 150, beaker.position.dy);
    _initialProbe = probe;
    meter = MacroPhMeter(bodyPosition: body, probePosition: probe);
  }

  late final MacroPhMeter meter;
  late final Offset _initialProbe;

  /// View calls this after hit-testing probe against fluids.
  void setProbeReading(PhValue value) => meter.updateDisplayedPH(value);

  @override
  void reset() {
    super.reset();
    meter.reset(probePosition: _initialProbe);
  }

  /// Format for meter display (2 decimal places or null).
  String? formatDisplayedPH([PhValue value]) {
    final v = value ?? meter.displayedPH;
    if (v == null) return null;
    return PhScaleConstants.toFixedNumber(
      v,
      PhScaleConstants.phMeterDecimalPlaces,
    ).toStringAsFixed(PhScaleConstants.phMeterDecimalPlaces);
  }
}

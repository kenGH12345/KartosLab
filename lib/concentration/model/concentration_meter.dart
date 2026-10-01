import 'dart:ui';

import 'concentration_constants.dart';
import 'concentration_solution.dart';
import 'probe_region.dart';
import 'solute.dart';

/// Concentration meter + probe — beers-law-lab `ConcentrationMeter.ts`.
///
/// Body is fixed; probe is movable. [value] is null when not measuring (NO_VALUE / —).
class ConcentrationMeterModel {
  ConcentrationMeterModel({
    Offset? bodyPosition,
    Offset? probePosition,
    Rect? probeDragBounds,
  })  : bodyPosition = bodyPosition ?? ConcentrationConstants.meterBodyPosition,
        probePosition =
            probePosition ?? ConcentrationConstants.probeInitialPosition,
        probeDragBounds =
            probeDragBounds ?? ConcentrationConstants.probeDragBounds,
        _initialProbePosition =
            probePosition ?? ConcentrationConstants.probeInitialPosition;

  final Offset bodyPosition;
  final Rect probeDragBounds;
  final Offset _initialProbePosition;

  Offset probePosition;

  /// Measured value in current [units]; null = unknown (—).
  double? value;

  ConcentrationMeterUnits units = ConcentrationMeterUnits.molesPerLiter;

  ProbeRegion region = ProbeRegion.none;

  void setProbePosition(Offset value) {
    probePosition = Offset(
      value.dx.clamp(probeDragBounds.left, probeDragBounds.right),
      value.dy.clamp(probeDragBounds.top, probeDragBounds.bottom),
    );
  }

  /// Apply source reading rules for [region].
  ///
  /// Source order in `ConcentrationMeterNode.updateValue`:
  /// 1. solution OR drain fluid → solution concentration / percent
  /// 2. solvent stream → 0
  /// 3. stock solution stream → stock concentration / percent
  /// 4. else → null
  void updateValueFromRegion({
    required ProbeRegion region,
    required ConcentrationSolution solution,
    required Solute selectedSolute,
  }) {
    this.region = region;
    switch (region) {
      case ProbeRegion.solution:
      case ProbeRegion.drainStream:
        value = units == ConcentrationMeterUnits.molesPerLiter
            ? solution.concentration
            : solution.percentConcentration;
      case ProbeRegion.waterStream:
        value = 0;
      case ProbeRegion.stockSolution:
        value = units == ConcentrationMeterUnits.molesPerLiter
            ? selectedSolute.stockSolutionConcentration
            : selectedSolute.stockSolutionPercentConcentration;
      case ProbeRegion.none:
        value = null;
    }
  }

  void reset() {
    value = null;
    region = ProbeRegion.none;
    probePosition = _initialProbePosition;
    units = ConcentrationMeterUnits.molesPerLiter;
  }
}

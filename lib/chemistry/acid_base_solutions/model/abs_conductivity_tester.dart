import 'dart:ui';

import 'abs_beaker.dart';
import 'abs_constants.dart';
import 'abs_range.dart';

/// Conductivity tester — PhET `ConductivityTester.ts`.
///
/// Brightness ∈ [0, 1] drives the light bulb. Uses **strict** `pH == 7`
/// equality for the distilled-water open-circuit case (issue #233).
class AbsConductivityTester {
  AbsConductivityTester({
    required this.beaker,
    required this.pHOfSolution,
  })  : bulbPosition = Offset(beaker.position.dx - 45, beaker.top - 30),
        probeSize = const Size(20, 68) {
    probeDragYRange = AbsRange(
      beaker.top - 20 - bulbPosition.dy,
      beaker.top + 50 - bulbPosition.dy,
    );
    final probeXOffset = 0.175 * beaker.size.width;
    final probeY = bulbPosition.dy + probeDragYRange.min + 10;
    _positiveProbePosition = Offset(beaker.right - probeXOffset, probeY);
    _negativeProbePosition = Offset(beaker.left + probeXOffset, probeY);
    _initialPositive = _positiveProbePosition;
    _initialNegative = _negativeProbePosition;
  }

  final AbsBeaker beaker;
  final double Function() pHOfSolution;

  /// Bottom-center of bulb's base (fixed).
  final Offset bulbPosition;
  final Size probeSize;
  late final AbsRange probeDragYRange;

  late Offset _positiveProbePosition;
  late Offset _negativeProbePosition;
  late final Offset _initialPositive;
  late final Offset _initialNegative;

  Offset get positiveProbePosition => _positiveProbePosition;

  set positiveProbePosition(Offset value) {
    final y = (value.dy - bulbPosition.dy).clamp(
          probeDragYRange.min,
          probeDragYRange.max,
        ) +
        bulbPosition.dy;
    _positiveProbePosition = Offset(_initialPositive.dx, y);
  }

  Offset get negativeProbePosition => _negativeProbePosition;

  set negativeProbePosition(Offset value) {
    final y = (value.dy - bulbPosition.dy).clamp(
          probeDragYRange.min,
          probeDragYRange.max,
        ) +
        bulbPosition.dy;
    _negativeProbePosition = Offset(_initialNegative.dx, y);
  }

  /// Brightness of bulb from 0 (off) to 1 (full on).
  double get brightness {
    final pH = pHOfSolution();
    if (beaker.containsPoint(_positiveProbePosition) &&
        beaker.containsPoint(_negativeProbePosition)) {
      // Strict equality — do not replace with epsilon.
      if (pH == AbsConstants.neutralPh) {
        return 0;
      }
      const neutral = AbsConstants.neutralBrightness;
      if (pH < AbsConstants.neutralPh) {
        return neutral +
            (1 - neutral) *
                (AbsConstants.neutralPh - pH) /
                (AbsConstants.neutralPh - AbsConstants.phRange.min);
      }
      return neutral +
          (1 - neutral) *
              (pH - AbsConstants.neutralPh) /
              (AbsConstants.phRange.max - AbsConstants.neutralPh);
    }
    return 0;
  }

  void reset() {
    _positiveProbePosition = _initialPositive;
    _negativeProbePosition = _initialNegative;
  }
}

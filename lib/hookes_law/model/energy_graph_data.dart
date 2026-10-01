import 'dart:math' as math;

import '../constants/hookes_law_constants.dart';
import 'hookes_law_numbers.dart';
import 'spring.dart';

/// Model-space and view-space samples for the Energy screen plots.
///
/// This is the data `EnergyPlot.ts`, `ForcePlot.ts`, and `EnergyBarGraph.ts`
/// compute before any scenery node is drawn. No canvas, no path.
class EnergyGraphData {
  const EnergyGraphData._();

  /// E = (k x^2) / 2 at an arbitrary displacement. Does not mutate [spring].
  static double energyAt(Spring spring, double displacement) {
    final k = spring.springConstant;
    return (k * displacement * displacement) / 2;
  }

  /// F = k x at an arbitrary displacement. Does not mutate [spring].
  static double forceAt(Spring spring, double displacement) {
    return spring.springConstant * displacement;
  }

  /// Quadratic samples and view-space Bézier controls from `EnergyPlot.ts`.
  ///
  /// The curve is two `quadraticCurveTo` segments, not a sampled polyline.
  /// Control-point formula from the source:
  /// `cpx = 2 * x2 - x1/2 - x3/2` (same for y).
  static EnergyPlotBezier energyPlotBezier(Spring spring) {
    final displacementRange = spring.displacementRange;
    if (displacementRange.min.abs() != displacementRange.max) {
      throw StateError(
        'Energy plot requires a displacement range symmetric about 0',
      );
    }

    final d1 = displacementRange.max;
    final d2 = displacementRange.max / 2;
    final d3 = 0.0;
    final k = spring.springConstant;
    final e1 = (k * d1 * d1) / 2;
    final e2 = (k * d2 * d2) / 2;
    final e3 = (k * d3 * d3) / 2;

    final unitX = HookesLawConstants.unitDisplacementX;
    final unitY = HookesLawConstants.unitEnergyY;
    final x1 = unitX * d1;
    final x2 = unitX * d2;
    final x3 = unitX * d3;
    final y1 = -unitY * e1;
    final y2 = -unitY * e2;
    final y3 = -unitY * e3;
    final cpx = (2 * x2) - (x1 / 2) - (x3 / 2);
    final cpy = (2 * y2) - (y1 / 2) - (y3 / 2);

    return EnergyPlotBezier(
      d1: d1,
      d2: d2,
      d3: d3,
      e1: e1,
      e2: e2,
      e3: e3,
      x1: x1,
      x2: x2,
      x3: x3,
      y1: y1,
      y2: y2,
      y3: y3,
      cpx: cpx,
      cpy: cpy,
      viewMinX: unitX * (1.1 * displacementRange.min),
      viewMaxX: unitX * (1.1 * displacementRange.max),
      viewMinY: 0,
      viewMaxY: HookesLawConstants.energyYAxisLength,
    );
  }

  /// F = kx line across the full displacement range, in view coordinates.
  /// `ForcePlot.ts` `springConstantProperty` listener.
  static ForcePlotLine forcePlotLine(Spring spring) {
    final unitX = HookesLawConstants.unitDisplacementX;
    final unitY = HookesLawConstants.unitForceY;
    final range = spring.displacementRange;
    final k = spring.springConstant;
    return ForcePlotLine(
      x0: unitX * range.min,
      y0: -unitY * k * range.min,
      x1: unitX * range.max,
      y1: -unitY * k * range.max,
      viewMinX: unitX * (1.1 * range.min),
      viewMaxX: unitX * (1.1 * range.max),
      viewMinY: -HookesLawConstants.forceYAxisLength / 2,
      viewMaxY: HookesLawConstants.forceYAxisLength / 2,
    );
  }

  /// Triangle under F = kx from the origin to the current point.
  /// Hidden when the displayed displacement rounds to 0 at 3 decimal places.
  static ForcePlotEnergyTriangle forcePlotEnergyTriangle(Spring spring) {
    final fixedDisplacement = HookesLawNumbers.toFixedNumber(
      spring.displacement,
      HookesLawConstants.displacementDecimalPlaces,
    );
    final x = HookesLawConstants.unitDisplacementX * fixedDisplacement;
    final y = -spring.appliedForce * HookesLawConstants.unitForceY;
    return ForcePlotEnergyTriangle(
      visible: fixedDisplacement != 0,
      originX: 0,
      originY: 0,
      x: x,
      y: y,
    );
  }

  /// Bar height in view pixels. Hidden when E is 0 because a zero-height
  /// rectangle is not drawn. `EnergyBarGraph.ts`.
  static EnergyBarSample energyBar(Spring spring) {
    final energy = spring.potentialEnergy;
    final height = math.max(1.0, energy * HookesLawConstants.unitEnergyY);
    return EnergyBarSample(visible: energy > 0, height: height, energy: energy);
  }
}

class EnergyPlotBezier {
  const EnergyPlotBezier({
    required this.d1,
    required this.d2,
    required this.d3,
    required this.e1,
    required this.e2,
    required this.e3,
    required this.x1,
    required this.x2,
    required this.x3,
    required this.y1,
    required this.y2,
    required this.y3,
    required this.cpx,
    required this.cpy,
    required this.viewMinX,
    required this.viewMaxX,
    required this.viewMinY,
    required this.viewMaxY,
  });

  final double d1;
  final double d2;
  final double d3;
  final double e1;
  final double e2;
  final double e3;
  final double x1;
  final double x2;
  final double x3;
  final double y1;
  final double y2;
  final double y3;
  final double cpx;
  final double cpy;
  final double viewMinX;
  final double viewMaxX;
  final double viewMinY;
  final double viewMaxY;
}

class ForcePlotLine {
  const ForcePlotLine({
    required this.x0,
    required this.y0,
    required this.x1,
    required this.y1,
    required this.viewMinX,
    required this.viewMaxX,
    required this.viewMinY,
    required this.viewMaxY,
  });

  final double x0;
  final double y0;
  final double x1;
  final double y1;
  final double viewMinX;
  final double viewMaxX;
  final double viewMinY;
  final double viewMaxY;
}

class ForcePlotEnergyTriangle {
  const ForcePlotEnergyTriangle({
    required this.visible,
    required this.originX,
    required this.originY,
    required this.x,
    required this.y,
  });

  final bool visible;
  final double originX;
  final double originY;
  final double x;
  final double y;
}

class EnergyBarSample {
  const EnergyBarSample({
    required this.visible,
    required this.height,
    required this.energy,
  });

  final bool visible;
  final double height;
  final double energy;
}

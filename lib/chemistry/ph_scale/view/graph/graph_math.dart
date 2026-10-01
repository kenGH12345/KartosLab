import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../model/ph_chemistry.dart';
import '../../model/ph_scale_constants.dart';
import '../../model/solution_derived_properties.dart';
import '../scientific_notation.dart';
import 'graph_enums.dart';

/// View state for GraphNode — PhET `GraphNode.ts` properties.
class GraphViewState extends ChangeNotifier {
  GraphViewState({
    this.hasLinearFeature = false,
    GraphUnits units = GraphUnits.molesPerLiter,
    GraphScale scale = GraphScale.logarithmic,
  })  : _units = units,
        _scale = scale;

  final bool hasLinearFeature;

  bool expanded = true;
  GraphUnits _units;
  GraphScale _scale;

  /// Linear zoom exponent; default = LINEAR_EXPONENT_RANGE.max = 1.
  int linearExponent = PhScaleConstants.linearExponentMax.toInt();

  GraphUnits get units => _units;
  GraphScale get scale => _scale;

  set units(GraphUnits v) {
    if (_units == v) return;
    _units = v;
    notifyListeners();
  }

  set scale(GraphScale v) {
    if (!hasLinearFeature || _scale == v) return;
    _scale = v;
    notifyListeners();
  }

  void setExpanded(bool v) {
    if (expanded == v) return;
    expanded = v;
    notifyListeners();
  }

  void setLinearExponent(int e) {
    final clamped = e
        .clamp(
          PhScaleConstants.linearExponentMin.toInt(),
          PhScaleConstants.linearExponentMax.toInt(),
        )
        .toInt();
    if (linearExponent == clamped) return;
    linearExponent = clamped;
    notifyListeners();
  }

  void zoomIn() => setLinearExponent(linearExponent - 1);
  void zoomOut() => setLinearExponent(linearExponent + 1);

  void reset() {
    expanded = true;
    _units = GraphUnits.molesPerLiter;
    _scale = GraphScale.logarithmic;
    linearExponent = PhScaleConstants.linearExponentMax.toInt();
    notifyListeners();
  }
}

/// Log scale math — PhET `LogarithmicGraphNode` (implementation, not JSDoc).
class LogGraphMath {
  LogGraphMath._();

  static const double scaleYMargin = 30;

  static double valueToY(num? value, double scaleHeight) {
    if (value == null || value == 0) {
      return scaleHeight - 0.5 * scaleYMargin;
    }
    final maxHeight = scaleHeight - 2 * scaleYMargin;
    final maxExp = PhScaleConstants.logarithmicExponentMax;
    final minExp = PhScaleConstants.logarithmicExponentMin;
    final valueExponent = math.log(value.toDouble()) / math.ln10;
    return scaleYMargin +
        maxHeight -
        (maxHeight * (valueExponent - minExp) / (maxExp - minExp));
  }

  static double yToValue(double y, double scaleHeight) {
    final yOffset = y - scaleYMargin;
    final maxHeight = scaleHeight - 2 * scaleYMargin;
    // linear(0, maxHeight, maxExp, minExp, yOffset)
    final maxExp = PhScaleConstants.logarithmicExponentMax;
    final minExp = PhScaleConstants.logarithmicExponentMin;
    final t = maxHeight == 0 ? 0.0 : yOffset / maxHeight;
    final exponent = maxExp + t * (minExp - maxExp);
    return math.pow(10, exponent).toDouble();
  }
}

/// Map derived properties → displayed value for one species.
double? graphValueFor({
  required SolutionDerivedProperties derived,
  required GraphUnits units,
  required GraphSpecies species,
}) {
  switch (species) {
    case GraphSpecies.h2o:
      return units == GraphUnits.molesPerLiter
          ? derived.concentrationH2O
          : derived.quantityH2O;
    case GraphSpecies.h3o:
      return units == GraphUnits.molesPerLiter
          ? derived.concentrationH3O
          : derived.quantityH3O;
    case GraphSpecies.oh:
      return units == GraphUnits.molesPerLiter
          ? derived.concentrationOH
          : derived.quantityOH;
  }
}

enum GraphSpecies { h2o, h3o, oh }


/// Indicator drag → pH — PhET `GraphIndicatorDragListener.doDrag`.
class GraphIndicatorDrag {
  GraphIndicatorDrag._();

  static void apply({
    required double yView,
    required double scaleHeight,
    required double totalVolume,
    required GraphUnits units,
    required bool isH3O,
    required void Function(double pH) setPH,
  }) {
    if (totalVolume == 0) return;

    final value = LogGraphMath.yToValue(yView, scaleHeight);
    if (value <= 0) return;

    final sn = ScientificNotation.from(
      value,
      mantissaDecimalPlaces: 1, // LOGARITHMIC_MANTISSA_DECIMAL_PLACES
    );
    final exp = int.parse(sn.exponent) - 1;
    final interval = math.pow(10, exp).toDouble();
    var adjusted = _roundToInterval(value, interval);

    final isConcentration = units == GraphUnits.molesPerLiter;
    if (isConcentration && (adjusted - 9.9e-8).abs() < 1e-20) {
      adjusted = 1.0e-7;
    }

    PhValue pH;
    if (isConcentration) {
      pH = isH3O
          ? PhChemistry.concentrationH3OToPH(adjusted)
          : PhChemistry.concentrationOHToPH(adjusted);
    } else {
      pH = isH3O
          ? PhChemistry.molesH3OToPH(adjusted, totalVolume)
          : PhChemistry.molesOHToPH(adjusted, totalVolume);
    }
    if (pH == null) return;
    final clamped = pH.clamp(PhScaleConstants.phMin, PhScaleConstants.phMax);
    setPH(clamped);
  }

  static double _roundToInterval(double value, double interval) {
    if (interval == 0) return value;
    return (value / interval).round() * interval;
  }
}

/// Linear scale: top tick = 8 × 10^exponent.
double linearValueToY({
  required num? value,
  required int exponent,
  required double topTickY,
  required double bottomTickY,
  required double offScaleY,
}) {
  final v = (value ?? 0).toDouble();
  final topTickValue = 8 * math.pow(10, exponent).toDouble();
  if (v > topTickValue) return offScaleY;
  if (topTickValue == 0) return bottomTickY;
  // linear(0, topTickValue, topTickY, bottomTickY, v) — note PhET: topTick is first label (mantissa 8)
  // In LinearGraphNode: tickLabels[0] is top (8), tickLabels[last] is bottom (0)
  return topTickY + (bottomTickY - topTickY) * (v / topTickValue);
}

// Re-export species selectors for indicators
double? valueH2O(SolutionDerivedProperties d, GraphUnits u) =>
    graphValueFor(derived: d, units: u, species: GraphSpecies.h2o);
double? valueH3O(SolutionDerivedProperties d, GraphUnits u) =>
    graphValueFor(derived: d, units: u, species: GraphSpecies.h3o);
double? valueOH(SolutionDerivedProperties d, GraphUnits u) =>
    graphValueFor(derived: d, units: u, species: GraphSpecies.oh);

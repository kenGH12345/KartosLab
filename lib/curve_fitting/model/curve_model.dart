import 'dart:ui';

import '../curve_fitting_constants.dart';
import '../solver/regression_solver.dart';
import '../solver/statistics_solver.dart';
import 'data_set.dart';
import 'fit_type.dart';

/// Polynomial curve model — PhET `Curve.js`.
class CurveModel {
  CurveModel({
    required this.dataSet,
    required List<double> sliderValues,
  }) : _sliderValues = sliderValues;

  final DataSet dataSet;
  List<double> _sliderValues;

  /// Ascending coefficients [a0, a1, …] length = order + 1.
  List<double> coefficients = [0, 0];

  double rSquared = 0;
  double chiSquared = 0;

  int order = 1;
  FitType fitType = FitType.best;

  void bindSliders(List<double> sliderValues) {
    _sliderValues = sliderValues;
  }

  /// Curve exists if ≥2 relevant points, or adjustable fit.
  bool get isCurvePresent =>
      dataSet.getRelevantPoints().length >= 2 || fitType == FitType.adjustable;

  double getYValueAt(double x) =>
      RegressionSolver.getYValueAt(coefficients, x);

  /// Sampled polyline over GRAPH_NODE_MODEL_BOUNDS x ∈ [-12, 12],
  /// NUMBER_STEPS = 220 (CurveShape.js).
  List<Offset> getShapeSamples() {
    final bounds = CurveFittingConstants.graphNodeModelBounds;
    final xMin = bounds.left;
    final xMax = bounds.right;
    final interval =
        (xMax - xMin) / CurveFittingConstants.numberSteps;

    final samples = <Offset>[];
    samples.add(Offset(xMin, getYValueAt(xMin)));
    for (var x = xMin + interval; x <= xMax; x += interval) {
      samples.add(Offset(x, getYValueAt(x)));
    }
    return samples;
  }

  void updateFit() {
    if (fitType == FitType.best) {
      coefficients = _getBestFitCoefficients();
    } else {
      coefficients = _getAdjustableFitCoefficients();
    }
    _updateRAndChiSquared();
  }

  List<double> _getAdjustableFitCoefficients() {
    final result = <double>[];
    for (var i = 0; i < _sliderValues.length; i++) {
      if (i <= order) {
        result.add(_sliderValues[i]);
      }
    }
    return result;
  }

  List<double> _getBestFitCoefficients() {
    final relevant = dataSet.getRelevantPoints();
    return RegressionSolver.getBestFitCoefficients(
      relevant,
      order,
      uniqueXCount: dataSet.getNumberUniquePositionX(),
    );
  }

  void _updateRAndChiSquared() {
    final stats = StatisticsSolver.computeRAndChiSquared(
      points: dataSet.getRelevantPoints(),
      coefficients: coefficients,
      order: order,
    );
    chiSquared = stats.chiSquared;
    rSquared = stats.rSquared;
  }

  void reset() {
    rSquared = 0;
    chiSquared = 0;
  }
}

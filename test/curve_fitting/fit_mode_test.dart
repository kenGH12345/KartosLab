import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/curve_fitting/model/curve_fitting_model.dart';
import 'package:kratos/curve_fitting/model/data_point.dart';
import 'package:kratos/curve_fitting/model/fit_type.dart';
import 'package:kratos/curve_fitting/solver/regression_solver.dart';

void main() {
  test('BEST fit uses solver coefficients', () {
    final model = CurveFittingModel();
    model.setFitType(FitType.best);
    model.addPoint(DataPoint(x: 0, y: 2, delta: 1));
    model.addPoint(DataPoint(x: 1, y: 5, delta: 1));
    model.addPoint(DataPoint(x: 2, y: 8, delta: 1));

    final expected = RegressionSolver.getBestFitCoefficients(
      model.points.getRelevantPoints(),
      model.order,
    );
    expect(model.curve.coefficients[0], closeTo(expected[0], 1e-9));
    expect(model.curve.coefficients[1], closeTo(expected[1], 1e-9));
    expect(model.curve.coefficients[0], closeTo(2, 1e-9));
    expect(model.curve.coefficients[1], closeTo(3, 1e-9));
  });

  test('ADJUSTABLE does NOT re-run best fit — uses sliders', () {
    final model = CurveFittingModel();
    model.addPoint(DataPoint(x: 0, y: 2, delta: 1));
    model.addPoint(DataPoint(x: 1, y: 5, delta: 1));
    model.addPoint(DataPoint(x: 2, y: 8, delta: 1));

    // Best would be [2,3]; force adjustable with different sliders
    model.setSliderValue(0, 0.5); // d
    model.setSliderValue(1, -1.0); // c
    model.setFitType(FitType.adjustable);

    expect(model.curve.coefficients.length, 2);
    expect(model.curve.coefficients[0], closeTo(0.5, 1e-12));
    expect(model.curve.coefficients[1], closeTo(-1.0, 1e-12));

    // Changing points must NOT overwrite adjustable coefficients with best fit
    model.addPoint(DataPoint(x: 3, y: 11, delta: 1));
    expect(model.curve.coefficients[0], closeTo(0.5, 1e-12));
    expect(model.curve.coefficients[1], closeTo(-1.0, 1e-12));

    // isCurvePresent true even with few points when adjustable
    final sparse = CurveFittingModel();
    sparse.setFitType(FitType.adjustable);
    expect(sparse.curve.isCurvePresent, isTrue);
  });
}

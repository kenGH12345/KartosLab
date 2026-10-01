import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/curve_fitting/model/curve_fitting_model.dart';
import 'package:kratos/curve_fitting/model/data_point.dart';
import 'package:kratos/curve_fitting/model/fit_type.dart';
import 'package:kratos/curve_fitting/solver/regression_solver.dart';

void main() {
  test('add / move points updates best-fit coefficients and residuals stats', () {
    final model = CurveFittingModel();
    model.setCurveVisible(true);
    model.setResidualsVisible(true);
    model.setFitType(FitType.best);
    model.setOrder(1);

    final p1 = DataPoint(x: 0, y: 2, delta: 1);
    final p2 = DataPoint(x: 1, y: 5, delta: 1);
    final p3 = DataPoint(x: 2, y: 8, delta: 1);
    model.addPoint(p1);
    model.addPoint(p2);
    model.addPoint(p3);

    expect(model.curve.isCurvePresent, isTrue);
    expect(model.curve.coefficients[0], closeTo(2, 1e-9));
    expect(model.curve.coefficients[1], closeTo(3, 1e-9));

    // Residual at x=1: yObs=5, yFit=5 → 0 contribution for that point
    expect(model.curve.getYValueAt(1), closeTo(5, 1e-9));
    expect(model.curve.chiSquared, closeTo(0, 1e-9));
    expect(model.curve.rSquared, closeTo(1, 1e-9));

    // Move a point → coefficients / stats change
    p2.setPosition(1, 7);
    expect(model.curve.coefficients[0], isNot(closeTo(2, 1e-6)));
    expect(model.curve.chiSquared, greaterThan(0));

    final expected = RegressionSolver.getBestFitCoefficients(
      model.points.getRelevantPoints(),
      model.order,
    );
    expect(model.curve.coefficients[0], closeTo(expected[0], 1e-9));
    expect(model.curve.coefficients[1], closeTo(expected[1], 1e-9));
  });

  test('curve off saves/restores residuals via panel semantics', () {
    final model = CurveFittingModel();
    model.setCurveVisible(true);
    model.setResidualsVisible(true);

    // Mirror ViewOptionsPanel: turning curve off saves and clears residuals
    var wereResidualsVisible = model.residualsVisible;
    model.setResidualsVisible(false);
    model.setCurveVisible(false);
    expect(model.residualsVisible, isFalse);
    expect(wereResidualsVisible, isTrue);

    // Turning curve on restores
    model.setCurveVisible(true);
    model.setResidualsVisible(wereResidualsVisible);
    expect(model.residualsVisible, isTrue);
  });

  test('points outside graph are not relevant until inside', () {
    final model = CurveFittingModel();
    final outside = DataPoint(x: 20, y: 0);
    model.addPoint(outside);
    expect(outside.isInsideGraph, isFalse);
    expect(model.points.getRelevantPoints(), isEmpty);

    outside.setPosition(1, 1);
    expect(outside.isInsideGraph, isTrue);
    expect(model.points.getRelevantPoints().length, 1);
  });

  test('animationActive excludes point from relevant set', () {
    final model = CurveFittingModel();
    final p = DataPoint(x: 1, y: 1)..animationActive = true;
    model.addPoint(p);
    expect(model.points.getRelevantPoints(), isEmpty);
  });
}

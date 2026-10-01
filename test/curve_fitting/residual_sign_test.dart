import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/curve_fitting/model/curve_fitting_model.dart';
import 'package:kratos/curve_fitting/model/data_point.dart';
import 'package:kratos/curve_fitting/render/cf_render_builder.dart';
import 'package:kratos/curve_fitting/solver/regression_solver.dart';

/// Residual display: vertical line from (x, yObs) to (x, yFit) —
/// NOT a signed residual quantity for painting.
void main() {
  test('residual connects yObs to yFit at same x', () {
    final model = CurveFittingModel();
    model.setCurveVisible(true);
    model.setResidualsVisible(true);
    model.setFitType(model.fitType); // best

    model.addPoint(DataPoint(x: 0, y: 5, delta: 1));
    model.addPoint(DataPoint(x: 2, y: 1, delta: 1));
    model.addPoint(DataPoint(x: 4, y: 9, delta: 1));

    final yFit0 = model.curve.getYValueAt(0);
    final yFit2 = model.curve.getYValueAt(2);

    expect(yFit0, isNot(equals(5))); // not exact fit necessarily
    // Semantics: residual endpoints use observed y and fitted y
    final fromY = 5.0;
    final toY = yFit0;
    // Line is vertical in model: same x, different y — sign is just direction
    expect(fromY - toY, isNot(equals(0)));

    final data = const CfRenderBuilder().build(model);
    expect(data.residuals, isNotEmpty);

    final r0 = data.residuals.firstWhere((r) => r.yObs == 5);
    expect(r0.yFit, closeTo(yFit0, 1e-12));
    expect(r0.fromView.dx, closeTo(r0.toView.dx, 1e-9)); // vertical in view too
    // Does NOT redefine residual as obs-fit for display — both ends kept
    expect(r0.yObs, 5);
    expect(r0.yFit, closeTo(RegressionSolver.getYValueAt(model.curve.coefficients, 0), 1e-12));

    final r2 = data.residuals.firstWhere((r) => r.yObs == 1);
    expect(r2.yFit, closeTo(yFit2, 1e-12));
  });
}

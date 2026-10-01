import 'package:kratos/energy_skate_park/solver/hermite_spline.dart';

/// Thin wrappers matching SplineEvaluation.ts.
class SplineEvaluation {
  SplineEvaluation._();

  static double atNumber(HermiteSpline spline, double x0) => spline.at(x0);

  static List<double> atArray(HermiteSpline spline, List<double> x0) {
    final n = x0.length;
    final ret = List<double>.filled(n, 0);
    for (var i = n - 1; i != -1; --i) {
      ret[i] = atNumber(spline, x0[i]);
    }
    return ret;
  }
}
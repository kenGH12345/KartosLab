/// Natural cubic Hermite spline matching numeric.js `numeric.spline(x,y)`
/// (k1/kn undefined → natural ends) and `Spline.prototype.diff` (scalar).
class HermiteSpline {
  HermiteSpline({
    required this.x,
    required this.yl,
    required this.yr,
    required this.kl,
    required this.kr,
  });

  final List<double> x;
  final List<double> yl;
  final List<double> yr;
  final List<double> kl;
  final List<double> kr;

  /// numeric.spline(x, y) with natural boundary conditions.
  factory HermiteSpline.fit(List<double> x, List<double> y) {
    assert(x.length == y.length && x.length >= 2);
    final n = x.length;
    final dx = List<double>.filled(n - 1, 0);
    final dy = List<double>.filled(n - 1, 0);
    for (var i = 0; i < n - 1; i++) {
      dx[i] = x[i + 1] - x[i];
      dy[i] = y[i + 1] - y[i];
    }

    // Sparse tridiagonal system equivalent to numeric.cLU + cLUsolve
    final lower = List<double>.filled(n, 0);
    final diag = List<double>.filled(n, 0);
    final upper = List<double>.filled(n, 0);
    final b = List<double>.filled(n, 0);

    b[0] = 3 / (dx[0] * dx[0]) * dy[0];
    diag[0] = 2 / dx[0];
    upper[0] = 1 / dx[0];

    for (var i = 1; i < n - 1; i++) {
      b[i] = 3 / (dx[i - 1] * dx[i - 1]) * dy[i - 1] +
          3 / (dx[i] * dx[i]) * dy[i];
      lower[i] = 1 / dx[i - 1];
      diag[i] = 2 / dx[i - 1] + 2 / dx[i];
      upper[i] = 1 / dx[i];
    }

    b[n - 1] = 3 / (dx[n - 2] * dx[n - 2]) * dy[n - 2];
    lower[n - 1] = 1 / dx[n - 2];
    diag[n - 1] = 2 / dx[n - 2];

    final k = _thomasSolve(lower, diag, upper, b);
    // numeric returns Spline(x, y, y, k, k)
    return HermiteSpline(
      x: List<double>.from(x),
      yl: List<double>.from(y),
      yr: List<double>.from(y),
      kl: k,
      kr: List<double>.from(k),
    );
  }

  /// Thomas algorithm for tridiagonal system.
  static List<double> _thomasSolve(
    List<double> lower,
    List<double> diag,
    List<double> upper,
    List<double> b,
  ) {
    final n = b.length;
    final cp = List<double>.filled(n, 0);
    final dp = List<double>.filled(n, 0);
    cp[0] = upper[0] / diag[0];
    dp[0] = b[0] / diag[0];
    for (var i = 1; i < n; i++) {
      final den = diag[i] - lower[i] * cp[i - 1];
      cp[i] = i < n - 1 ? upper[i] / den : 0;
      dp[i] = (b[i] - lower[i] * dp[i - 1]) / den;
    }
    final x = List<double>.filled(n, 0);
    x[n - 1] = dp[n - 1];
    for (var i = n - 2; i >= 0; i--) {
      x[i] = dp[i] - cp[i] * x[i + 1];
    }
    return x;
  }

  /// SplineEvaluation / numeric.Spline._at (scalar).
  double _at(double x1, int p) {
    final a = kl[p] * (x[p + 1] - x[p]) - (yr[p + 1] - yl[p]);
    final b = kr[p + 1] * (x[p] - x[p + 1]) + yr[p + 1] - yl[p];
    final t = (x1 - x[p]) / (x[p + 1] - x[p]);
    final s = t * (1 - t);
    return (1 - t) * yl[p] + t * yr[p + 1] + a * s * (1 - t) + b * s * t;
  }

  double at(double x0) {
    final n = x.length;
    var p = 0;
    var q = n - 1;
    while (q - p > 1) {
      final mid = (p + q) ~/ 2;
      if (x[mid] <= x0) {
        p = mid;
      } else {
        q = mid;
      }
    }
    return _at(x0, p);
  }

  /// numeric.Spline.prototype.diff (scalar version).
  HermiteSpline diff() {
    final n = yl.length;
    final zl = kl;
    final zr = kr;
    final pl = List<double>.filled(n, 0);
    final pr = List<double>.filled(n, 0);
    // Segments are 0..n-2; numeric.js loop hits i=n-1 with NaN but those slots unused.
    for (var i = 0; i < n - 1; i++) {
      final dx = x[i + 1] - x[i];
      final dy = yr[i + 1] - yl[i];
      pl[i] = (dy * 6 + kl[i] * (-4 * dx) + kr[i + 1] * (-2 * dx)) / (dx * dx);
      pr[i + 1] = (dy * (-6) + kl[i] * (2 * dx) + kr[i + 1] * (4 * dx)) / (dx * dx);
    }
    return HermiteSpline(x: x, yl: zl, yr: zr, kl: pl, kr: pr);
  }
}
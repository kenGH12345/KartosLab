/// Square-matrix determinant + linear solve via Gaussian elimination
/// with partial pivoting (PhET `Matrix.det` / `Matrix.solve` for n×n).
class MatrixSolver {
  MatrixSolver._();

  /// Determinant of an n×n matrix [a]. Empty (0×0) matrix has det = 1.
  static double det(List<List<double>> a) {
    final n = a.length;
    if (n == 0) return 1;
    assert(a.every((row) => row.length == n));

    final m = List.generate(n, (i) => List<double>.from(a[i]));
    var sign = 1.0;

    for (var k = 0; k < n; k++) {
      var pivot = k;
      var maxAbs = m[k][k].abs();
      for (var i = k + 1; i < n; i++) {
        final v = m[i][k].abs();
        if (v > maxAbs) {
          maxAbs = v;
          pivot = i;
        }
      }
      if (maxAbs == 0) return 0;

      if (pivot != k) {
        final tmp = m[k];
        m[k] = m[pivot];
        m[pivot] = tmp;
        sign = -sign;
      }

      for (var i = k + 1; i < n; i++) {
        final factor = m[i][k] / m[k][k];
        m[i][k] = 0;
        for (var j = k + 1; j < n; j++) {
          m[i][j] -= factor * m[k][j];
        }
      }
    }

    var d = sign;
    for (var i = 0; i < n; i++) {
      d *= m[i][i];
    }
    return d;
  }

  /// Solves [a] x = [b] for square [a] (n×n) and column [b] (length n).
  /// Uses Gaussian elimination with partial pivoting.
  static List<double> solve(List<List<double>> a, List<double> b) {
    final n = a.length;
    assert(b.length == n);
    assert(a.every((row) => row.length == n));
    if (n == 0) return <double>[];

    // Augmented matrix [A|b]
    final m = List.generate(n, (i) {
      final row = List<double>.from(a[i]);
      row.add(b[i]);
      return row;
    });

    for (var k = 0; k < n; k++) {
      var pivot = k;
      var maxAbs = m[k][k].abs();
      for (var i = k + 1; i < n; i++) {
        final v = m[i][k].abs();
        if (v > maxAbs) {
          maxAbs = v;
          pivot = i;
        }
      }
      if (maxAbs == 0) {
        throw StateError('Matrix is singular.');
      }
      if (pivot != k) {
        final tmp = m[k];
        m[k] = m[pivot];
        m[pivot] = tmp;
      }

      for (var i = k + 1; i < n; i++) {
        final factor = m[i][k] / m[k][k];
        for (var j = k; j <= n; j++) {
          m[i][j] -= factor * m[k][j];
        }
      }
    }

    final x = List<double>.filled(n, 0);
    for (var i = n - 1; i >= 0; i--) {
      var sum = m[i][n];
      for (var j = i + 1; j < n; j++) {
        sum -= m[i][j] * x[j];
      }
      x[i] = sum / m[i][i];
    }
    return x;
  }

  /// Convenience: check |det| without throwing.
  static bool isSingular(List<List<double>> a, double epsilon) =>
      det(a).abs() <= epsilon;
}

import 'dart:math' as math;

/// Dense matrix + Householder QR least-squares solve.
/// PhET `MNACircuit.solve` uses `QRDecomposition` because the stamp system is
/// overdetermined (one extra reference-voltage equation per component).
class MnaMatrix {
  MnaMatrix(this.rows, this.cols)
      : _data = List<double>.filled(rows * cols, 0);

  final int rows;
  final int cols;
  final List<double> _data;

  double get(int r, int c) => _data[r * cols + c];

  void set(int r, int c, double v) => _data[r * cols + c] = v;

  void add(int r, int c, double v) => _data[r * cols + c] += v;

  /// Solves A x = z in least squares via thin QR. If rank-deficient, returns zeros
  /// (PhET catch in `MNACircuit.ts` around dc#113).
  static List<double> qrSolve(MnaMatrix a, List<double> z) {
    final m = a.rows;
    final n = a.cols;
    if (n == 0) return <double>[];
    if (m == 0) return List<double>.filled(n, 0);

    final work = List<double>.from(a._data);
    final b = List<double>.from(z);
    if (b.length != m) {
      throw ArgumentError('rhs length ${b.length} != rows $m');
    }

    try {
      // Thin QR via modified Gram-Schmidt on columns of A (m×n, m≥n).
      final q = List<List<double>>.generate(
        m,
        (i) => List<double>.generate(n, (j) => work[i * n + j]),
      );
      final r = List<List<double>>.generate(n, (_) => List<double>.filled(n, 0));
      for (var k = 0; k < n; k++) {
        var nrm = 0.0;
        for (var i = 0; i < m; i++) {
          nrm += q[i][k] * q[i][k];
        }
        nrm = math.sqrt(nrm);
        if (nrm < 1e-18) continue;
        r[k][k] = nrm;
        for (var i = 0; i < m; i++) {
          q[i][k] /= nrm;
        }
        for (var j = k + 1; j < n; j++) {
          var dot = 0.0;
          for (var i = 0; i < m; i++) {
            dot += q[i][k] * q[i][j];
          }
          r[k][j] = dot;
          for (var i = 0; i < m; i++) {
            q[i][j] -= dot * q[i][k];
          }
        }
      }
      final y = List<double>.filled(n, 0);
      for (var k = 0; k < n; k++) {
        var acc = 0.0;
        for (var i = 0; i < m; i++) {
          acc += q[i][k] * b[i];
        }
        y[k] = acc;
      }
      final x = List<double>.filled(n, 0);
      for (var i = n - 1; i >= 0; i--) {
        var sum = y[i];
        for (var j = i + 1; j < n; j++) {
          sum -= r[i][j] * x[j];
        }
        final rii = r[i][i];
        x[i] = rii.abs() < 1e-18 ? 0 : sum / rii;
      }
      return x;
    } catch (_) {
      return List<double>.filled(n, 0);
    }
  }
}
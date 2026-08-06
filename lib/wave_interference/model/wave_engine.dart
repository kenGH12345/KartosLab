import 'dart:math';
import 'dart:typed_data';

/// FDTD 2D wave equation propagator on a rectangular lattice.
///
/// Implements the discretized wave equation:
///   u[t+1] = 2*u[t] - u[t-1] + c^2 * laplacian(u[t])
///
/// Where laplacian uses a 5-point stencil. Barriers (potential != 0) are
/// treated as Dirichlet boundary (value fixed to 0).
/// Damping zones on all 4 edges absorb outgoing waves (Sommerfeld-like).
class WaveEngine {
  final int width;
  final int height;

  /// Current wave state (t).
  late List<Float64List> _curr;

  /// Previous wave state (t-1).
  late List<Float64List> _prev;

  /// Next wave state buffer (reused each frame to avoid per-frame allocation).
  late List<Float64List> _next;

  /// Barrier mask: true = barrier (value forced to 0).
  late List<Uint8List> _barrier;

  /// Damping zone width on each edge.
  static const int dampWidth = 15;

  /// Wave speed squared (c^2).
  static const double c2 = 0.25;

  /// Damping coefficients for absorbing boundaries.
  static const List<double> dampCoeffs = [1.0, 1.0, 0.999, 0.998, 0.995, 0.99, 0.97, 0.94, 0.90, 0.85, 0.78, 0.70, 0.60, 0.48, 0.35];

  double _time = 0;

  WaveEngine({required this.width, required this.height}) {
    _curr = List.generate(width, (_) => Float64List(height));
    _prev = List.generate(width, (_) => Float64List(height));
    _next = List.generate(width, (_) => Float64List(height));
    _barrier = List.generate(width, (_) => Uint8List(height));
  }

  List<Float64List> get current => _curr;
  double get time => _time;

  /// Set a barrier (opaque wall) at grid position.
  void setBarrier(int i, int j) {
    if (i >= 0 && i < width && j >= 0 && j < height) {
      _barrier[i][j] = 1;
    }
  }

  /// Clear all barriers.
  void clearBarriers() {
    for (int i = 0; i < width; i++) { _barrier[i].fillRange(0, height, 0); }
  }

  /// Set a vertical double-slit barrier at column x.
  void setDoubleSlit(int x, int slitWidth, int slitSize, int slitSeparation) {
    int midBarH = slitSeparation - slitSize;
    if (midBarH <= 0) midBarH = 1;
    int topBarH = height ~/ 2 - midBarH ~/ 2 - slitSize;
    topBarH = max(0, topBarH);

    for (int dx = 0; dx < slitWidth; dx++) {
      int col = x + dx;
      if (col >= width) break;
      // Top bar
      for (int j = 0; j < topBarH; j++) { setBarrier(col, j); }
      // Middle bar
      int midY = topBarH + slitSize;
      for (int j = midY; j < midY + midBarH; j++) {
        if (j < height) setBarrier(col, j);
      }
      // Bottom bar
      int bottomY = midY + midBarH + slitSize;
      for (int j = bottomY; j < height; j++) { setBarrier(col, j); }
    }
  }

  /// Set a single-slit barrier: two opaque walls with one open slit centered vertically.
  void setSingleSlit(int x, int slitWidth, int slitSize) {
    final topBarH = max(0, height ~/ 2 - slitSize ~/ 2);
    for (int dx = 0; dx < slitWidth; dx++) {
      int col = x + dx;
      if (col >= width) break;
      // Top bar
      for (int j = 0; j < topBarH; j++) {
        setBarrier(col, j);
      }
      // Bottom bar (below the slit opening)
      final bottomY = topBarH + slitSize;
      for (int j = bottomY; j < height; j++) {
        setBarrier(col, j);
      }
    }
  }

  /// Drive the oscillator source (circular region) with value.
  void setSource(int cx, int cy, int radius, double value) {
    for (int i = cx - radius; i <= cx + radius; i++) {
      for (int j = cy - radius; j <= cy + radius; j++) {
        if (i < 0 || i >= width || j < 0 || j >= height) continue;
        double dist = sqrt(((i - cx) * (i - cx) + (j - cy) * (j - cy)).toDouble());
        if (dist <= radius) {
          _curr[i][j] = value;
          _prev[i][j] = value;
        }
      }
    }
  }

  /// Advance one timestep.
  void propagate(double dt) {
    _time += dt;

    // Reuse pre-allocated _next buffer (3-buffer rotation, zero per-frame alloc).
    final next = _next;

    for (int i = 1; i < width - 1; i++) {
      for (int j = 1; j < height - 1; j++) {
        if (_barrier[i][j] != 0) { next[i][j] = 0; continue; }

        double laplacian = _curr[i + 1][j] + _curr[i - 1][j]
          + _curr[i][j + 1] + _curr[i][j - 1]
          - 4 * _curr[i][j];

        next[i][j] = 2 * _curr[i][j] - _prev[i][j] + c2 * laplacian;
      }
    }

    // Zero the outer 1-cell frame that the loop above skips, so the rotated
    // buffer doesn't carry stale values from two frames ago.
    for (int j = 0; j < height; j++) {
      next[0][j] = 0;
      next[width - 1][j] = 0;
    }
    for (int i = 0; i < width; i++) {
      next[i][0] = 0;
      next[i][height - 1] = 0;
    }

    // Damp edges
    _dampAll(next);

    // Rotate buffers: prev ← curr, curr ← next, next ← prev (recycled).
    final recycled = _prev;
    _prev = _curr;
    _curr = next;
    _next = recycled;
  }

  void _dampAll(List<Float64List> w) {
    for (int step = 0; step < dampWidth && step < dampCoeffs.length; step++) {
      double damp = dampCoeffs[step];
      // Left edge
      for (int j = 0; j < height; j++) { w[step][j] *= damp; }
      // Right edge
      for (int j = 0; j < height; j++) { w[width - 1 - step][j] *= damp; }
      // Top edge
      for (int i = 0; i < width; i++) { w[i][step] *= damp; }
      // Bottom edge
      for (int i = 0; i < width; i++) { w[i][height - 1 - step] *= damp; }
    }
  }

  void reset() {
    _time = 0;
    for (int i = 0; i < width; i++) {
      _curr[i].fillRange(0, height, 0);
      _prev[i].fillRange(0, height, 0);
      _next[i].fillRange(0, height, 0);
    }
  }

  void dispose() => reset();
}
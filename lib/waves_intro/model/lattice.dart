import '../waves_intro_constants.dart';

/// Faithful port of PhET `scenery-phet/js/Lattice.ts`.
///
/// Discretized 2D wave equation with absorbing boundaries.
/// WAVE_SPEED=0.5, WAVE_SPEED_SQUARED=0.25 — [已确认] Lattice.ts
class Lattice {
  Lattice({
    required this.width,
    required this.height,
    required this.dampX,
    required this.dampY,
  })  : _matrices = List.generate(
          _numberOfMatrices,
          (_) => _Matrix(width, height),
        ),
        _visited = _Matrix(width, height),
        _allowedMask = _Matrix(width, height, fill: 1);

  static const int _numberOfMatrices = 3;
  static const double lightVisitThreshold = 1e-3;

  final int width;
  final int height;
  final int dampX;
  final int dampY;

  final List<_Matrix> _matrices;
  final _Matrix _visited;
  final _Matrix _allowedMask;

  int _currentMatrixIndex = 0;

  /// EventTimer ratio for view interpolation — [已确认] Lattice.interpolationRatio
  double interpolationRatio = 0;

  int get visibleMinX => dampX;
  int get visibleMinY => dampY;
  int get visibleMaxX => width - dampX;
  int get visibleMaxY => height - dampY;

  bool visibleBoundsContains(int i, int j) {
    return visibleMinX <= i &&
        i < visibleMaxX &&
        visibleMinY <= j &&
        j < visibleMaxY;
  }

  bool contains(int i, int j) =>
      i >= 0 && i < width && j >= 0 && j < height;

  /// Center horizontal line (excludes damping) — [已确认] getCenterLineValues
  void getCenterLineValues(List<double> array) {
    final samplingWidth = width - dampX * 2;
    if (array.length != samplingWidth) {
      array
        ..clear()
        ..addAll(List<double>.filled(samplingWidth, 0));
    }
    final samplingVerticalPosition = height ~/ 2;
    for (var i = 0; i < samplingWidth; i++) {
      array[i] = getCurrentValue(i + dampX, samplingVerticalPosition);
    }
  }

  /// Rightmost visible column (before damping) — [已确认] Lattice.getOutputColumn @ 31ebfd7
  List<double> getOutputColumn() {
    final column = <double>[];
    for (var j = dampY; j < height - dampY; j++) {
      final a = getCurrentValue(width - dampX - 1, j);
      final b = getCurrentValue(width - dampX - 2, j);
      column.add((a + b) / 2);
    }
    return column;
  }

  double getCurrentValue(int i, int j) {
    if (!contains(i, j)) return 0;
    return _allowedMask.get(i, j) == 1
        ? _matrices[_currentMatrixIndex].get(i, j)
        : 0;
  }

  double getInterpolatedValue(int i, int j) {
    if (!contains(i, j)) return 0;
    if (_allowedMask.get(i, j) != 1) return 0;
    final currentValue = getCurrentValue(i, j);
    final lastValue = _getLastValue(i, j);
    return currentValue * interpolationRatio +
        lastValue * (1 - interpolationRatio);
  }

  void setCurrentValue(int i, int j, double value) {
    _matrices[_currentMatrixIndex].set(i, j, value);
  }

  double _getLastValue(int i, int j) {
    return _matrices[(_currentMatrixIndex + 1) % _matrices.length].get(i, j);
  }

  void setLastValue(int i, int j, double value) {
    _matrices[(_currentMatrixIndex + 1) % _matrices.length].set(i, j, value);
  }

  void setAllowed(int i, int j, bool allowed) {
    _allowedMask.set(i, j, allowed ? 1 : 0);
  }

  bool hasCellBeenVisited(int i, int j) {
    return _visited.get(i, j) == 1 && _allowedMask.get(i, j) == 1;
  }

  void clear() => clearRight(0);

  void clearRight(int column) {
    for (var i = column; i < width; i++) {
      for (var j = 0; j < height; j++) {
        for (final m in _matrices) {
          m.set(i, j, 0);
        }
        _visited.set(i, j, 0);
        _allowedMask.set(i, j, 1);
      }
    }
  }

  /// Propagate one discrete step — [已确认] Lattice.step formula
  void step() {
    _currentMatrixIndex =
        (_currentMatrixIndex - 1 + _matrices.length) % _matrices.length;

    final matrix0 = _matrices[(_currentMatrixIndex + 0) % _matrices.length];
    final matrix1 = _matrices[(_currentMatrixIndex + 1) % _matrices.length];
    final matrix2 = _matrices[(_currentMatrixIndex + 2) % _matrices.length];
    final w = matrix0.rows;
    final h = matrix0.cols;
    const c2 = WavesIntroConstants.waveSpeedSquared;
    const c = WavesIntroConstants.waveSpeed;

    for (var i = 1; i < w - 1; i++) {
      for (var j = 1; j < h - 1; j++) {
        final neighborSum = matrix1.get(i + 1, j) +
            matrix1.get(i - 1, j) +
            matrix1.get(i, j + 1) +
            matrix1.get(i, j - 1);
        final m1ij = matrix1.get(i, j);
        final value =
            m1ij * 2 - matrix2.get(i, j) + c2 * (neighborSum + m1ij * -4);
        matrix0.set(i, j, value);
        if (value.abs() > lightVisitThreshold) {
          _visited.set(i, j, 1);
        }
      }
    }

    // Absorbing boundaries — [已确认] Lattice.ts edges
    var i = 0;
    for (var j = 0; j < h; j++) {
      final sum = matrix1.get(i, j) +
          matrix1.get(i + 1, j) -
          matrix2.get(i + 1, j) +
          c *
              (matrix1.get(i + 1, j) -
                  matrix1.get(i, j) +
                  matrix2.get(i + 1, j) -
                  matrix2.get(i + 2, j));
      matrix0.set(i, j, sum);
    }

    i = w - 1;
    for (var j = 0; j < h; j++) {
      final sum = matrix1.get(i, j) +
          matrix1.get(i - 1, j) -
          matrix2.get(i - 1, j) +
          c *
              (matrix1.get(i - 1, j) -
                  matrix1.get(i, j) +
                  matrix2.get(i - 1, j) -
                  matrix2.get(i - 2, j));
      matrix0.set(i, j, sum);
    }

    var j = 0;
    for (var ii = 0; ii < w; ii++) {
      final sum = matrix1.get(ii, j) +
          matrix1.get(ii, j + 1) -
          matrix2.get(ii, j + 1) +
          c *
              (matrix1.get(ii, j + 1) -
                  matrix1.get(ii, j) +
                  matrix2.get(ii, j + 1) -
                  matrix2.get(ii, j + 2));
      matrix0.set(ii, j, sum);
    }

    j = h - 1;
    for (var ii = 0; ii < w; ii++) {
      final sum = matrix1.get(ii, j) +
          matrix1.get(ii, j - 1) -
          matrix2.get(ii, j - 1) +
          c *
              (matrix1.get(ii, j - 1) -
                  matrix1.get(ii, j) +
                  matrix2.get(ii, j - 1) -
                  matrix2.get(ii, j - 2));
      matrix0.set(ii, j, sum);
    }
  }
}

class _Matrix {
  _Matrix(this.rows, this.cols, {double fill = 0})
      : _data = List<double>.filled(rows * cols, fill);

  final int rows;
  final int cols;
  final List<double> _data;

  double get(int i, int j) => _data[i * cols + j];

  void set(int i, int j, double v) => _data[i * cols + j] = v;
}

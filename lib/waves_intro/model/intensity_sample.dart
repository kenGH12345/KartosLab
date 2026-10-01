import 'lattice.dart';

/// Time-averaged intensity on the right edge — PhET `IntensitySample.js` @ 31ebfd7.
///
/// intensity ∝ ⟨wave²⟩ over [historyLength] columns; then 2/3-point spatial smooth.
class IntensitySample {
  IntensitySample(this.lattice) {
    clear();
  }

  /// [已确认] IntensitySample.js HISTORY_LENGTH
  static const int historyLength = 90;

  final Lattice lattice;
  final List<List<double>> _history = [];

  List<double> getIntensityValues() {
    if (_history.isEmpty) return const [];
    final len = _history[0].length;
    final intensities = List<double>.filled(len, 0);
    for (var i = 0; i < len; i++) {
      var sum = 0.0;
      for (var k = 0; k < _history.length; k++) {
        final v = _history[k][i];
        sum += v * v; // squared for intensity
      }
      intensities[i] = sum / _history.length;
    }

    final averaged = List<double>.filled(len, 0);
    if (len == 1) {
      averaged[0] = intensities[0];
      return averaged;
    }
    averaged[0] = (intensities[0] + intensities[1]) / 2;
    averaged[len - 1] = (intensities[len - 1] + intensities[len - 2]) / 2;
    for (var i = 1; i < len - 1; i++) {
      averaged[i] =
          (intensities[i - 1] + intensities[i] + intensities[i + 1]) / 3;
    }
    return averaged;
  }

  void clear() {
    _history.clear();
    step();
  }

  void step() {
    _history.add(lattice.getOutputColumn());
    while (_history.length > historyLength) {
      _history.removeAt(0);
    }
  }
}

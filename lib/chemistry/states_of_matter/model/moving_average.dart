/// Simple moving average — PhET MovingAverage.
class MovingAverage {
  MovingAverage(this.size, {double initialValue = 0})
      : _initialValue = initialValue,
        _array = List<double>.filled(size, initialValue) {
    reset();
  }

  final int size;
  double average = 0;
  final double _initialValue;
  final List<double> _array;
  int _currentIndex = 0;
  double _total = 0;

  void addValue(double newValue) {
    final replacedValue = _array[_currentIndex];
    _array[_currentIndex] = newValue;
    _currentIndex = (_currentIndex + 1) % size;
    _total = (_total - replacedValue) + newValue;
    average = _total / size;
  }

  void reset() {
    for (var i = 0; i < size; i++) {
      _array[i] = _initialValue;
    }
    _total = _initialValue * size;
    average = _total / size;
    _currentIndex = 0;
  }
}

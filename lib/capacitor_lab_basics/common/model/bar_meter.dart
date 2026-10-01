/// Bar meter binding — `js/common/model/meter/BarMeter.js`
class BarMeter {
  BarMeter({
    required bool Function() isVisible,
    required void Function(bool) setVisible,
    required double Function() value,
    required void Function() resetVisible,
  })  : _isVisible = isVisible,
        _setVisible = setVisible,
        _value = value,
        _resetVisible = resetVisible;

  final bool Function() _isVisible;
  final void Function(bool) _setVisible;
  final double Function() _value;
  final void Function() _resetVisible;

  bool get visible => _isVisible();
  set visible(bool v) => _setVisible(v);

  double get value => _value();

  /// Resets the visibility property only — `BarMeter.reset`
  void reset() => _resetVisible();
}

import 'hookes_law_numbers.dart';

/// Axon `NumberProperty` subset used by this sim.
///
/// * `set` constrains to [range] before comparing.
/// * Listeners are not called when the constrained value is unchanged (`===`).
/// * `link` runs immediately with the current value (axon `link`).
/// * `addListener` does not run immediately (used for guards and tests).
/// * Re-entrant `set` is allowed. A depth cap only stops a true divergence;
///   source relies on 10-decimal rounding to settle in a few turns.
class NumberProperty {
  NumberProperty(
    double initial, {
    required this.range,
  })  : _initial = initial,
        _value = range.constrain(initial);

  final HookesLawRange range;
  final double _initial;
  double _value;
  int _depth = 0;

  final List<void Function(double value)> _listeners =
      <void Function(double value)>[];

  double get value => _value;

  double get initialValue => _initial;

  set value(double raw) {
    final next = range.constrain(raw);
    if (next == _value) {
      return;
    }
    _value = next;
    _notify();
  }

  void link(void Function(double value) listener) {
    _listeners.add(listener);
    listener(_value);
  }

  void addListener(void Function(double value) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(double value) listener) {
    _listeners.remove(listener);
  }

  void reset() {
    value = _initial;
  }

  void _notify() {
    if (_depth >= 32) {
      throw StateError(
        'NumberProperty updates did not settle (re-entrant loop)',
      );
    }
    _depth++;
    try {
      for (final listener in List<void Function(double)>.of(_listeners)) {
        listener(_value);
      }
    } finally {
      _depth--;
    }
  }
}

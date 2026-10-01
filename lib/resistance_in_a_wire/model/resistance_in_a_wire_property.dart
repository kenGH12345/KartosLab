import 'resistance_in_a_wire_constants.dart';

/// Minimal axon `NumberProperty` subset for Resistance in a Wire.
///
/// * `value=` applies [ResistanceInAWireRange.constrain] (PhET Range path).
/// * Listeners fire only when the constrained value changes.
/// * [link] notifies immediately; [addListener] does not.
class NumberProperty {
  NumberProperty(
    double initial, {
    required this.range,
  })  : _initial = range.constrain(initial),
        _value = range.constrain(initial);

  final ResistanceInAWireRange range;
  final double _initial;
  double _value;

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

  int get listenerCount => _listeners.length;

  void dispose() {
    _listeners.clear();
  }

  void _notify() {
    for (final listener in List<void Function(double)>.of(_listeners)) {
      listener(_value);
    }
  }
}

/// Axon `DerivedProperty` subset — recomputes when any dependency changes.
class DerivedProperty<T> {
  DerivedProperty(
    List<NumberProperty> dependencies,
    this._compute,
  ) : _dependencies = List<NumberProperty>.unmodifiable(dependencies) {
    _value = _compute();
    _depListener = (_) => _recompute();
    for (final dep in _dependencies) {
      dep.addListener(_depListener);
    }
  }

  final List<NumberProperty> _dependencies;
  final T Function() _compute;
  late T _value;
  late final void Function(double) _depListener;

  final List<void Function(T value)> _listeners = <void Function(T value)>[];

  T get value => _value;

  void link(void Function(T value) listener) {
    _listeners.add(listener);
    listener(_value);
  }

  void addListener(void Function(T value) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(T value) listener) {
    _listeners.remove(listener);
  }

  int get listenerCount => _listeners.length;

  void dispose() {
    for (final dep in _dependencies) {
      dep.removeListener(_depListener);
    }
    _listeners.clear();
  }

  void _recompute() {
    final next = _compute();
    if (next == _value) {
      return;
    }
    _value = next;
    for (final listener in List<void Function(T)>.of(_listeners)) {
      listener(_value);
    }
  }
}

/// PhET `dot/Utils.toFixedNumber` → `Number(value.toFixed(n))`.
double toFixedNumber(double value, int decimalPlaces) {
  return double.parse(value.toStringAsFixed(decimalPlaces));
}

/// PhET `dot/Utils.toFixed` → string with exact decimal places after rounding.
String toFixed(double value, int decimalPlaces) {
  return toFixedNumber(value, decimalPlaces).toStringAsFixed(decimalPlaces);
}

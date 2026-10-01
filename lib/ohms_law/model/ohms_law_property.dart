import 'ohms_law_constants.dart';

/// Minimal axon `NumberProperty` subset for Ohm's Law.
///
/// * `value=` applies [OhmsLawRange.constrain] (PhET slider / Range path).
/// * Listeners fire only when the constrained value changes.
/// * [link] notifies immediately; [addListener] does not.
class NumberProperty {
  NumberProperty(
    double initial, {
    required this.range,
  })  : _initial = range.constrain(initial),
        _value = range.constrain(initial);

  final OhmsLawRange range;
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

/// Axon `EnumerationDeprecatedProperty` subset for [CurrentUnit]-like enums.
class EnumProperty<T> {
  EnumProperty(T initial)
      : _initial = initial,
        _value = initial;

  final T _initial;
  T _value;

  final List<void Function(T value)> _listeners = <void Function(T value)>[];

  T get value => _value;

  T get initialValue => _initial;

  set value(T next) {
    if (next == _value) {
      return;
    }
    _value = next;
    for (final listener in List<void Function(T)>.of(_listeners)) {
      listener(_value);
    }
  }

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

  /// Intentionally empty — source `reset()` does **not** reset units.
  void reset() {
    // no-op by design (OhmsLawModel.reset does not call this)
  }

  int get listenerCount => _listeners.length;

  void dispose() {
    _listeners.clear();
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

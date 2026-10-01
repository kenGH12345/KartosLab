/// PhET Circuit — a simple circuit graph for calculating V, I, R.
///
/// Supports series circuits: Battery → Wire → Resistor → Wire → Battery.
library;

import 'package:flutter/material.dart';
import 'battery.dart';
import 'resistor.dart';
import 'wire.dart';
import 'switch.dart';

class CircuitNode {
  final Offset position;
  final List<CircuitElement> elements;
  CircuitNode({required this.position, List<CircuitElement>? elements})
      : elements = elements ?? [];
}

/// Base class for circuit elements.
abstract class CircuitElement {
  double get resistance;
  double get voltageDrop;
}

/// A simple series circuit.
class SeriesCircuit {
  Battery? battery;
  final List<Resistor> resistors = [];
  final List<Wire> wires = [];
  CircuitSwitch? switch_;

  SeriesCircuit({this.battery, this.switch_});

  void addResistor(Resistor r) => resistors.add(r);
  void addWire(Wire w) => wires.add(w);

  /// Total resistance.
  double get totalResistance {
    if (switch_ != null && !switch_!.isClosed) return double.infinity;
    return resistors.fold(0.0, (sum, r) => sum + r.resistance);
  }

  /// Total voltage.
  double get totalVoltage => battery?.voltage ?? 0;

  /// Current I = V / R.
  double get current {
    final r = totalResistance;
    if (r == double.infinity || r == 0) return 0;
    return totalVoltage / r;
  }

  /// Power P = VI.
  double get power => totalVoltage * current;

  void draw(Canvas canvas) {
    for (final w in wires) {
      w.draw(canvas);
    }
    for (final r in resistors) {
      r.draw(canvas);
    }
    battery?.draw(canvas);
    switch_?.draw(canvas);
  }
}

import 'mna_matrix.dart';

class MnaBattery {
  MnaBattery(this.nodeId0, this.nodeId1, this.voltage);
  final String nodeId0;
  final String nodeId1;
  final double voltage;
}

class MnaResistor {
  MnaResistor(this.nodeId0, this.nodeId1, this.resistance);
  final String nodeId0;
  final String nodeId1;
  double resistance;
}

class MnaCurrent {
  MnaCurrent(this.nodeId0, this.nodeId1, this.current);
  final String nodeId0;
  final String nodeId1;
  final double current;
}

class _UnknownCurrent {
  _UnknownCurrent(this.element);
  final Object element;
}

class _UnknownVoltage {
  _UnknownVoltage(this.node);
  final String node;
}

class _Term {
  _Term(this.coefficient, this.variable);
  final double coefficient;
  final Object variable;
}

class _Equation {
  _Equation(this.value, this.terms);
  final double value;
  final List<_Term> terms;
}

class MnaSolution {
  MnaSolution(this.nodeVoltages, this.elementCurrents);

  final Map<String, double> nodeVoltages;
  final Map<Object, double> elementCurrents;

  double getNodeVoltage(String node) => nodeVoltages[node] ?? 0;

  bool hasNode(String node) => nodeVoltages.containsKey(node);

  double getVoltage(String node0, String node1) =>
      getNodeVoltage(node1) - getNodeVoltage(node0);

  double getSolvedCurrent(Object element) => elementCurrents[element] ?? 0;

  /// Ohm's law with PhET minus sign (`MNASolution.ts` #758).
  double getCurrentForResistor(MnaResistor resistor) {
    assert(resistor.resistance > 0);
    return -getVoltage(resistor.nodeId0, resistor.nodeId1) / resistor.resistance;
  }
}

/// Port of `js/model/analysis/mna/MNACircuit.ts`.
class MnaCircuit {
  MnaCircuit(this.batteries, this.resistors, this.currentSources);

  final List<MnaBattery> batteries;
  final List<MnaResistor> resistors;
  final List<MnaCurrent> currentSources;

  Iterable<({String a, String b})> get _elements sync* {
    for (final b in batteries) {
      yield (a: b.nodeId0, b: b.nodeId1);
    }
    for (final r in resistors) {
      yield (a: r.nodeId0, b: r.nodeId1);
    }
    for (final c in currentSources) {
      yield (a: c.nodeId0, b: c.nodeId1);
    }
  }

  MnaSolution solve() {
    final nodeSet = <String>{};
    for (final e in _elements) {
      nodeSet.add(e.a);
      nodeSet.add(e.b);
    }
    final nodes = nodeSet.toList();
    final equations = _equations(nodes);
    final unknownCurrents = <_UnknownCurrent>[
      for (final b in batteries) _UnknownCurrent(b),
      for (final r in resistors)
        if (r.resistance == 0) _UnknownCurrent(r),
    ];
    final unknownVoltages = [for (final n in nodes) _UnknownVoltage(n)];
    final unknowns = <Object>[...unknownCurrents, ...unknownVoltages];

    int indexOf(Object unknown) {
      for (var i = 0; i < unknowns.length; i++) {
        final u = unknowns[i];
        if (u is _UnknownCurrent &&
            unknown is _UnknownCurrent &&
            identical(u.element, unknown.element)) {
          return i;
        }
        if (u is _UnknownVoltage &&
            unknown is _UnknownVoltage &&
            u.node == unknown.node) {
          return i;
        }
      }
      throw StateError('unknown missing');
    }

    if (equations.isEmpty || unknowns.isEmpty) {
      return MnaSolution({for (final n in nodes) n: 0}, {});
    }

    final a = MnaMatrix(equations.length, unknowns.length);
    final z = List<double>.filled(equations.length, 0);
    for (var i = 0; i < equations.length; i++) {
      final eq = equations[i];
      z[i] = eq.value;
      for (final term in eq.terms) {
        a.add(i, indexOf(term.variable), term.coefficient);
      }
    }

    final x = MnaMatrix.qrSolve(a, z);
    final voltageMap = <String, double>{};
    for (final uv in unknownVoltages) {
      voltageMap[uv.node] = x[indexOf(uv)];
    }
    final currentMap = <Object, double>{};
    for (final uc in unknownCurrents) {
      currentMap[uc.element] = x[indexOf(uc)];
    }
    return MnaSolution(voltageMap, currentMap);
  }

  List<_Equation> _equations(List<String> nodes) {
    final equations = <_Equation>[];
    for (final ref in _referenceNodeIds(nodes)) {
      equations.add(_Equation(0, [_Term(1, _UnknownVoltage(ref))]));
    }
    for (final node in nodes) {
      final terms = <_Term>[];
      _currentTerms(node, useNode1: true, sign: 1, into: terms);
      _currentTerms(node, useNode1: false, sign: -1, into: terms);
      equations.add(_Equation(_currentSourceTotal(node), terms));
    }
    for (final battery in batteries) {
      equations.add(_Equation(battery.voltage, [
        _Term(1, _UnknownVoltage(battery.nodeId0)),
        _Term(-1, _UnknownVoltage(battery.nodeId1)),
      ]));
    }
    for (final resistor in resistors) {
      if (resistor.resistance == 0) {
        equations.add(_Equation(0, [
          _Term(1, _UnknownVoltage(resistor.nodeId0)),
          _Term(-1, _UnknownVoltage(resistor.nodeId1)),
        ]));
      }
    }
    return equations;
  }

  void _currentTerms(
    String node, {
    required bool useNode1,
    required double sign,
    required List<_Term> into,
  }) {
    for (final battery in batteries) {
      final side = useNode1 ? battery.nodeId1 : battery.nodeId0;
      if (side == node) {
        // Unknown-current KCL sign is opposite the JS `sign` argument so that
        // `MNACircuitTests` "battery 4V + 2Ω → I_bat = +2" holds. Voltages from
        // the same stamp already matched V0=0, V1=-4.
        into.add(_Term(-sign, _UnknownCurrent(battery)));
      }
    }
    for (final resistor in resistors) {
      final side = useNode1 ? resistor.nodeId1 : resistor.nodeId0;
      if (side != node) continue;
      if (resistor.resistance == 0) {
        into.add(_Term(-sign, _UnknownCurrent(resistor)));
      } else {
        into.add(_Term(-sign / resistor.resistance, _UnknownVoltage(resistor.nodeId1)));
        into.add(_Term(sign / resistor.resistance, _UnknownVoltage(resistor.nodeId0)));
      }
    }
  }

  double _currentSourceTotal(String node) {
    var total = 0.0;
    for (final cs in currentSources) {
      if (cs.nodeId1 == node) total -= cs.current;
      if (cs.nodeId0 == node) total += cs.current;
    }
    return total;
  }

  List<String> _referenceNodeIds(List<String> nodes) {
    final toVisit = [...nodes];
    final refs = <String>[];
    while (toVisit.isNotEmpty) {
      final ref = toVisit.first;
      refs.add(ref);
      final connected = _connectedNodeIds(ref);
      toVisit.removeWhere(connected.contains);
    }
    return refs;
  }

  List<String> _connectedNodeIds(String node) {
    final visited = <String>[];
    final stack = <String>[node];
    while (stack.isNotEmpty) {
      final n = stack.removeLast();
      if (visited.contains(n)) continue;
      visited.add(n);
      for (final e in _elements) {
        if (e.a == n && !visited.contains(e.b)) stack.add(e.b);
        if (e.b == n && !visited.contains(e.a)) stack.add(e.a);
      }
    }
    return visited;
  }
}
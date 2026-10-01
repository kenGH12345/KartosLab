import 'dart:math' as math;

import '../cck_constants.dart';
import 'mna.dart';

class LtaResistiveBattery {
  LtaResistiveBattery(this.id, this.node0, this.node1, this.voltage, this.resistance);
  final int id;
  final String node0;
  final String node1;
  final double voltage;
  final double resistance;
}

class LtaCapacitor {
  LtaCapacitor(
    this.id,
    this.node0,
    this.node1,
    this.voltage,
    this.current,
    this.capacitance,
  );
  final int id;
  final String node0;
  final String node1;
  final double voltage;
  final double current;
  final double capacitance;
  String? capacitorVoltageNode1;
}

class LtaInductor {
  LtaInductor(
    this.id,
    this.node0,
    this.node1,
    this.voltage,
    this.current,
    this.inductance,
  );
  final int id;
  final String node0;
  final String node1;
  final double voltage;
  final double current;
  final double inductance;
  String? inductorVoltageNode1;
}

class LtaCompanionCurrent {
  LtaCompanionCurrent(this.id, this.read);
  final int id;
  final double Function(MnaSolution) read;
}

class LtaSolution {
  LtaSolution(this.mna, this.companions);
  final MnaSolution mna;
  final List<LtaCompanionCurrent> companions;

  double getNodeVoltage(String node) => mna.getNodeVoltage(node);

  bool hasNode(String node) => mna.hasNode(node);

  double getVoltage(String node0, String node1) =>
      getNodeVoltage(node1) - getNodeVoltage(node0);

  double getCurrent(MnaResistor element) {
    if (element.resistance > 0) {
      return mna.getCurrentForResistor(element);
    }
    return mna.getSolvedCurrent(element);
  }

  double getCurrentForCompanion(int id) {
    return companions.firstWhere((c) => c.id == id).read(mna);
  }
}

class LtaState {
  LtaState(this.circuit, this.solution);
  final LtaCircuit circuit;
  final LtaSolution? solution;

  LtaState update(double dt) {
    final solved = circuit.solvePropagate(dt);
    return LtaState(circuit.updateCircuit(solved), solved);
  }

  List<double> characteristicArray() => [
        for (final c in circuit.capacitors) c.current,
        for (final l in circuit.inductors) l.current,
      ];
}

class LtaStateSet {
  LtaStateSet(this.steps);
  final List<({double dt, LtaState state})> steps;

  LtaState get finalState => steps.last.state;

  double timeAverageCurrent(MnaResistor element) {
    var sum = 0.0;
    var t = 0.0;
    for (final s in steps) {
      sum += s.state.solution!.getCurrent(element) * s.dt;
      t += s.dt;
    }
    return sum / t;
  }

  double timeAverageCompanion(int id) {
    var sum = 0.0;
    var t = 0.0;
    for (final s in steps) {
      sum += s.state.solution!.getCurrentForCompanion(id) * s.dt;
      t += s.dt;
    }
    return sum / t;
  }

  double instantaneousCompanion(int id) =>
      finalState.solution!.getCurrentForCompanion(id);

  double instantaneousVoltage(String n0, String n1) =>
      finalState.solution!.getVoltage(n0, n1);
}

/// Port of `LTACircuit.ts` trapezoidal companions + `TimestepSubdivisions.ts`.
class LtaCircuit {
  LtaCircuit(this.resistors, this.batteries, this.capacitors, this.inductors);

  final List<MnaResistor> resistors;
  final List<LtaResistiveBattery> batteries;
  final List<LtaCapacitor> capacitors;
  final List<LtaInductor> inductors;

  LtaSolution solvePropagate(double dt) {
    final companionBatteries = <MnaBattery>[];
    final companionResistors = <MnaResistor>[];
    final companions = <LtaCompanionCurrent>[];
    var synthetic = 0;

    for (final b in batteries) {
      final mid = 'syntheticNode${synthetic++}';
      final idealBattery = MnaBattery(b.node0, mid, b.voltage);
      final idealResistor = MnaResistor(mid, b.node1, b.resistance);
      companionBatteries.add(idealBattery);
      companionResistors.add(idealResistor);
      companions.add(LtaCompanionCurrent(b.id, (s) => s.getSolvedCurrent(idealBattery)));
    }

    for (final c in capacitors) {
      final n1 = 'syntheticNode${synthetic++}';
      final n2 = 'syntheticNode${synthetic++}';
      final companionResistance = dt / 2.0 / c.capacitance;
      final companionVoltage = companionResistance * c.current - c.voltage;
      final battery = MnaBattery(c.node0, n1, companionVoltage);
      final resistor = MnaResistor(n1, n2, companionResistance);
      final resistor2 = MnaResistor(n2, c.node1, CckConstants.capacitorResistance);
      companionBatteries.add(battery);
      companionResistors.add(resistor);
      companionResistors.add(resistor2);
      c.capacitorVoltageNode1 = n2;
      companions.add(LtaCompanionCurrent(c.id, (s) => s.getCurrentForResistor(resistor)));
    }

    for (final l in inductors) {
      final n1 = 'syntheticNode${synthetic++}';
      final n2 = 'syntheticNode${synthetic++}';
      final companionResistance = 2 * l.inductance / dt;
      final companionVoltage = l.voltage + -companionResistance * l.current;
      final battery = MnaBattery(l.node0, n1, companionVoltage);
      final resistor = MnaResistor(n1, n2, companionResistance);
      final added = MnaResistor(n2, l.node1, CckConstants.inductorResistance);
      companionBatteries.add(battery);
      companionResistors.add(resistor);
      companionResistors.add(added);
      l.inductorVoltageNode1 = n2;
      companions.add(LtaCompanionCurrent(l.id, (s) => s.getCurrentForResistor(resistor)));
    }

    final mna = MnaCircuit(
      companionBatteries,
      [...resistors, ...companionResistors],
      const [],
    ).solve();
    return LtaSolution(mna, companions);
  }

  LtaCircuit updateCircuit(LtaSolution solution) {
    final caps = [
      for (final c in capacitors)
        LtaCapacitor(
          c.id,
          c.node0,
          c.node1,
          solution.getVoltage(c.node0, c.capacitorVoltageNode1!),
          solution.getCurrentForCompanion(c.id),
          c.capacitance,
        ),
    ];
    final inds = [
      for (final l in inductors)
        LtaInductor(
          l.id,
          l.node0,
          l.node1,
          solution.getVoltage(l.node0, l.inductorVoltageNode1!),
          solution.getCurrentForCompanion(l.id),
          l.inductance,
        ),
    ];
    return LtaCircuit(resistors, batteries, caps, inds);
  }

  LtaStateSet solveWithSubdivisions(double totalDt) {
    final history = <({double dt, LtaState state})>[];
    var state = LtaState(this, null);
    var elapsed = 0.0;
    var attempted = totalDt;
    while (elapsed < totalDt - 1e-18) {
      final step = _search(state, attempted);
      state = step.state;
      history.add(step);
      elapsed += step.dt;
      attempted = math.min(step.dt * 2, totalDt - elapsed);
    }
    return LtaStateSet(history);
  }

  ({double dt, LtaState state}) _search(LtaState state, double dt) {
    if (dt == CckConstants.pausedDt) {
      return (dt: CckConstants.pausedDt, state: state.update(CckConstants.pausedDt));
    }
    if (dt <= CckConstants.minSubDt) {
      return (dt: CckConstants.minSubDt, state: state.update(CckConstants.minSubDt));
    }
    final a = state.update(dt);
    final b1 = state.update(dt / 2);
    final b2 = b1.update(dt / 2);
    final distance = _euclidean(a.characteristicArray(), b2.characteristicArray());
    if (distance < CckConstants.timestepErrorThreshold) {
      return (dt: dt, state: b2);
    }
    return _search(state, dt / 2);
  }

  static double _euclidean(List<double> x, List<double> y) {
    var s = 0.0;
    for (var i = 0; i < x.length; i++) {
      final d = x[i] - y[i];
      s += d * d;
    }
    return math.sqrt(s);
  }
}
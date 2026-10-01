import '../cck_constants.dart';
import '../model/circuit.dart';
import '../model/elements.dart';
import '../model/vertex.dart';
import 'lta.dart';
import 'mna.dart';

class LinearTransientAnalysis {
  LinearTransientAnalysis._();

  static double clampMagnitude(double value, [double magnitude = 1e20]) {
    if (value.abs() > magnitude) {
      return value.sign * magnitude;
    }
    return value;
  }

  static void solve(CckCircuit circuit, double dt) {
    final ltaBatteries = <LtaResistiveBattery>[];
    final ltaResistors = <MnaResistor>[];
    final ltaCaps = <LtaCapacitor>[];
    final ltaInds = <LtaInductor>[];
    final nonParticipants = <CckElement>[];

    final resistorMap = <MnaResistor, CckElement>{};
    final batteryMap = <int, CckElement>{};
    final capMap = <int, CckCapacitor>{};
    final indMap = <int, CckInductor>{};

    var id = 0;
    for (final el in circuit.elements) {
      if (!circuit.isInLoop(el)) {
        nonParticipants.add(el);
        continue;
      }
      if (!el.traversable) continue;
      if (el is CckBattery || el is CckAcSource) {
        final v = el is CckBattery ? el.voltage : (el as CckAcSource).voltage;
        final r = el is CckBattery
            ? el.internalResistance
            : (el as CckAcSource).internalResistance;
        final adapter = LtaResistiveBattery(
          id++,
          el.start.nodeId,
          el.end.nodeId,
          v,
          r,
        );
        batteryMap[adapter.id] = el;
        ltaBatteries.add(adapter);
      } else if (el is CckCapacitor) {
        final adapter = LtaCapacitor(
          id++,
          el.start.nodeId,
          el.end.nodeId,
          el.mnaVoltageDrop,
          el.mnaCurrent,
          el.capacitance,
        );
        capMap[adapter.id] = el;
        ltaCaps.add(adapter);
      } else if (el is CckInductor) {
        final adapter = LtaInductor(
          id++,
          el.start.nodeId,
          el.end.nodeId,
          el.mnaVoltageDrop,
          el.mnaCurrent,
          el.inductance,
        );
        indMap[adapter.id] = el;
        ltaInds.add(adapter);
      } else {
        final r = el.resistance == 0
            ? CckConstants.minimumResistance
            : el.resistance;
        final adapter = MnaResistor(el.start.nodeId, el.end.nodeId, r);
        resistorMap[adapter] = el;
        ltaResistors.add(adapter);
      }
    }

    final lta = LtaCircuit(ltaResistors, ltaBatteries, ltaCaps, ltaInds);
    final result = lta.solveWithSubdivisions(dt);

    for (final b in ltaBatteries) {
      batteryMap[b.id]!.current = result.timeAverageCompanion(b.id);
    }
    for (final r in ltaResistors) {
      resistorMap[r]!.current = result.timeAverageCurrent(r);
    }
    for (final c in ltaCaps) {
      final cap = capMap[c.id]!;
      cap.current = result.timeAverageCompanion(c.id);
      cap.mnaCurrent = clampMagnitude(result.instantaneousCompanion(c.id));
      cap.mnaVoltageDrop = clampMagnitude(
        result.instantaneousVoltage(c.node0, c.node1),
      );
    }
    for (final l in ltaInds) {
      final ind = indMap[l.id]!;
      ind.current = result.timeAverageCompanion(l.id);
      ind.mnaCurrent = clampMagnitude(result.instantaneousCompanion(l.id));
      ind.mnaVoltageDrop = clampMagnitude(
        result.instantaneousVoltage(l.node0, l.node1),
      );
    }
    for (final el in nonParticipants) {
      el.current = 0;
    }

    final solved = <CckVertex>[];
    final unsolved = <CckVertex>[];
    for (final v in circuit.vertices) {
      final voltage = result.finalState.solution?.hasNode(v.nodeId) == true
          ? result.finalState.solution!.getNodeVoltage(v.nodeId)
          : null;
      if (voltage != null) {
        v.voltage = -voltage;
        solved.add(v);
      } else {
        unsolved.add(v);
      }
    }

    void visitVoltage(CckVertex start, CckElement el, CckVertex end) {
      if (solved.contains(end)) return;
      if (!el.traversable) return;
      final sign = identical(start, el.start) ? 1.0 : -1.0;
      if (el is CckBattery) {
        end.voltage = start.voltage + sign * el.voltage;
      } else if (el is CckAcSource) {
        end.voltage = start.voltage + sign * el.voltage;
      } else if (el is CckCapacitor) {
        end.voltage = start.voltage - sign * el.mnaVoltageDrop;
      } else if (el is CckInductor) {
        end.voltage = start.voltage - sign * el.mnaVoltageDrop;
      } else {
        end.voltage = start.voltage;
      }
      solved.add(end);
    }

    final visited = <CckVertex>[];
    void dfs(
      CckVertex vertex,
      void Function(CckVertex, CckElement, CckVertex) visit,
    ) {
      visited.add(vertex);
      for (final el in circuit.elements) {
        if (!el.contains(vertex) || !el.traversable) continue;
        final opp = el.opposite(vertex);
        if (visited.contains(opp)) continue;
        visit(vertex, el, opp);
        dfs(opp, visit);
      }
    }

    for (final v in [...solved, ...unsolved]) {
      if (!visited.contains(v)) {
        dfs(v, visitVoltage);
      }
    }
  }
}
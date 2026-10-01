import '../cck_constants.dart';
import '../solver/linear_transient_analysis.dart';
import 'cck_vec.dart';
import 'charge.dart';
import 'charge_animator.dart';
import 'elements.dart';
import 'enums.dart';
import 'vertex.dart';

class CckCircuit {
  CckCircuit() {
    chargeAnimator = CckChargeAnimator(this);
  }

  final vertices = <CckVertex>[];
  final elements = <CckElement>[];
  final charges = <CckCharge>[];
  final voltmeters = [CckVoltmeter(), CckVoltmeter()];
  late final CckChargeAnimator chargeAnimator;
  bool seriesAmmeterActive = false;
  bool voltageChartVisible = false;
  bool currentChartVisible = false;
  final voltageChart = <double>[];
  final currentChart = <double>[];

  CckViewType viewType = CckViewType.lifelike;
  CckCurrentType currentType = CckCurrentType.electrons;
  bool showCurrent = true;
  bool showLabels = true;
  bool showValues = false;
  bool stopwatchVisible = false;
  double wireResistivity = CckConstants.wireResistivityMin;
  double sourceResistance = CckConstants.batteryMinimumResistance;
  double time = 0;
  bool dirty = true;
  CckElement? selectedElement;
  CckVertex? selectedVertex;
  int zoomIndex = 1;
  double animatedZoom = 1;
  bool playing = true;
  double stopwatchTime = 0;

  int _nextId = 1;

  int nextId() => _nextId++;

  int _id() => nextId();

  CckVertex addVertex(CckVec pos) {
    final v = CckVertex(_id(), pos);
    vertices.add(v);
    return v;
  }

  T addElement<T extends CckElement>(T element) {
    elements.add(element);
    if (element is CckWire) {
      element.resistivity = wireResistivity;
      element.updateResistance();
    }
    if (element is CckBattery) {
      element.internalResistance = sourceResistance;
    }
    if (element is CckAcSource) {
      element.internalResistance = sourceResistance;
    }
    element.chargeLayoutDirty = true;
    dirty = true;
    return element;
  }

  int countAt(CckVertex vertex) =>
      elements.where((e) => e.contains(vertex)).length;

  List<CckElement> neighbors(CckVertex vertex) =>
      elements.where((e) => e.contains(vertex)).toList();

  List<CckCharge> chargesIn(CckElement element) =>
      charges.where((c) => identical(c.element, element)).toList();

  int countKind(CckElementKind kind, [CckResistorKind? resistorKind]) {
    return elements.where((e) {
      if (e.kind != kind) return false;
      if (resistorKind != null) {
        return e is CckResistor && e.resistorKind == resistorKind;
      }
      return true;
    }).length;
  }

  int stockLimit(CckElementKind kind, [CckResistorKind? resistorKind]) {
    if (kind == CckElementKind.wire) return CckConstants.numberOfWires;
    if (kind == CckElementKind.inductor) return CckConstants.stockInductor;
    if (kind == CckElementKind.resistor &&
        resistorKind != null &&
        resistorKind != CckResistorKind.resistor) {
      return CckConstants.stockHousehold;
    }
    return CckConstants.stockStandard;
  }

  bool canSpawn(CckElementKind kind, [CckResistorKind? resistorKind]) {
    return countKind(kind, resistorKind) < stockLimit(kind, resistorKind);
  }

  /// `Circuit.ts` SNAP_RADIUS merge.
  void connect(CckVertex target, CckVertex old) {
    if (identical(target, old)) return;
    for (final el in elements) {
      el.replaceVertex(old, target);
    }
    vertices.remove(old);
    if (identical(selectedVertex, old)) selectedVertex = target;
    for (final el in elements) {
      el.chargeLayoutDirty = true;
    }
    dirty = true;
  }

  void removeElement(CckElement el) {
    elements.remove(el);
    charges.removeWhere((c) => identical(c.element, el));
    if (identical(selectedElement, el)) selectedElement = null;
    _disposeOrphanVertices();
    dirty = true;
  }

  void _disposeOrphanVertices() {
    vertices.removeWhere((v) {
      final used = elements.any((e) => e.contains(v));
      return !used;
    });
  }

  void clear() {
    elements.clear();
    vertices.clear();
    charges.clear();
    selectedElement = null;
    selectedVertex = null;
    time = 0;
    stopwatchTime = 0;
    dirty = true;
    seriesAmmeterActive = false;
    voltageChartVisible = false;
    currentChartVisible = false;
    voltageChart.clear();
    currentChart.clear();
    for (final m in voltmeters) {
      m.active = false;
      m.reading = null;
    }
  }

  void reset() {
    clear();
    showCurrent = true;
    currentType = CckCurrentType.electrons;
    showLabels = true;
    showValues = false;
    stopwatchVisible = false;
    wireResistivity = CckConstants.wireResistivityMin;
    sourceResistance = CckConstants.batteryMinimumResistance;
    viewType = CckViewType.lifelike;
    zoomIndex = 1;
    animatedZoom = 1;
    playing = true;
    chargeAnimator.reset();
  }

  /// Path from start to end through other traversable elements. `Circuit.isInLoop`.
  bool isInLoop(CckElement element) {
    if (!element.traversable) return false;
    final stack = <CckVertex>[element.start];
    final visited = <CckVertex>[];
    while (stack.isNotEmpty) {
      final vertex = stack.removeLast();
      if (visited.contains(vertex)) continue;
      visited.add(vertex);
      for (final neighbor in elements) {
        if (!neighbor.contains(vertex)) continue;
        if (identical(neighbor, element)) continue;
        if (!neighbor.traversable) continue;
        final opposite = neighbor.opposite(vertex);
        if (identical(opposite, element.end)) return true;
        stack.add(opposite);
      }
    }
    return false;
  }

  CckVertex? dropTarget(CckVertex vertex) {
    CckVertex? best;
    var bestDist = CckConstants.snapRadius;
    for (final candidate in vertices) {
      if (identical(candidate, vertex)) continue;
      if (_adjacent(vertex, candidate)) continue;
      final d = vertex.unsnapped.distanceTo(candidate.pos);
      if (d < bestDist) {
        bestDist = d;
        best = candidate;
      }
    }
    return best;
  }

  bool _adjacent(CckVertex a, CckVertex b) {
    return elements.any((e) => e.contains(a) && e.contains(b));
  }

  void step(double dt) {
    time += dt;
    for (final el in elements) {
      if (el is CckAcSource) {
        el.stepAc(time);
        dirty = true;
      }
      if (el is CckFuse) {
        final before = el.resistance;
        el.stepFuse(dt);
        if (el.resistance != before) dirty = true;
      }
      if (el is CckWire) {
        el.resistivity = wireResistivity;
        el.updateResistance();
      }
      if (el is CckBattery) el.internalResistance = sourceResistance;
      if (el is CckAcSource) el.internalResistance = sourceResistance;
    }
    final hasDynamic = elements.any((e) => e is CckCapacitor || e is CckInductor);
    if (dirty || hasDynamic) {
      LinearTransientAnalysis.solve(this, dt);
      dirty = false;
      for (final el in elements) {
        if (el is CckInductor) {
          bool hasCurrent(CckVertex v) {
            return elements.any((n) {
              if (identical(n, el) || !n.contains(v)) return false;
              return n.current.abs() > 1e-4;
            });
          }
          if (!hasCurrent(el.start) && !hasCurrent(el.end)) {
            el.clearDynamics();
          }
        }
      }
    }
    layoutCharges();
    chargeAnimator.step(dt);
    _updateVoltmeters();
    _sampleCharts();
    if (playing) {
      stopwatchTime += dt;
    }
  }

  void layoutCharges() {
    final desiredSign =
        currentType == CckCurrentType.electrons ? -1 : 1;
    for (final el in elements) {
      if (!el.chargeLayoutDirty &&
          chargesIn(el).every((c) => c.sign == desiredSign)) {
        continue;
      }
      el.chargeLayoutDirty = false;
      charges.removeWhere((c) => identical(c.element, el));
      const offset = CckConstants.chargeSeparation / 2;
      final last = el.chargePathLength - offset;
      final first = offset;
      final lengthForCharges = last - first;
      if (lengthForCharges <= 0) continue;
      final n = (lengthForCharges / CckConstants.chargeSeparation).ceil();
      final spacing = n <= 1 ? 0.0 : lengthForCharges / (n - 1);
      for (var i = 0; i < n; i++) {
        final pos = n == 1
            ? (first + last) / 2
            : i * spacing + offset;
        final charge = CckCharge(
          element: el,
          distance: pos,
          sign: desiredSign,
        )..updatePositionAndAngle();
        charges.add(charge);
      }
    }
  }

  void _updateVoltmeters() {
    for (final meter in voltmeters) {
      if (!meter.active) {
        meter.reading = null;
        continue;
      }
      final red = _probeConnection(meter.redProbe);
      final black = _probeConnection(meter.blackProbe);
      if (red == null || black == null) {
        meter.reading = null;
        continue;
      }
      if (!_electricallyConnected(red.vertex, black.vertex)) {
        meter.reading = null;
        continue;
      }
      meter.reading = red.voltage - black.voltage;
    }
  }

  _ProbeHit? _probeConnection(CckVec probe) {
    CckVertex? bestVertex;
    var bestD = CckConstants.solderRadius;
    for (final v in vertices) {
      final d = probe.distanceTo(v.pos);
      if (d <= bestD) {
        bestD = d;
        bestVertex = v;
      }
    }
    if (bestVertex != null) {
      return _ProbeHit(bestVertex, bestVertex.voltage);
    }
    for (final el in elements) {
      if (!el.isMetallic && el is! CckWire) continue;
      final start = el.start.pos;
      final end = el.end.pos;
      final seg = end - start;
      final len2 = seg.x * seg.x + seg.y * seg.y;
      if (len2 == 0) continue;
      final t = ((probe - start).dot(seg) / len2).clamp(0.0, 1.0);
      final closest = start.lerp(end, t);
      if (probe.distanceTo(closest) > CckConstants.wireLifelikeWidth) continue;
      final voltage = el.start.voltage + (el.end.voltage - el.start.voltage) * t;
      return _ProbeHit(el.start, voltage);
    }
    return null;
  }

  bool _electricallyConnected(CckVertex a, CckVertex b) {
    if (identical(a, b)) return true;
    final stack = <CckVertex>[a];
    final seen = <CckVertex>{};
    while (stack.isNotEmpty) {
      final v = stack.removeLast();
      if (!seen.add(v)) continue;
      if (identical(v, b)) return true;
      for (final el in neighbors(v)) {
        if (!el.traversable) continue;
        stack.add(el.opposite(v));
      }
    }
    return false;
  }

  void _sampleCharts() {
    if (voltageChartVisible) {
      final v = voltmeters.first.reading ?? 0;
      voltageChart.add(v);
      if (voltageChart.length > 240) voltageChart.removeAt(0);
    }
    if (currentChartVisible) {
      var i = 0.0;
      for (final el in elements) {
        if (el is CckSeriesAmmeter) i = el.current;
      }
      currentChart.add(i);
      if (currentChart.length > 240) currentChart.removeAt(0);
    }
  }
}

class _ProbeHit {
  _ProbeHit(this.vertex, this.voltage);
  final CckVertex vertex;
  final double voltage;
}
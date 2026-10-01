import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import '../cck_constants.dart';
import '../model/cck_vec.dart';
import '../model/circuit.dart';
import '../model/elements.dart';
import '../model/enums.dart';
import '../model/vertex.dart';

class CckAcController extends ChangeNotifier {
  CckAcController() : circuit = CckCircuit();

  final CckCircuit circuit;
  double? _zoomFrom;
  double? _zoomTo;
  double _zoomT = 1;
  CckVec? toolboxOrigin;
  CckVec? toolboxSize;

  double get zoomScale => circuit.animatedZoom;

  void tick(double wallDt) {
    if (wallDt >= CckConstants.maxDt) return;
    if (_zoomFrom != null && _zoomTo != null && _zoomT < 1) {
      final oldT = _zoomT;
      _zoomT = math.min(1, _zoomT + wallDt / CckConstants.zoomAnimationTime);
      final e0 = _cubic(_zoomT) - _cubic(oldT);
      circuit.animatedZoom += e0 * (_zoomTo! - _zoomFrom!);
      if (_zoomT >= 1) {
        circuit.animatedZoom = _zoomTo!;
        _zoomFrom = null;
        _zoomTo = null;
      }
    }
    for (final el in circuit.elements) {
      if (el is CckFuse && el.sparkProgress >= 0) {
        el.sparkProgress += wallDt / CckConstants.fuseSparkDuration;
        if (el.sparkProgress >= 1) el.sparkProgress = -1;
      }
    }
    circuit.step(circuit.playing ? 1 / 60 : CckConstants.pausedDt);
    notifyListeners();
  }

  void stepOnce() {
    for (var i = 0; i < 6; i++) {
      circuit.step(1 / 60);
    }
    notifyListeners();
  }

  void setPlaying(bool playing) {
    circuit.playing = playing;
    notifyListeners();
  }

  void setZoomIndex(int index) {
    index = index.clamp(0, CckConstants.zoomScales.length - 1);
    circuit.zoomIndex = index;
    _zoomFrom = circuit.animatedZoom;
    _zoomTo = CckConstants.zoomScales[index];
    _zoomT = 0;
    notifyListeners();
  }

  /// `Easing.CUBIC_IN_OUT` used by `ZoomAnimation.ts`.
  static double _cubic(double t) {
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  void reset() {
    circuit.reset();
    _zoomFrom = null;
    _zoomTo = null;
    _zoomT = 1;
    notifyListeners();
  }

  CckElement? spawn(
    CckElementKind kind,
    CckVec center, {
    CckResistorKind resistorKind = CckResistorKind.resistor,
  }) {
    if (!circuit.canSpawn(kind, kind == CckElementKind.resistor ? resistorKind : null)) {
      return null;
    }
    final length = _lengthFor(kind, resistorKind);
    final start = circuit.addVertex(CckVec(center.x - length / 2, center.y));
    final end = circuit.addVertex(CckVec(center.x + length / 2, center.y));
    final CckElement el = switch (kind) {
      CckElementKind.wire => CckWire(id: circuit.nextId(), start: start, end: end),
      CckElementKind.battery =>
        CckBattery(id: circuit.nextId(), start: start, end: end),
      CckElementKind.acSource =>
        CckAcSource(id: circuit.nextId(), start: start, end: end),
      CckElementKind.resistor => CckResistor(
          id: circuit.nextId(),
          start: start,
          end: end,
          resistorKind: resistorKind,
        ),
      CckElementKind.lightBulb =>
        CckLightBulb(id: circuit.nextId(), start: start, end: end),
      CckElementKind.capacitor =>
        CckCapacitor(id: circuit.nextId(), start: start, end: end),
      CckElementKind.inductor =>
        CckInductor(id: circuit.nextId(), start: start, end: end),
      CckElementKind.switch_ =>
        CckSwitch(id: circuit.nextId(), start: start, end: end),
      CckElementKind.fuse => CckFuse(id: circuit.nextId(), start: start, end: end),
      CckElementKind.seriesAmmeter =>
        CckSeriesAmmeter(id: circuit.nextId(), start: start, end: end),
    };
    circuit.addElement(el);
    notifyListeners();
    return el;
  }

  static double _lengthFor(CckElementKind kind, CckResistorKind rk) {
    return switch (kind) {
      CckElementKind.wire => CckConstants.wireLength,
      CckElementKind.battery => CckConstants.batteryLength,
      CckElementKind.acSource => CckConstants.acVoltageLength,
      CckElementKind.lightBulb => CckConstants.resistorLength,
      CckElementKind.capacitor => CckConstants.capacitorLength,
      CckElementKind.inductor => CckConstants.inductorLength,
      CckElementKind.switch_ => CckConstants.switchLength,
      CckElementKind.fuse => CckConstants.fuseLength,
      CckElementKind.seriesAmmeter => CckConstants.seriesAmmeterLength,
      CckElementKind.resistor => switch (rk) {
          CckResistorKind.resistor => CckConstants.resistorLength,
          CckResistorKind.coin => CckConstants.coinLength,
          CckResistorKind.paperClip => CckConstants.paperClipLength,
          CckResistorKind.pencil ||
          CckResistorKind.thinPencil =>
            CckConstants.pencilLength,
          CckResistorKind.eraser => CckConstants.eraserLength,
          CckResistorKind.dollarBill => CckConstants.dollarBillLength,
        },
    };
  }

  void moveVertex(CckVertex vertex, CckVec pos) {
    vertex.unsnappedX = pos.x;
    vertex.unsnappedY = pos.y;
    vertex.x = pos.x;
    vertex.y = pos.y;
    for (final el in circuit.neighbors(vertex)) {
      el.chargeLayoutDirty = true;
      if (el is CckWire) el.updateResistance();
    }
    circuit.dirty = true;
    notifyListeners();
  }

  void moveElement(CckElement el, CckVec delta) {
    moveVertex(el.start, CckVec(el.start.x + delta.x, el.start.y + delta.y));
    moveVertex(el.end, CckVec(el.end.x + delta.x, el.end.y + delta.y));
  }

  bool dropVertex(CckVertex vertex) {
    if (_returnedToToolbox(vertex.pos)) {
      final owners = circuit.neighbors(vertex).toList();
      for (final el in owners) {
        circuit.removeElement(el);
      }
      notifyListeners();
      return true;
    }
    final target = circuit.dropTarget(vertex);
    if (target != null) {
      circuit.connect(target, vertex);
    }
    circuit.dirty = true;
    notifyListeners();
    return false;
  }

  bool dropElement(CckElement el) {
    if (_returnedToToolbox(el.center)) {
      circuit.removeElement(el);
      notifyListeners();
      return true;
    }
    dropVertex(el.start);
    dropVertex(el.end);
    return false;
  }

  bool _returnedToToolbox(CckVec pos) {
    final origin = toolboxOrigin;
    final size = toolboxSize;
    if (origin == null || size == null) return false;
    return pos.x >= origin.x &&
        pos.x <= origin.x + size.x &&
        pos.y >= origin.y &&
        pos.y <= origin.y + size.y;
  }

  void selectElement(CckElement? el) {
    circuit.selectedElement = el;
    circuit.selectedVertex = null;
    notifyListeners();
  }

  void selectVertex(CckVertex? v) {
    circuit.selectedVertex = v;
    circuit.selectedElement = null;
    notifyListeners();
  }

  void deleteSelected() {
    final el = circuit.selectedElement;
    if (el != null) circuit.removeElement(el);
    notifyListeners();
  }

  void toggleSwitch(CckSwitch sw) {
    sw.closed = !sw.closed;
    circuit.dirty = true;
    notifyListeners();
  }

  void setViewType(CckViewType t) {
    circuit.viewType = t;
    notifyListeners();
  }

  void setCurrentType(CckCurrentType t) {
    circuit.currentType = t;
    for (final el in circuit.elements) {
      el.chargeLayoutDirty = true;
    }
    circuit.layoutCharges();
    notifyListeners();
  }

  void setShowCurrent(bool v) {
    circuit.showCurrent = v;
    notifyListeners();
  }

  void setShowLabels(bool v) {
    circuit.showLabels = v;
    notifyListeners();
  }

  void setShowValues(bool v) {
    circuit.showValues = v;
    notifyListeners();
  }

  void setStopwatchVisible(bool v) {
    circuit.stopwatchVisible = v;
    notifyListeners();
  }

  void setWireResistivity(double v) {
    circuit.wireResistivity = v;
    circuit.dirty = true;
    notifyListeners();
  }

  void setSourceResistance(double v) {
    circuit.sourceResistance = v;
    circuit.dirty = true;
    notifyListeners();
  }

  void toggleVoltmeter([int index = 0]) {
    final m = circuit.voltmeters[index];
    m.active = !m.active;
    notifyListeners();
  }

  void toggleVoltageChart() {
    circuit.voltageChartVisible = !circuit.voltageChartVisible;
    notifyListeners();
  }

  void toggleCurrentChart() {
    circuit.currentChartVisible = !circuit.currentChartVisible;
    notifyListeners();
  }

  void setBatteryVoltage(CckBattery el, double v) {
    el.voltage = v;
    circuit.dirty = true;
    notifyListeners();
  }

  void setAcVoltage(CckAcSource el, double v) {
    el.maximumVoltage = v;
    circuit.dirty = true;
    notifyListeners();
  }

  void setAcFrequency(CckAcSource el, double v) {
    el.frequency = v;
    notifyListeners();
  }

  void setResistance(CckResistor el, double v) {
    el.resistanceValue = v;
    circuit.dirty = true;
    notifyListeners();
  }

  void setBulbResistance(CckLightBulb el, double v) {
    el.resistanceValue = v;
    circuit.dirty = true;
    notifyListeners();
  }

  void setCapacitance(CckCapacitor el, double v) {
    el.capacitance = v;
    circuit.dirty = true;
    notifyListeners();
  }

  void setInductance(CckInductor el, double v) {
    el.inductance = v;
    circuit.dirty = true;
    notifyListeners();
  }

  void setFuseRating(CckFuse el, double v) {
    el.currentRating = v;
    if (!el.tripped) el.resetFuse();
    circuit.dirty = true;
    notifyListeners();
  }
}

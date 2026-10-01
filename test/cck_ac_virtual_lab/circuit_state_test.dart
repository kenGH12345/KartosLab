import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/cck_ac_virtual_lab/cck_constants.dart';
import 'package:kratos/cck_ac_virtual_lab/controller/cck_ac_controller.dart';
import 'package:kratos/cck_ac_virtual_lab/model/cck_vec.dart';
import 'package:kratos/cck_ac_virtual_lab/model/circuit.dart';
import 'package:kratos/cck_ac_virtual_lab/model/elements.dart';
import 'package:kratos/cck_ac_virtual_lab/model/enums.dart';
import 'package:kratos/cck_ac_virtual_lab/model/vertex.dart';

void main() {
  test('wire resistance R = rho L / A with L = viewPx * 0.0005', () {
    final start = CckVertex(1, const CckVec(0, 0));
    final end = CckVertex(2, const CckVec(100, 0));
    final wire = CckWire(id: 1, start: start, end: end);
    wire.resistivity = 1e-10;
    wire.updateResistance();
    final expected = math.max(
      CckConstants.minimumWireResistance,
      1e-10 * 100 * 0.0005 / 5e-4,
    );
    expect(wire.resistance, closeTo(expected, 1e-18));
  });

  test('AC voltage formula matches ACVoltage.step', () {
    final ac = CckAcSource(
      id: 1,
      start: CckVertex(1, CckVec.zero),
      end: CckVertex(2, const CckVec(68, 0)),
    );
    ac.maximumVoltage = 9;
    ac.frequency = 0.5;
    ac.phaseDeg = 0;
    ac.stepAc(0.5);
    expect(ac.voltage, closeTo(-9 * math.sin(2 * math.pi * 0.5 * 0.5), 1e-12));
  });

  test('fuse resistance 0.06/rating and trips when |I| > rating', () {
    final fuse = CckFuse(
      id: 1,
      start: CckVertex(1, CckVec.zero),
      end: CckVertex(2, const CckVec(110, 0)),
    );
    expect(fuse.resistance, closeTo(0.06 / 4, 1e-12));
    fuse.current = 5;
    fuse.stepFuse(1 / 60);
    expect(fuse.tripped, isTrue);
    expect(fuse.resistance, CckConstants.maxResistance);
    expect(fuse.traversable, isFalse);
  });

  test('light bulb brightness formula', () {
    final bulb = CckLightBulb(
      id: 1,
      start: CckVertex(1, CckVec.zero),
      end: CckVertex(2, const CckVec(110, 0)),
    );
    bulb.current = 0;
    expect(bulb.computeBrightness(), 0);
    bulb.current = 10;
    expect(bulb.computeBrightness(), inInclusiveRange(0, 1));
  });

  test('reset clears topology and restores defaults', () {
    final c = CckAcController();
    c.spawn(CckElementKind.battery, const CckVec(200, 200));
    expect(c.circuit.elements, isNotEmpty);
    c.reset();
    expect(c.circuit.elements, isEmpty);
    expect(c.circuit.vertices, isEmpty);
    expect(c.circuit.playing, isTrue);
    expect(c.circuit.animatedZoom, 1);
    expect(c.circuit.showCurrent, isTrue);
  });

  test('series battery+resistor loop solves ~Ohm current', () {
    final circuit = CckCircuit();
    final v0 = circuit.addVertex(const CckVec(0, 0));
    final v1 = circuit.addVertex(const CckVec(102, 0));
    final v2 = circuit.addVertex(const CckVec(212, 0));
    final v3 = circuit.addVertex(const CckVec(0, 80));
    final bat = circuit.addElement(CckBattery(id: 1, start: v0, end: v1));
    circuit.addElement(CckResistor(id: 2, start: v1, end: v2));
    circuit.addElement(CckWire(id: 3, start: v2, end: v3));
    circuit.addElement(CckWire(id: 4, start: v3, end: v0));
    circuit.step(1 / 60);
    expect(bat.current.abs(), greaterThan(0.1));
  });

  test('open switch is not in a loop', () {
    final circuit = CckCircuit();
    final a = circuit.addVertex(CckVec.zero);
    final b = circuit.addVertex(const CckVec(112, 0));
    final sw = circuit.addElement(CckSwitch(id: 1, start: a, end: b));
    expect(circuit.isInLoop(sw), isFalse);
    sw.closed = true;
    expect(sw.traversable, isTrue);
  });

  test('household resistor kinds match ResistorType.ts', () {
    CckResistor r(CckResistorKind k) => CckResistor(
          id: 1,
          start: CckVertex(1, CckVec.zero),
          end: CckVertex(2, const CckVec(100, 0)),
          resistorKind: k,
        );
    expect(r(CckResistorKind.coin).resistance, 0);
    expect(r(CckResistorKind.pencil).resistance, 25);
    expect(r(CckResistorKind.thinPencil).resistance, 50);
    expect(r(CckResistorKind.eraser).resistance, 1e6);
  });

  test('tick ignores dt >= 0.5 and uses 1/60 while playing', () {
    final c = CckAcController();
    c.tick(0.6);
    expect(c.circuit.time, 0);
    c.tick(1 / 60);
    expect(c.circuit.time, closeTo(1 / 60, 1e-12));
    c.setPlaying(false);
    final t = c.circuit.time;
    c.tick(1 / 60);
    expect(c.circuit.time - t, closeTo(CckConstants.pausedDt, 1e-15));
  });

  test('dropVertex snaps within SNAP_RADIUS=30', () {
    final c = CckAcController();
    final a = c.circuit.addVertex(const CckVec(0, 0));
    final b = c.circuit.addVertex(const CckVec(100, 0));
    c.circuit.addElement(CckWire(id: 1, start: a, end: b));
    final c0 = c.circuit.addVertex(const CckVec(200, 80));
    final d = c.circuit.addVertex(const CckVec(118, 6));
    c.circuit.addElement(CckResistor(id: 2, start: c0, end: d));
    d.unsnappedX = 118;
    d.unsnappedY = 6;
    c.dropVertex(d);
    expect(c.circuit.vertices.contains(d), isFalse);
    expect(c.circuit.elements.last.end, b);
  });

  test('series RC capacitor voltage approaches battery (trapezoidal companion)', () {
    final circuit = CckCircuit();
    final v0 = circuit.addVertex(const CckVec(0, 0));
    final v1 = circuit.addVertex(const CckVec(102, 0));
    final v2 = circuit.addVertex(const CckVec(212, 0));
    final v3 = circuit.addVertex(const CckVec(0, 80));
    circuit.addElement(CckBattery(id: 1, start: v0, end: v1)..voltage = 9);
    circuit.addElement(CckResistor(id: 2, start: v1, end: v2)..resistanceValue = 10);
    final cap = circuit.addElement(
      CckCapacitor(id: 3, start: v2, end: v3)..capacitance = 0.1,
    );
    circuit.addElement(CckWire(id: 4, start: v3, end: v0));
    for (var i = 0; i < 180; i++) {
      circuit.step(1 / 60);
    }
    expect(cap.mnaVoltageDrop.abs(), greaterThan(5));
    expect(cap.mnaVoltageDrop.abs(), lessThan(10));
  });

  test('AC source length is AC_VOLTAGE_LENGTH not battery length', () {
    final c = CckAcController();
    final el = c.spawn(CckElementKind.acSource, const CckVec(200, 200));
    expect(el, isNotNull);
    expect(el!.length, CckConstants.acVoltageLength);
  });
}
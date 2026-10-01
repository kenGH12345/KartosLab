import 'dart:math' as math;
import 'dart:ui' show Offset, Path, Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/capacitance/model/capacitance_model.dart';
import 'package:kratos/capacitor_lab_basics/clb_constants.dart';
import 'package:kratos/capacitor_lab_basics/common/model/circuit_state.dart';
import 'package:kratos/capacitor_lab_basics/common/model/clb_model.dart';
import 'package:kratos/capacitor_lab_basics/common/model/probe_target.dart';
import 'package:kratos/capacitor_lab_basics/common/model/voltmeter.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/circuit_geometry.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/path_intersection.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/probe_hit_tester.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/voltmeter_shape_creator.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/yaw_pitch_mvt.dart';
import 'package:kratos/capacitor_lab_basics/common/widgets/voltmeter_drag_layer.dart';

/// Tip path whose tip-shape origin is at the given model point.
Path tipAtModel(YawPitchMvt mvt, double modelX, double modelY) {
  final vm = Voltmeter(isVisible: () => true)
    ..positiveProbeX = modelX - VoltmeterShapeCreator.tipOffsetX
    ..positiveProbeY = modelY - VoltmeterShapeCreator.tipOffsetY;
  return VoltmeterShapeCreator(vm, mvt).getPositiveProbeTipShape();
}

void main() {
  group('body_drag_does_not_move_probe', () {
    test('body move leaves absolute probe coords unchanged', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final mvt = YawPitchMvt();
      placeVoltmeterFromToolbox(
        voltmeter: model.voltmeter,
        mvt: mvt,
        bodyTopLeftView: const Offset(400, 200),
      );
      final vm = model.voltmeter;
      final px = vm.positiveProbeX;
      final py = vm.positiveProbeY;
      final nx = vm.negativeProbeX;
      final ny = vm.negativeProbeY;

      vm.bodyX += 0.01;
      vm.bodyY -= 0.005;

      expect(vm.positiveProbeX, px);
      expect(vm.positiveProbeY, py);
      expect(vm.negativeProbeX, nx);
      expect(vm.negativeProbeY, ny);
    });
  });

  group('probe_grab_offset / toolbox extract', () {
    test(
        'placeVoltmeterFromToolbox moves body only; probes stay absolute',
        () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final mvt = YawPitchMvt();
      final vm = model.voltmeter;
      // Simulate probes left away from defaults (PhET persists across hide/show).
      vm.positiveProbeX = 0.02;
      vm.positiveProbeY = 0.01;
      vm.negativeProbeX = 0.03;
      vm.negativeProbeY = 0.012;

      placeVoltmeterFromToolbox(
        voltmeter: vm,
        mvt: mvt,
        bodyTopLeftView: const Offset(100, 80),
      );
      expect(vm.positiveProbeX, 0.02);
      expect(vm.positiveProbeY, 0.01);
      expect(vm.negativeProbeX, 0.03);
      expect(vm.negativeProbeY, 0.012);

      final bodyView = mvt.modelToViewXYZ(vm.bodyX, vm.bodyY, 0);
      expect(bodyView.dx, closeTo(100, 1e-6));
      expect(bodyView.dy, closeTo(80, 1e-6));
    });

    test('voltmeterBodyTopLeftCenteredOn centers body under pointer', () {
      const pointer = Offset(400, 300);
      final tl = voltmeterBodyTopLeftCenteredOn(pointer);
      expect(tl.dx + VoltmeterDragLayer.bodyW / 2, closeTo(pointer.dx, 1e-9));
      expect(tl.dy + VoltmeterDragLayer.bodyH / 2, closeTo(pointer.dy, 1e-9));
    });

    test('independent probe delta does not move body or other probe', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final vm = model.voltmeter;
      final bodyX = vm.bodyX;
      final bodyY = vm.bodyY;
      final nx = vm.negativeProbeX;
      final ny = vm.negativeProbeY;

      vm.positiveProbeX += 0.002;
      vm.positiveProbeY += 0.001;

      expect(vm.bodyX, bodyX);
      expect(vm.bodyY, bodyY);
      expect(vm.negativeProbeX, nx);
      expect(vm.negativeProbeY, ny);
    });
  });

  group('red_black_sign_reversal', () {
    test('plate targets reverse sign; no abs()', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final c = model.circuit;
      c.battery.voltage = 1.5;
      final vm = model.voltmeter;

      vm.positiveProbeTarget = ProbeTarget.capacitorTop;
      vm.negativeProbeTarget = ProbeTarget.capacitorBottom;
      final forward = vm.computeValue(c)!;
      expect(forward, closeTo(1.5, 1e-12));
      expect(forward, greaterThan(0));

      vm.positiveProbeTarget = ProbeTarget.capacitorBottom;
      vm.negativeProbeTarget = ProbeTarget.capacitorTop;
      final reverse = vm.computeValue(c)!;
      expect(reverse, closeTo(-1.5, 1e-12));
      expect(reverse, -forward);
    });
  });

  group('same_node_measurement', () {
    test('same CircuitPosition after ProbeTarget map → 0', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final c = model.circuit;
      final vm = model.voltmeter;

      vm.positiveProbeTarget = ProbeTarget.capacitorTop;
      vm.negativeProbeTarget = ProbeTarget.wireCapacitorTop;
      expect(
        vm.positiveProbeTarget.circuitPosition,
        vm.negativeProbeTarget.circuitPosition,
      );
      expect(vm.computeValue(c), 0);

      vm.positiveProbeTarget = ProbeTarget.wireBatteryBottom;
      vm.negativeProbeTarget = ProbeTarget.wireBatteryBottom;
      expect(vm.computeValue(c), 0);
    });
  });

  group('invalid_probe_region', () {
    test('empty space tip → NONE → measuredVoltage null', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      model.setVoltmeterVisible(true);
      final mvt = YawPitchMvt();
      final tester = ProbeHitTester(circuit: model.circuit, mvt: mvt);
      expect(tester.getProbeTarget(tipAtModel(mvt, 0.2, 0.2)), ProbeTarget.none);

      final vm = model.voltmeter;
      vm.positiveProbeX = 0.2;
      vm.positiveProbeY = 0.2;
      vm.negativeProbeX = 0.21;
      vm.negativeProbeY = 0.21;
      model.refreshVoltmeterReading();
      expect(vm.measuredVoltage, isNull);
    });
  });

  group('switch_contact_boundary', () {
    test('open circuit: switch tip circle is NOT SWITCH_CONNECTION', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final c = model.circuit;
      c.setCircuitConnection(CircuitState.openCircuit);
      final mvt = YawPitchMvt();
      final tester = ProbeHitTester(circuit: c, mvt: mvt);
      final cfg = c.config;
      final hinge = CircuitGeometry.switchHingePoint(isTop: true, config: cfg);
      final tipEnd = CircuitGeometry.switchTipEndFromAngle(
        hinge: hinge,
        angle: c.topSwitchAngle,
      );
      expect(
        tester.getProbeTarget(tipAtModel(mvt, tipEnd.x, tipEnd.y)),
        isNot(ProbeTarget.switchConnectionTop),
      );
    });

    test('closed: connection circle = SWITCH_CONNECTION; mid-lever = WIRE_SWITCH',
        () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final c = model.circuit;
      expect(c.circuitConnection, CircuitState.batteryConnected);
      final mvt = YawPitchMvt();
      final tester = ProbeHitTester(circuit: c, mvt: mvt);
      final cfg = c.config;
      final hinge = CircuitGeometry.switchHingePoint(isTop: true, config: cfg);
      // PhET CircuitSwitch.contacts: circle at hinge + dir * SWITCH_WIRE_LENGTH
      // (full length). Visual blade tip uses 0.9× length — different ProbeTarget.
      final angle = c.topSwitchAngle;
      final connX =
          hinge.x + ClbConstants.switchWireLength * math.cos(angle);
      final connY =
          hinge.y + ClbConstants.switchWireLength * math.sin(angle);

      expect(
        tester.getProbeTarget(tipAtModel(mvt, connX, connY)),
        ProbeTarget.switchConnectionTop,
      );

      final tipEnd = CircuitGeometry.switchTipEndFromAngle(
        hinge: hinge,
        angle: angle,
      );
      final midX = (hinge.x + tipEnd.x) / 2;
      final midY = (hinge.y + tipEnd.y) / 2;
      final leverTarget =
          tester.getProbeTarget(tipAtModel(mvt, midX, midY));
      expect(leverTarget, ProbeTarget.wireSwitchTop);
      expect(leverTarget, isNot(ProbeTarget.switchConnectionTop));
      // Both collapse to same CircuitPosition rail
      expect(
        leverTarget.circuitPosition,
        ProbeTarget.switchConnectionTop.circuitPosition,
      );
    });
  });

  group('wire_contact_boundary', () {
    test('tip on segment capsule hits wire; far offset misses', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final c = model.circuit;
      final mvt = YawPitchMvt();
      final tester = ProbeHitTester(circuit: c, mvt: mvt);
      final segs = CircuitGeometry.capacitanceSegments(
        battery: c.battery,
        capacitor: c.capacitor,
        config: c.config,
        connection: c.circuitConnection,
        topAngle: c.topSwitchAngle,
        bottomAngle: c.bottomSwitchAngle,
      );
      final seg = segs[4];
      final midX = (seg.start.x + seg.end.x) / 2;
      final midY = (seg.start.y + seg.end.y) / 2;
      expect(
        tester.getProbeTarget(tipAtModel(mvt, midX, midY)),
        ProbeTarget.wireCapacitorTop,
      );

      expect(
        tester.getProbeTarget(tipAtModel(mvt, midX + 0.05, midY + 0.05)),
        ProbeTarget.none,
      );

      final a = mvt.modelToViewShapeXY(seg.start.x, seg.start.y);
      final b = mvt.modelToViewShapeXY(seg.end.x, seg.end.y);
      final capsule = PathIntersection.wireSegmentCapsule(a, b);
      final bounds = capsule.getBounds();
      expect(bounds.width, lessThan(200));
      expect(bounds.height, lessThan(200));
      final len = math.sqrt(
        (b.dx - a.dx) * (b.dx - a.dx) + (b.dy - a.dy) * (b.dy - a.dy),
      );
      expect(len, greaterThan(0));
    });
  });

  group('battery_terminal_measurement', () {
    test('top terminal + bottom wire → signed V; voltage follows circuit', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      model.setVoltmeterVisible(true);
      final c = model.circuit;
      c.battery.voltage = 0.8;
      final vm = model.voltmeter;

      vm.positiveProbeTarget = ProbeTarget.batteryTopTerminal;
      vm.negativeProbeTarget = ProbeTarget.wireBatteryBottom;
      expect(vm.computeValue(c), closeTo(0.8, 1e-12));

      vm.positiveProbeTarget = ProbeTarget.wireBatteryBottom;
      vm.negativeProbeTarget = ProbeTarget.batteryTopTerminal;
      expect(vm.computeValue(c), closeTo(-0.8, 1e-12));

      // voltage setter refreshes tip hits; re-assert targets after change
      c.battery.voltage = 1.1;
      vm.positiveProbeTarget = ProbeTarget.capacitorTop;
      vm.negativeProbeTarget = ProbeTarget.capacitorBottom;
      expect(vm.computeValue(c), closeTo(1.1, 1e-12));

      c.battery.voltage = 0.4;
      vm.positiveProbeTarget = ProbeTarget.capacitorTop;
      vm.negativeProbeTarget = ProbeTarget.capacitorBottom;
      expect(vm.computeValue(c), closeTo(0.4, 1e-12));
    });
  });

  group('toolbox_return', () {
    test(
        'eroded body ∩ toolbox hides only; probes persist; rim-only does not',
        () {
      final model = CapacitanceModel(shared: ClbSharedState());
      final mvt = YawPitchMvt();
      model.setVoltmeterVisible(true);
      placeVoltmeterFromToolbox(
        voltmeter: model.voltmeter,
        mvt: mvt,
        bodyTopLeftView: const Offset(50, 50),
      );
      model.voltmeter.positiveProbeX = 0.01;
      model.voltmeter.measuredVoltage = 1.0;

      final bodyW = VoltmeterDragLayer.bodyW;
      final bodyH = VoltmeterDragLayer.bodyH;
      final dock = Rect.fromLTWH(40, 40, bodyW + 40, bodyH + 40);
      expect(
        maybeReturnVoltmeterToToolbox(
          model: model,
          mvt: mvt,
          toolboxBounds: dock,
        ),
        isTrue,
      );
      expect(model.voltmeterVisible, isFalse);
      // PhET: return does not reset probes — only Reset All does.
      expect(model.voltmeter.positiveProbeX, 0.01);

      model.setVoltmeterVisible(true);
      placeVoltmeterFromToolbox(
        voltmeter: model.voltmeter,
        mvt: mvt,
        bodyTopLeftView: const Offset(200, 200),
      );
      // Far rim: even with +36 halo, eroded body must not dock.
      final rimOnly = Rect.fromLTWH(200 - 50, 200, 15, 20);
      expect(
        maybeReturnVoltmeterToToolbox(
          model: model,
          mvt: mvt,
          toolboxBounds: rimOnly,
        ),
        isFalse,
      );
      expect(model.voltmeterVisible, isTrue);
    });
  });

  group('live_reading_refresh', () {
    test('tip on plates + battery change refreshes measuredVoltage', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      model.setVoltmeterVisible(true);
      final c = model.circuit;
      c.battery.voltage = 1.2;
      final cap = c.capacitor;
      final top = cap.getTopConnectionPoint();
      final bottom = cap.getBottomConnectionPoint();
      final vm = model.voltmeter;

      vm.positiveProbeX = top.x - VoltmeterShapeCreator.tipOffsetX;
      vm.positiveProbeY = top.y - VoltmeterShapeCreator.tipOffsetY;
      vm.negativeProbeX = bottom.x - VoltmeterShapeCreator.tipOffsetX;
      vm.negativeProbeY = bottom.y - VoltmeterShapeCreator.tipOffsetY;
      model.refreshVoltmeterReading();
      expect(vm.measuredVoltage, closeTo(1.2, 1e-6));

      c.battery.voltage = 0.5;
      model.refreshVoltmeterReading();
      expect(vm.measuredVoltage, closeTo(0.5, 1e-6));

      vm.positiveProbeX = 0.2;
      vm.positiveProbeY = 0.2;
      model.notifyViewChanged();
      expect(vm.measuredVoltage, isNull);
    });
  });

  group('probe_tip_measurement_source', () {
    test('measurement tip uses PROBE_TIP_OFFSET polygon, not asset center', () {
      expect(VoltmeterShapeCreator.tipOffsetX, 0.00018);
      expect(VoltmeterShapeCreator.tipOffsetY, 0.00025);
      expect(VoltmeterShapeCreator.tipWidth, 0.0003);
      expect(VoltmeterShapeCreator.tipHeight, 0.0013);

      final model = CapacitanceModel(shared: ClbSharedState());
      final mvt = YawPitchMvt();
      final vm = model.voltmeter;
      final shapes = VoltmeterShapeCreator(vm, mvt);
      final tipBounds = shapes.getPositiveProbeTipShape().getBounds();
      final tipOrigin = mvt.modelToViewXYZ(
        vm.positiveProbeX + VoltmeterShapeCreator.tipOffsetX,
        vm.positiveProbeY + VoltmeterShapeCreator.tipOffsetY,
        0,
      );
      expect(
        (Offset(tipBounds.center.dx, tipBounds.center.dy) - tipOrigin)
            .distance,
        lessThan(20),
      );
    });
  });
}

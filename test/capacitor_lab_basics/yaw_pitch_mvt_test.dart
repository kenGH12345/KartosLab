import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/clb_constants.dart';
import 'package:kratos/capacitor_lab_basics/common/model/battery.dart';
import 'package:kratos/capacitor_lab_basics/common/model/capacitor.dart';
import 'package:kratos/capacitor_lab_basics/common/model/circuit_config.dart';
import 'package:kratos/capacitor_lab_basics/common/painters/battery_painter.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/box_shape_creator.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/circuit_geometry.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/yaw_pitch_mvt.dart';

void main() {
  group('YawPitchMvt', () {
    test('z=0 maps as uniform scale', () {
      final m = YawPitchMvt();
      final p = m.modelToViewPosition(0.0065, 0.030, 0);
      expect(p.dx, closeTo(0.0065 * ClbConstants.mvtScale, 1e-9));
      expect(p.dy, closeTo(0.030 * ClbConstants.mvtScale, 1e-9));
    });

    test('z contribution matches setPolar(z*sin(pitch), yaw)', () {
      final m = YawPitchMvt();
      const z = 0.01;
      final r = z * math.sin(ClbConstants.mvtPitchRad);
      final p = m.modelToViewPosition(0, 0, z);
      expect(
        p.dx,
        closeTo(r * math.cos(ClbConstants.mvtYawRad) * ClbConstants.mvtScale, 1e-9),
      );
      expect(
        p.dy,
        closeTo(r * math.sin(ClbConstants.mvtYawRad) * ClbConstants.mvtScale, 1e-9),
      );
    });

    test('modelToViewXYZ matches modelToViewPosition', () {
      final m = YawPitchMvt();
      final a = m.modelToViewPosition(0.01, 0.02, 0.003);
      final b = m.modelToViewXYZ(0.01, 0.02, 0.003);
      expect(b.dx, closeTo(a.dx, 1e-12));
      expect(b.dy, closeTo(a.dy, 1e-12));
    });

    test('modelToViewDelta subtracts origin', () {
      final m = YawPitchMvt();
      final origin = m.modelToViewXYZ(0, 0, 0);
      final abs = m.modelToViewXYZ(0.001, 0.002, 0.003);
      final delta = m.modelToViewDeltaXYZ(0.001, 0.002, 0.003);
      expect(delta.dx, closeTo(abs.dx - origin.dx, 1e-12));
      expect(delta.dy, closeTo(abs.dy - origin.dy, 1e-12));
    });

    test('viewToModelXY is inverse scale with z=0', () {
      final m = YawPitchMvt();
      final v = m.modelToViewXYZ(0.0065, 0.030, 0);
      final back = m.viewToModelXY(v.dx, v.dy);
      expect(back.x, closeTo(0.0065, 1e-12));
      expect(back.y, closeTo(0.030, 1e-12));
      expect(back.z, 0);
    });
  });

  group('BoxShapeCreator', () {
    test('top face points are centered and foreshortened', () {
      final m = YawPitchMvt();
      final boxes = BoxShapeCreator(m);
      const w = 0.014;
      const d = 0.014;
      final face = boxes.createTopFace(0, 0, 0, w, 0.0005, d);

      final p0 = m.modelToViewXYZ(-w / 2, 0, d / 2);
      final p1 = m.modelToViewXYZ(w / 2, 0, d / 2);
      final p2 = m.modelToViewXYZ(w / 2, 0, -d / 2);
      final p3 = m.modelToViewXYZ(-w / 2, 0, -d / 2);

      expect(face.p0.dx, closeTo(p0.dx, 1e-9));
      expect(face.p0.dy, closeTo(p0.dy, 1e-9));
      expect(face.p1.dx, closeTo(p1.dx, 1e-9));
      expect(face.p2.dx, closeTo(p2.dx, 1e-9));
      expect(face.p3.dx, closeTo(p3.dx, 1e-9));
    });

    test('front face drops by height in +y', () {
      final m = YawPitchMvt();
      final boxes = BoxShapeCreator(m);
      const h = 0.0005;
      final face = boxes.createFrontFace(0, 0, 0, 0.01, h, 0.01);
      expect(face.p2.dy - face.p1.dy, closeTo(h * ClbConstants.mvtScale, 1e-9));
      expect(face.p3.dy - face.p0.dy, closeTo(h * ClbConstants.mvtScale, 1e-9));
    });
  });

  group('CircuitGeometry BATTERY_CONNECTED', () {
    test('top hinge uses plateSeparationMax + switchYSpacing', () {
      final cfg = CircuitConfig.capacitanceScreen();
      final hinge = CircuitGeometry.switchHingePoint(isTop: true, config: cfg);
      final yOffset =
          ClbConstants.plateSeparationMax + ClbConstants.switchYSpacing;
      expect(hinge.x, closeTo(ClbConstants.batteryX + cfg.capacitorXSpacing, 1e-12));
      expect(hinge.y, closeTo(ClbConstants.batteryY - yOffset, 1e-12));
      expect(hinge.z, 0);
    });

    test('battery→switch top start uses positive terminal offset', () {
      final battery = Battery(voltage: 1.0);
      expect(battery.isPositiveTerminalUp, isTrue);
      final cfg = CircuitConfig.capacitanceScreen();
      final hinge = CircuitGeometry.switchHingePoint(isTop: true, config: cfg);
      final conn =
          CircuitGeometry.batteryConnectedPoint(hinge: hinge, isTop: true);
      final segs = CircuitGeometry.batteryToSwitchSegments(
        battery: battery,
        batteryConnection: conn,
        isTop: true,
      );
      expect(segs, hasLength(2));
      expect(segs[0].start.x, closeTo(battery.x, 1e-12));
      expect(
        segs[0].start.y,
        closeTo(battery.y + ClbConstants.batteryPositiveTerminalYOffset, 1e-12),
      );
      expect(segs[0].end.x, closeTo(battery.x, 1e-12));
      expect(segs[0].end.y, closeTo(conn.y, 1e-12));
      expect(
        segs[1].end.x,
        closeTo(conn.x + ClbConstants.batteryToSwitchSeparationOffsetX, 1e-12),
      );
    });

    test('capacitor top wire starts at getTopConnectionPoint', () {
      final cap = Capacitor();
      final cfg = CircuitConfig.capacitanceScreen();
      final hinge = CircuitGeometry.switchHingePoint(isTop: true, config: cfg);
      final seg = CircuitGeometry.capacitorToSwitchSegment(
        capacitor: cap,
        hinge: hinge,
        isTop: true,
      );
      final top = cap.getTopConnectionPoint();
      expect(seg.start.x, closeTo(top.x, 1e-12));
      expect(seg.start.y, closeTo(top.y, 1e-12));
      expect(seg.end.x, closeTo(hinge.x, 1e-12));
      expect(seg.end.y, closeTo(hinge.y, 1e-12));
    });

    test('full capacitance segment count is 8', () {
      final segs = CircuitGeometry.capacitanceBatteryConnectedSegments(
        battery: Battery(),
        capacitor: Capacitor(),
      );
      expect(segs, hasLength(8));
    });
  });

  group('BatteryPainter bounds scale', () {
    test('scaled width = 2 * mainRadius * 0.30', () {
      expect(BatteryPainter.unscaledWidth, closeTo(2 * 158, 1e-9));
      expect(
        BatteryPainter.scaledWidth(),
        closeTo(2 * 158 * ClbConstants.batteryGraphicScale, 1e-9),
      );
      expect(BatteryPainter.scaledWidth(), closeTo(94.8, 1e-9));
    });

    test('positive-up unscaled height includes terminal', () {
      expect(
        BatteryPainter.unscaledHeightPositiveUp,
        closeTo(511 + 26, 1e-9),
      );
      expect(
        BatteryPainter.scaledHeightPositiveUp(),
        closeTo((511 + 26) * 0.30, 1e-9),
      );
    });
  });
}

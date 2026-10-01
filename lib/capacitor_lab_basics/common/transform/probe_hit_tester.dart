import 'dart:math' as math;
import 'dart:ui' show Offset, Path, Rect;

import '../../clb_constants.dart';
import '../model/circuit_state.dart';
import '../model/light_bulb.dart';
import '../model/parallel_circuit.dart';
import '../model/probe_target.dart';
import 'box_shape_creator.dart';
import 'circuit_geometry.dart';
import 'path_intersection.dart';
import 'yaw_pitch_mvt.dart';

/// Probe tip → circuit component hit order — `ParallelCircuit.getProbeTarget`
class ProbeHitTester {
  ProbeHitTester({
    required this.circuit,
    required this.mvt,
  }) : boxes = BoxShapeCreator(mvt);

  final ParallelCircuit circuit;
  final YawPitchMvt mvt;
  final BoxShapeCreator boxes;

  ProbeTarget getProbeTarget(Path tip) {
    final bulb = circuit.lightBulb;
    if (bulb != null) {
      if (_intersectsBulbTopBase(tip, bulb)) {
        return ProbeTarget.lightBulbTop;
      }
      if (_intersectsBulbBottomBase(tip, bulb)) {
        return ProbeTarget.lightBulbBottom;
      }
    }

    if (_batteryContacts(tip)) {
      return ProbeTarget.batteryTopTerminal;
    }

    if (_switchConnectionContacts(tip, isTop: true)) {
      return ProbeTarget.switchConnectionTop;
    }
    if (_switchConnectionContacts(tip, isTop: false)) {
      return ProbeTarget.switchConnectionBottom;
    }

    if (_capacitorContacts(tip, isTop: true)) {
      return ProbeTarget.capacitorTop;
    }
    if (_capacitorContacts(tip, isTop: false)) {
      return ProbeTarget.capacitorBottom;
    }

    if (_touchesSwitchWire(tip, isTop: true)) {
      return ProbeTarget.wireSwitchTop;
    }
    if (_touchesSwitchWire(tip, isTop: false)) {
      return ProbeTarget.wireSwitchBottom;
    }

    if (_touchesWireSegments(tip, _capacitorTopSegments())) {
      return ProbeTarget.wireCapacitorTop;
    }
    if (_touchesWireSegments(tip, _capacitorBottomSegments())) {
      return ProbeTarget.wireCapacitorBottom;
    }
    if (_touchesWireSegments(tip, _batteryTopSegments())) {
      return ProbeTarget.wireBatteryTop;
    }
    if (_touchesWireSegments(tip, _batteryBottomSegments())) {
      return ProbeTarget.wireBatteryBottom;
    }
    if (circuit.lightBulb != null) {
      if (_touchesWireSegments(tip, _lightBulbTopSegments())) {
        return ProbeTarget.wireLightBulbTop;
      }
      if (_touchesWireSegments(tip, _lightBulbBottomSegments())) {
        return ProbeTarget.wireLightBulbBottom;
      }
    }

    return ProbeTarget.none;
  }

  bool _intersectsBulbTopBase(Path tip, LightBulb bulb) {
    // LightBulbShapeCreator.createTopBaseShape — model rect → scale-only view
    const dx = 0.0013;
    const dy = 0.00175;
    const w = 0.00225;
    const h = 0.0035;
    final left = (bulb.x - dx) * mvt.scale;
    final top = (bulb.y - dy) * mvt.scale;
    final shape = Path()
      ..addRect(Rect.fromLTWH(left, top, w * mvt.scale, h * mvt.scale));
    return PathIntersection.intersects(tip, shape);
  }

  bool _intersectsBulbBottomBase(Path tip, LightBulb bulb) {
    final smallLeft = bulb.x - 0.00343;
    final smallRight = smallLeft + 0.00063;
    final smallTop = bulb.y - 0.00113;
    final smallBottom = smallTop + 0.00228;
    final midY = (smallTop + smallBottom) / 2;
    Offset v(double x, double y) => Offset(x * mvt.scale, y * mvt.scale);
    final shape = Path()
      ..moveTo(v(smallLeft, midY).dx, v(smallLeft, midY).dy)
      ..cubicTo(
        v(smallLeft, smallTop * 0.8 + smallBottom * 0.2).dx,
        v(smallLeft, smallTop * 0.8 + smallBottom * 0.2).dy,
        v(smallLeft * 0.6 + smallRight * 0.4, smallTop * 0.85 + smallBottom * 0.15)
            .dx,
        v(smallLeft * 0.6 + smallRight * 0.4, smallTop * 0.85 + smallBottom * 0.15)
            .dy,
        v(smallRight, smallTop).dx,
        v(smallRight, smallTop).dy,
      )
      ..lineTo(v(smallRight, smallBottom).dx, v(smallRight, smallBottom).dy)
      ..cubicTo(
        v(smallLeft * 0.6 + smallRight * 0.4, smallBottom * 0.85 + smallTop * 0.15)
            .dx,
        v(smallLeft * 0.6 + smallRight * 0.4, smallBottom * 0.85 + smallTop * 0.15)
            .dy,
        v(smallLeft, smallBottom * 0.8 + smallTop * 0.2).dx,
        v(smallLeft, smallBottom * 0.8 + smallTop * 0.2).dy,
        v(smallLeft, midY).dx,
        v(smallLeft, midY).dy,
      )
      ..close();
    return PathIntersection.intersects(tip, shape);
  }

  /// Top-terminal ellipse (+ short side band) from BatteryPainter geometry.
  bool _batteryContacts(Path tip) {
    final bat = circuit.battery;
    final center = mvt.modelToViewXYZ(bat.x, bat.y, bat.z);
    final scale = ClbConstants.batteryGraphicScale;
    final isPositiveDown = !bat.isPositiveTerminalUp;
    const mainH = ClbConstants.batteryMainHeight;
    const posTermH = ClbConstants.batteryPositiveTerminalHeight;
    final terminalTopY = isPositiveDown ? 0.0 : -posTermH;
    final localCenterY = (terminalTopY + mainH) / 2;
    final terminalRadius = isPositiveDown
        ? ClbConstants.batteryNegativeTerminalRadius
        : ClbConstants.batteryPositiveTerminalRadius;
    final termCy = center.dy + (terminalTopY - localCenterY) * scale;
    final bodyTopCy = center.dy + (0 - localCenterY) * scale;
    final rx = terminalRadius * scale;
    final ry = terminalRadius * ClbConstants.batteryPerspectiveRatio * scale;

    final shape = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(center.dx, termCy),
        width: rx * 2,
        height: ry * 2,
      ));
    if (!isPositiveDown) {
      final top = math.min(termCy, bodyTopCy);
      final bottom = math.max(termCy, bodyTopCy);
      shape.addRect(Rect.fromLTRB(center.dx - rx, top, center.dx + rx, bottom));
    }
    return PathIntersection.intersects(tip, shape);
  }

  /// `CircuitSwitch.contacts` — circle at connection tip when connected.
  bool _switchConnectionContacts(Path tip, {required bool isTop}) {
    final connection = circuit.circuitConnection;
    if (connection == CircuitState.switchInTransit ||
        connection == CircuitState.openCircuit) {
      return false;
    }
    final cfg = circuit.config;
    final hinge = CircuitGeometry.switchHingePoint(isTop: isTop, config: cfg);
    final angle = isTop ? circuit.topSwitchAngle : circuit.bottomSwitchAngle;
    final end = hinge.plusXYZ(
      ClbConstants.switchWireLength * math.cos(angle),
      ClbConstants.switchWireLength * math.sin(angle),
      0,
    );
    final dx = end.x - hinge.x;
    final dy = end.y - hinge.y;
    final mag = math.sqrt(dx * dx + dy * dy);
    if (mag < 1e-12) return false;
    final point = mvt.modelToViewXYZ(
      hinge.x + dx / mag * ClbConstants.switchWireLength,
      hinge.y + dy / mag * ClbConstants.switchWireLength,
      hinge.z,
    );
    final circle = Path()
      ..addOval(Rect.fromCircle(
        center: point,
        radius: ClbConstants.connectionPointRadius,
      ));
    return PathIntersection.intersects(tip, circle);
  }

  /// Union of top/front/right faces — `Capacitor.contacts`
  bool _capacitorContacts(Path tip, {required bool isTop}) {
    final cap = circuit.capacitor;
    final sizeW = cap.plateWidth;
    final sizeH = cap.plateHeight;
    final sizeD = cap.plateDepth;
    final y = isTop
        ? cap.getTopConnectionPoint().y
        : cap.y + cap.plateSeparation / 2;
    final top = boxes.createTopFace(cap.x, y, cap.z, sizeW, sizeH, sizeD);
    final front = boxes.createFrontFace(cap.x, y, cap.z, sizeW, sizeH, sizeD);
    final right =
        boxes.createRightSideFace(cap.x, y, cap.z, sizeW, sizeH, sizeD);
    final shape = Path()
      ..addPath(top.toPath(), Offset.zero)
      ..addPath(front.toPath(), Offset.zero)
      ..addPath(right.toPath(), Offset.zero);
    if (PathIntersection.intersects(tip, shape)) return true;
    return _switchConnectionContacts(tip, isTop: isTop);
  }

  bool _touchesSwitchWire(Path tip, {required bool isTop}) {
    final segs = circuitSegments();
    final seg = isTop ? segs[6] : segs[7];
    return _touchesWireSegments(tip, [seg]);
  }

  List<ModelWireSegment> _batteryTopSegments() =>
      circuitSegments().sublist(0, 2);

  List<ModelWireSegment> _batteryBottomSegments() =>
      circuitSegments().sublist(2, 4);

  List<ModelWireSegment> _capacitorTopSegments() => [circuitSegments()[4]];

  List<ModelWireSegment> _capacitorBottomSegments() => [circuitSegments()[5]];

  List<ModelWireSegment> _lightBulbTopSegments() =>
      circuitSegments().sublist(8, 10);

  List<ModelWireSegment> _lightBulbBottomSegments() =>
      circuitSegments().sublist(10, 12);

  List<ModelWireSegment> circuitSegments() {
    final bulb = circuit.lightBulb;
    if (bulb != null) {
      return CircuitGeometry.lightBulbScreenSegments(
        battery: circuit.battery,
        capacitor: circuit.capacitor,
        lightBulb: bulb,
        config: circuit.config,
        connection: circuit.circuitConnection,
        topAngle: circuit.topSwitchAngle,
        bottomAngle: circuit.bottomSwitchAngle,
      );
    }
    return CircuitGeometry.capacitanceSegments(
      battery: circuit.battery,
      capacitor: circuit.capacitor,
      config: circuit.config,
      connection: circuit.circuitConnection,
      topAngle: circuit.topSwitchAngle,
      bottomAngle: circuit.bottomSwitchAngle,
    );
  }

  bool _touchesWireSegments(Path tip, List<ModelWireSegment> segs) {
    for (final s in segs) {
      final a = mvt.modelToViewShapeXY(s.start.x, s.start.y);
      final b = mvt.modelToViewShapeXY(s.end.x, s.end.y);
      final capsule = PathIntersection.wireSegmentCapsule(a, b);
      if (PathIntersection.intersects(tip, capsule)) return true;
    }
    return false;
  }
}

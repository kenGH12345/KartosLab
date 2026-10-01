import 'dart:math' as math;

import '../../clb_constants.dart';
import '../model/battery.dart';
import '../model/capacitor.dart';
import '../model/circuit_config.dart';
import '../model/circuit_state.dart';
import '../model/light_bulb.dart';
import 'yaw_pitch_mvt.dart';

/// Straight wire segment in model XYZ (meters).
class ModelWireSegment {
  const ModelWireSegment(this.start, this.end);

  final ModelVector3 start;
  final ModelVector3 end;
}

/// Static wire / switch geometry for Capacitance screen —
/// BATTERY_CONNECTED pose.
///
/// Formulas from:
/// - `CircuitSwitch.js` hinge + connection points
/// - `BatteryToSwitchWire.js`
/// - `CapacitorToSwitchWire.js` + `WireSegment` component factories
/// - Switch tip: `CircuitSwitch` angleProperty → 0.9 × SWITCH_WIRE_LENGTH
class CircuitGeometry {
  CircuitGeometry._();

  /// Hinge point — `CircuitSwitch.getSwitchHingePoint`
  ///
  /// x = BATTERY.x + capacitorXSpacing
  /// yOffset = PLATE_SEPARATION_MAX + SWITCH_Y_SPACING
  /// top: y = BATTERY.y − yOffset; bottom: y = BATTERY.y + yOffset
  static ModelVector3 switchHingePoint({
    required bool isTop,
    required CircuitConfig config,
  }) {
    final yOffset =
        ClbConstants.plateSeparationMax + ClbConstants.switchYSpacing;
    final y = isTop
        ? ClbConstants.batteryY - yOffset
        : ClbConstants.batteryY + yOffset;
    return ModelVector3(
      ClbConstants.batteryX + config.capacitorXSpacing,
      y,
      ClbConstants.batteryZ,
    );
  }

  /// Connection points around hinge — `CircuitSwitch.getSwitchConnections`
  ///
  /// SWITCH_ANGLE = π/4; length = SWITCH_WIRE_LENGTH
  /// dx = length·sin(θ); dy = length·cos(θ)
  /// Top BATTERY_CONNECTED (left): hinge − (dx, dy)
  /// Bottom BATTERY_CONNECTED (left): hinge + (−dx, dy)
  static ModelVector3 batteryConnectedPoint({
    required ModelVector3 hinge,
    required bool isTop,
  }) {
    final length = ClbConstants.switchWireLength;
    final dx = length * math.sin(ClbConstants.switchAngleRad);
    final dy = length * math.cos(ClbConstants.switchAngleRad);
    if (isTop) {
      return hinge.plusXYZ(-dx, -dy, 0);
    }
    return hinge.plusXYZ(-dx, dy, 0);
  }

  /// OPEN_CIRCUIT connection — vertical from hinge.
  /// Top: hinge − (0, length); Bottom: hinge + (0, length)
  static ModelVector3 openCircuitPoint({
    required ModelVector3 hinge,
    required bool isTop,
  }) {
    final length = ClbConstants.switchWireLength;
    if (isTop) {
      return hinge.plusXYZ(0, -length, 0);
    }
    return hinge.plusXYZ(0, length, 0);
  }

  /// LIGHT_BULB_CONNECTED (right) — Capacitance screen cannot snap here.
  static ModelVector3 lightBulbConnectedPoint({
    required ModelVector3 hinge,
    required bool isTop,
  }) {
    final length = ClbConstants.switchWireLength;
    final dx = length * math.sin(ClbConstants.switchAngleRad);
    final dy = length * math.cos(ClbConstants.switchAngleRad);
    if (isTop) {
      return hinge.plusXYZ(dx, -dy, 0);
    }
    return hinge.plusXYZ(dx, dy, 0);
  }

  /// Steady-state switch angle for a connection — `CircuitSwitch` defaults.
  static double angleForConnection({
    required CircuitState connection,
    required bool isTop,
  }) {
    switch (connection) {
      case CircuitState.batteryConnected:
        return isTop ? -math.pi * 3 / 4 : math.pi * 3 / 4;
      case CircuitState.openCircuit:
        return isTop ? -math.pi / 2 : math.pi / 2;
      case CircuitState.lightBulbConnected:
        return isTop ? -math.pi / 4 : math.pi / 4;
      case CircuitState.switchInTransit:
        return isTop ? -math.pi * 3 / 4 : math.pi * 3 / 4;
    }
  }

  /// Capacitance angle limits (no bulb) — `CircuitSwitch` Range.
  /// With bulb: right limit ±π/4 (LIGHT_BULB).
  static double leftLimitAngle({required bool isTop}) =>
      isTop ? -math.pi * 3 / 4 : math.pi * 3 / 4;

  static double rightLimitAngle({
    required bool isTop,
    bool hasLightBulb = false,
  }) {
    if (hasLightBulb) {
      return isTop ? -math.pi / 4 : math.pi / 4;
    }
    return isTop ? -math.pi / 2 : math.pi / 2;
  }

  /// Snap abs(angle) → connection — `CircuitSwitchDragHandler`
  ///
  /// 2-state (Capacitance): right→OPEN, left→BATTERY
  /// 3-state (Light Bulb): right→LIGHT_BULB, center→OPEN, left→BATTERY
  static CircuitState snapConnectionFromAbsAngle(
    double absAngle, {
    bool threeState = false,
  }) {
    const rightMax = 3 * math.pi / 8;
    const centerMax = 5 * math.pi / 8;
    if (absAngle <= rightMax) {
      return threeState
          ? CircuitState.lightBulbConnected
          : CircuitState.openCircuit;
    }
    if (absAngle <= centerMax) {
      return CircuitState.openCircuit;
    }
    return CircuitState.batteryConnected;
  }

  /// Connection point for a steady state (not in-transit).
  static ModelVector3 connectionPoint({
    required ModelVector3 hinge,
    required bool isTop,
    required CircuitState connection,
  }) {
    switch (connection) {
      case CircuitState.batteryConnected:
        return batteryConnectedPoint(hinge: hinge, isTop: isTop);
      case CircuitState.openCircuit:
        return openCircuitPoint(hinge: hinge, isTop: isTop);
      case CircuitState.lightBulbConnected:
        return lightBulbConnectedPoint(hinge: hinge, isTop: isTop);
      case CircuitState.switchInTransit:
        return batteryConnectedPoint(hinge: hinge, isTop: isTop);
    }
  }

  /// Switch tip end (shortened) — angle from hinge→connection,
  /// magnitude 0.9 × SWITCH_WIRE_LENGTH.
  static ModelVector3 switchTipEnd({
    required ModelVector3 hinge,
    required ModelVector3 connection,
  }) {
    final dx = connection.x - hinge.x;
    final dy = connection.y - hinge.y;
    final angle = math.atan2(dy, dx);
    return switchTipEndFromAngle(hinge: hinge, angle: angle);
  }

  /// Tip from polar angle — `CircuitSwitch.angleProperty` link.
  static ModelVector3 switchTipEndFromAngle({
    required ModelVector3 hinge,
    required double angle,
  }) {
    final r = ClbConstants.switchWireTipScale * ClbConstants.switchWireLength;
    return hinge.plusXYZ(r * math.cos(angle), r * math.sin(angle), 0);
  }

  /// Battery → switch segments for one side — `BatteryToSwitchWire.js`
  ///
  /// Vertical: terminal → leftCorner (battery.x, connection.y)
  /// Horizontal: leftCorner → connection + (−0.0006, 0, 0)
  static List<ModelWireSegment> batteryToSwitchSegments({
    required Battery battery,
    required ModelVector3 batteryConnection,
    required bool isTop,
  }) {
    final horizontalY = batteryConnection.y;
    final leftCorner = ModelVector3(battery.x, horizontalY, 0);

    final ModelVector3 start;
    if (isTop) {
      // BatteryToSwitchWire.js:36-37
      start = ModelVector3(
        battery.x,
        battery.y + battery.topTerminalYOffset,
        0,
      );
    } else {
      // BatteryToSwitchWire.js:50-51 (+ bottomOffset 0.00065)
      start = ModelVector3(
        battery.x,
        battery.y +
            battery.bottomTerminalYOffset +
            ClbConstants.batteryBottomWireProbeOffset,
        0,
      );
    }

    final end = batteryConnection.plusXYZ(
      ClbConstants.batteryToSwitchSeparationOffsetX,
      0,
      0,
    );

    return [
      ModelWireSegment(start, leftCorner),
      ModelWireSegment(leftCorner, end),
    ];
  }

  /// Capacitor → switch hinge — `CapacitorToSwitchWire.js` /
  /// `WireSegment.createComponentTop/BottomWireSegment`
  static ModelWireSegment capacitorToSwitchSegment({
    required Capacitor capacitor,
    required ModelVector3 hinge,
    required bool isTop,
  }) {
    final conn = isTop
        ? capacitor.getTopConnectionPoint()
        : capacitor.getBottomConnectionPoint();
    return ModelWireSegment(
      ModelVector3(conn.x, conn.y, conn.z),
      hinge,
    );
  }

  /// All static segments for Capacitance BATTERY_CONNECTED.
  static List<ModelWireSegment> capacitanceBatteryConnectedSegments({
    required Battery battery,
    required Capacitor capacitor,
    CircuitConfig? config,
  }) {
    return capacitanceSegments(
      battery: battery,
      capacitor: capacitor,
      config: config,
      connection: CircuitState.batteryConnected,
    );
  }

  /// Capacitance wire segments for current switch pose.
  ///
  /// Battery↔switch contacts stay at BATTERY connection points; only the
  /// switch blade (hinge→tip) follows [topAngle]/[bottomAngle] / OPEN tip.
  static List<ModelWireSegment> capacitanceSegments({
    required Battery battery,
    required Capacitor capacitor,
    CircuitConfig? config,
    required CircuitState connection,
    double? topAngle,
    double? bottomAngle,
  }) {
    final cfg = config ?? CircuitConfig.capacitanceScreen();
    assert(
      cfg.circuitConnections.contains(CircuitState.batteryConnected),
    );

    final topHinge = switchHingePoint(isTop: true, config: cfg);
    final bottomHinge = switchHingePoint(isTop: false, config: cfg);
    // Fixed battery contact pads (not the moving tip)
    final topBat = batteryConnectedPoint(hinge: topHinge, isTop: true);
    final bottomBat =
        batteryConnectedPoint(hinge: bottomHinge, isTop: false);

    final topTipAngle = topAngle ??
        angleForConnection(connection: connection, isTop: true);
    final bottomTipAngle = bottomAngle ??
        angleForConnection(connection: connection, isTop: false);

    return [
      ...batteryToSwitchSegments(
        battery: battery,
        batteryConnection: topBat,
        isTop: true,
      ),
      ...batteryToSwitchSegments(
        battery: battery,
        batteryConnection: bottomBat,
        isTop: false,
      ),
      capacitorToSwitchSegment(
        capacitor: capacitor,
        hinge: topHinge,
        isTop: true,
      ),
      capacitorToSwitchSegment(
        capacitor: capacitor,
        hinge: bottomHinge,
        isTop: false,
      ),
      ModelWireSegment(
        topHinge,
        switchTipEndFromAngle(hinge: topHinge, angle: topTipAngle),
      ),
      ModelWireSegment(
        bottomHinge,
        switchTipEndFromAngle(hinge: bottomHinge, angle: bottomTipAngle),
      ),
    ];
  }

  /// Light bulb → switch — `LightBulbToSwitchWire.js`
  ///
  /// Vertical: bulb terminal → rightCorner(connectionX, batteryHorizY)
  /// Horizontal: rightCorner → LIGHT_BULB connection + (+0.0006, 0, 0)
  static List<ModelWireSegment> lightBulbToSwitchSegments({
    required LightBulb lightBulb,
    required ModelVector3 hinge,
    required bool isTop,
  }) {
    final batConn = batteryConnectedPoint(hinge: hinge, isTop: isTop);
    final bulbConn = isTop
        ? lightBulb.getTopConnectionPoint()
        : lightBulb.getBottomConnectionPoint();
    final rightCorner = ModelVector3(bulbConn.x, batConn.y, 0);
    final bulbStart = ModelVector3(bulbConn.x, bulbConn.y, bulbConn.z);
    final lbPad = lightBulbConnectedPoint(hinge: hinge, isTop: isTop);
    final end = lbPad.plusXYZ(
      ClbConstants.lightBulbToSwitchSeparationOffsetX,
      0,
      0,
    );
    return [
      ModelWireSegment(bulbStart, rightCorner),
      ModelWireSegment(rightCorner, end),
    ];
  }

  /// Full Light Bulb screen segments = capacitance-style + bulb wires.
  ///
  /// Indices: [0..7] same as capacitanceSegments; [8..9] top bulb;
  /// [10..11] bottom bulb.
  static List<ModelWireSegment> lightBulbScreenSegments({
    required Battery battery,
    required Capacitor capacitor,
    required LightBulb lightBulb,
    CircuitConfig? config,
    required CircuitState connection,
    double? topAngle,
    double? bottomAngle,
  }) {
    final cfg = config ?? CircuitConfig.lightBulbScreen();
    final base = capacitanceSegments(
      battery: battery,
      capacitor: capacitor,
      config: cfg,
      connection: connection,
      topAngle: topAngle,
      bottomAngle: bottomAngle,
    );
    final topHinge = switchHingePoint(isTop: true, config: cfg);
    final bottomHinge = switchHingePoint(isTop: false, config: cfg);
    return [
      ...base,
      ...lightBulbToSwitchSegments(
        lightBulb: lightBulb,
        hinge: topHinge,
        isTop: true,
      ),
      ...lightBulbToSwitchSegments(
        lightBulb: lightBulb,
        hinge: bottomHinge,
        isTop: false,
      ),
    ];
  }
}

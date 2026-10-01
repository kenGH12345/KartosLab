import 'dart:math' as math;
import 'dart:ui' show Color, Offset, Rect;

import 'package:flutter/foundation.dart';

import '../../clb_colors.dart';
import '../../clb_constants.dart';
import '../model/battery.dart';
import '../model/capacitor.dart';
import '../model/circuit_config.dart';
import '../model/circuit_state.dart';
import '../model/clb_model.dart';
import '../model/light_bulb.dart';
import '../model/voltmeter.dart';
import '../transform/box_shape_creator.dart';
import '../transform/circuit_geometry.dart';
import '../transform/yaw_pitch_mvt.dart';

/// View-space wire segment (already MVT-scaled xy; z discarded like PhET
/// `WireShapeCreator` → `modelToViewShape` scale-only).
@immutable
class WireSegmentView {
  const WireSegmentView(this.start, this.end);

  final Offset start;
  final Offset end;
}

/// One capacitor plate's three visible faces in view coordinates.
@immutable
class PlateRenderData {
  const PlateRenderData({
    required this.top,
    required this.front,
    required this.right,
  });

  final BoxFacePoints top;
  final BoxFacePoints front;
  final BoxFacePoints right;
}

/// Switch cue arrow placement (view coords).
@immutable
class SwitchCueArrowData {
  const SwitchCueArrowData({
    required this.wireCenter,
    required this.flipVertical,
  });

  final Offset wireCenter;
  final bool flipVertical;
}

/// One switch blade pose in view space.
@immutable
class SwitchBladeView {
  const SwitchBladeView({
    required this.hinge,
    required this.tip,
    required this.angle,
    required this.isTop,
    required this.batteryContact,
    required this.openContact,
    this.lightBulbContact,
  });

  final Offset hinge;
  final Offset tip;
  final double angle;
  final bool isTop;
  /// ConnectionNode positions (view) — `CircuitSwitch.getSwitchConnections`.
  final Offset batteryContact;
  final Offset openContact;
  final Offset? lightBulbContact;
}

/// Immutable circuit snapshot for painters — built FROM model.
/// Painters must not recompute C / Q / V.
@immutable
class CircuitRenderData {
  const CircuitRenderData({
    required this.batteryCenter,
    required this.positiveTerminalUp,
    required this.batteryGraphicScale,
    required this.topPlate,
    required this.bottomPlate,
    required this.wireSegments,
    required this.bottomWireSegments,
    required this.topWireSegments,
    required this.plateColor,
    required this.plateFrontColor,
    required this.plateRightColor,
    required this.voltmeterBodyTopLeft,
    required this.voltmeterBodyScale,
    required this.positiveProbeTopCenter,
    required this.negativeProbeTopCenter,
    required this.probeScale,
    required this.probeRotationRad,
    required this.showSwitchCueArrows,
    required this.switchCueArrows,
    required this.circuitConnection,
    required this.topSwitch,
    required this.bottomSwitch,
    required this.switchTipHighlighted,
    required this.plateSeparationHandleAnchor,
    required this.plateAreaHandleAnchor,
    required this.plateAreaHandleRotationRad,
    required this.voltmeterVisible,
    required this.toolboxBounds,
    required this.topWireLeft,
    required this.capacitanceMeterValue,
    required this.plateChargeMeterValue,
    required this.storedEnergyMeterValue,
    required this.capacitanceMeterVisible,
    required this.plateChargeMeterVisible,
    required this.storedEnergyMeterVisible,
    required this.barGraphsVisible,
    required this.plateChargesVisible,
    required this.electricFieldVisible,
    required this.plateCharge,
    required this.effectiveEField,
    required this.maxPlateCharge,
    required this.maxEffectiveEField,
    required this.capacitorX,
    required this.capacitorY,
    required this.capacitorZ,
    required this.plateWidth,
    required this.plateDepth,
    required this.plateSeparation,
    required this.plateHeight,
    required this.topPlateFaceY,
    required this.bottomPlateFaceY,
    required this.bulbViewCenter,
    required this.bulbHaloScale,
    required this.bulbLit,
    required this.hasLightBulb,
  });

  final Offset batteryCenter;
  final bool positiveTerminalUp;
  final double batteryGraphicScale;

  final PlateRenderData topPlate;
  final PlateRenderData bottomPlate;

  /// All wire segments (convenience).
  final List<WireSegmentView> wireSegments;

  /// Bottom layer wires — behind battery/plates (`CLBCircuitNode` bottomWireNode).
  final List<WireSegmentView> bottomWireSegments;

  /// Top layer wires — above capacitor (`CLBCircuitNode` topWireNode + switches).
  final List<WireSegmentView> topWireSegments;

  final Color plateColor;
  final Color plateFrontColor;
  final Color plateRightColor;

  final Offset voltmeterBodyTopLeft;
  final double voltmeterBodyScale;
  final Offset positiveProbeTopCenter;
  final Offset negativeProbeTopCenter;
  final double probeScale;
  final double probeRotationRad;

  final bool showSwitchCueArrows;
  final List<SwitchCueArrowData> switchCueArrows;

  final CircuitState circuitConnection;
  final SwitchBladeView topSwitch;
  final SwitchBladeView bottomSwitch;

  /// Yellow tip fill while SWITCH_IN_TRANSIT (`SwitchNode` tipCircle).
  final bool switchTipHighlighted;

  /// PlateSeparationDragHandleNode.updateOffset — view coords.
  final Offset plateSeparationHandleAnchor;

  /// PlateAreaDragHandleNode.updateOffset — view coords.
  final Offset plateAreaHandleAnchor;

  /// Area handle rotation: −π/2 + yaw/2.
  final double plateAreaHandleRotationRad;

  final bool voltmeterVisible;

  /// Toolbox panel bounds in canvas coords (return-to-toolbox).
  final Rect toolboxBounds;

  /// Left edge of top-wire layer — for BarMeterPanel.left.
  final double topWireLeft;

  final double capacitanceMeterValue;
  final double plateChargeMeterValue;
  final double storedEnergyMeterValue;
  final bool capacitanceMeterVisible;
  final bool plateChargeMeterVisible;
  final bool storedEnergyMeterVisible;
  final bool barGraphsVisible;

  final bool plateChargesVisible;
  final bool electricFieldVisible;
  final double plateCharge;
  final double effectiveEField;
  final double maxPlateCharge;
  final double maxEffectiveEField;
  final double capacitorX;
  final double capacitorY;
  final double capacitorZ;
  final double plateWidth;
  final double plateDepth;
  final double plateSeparation;
  final double plateHeight;

  /// Model Y of top face of top / bottom plate (for charge placement).
  final double topPlateFaceY;
  final double bottomPlateFaceY;

  /// Light bulb view center (null when Capacitance screen).
  final Offset? bulbViewCenter;
  final double bulbHaloScale;
  final bool bulbLit;
  final bool hasLightBulb;

  /// Build from Capacitance (or any parallel) circuit model state.
  factory CircuitRenderData.fromModels({
    required Battery battery,
    required Capacitor capacitor,
    required Voltmeter voltmeter,
    required bool switchUsed,
    required CircuitState circuitConnection,
    required double topSwitchAngle,
    required double bottomSwitchAngle,
    LightBulb? lightBulb,
    bool voltmeterVisible = false,
    bool capacitanceMeterVisible = true,
    bool plateChargeMeterVisible = false,
    bool storedEnergyMeterVisible = false,
    bool barGraphsVisible = true,
    bool plateChargesVisible = true,
    bool electricFieldVisible = false,
    double? maxPlateCharge,
    double? maxEffectiveEField,
    double capacitanceMeterValue = 0,
    double plateChargeMeterValue = 0,
    double storedEnergyMeterValue = 0,
    Rect? toolboxBounds,
    CircuitConfig? config,
    YawPitchMvt? mvt,
  }) {
    final transform = mvt ?? YawPitchMvt();
    final cfg = config ?? CircuitConfig.capacitanceScreen();
    final boxes = BoxShapeCreator(transform);

    final batCenter =
        transform.modelToViewXYZ(battery.x, battery.y, battery.z);

    // CapacitorNode.updateGeometry — plate origins relative to capacitor center
    final topPlateY =
        capacitor.y - capacitor.plateSeparation / 2 - capacitor.plateHeight;
    final bottomPlateY = capacitor.y + capacitor.plateSeparation / 2;

    final topPlate = PlateRenderData(
      top: boxes.createTopFace(
        capacitor.x,
        topPlateY,
        capacitor.z,
        capacitor.plateWidth,
        capacitor.plateHeight,
        capacitor.plateDepth,
      ),
      front: boxes.createFrontFace(
        capacitor.x,
        topPlateY,
        capacitor.z,
        capacitor.plateWidth,
        capacitor.plateHeight,
        capacitor.plateDepth,
      ),
      right: boxes.createRightSideFace(
        capacitor.x,
        topPlateY,
        capacitor.z,
        capacitor.plateWidth,
        capacitor.plateHeight,
        capacitor.plateDepth,
      ),
    );

    final bottomPlate = PlateRenderData(
      top: boxes.createTopFace(
        capacitor.x,
        bottomPlateY,
        capacitor.z,
        capacitor.plateWidth,
        capacitor.plateHeight,
        capacitor.plateDepth,
      ),
      front: boxes.createFrontFace(
        capacitor.x,
        bottomPlateY,
        capacitor.z,
        capacitor.plateWidth,
        capacitor.plateHeight,
        capacitor.plateDepth,
      ),
      right: boxes.createRightSideFace(
        capacitor.x,
        bottomPlateY,
        capacitor.z,
        capacitor.plateWidth,
        capacitor.plateHeight,
        capacitor.plateDepth,
      ),
    );

    final modelSegs = (lightBulb != null)
        ? CircuitGeometry.lightBulbScreenSegments(
            battery: battery,
            capacitor: capacitor,
            lightBulb: lightBulb,
            config: cfg,
            connection: circuitConnection,
            topAngle: topSwitchAngle,
            bottomAngle: bottomSwitchAngle,
          )
        : CircuitGeometry.capacitanceSegments(
            battery: battery,
            capacitor: capacitor,
            config: cfg,
            connection: circuitConnection,
            topAngle: topSwitchAngle,
            bottomAngle: bottomSwitchAngle,
          );

    // Segment order Capacitance: [0..1] top bat, [2..3] bottom bat,
    // [4] cap top, [5] cap bottom, [6] top switch, [7] bottom switch
    // Light Bulb adds: [8..9] top bulb, [10..11] bottom bulb
    WireSegmentView viewOf(ModelWireSegment s) => WireSegmentView(
          transform.modelToViewShapeXY(s.start.x, s.start.y),
          transform.modelToViewShapeXY(s.end.x, s.end.y),
        );

    final bottomWireSegments = <WireSegmentView>[
      viewOf(modelSegs[2]),
      viewOf(modelSegs[3]),
      viewOf(modelSegs[5]),
      viewOf(modelSegs[7]),
      if (lightBulb != null) ...[
        viewOf(modelSegs[10]),
        viewOf(modelSegs[11]),
      ],
    ];
    final topWireSegments = <WireSegmentView>[
      viewOf(modelSegs[0]),
      viewOf(modelSegs[1]),
      viewOf(modelSegs[4]),
      viewOf(modelSegs[6]),
      if (lightBulb != null) ...[
        viewOf(modelSegs[8]),
        viewOf(modelSegs[9]),
      ],
    ];
    final wireViews = [...bottomWireSegments, ...topWireSegments];

    final plate = ClbColors.plate;
    final front = _darkerColor(plate);
    final right = _darkerColor(front);

    final bodyPos = transform.modelToViewXYZ(
      voltmeter.bodyX,
      voltmeter.bodyY,
      voltmeter.bodyZ,
    );
    final posProbe = transform.modelToViewXYZ(
      voltmeter.positiveProbeX,
      voltmeter.positiveProbeY,
      voltmeter.positiveProbeZ,
    );
    final negProbe = transform.modelToViewXYZ(
      voltmeter.negativeProbeX,
      voltmeter.negativeProbeY,
      voltmeter.negativeProbeZ,
    );

    final topHinge = CircuitGeometry.switchHingePoint(isTop: true, config: cfg);
    final bottomHinge =
        CircuitGeometry.switchHingePoint(isTop: false, config: cfg);
    final topTip = CircuitGeometry.switchTipEndFromAngle(
      hinge: topHinge,
      angle: topSwitchAngle,
    );
    final bottomTip = CircuitGeometry.switchTipEndFromAngle(
      hinge: bottomHinge,
      angle: bottomSwitchAngle,
    );

    final topHingeView = transform.modelToViewXYZ(topHinge.x, topHinge.y, topHinge.z);
    final bottomHingeView =
        transform.modelToViewXYZ(bottomHinge.x, bottomHinge.y, bottomHinge.z);
    final topTipView = transform.modelToViewXYZ(topTip.x, topTip.y, topTip.z);
    final bottomTipView =
        transform.modelToViewXYZ(bottomTip.x, bottomTip.y, bottomTip.z);

    final topWireCenter = Offset(
      (topHingeView.dx + topTipView.dx) / 2,
      (topHingeView.dy + topTipView.dy) / 2,
    );
    final bottomWireCenter = Offset(
      (bottomHingeView.dx + bottomTipView.dx) / 2,
      (bottomHingeView.dy + bottomTipView.dy) / 2,
    );

    // PlateSeparationDragHandleNode.updateOffset
    final sepAnchor = transform.modelToViewXYZ(
      capacitor.x + 0.3 * capacitor.plateWidth,
      capacitor.y -
          capacitor.plateSeparation / 2 -
          capacitor.plateHeight,
      0,
    );

    // PlateAreaDragHandleNode.updateOffset — back-right of top face
    final areaAnchor = transform.modelToViewXYZ(
      capacitor.x + capacitor.plateWidth / 2,
      capacitor.y -
          capacitor.plateSeparation / 2 -
          capacitor.plateHeight,
      capacitor.z + capacitor.plateDepth / 2,
    );

    var topWireLeft = double.infinity;
    for (final s in topWireSegments) {
      topWireLeft = math.min(topWireLeft, math.min(s.start.dx, s.end.dx));
    }
    if (topWireLeft.isInfinite) topWireLeft = batCenter.dx;

    final topBat = CircuitGeometry.batteryConnectedPoint(
      hinge: topHinge,
      isTop: true,
    );
    final topOpen = CircuitGeometry.openCircuitPoint(
      hinge: topHinge,
      isTop: true,
    );
    final topBulb = lightBulb == null
        ? null
        : CircuitGeometry.lightBulbConnectedPoint(hinge: topHinge, isTop: true);
    final botBat = CircuitGeometry.batteryConnectedPoint(
      hinge: bottomHinge,
      isTop: false,
    );
    final botOpen = CircuitGeometry.openCircuitPoint(
      hinge: bottomHinge,
      isTop: false,
    );
    final botBulb = lightBulb == null
        ? null
        : CircuitGeometry.lightBulbConnectedPoint(
            hinge: bottomHinge,
            isTop: false,
          );

    return CircuitRenderData(
      batteryCenter: batCenter,
      positiveTerminalUp: battery.isPositiveTerminalUp,
      batteryGraphicScale: ClbConstants.batteryGraphicScale,
      topPlate: topPlate,
      bottomPlate: bottomPlate,
      wireSegments: wireViews,
      bottomWireSegments: bottomWireSegments,
      topWireSegments: topWireSegments,
      plateColor: plate,
      plateFrontColor: front,
      plateRightColor: right,
      voltmeterBodyTopLeft: bodyPos,
      voltmeterBodyScale: ClbConstants.voltmeterBodyScale,
      positiveProbeTopCenter: posProbe,
      negativeProbeTopCenter: negProbe,
      probeScale: ClbConstants.voltmeterProbeScale,
      probeRotationRad: -ClbConstants.mvtYawRad,
      showSwitchCueArrows: !switchUsed,
      switchCueArrows: [
        SwitchCueArrowData(wireCenter: topWireCenter, flipVertical: false),
        SwitchCueArrowData(
          wireCenter: bottomWireCenter,
          flipVertical: bottomTip.y > bottomHinge.y,
        ),
      ],
      circuitConnection: circuitConnection,
      topSwitch: SwitchBladeView(
        hinge: topHingeView,
        tip: topTipView,
        angle: topSwitchAngle,
        isTop: true,
        batteryContact: transform.modelToViewXYZ(topBat.x, topBat.y, topBat.z),
        openContact: transform.modelToViewXYZ(topOpen.x, topOpen.y, topOpen.z),
        lightBulbContact: topBulb == null
            ? null
            : transform.modelToViewXYZ(topBulb.x, topBulb.y, topBulb.z),
      ),
      bottomSwitch: SwitchBladeView(
        hinge: bottomHingeView,
        tip: bottomTipView,
        angle: bottomSwitchAngle,
        isTop: false,
        batteryContact: transform.modelToViewXYZ(botBat.x, botBat.y, botBat.z),
        openContact: transform.modelToViewXYZ(botOpen.x, botOpen.y, botOpen.z),
        lightBulbContact: botBulb == null
            ? null
            : transform.modelToViewXYZ(botBulb.x, botBulb.y, botBulb.z),
      ),
      switchTipHighlighted:
          circuitConnection == CircuitState.switchInTransit,
      plateSeparationHandleAnchor: sepAnchor,
      plateAreaHandleAnchor: areaAnchor,
      plateAreaHandleRotationRad:
          (-math.pi / 2) + (ClbConstants.mvtYawRad / 2),
      voltmeterVisible: voltmeterVisible,
      toolboxBounds: toolboxBounds ??
          const Rect.fromLTWH(
            ClbConstants.canvasWidth - 185,
            200,
            175,
            80,
          ),
      topWireLeft: topWireLeft,
      capacitanceMeterValue: capacitanceMeterValue,
      plateChargeMeterValue: plateChargeMeterValue,
      storedEnergyMeterValue: storedEnergyMeterValue,
      capacitanceMeterVisible: capacitanceMeterVisible,
      plateChargeMeterVisible: plateChargeMeterVisible,
      storedEnergyMeterVisible: storedEnergyMeterVisible,
      barGraphsVisible: barGraphsVisible,
      plateChargesVisible: plateChargesVisible,
      electricFieldVisible: electricFieldVisible,
      plateCharge: capacitor.plateCharge,
      effectiveEField: capacitor.effectiveEField,
      maxPlateCharge: maxPlateCharge ?? double.infinity,
      maxEffectiveEField: maxEffectiveEField ?? double.infinity,
      capacitorX: capacitor.x,
      capacitorY: capacitor.y,
      capacitorZ: capacitor.z,
      plateWidth: capacitor.plateWidth,
      plateDepth: capacitor.plateDepth,
      plateSeparation: capacitor.plateSeparation,
      plateHeight: capacitor.plateHeight,
      topPlateFaceY: topPlateY,
      bottomPlateFaceY: bottomPlateY,
      bulbViewCenter: lightBulb == null
          ? null
          : transform.modelToViewXYZ(
              lightBulb.x + ClbConstants.bulbViewOffsetX,
              lightBulb.y,
              lightBulb.z,
            ),
      bulbHaloScale: _bulbHaloScale(
        lightBulb: lightBulb,
        connection: circuitConnection,
        plateVoltage: capacitor.plateVoltage,
      ),
      bulbLit: lightBulb != null &&
          circuitConnection == CircuitState.lightBulbConnected,
      hasLightBulb: lightBulb != null,
    );
  }

  static double _bulbHaloScale({
    required LightBulb? lightBulb,
    required CircuitState connection,
    required double plateVoltage,
  }) {
    if (lightBulb == null ||
        connection != CircuitState.lightBulbConnected) {
      return 0;
    }
    final i = lightBulb.getCurrent(plateVoltage).abs();
    // LinearFunction(0, 5e-13, 0, 225)
    final t = (i / ClbConstants.bulbMaxCurrentForHalo).clamp(0.0, 1.0);
    return t * ClbConstants.bulbMaxHaloScale;
  }

  factory CircuitRenderData.fromClbModel(
    ClbModel model, {
    YawPitchMvt? mvt,
    Rect? toolboxBounds,
  }) {
    return CircuitRenderData.fromModels(
      battery: model.circuit.battery,
      capacitor: model.circuit.capacitor,
      voltmeter: model.voltmeter,
      switchUsed: model.shared.switchUsed,
      circuitConnection: model.circuit.circuitConnection,
      topSwitchAngle: model.circuit.topSwitchAngle,
      bottomSwitchAngle: model.circuit.bottomSwitchAngle,
      lightBulb: model.circuit.lightBulb,
      voltmeterVisible: model.voltmeterVisible,
      capacitanceMeterVisible: model.capacitanceMeterVisible,
      plateChargeMeterVisible: model.topPlateChargeMeterVisible,
      storedEnergyMeterVisible: model.storedEnergyMeterVisible,
      barGraphsVisible: model.barGraphsVisible,
      plateChargesVisible: model.plateChargesVisible,
      electricFieldVisible: model.electricFieldVisible,
      maxPlateCharge: model.maxPlateCharge,
      maxEffectiveEField: model.maxEffectiveEField,
      capacitanceMeterValue: model.capacitanceMeter.value,
      plateChargeMeterValue: model.plateChargeMeter.value,
      storedEnergyMeterValue: model.storedEnergyMeter.value,
      toolboxBounds: toolboxBounds,
      config: model.circuit.config,
      mvt: mvt,
    );
  }
}

/// [推测] PhET `Color.darkerColor()` 无 factor 时按 RGB × 0.7。
Color _darkerColor(Color c) {
  const factor = 0.7;
  return Color.from(
    alpha: c.a,
    red: (c.r * factor).clamp(0.0, 1.0),
    green: (c.g * factor).clamp(0.0, 1.0),
    blue: (c.b * factor).clamp(0.0, 1.0),
  );
}

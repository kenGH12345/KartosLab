import 'package:flutter/material.dart';

import '../../clb_constants.dart';
import '../painters/battery_painter.dart';
import '../painters/capacitor_plates_painter.dart';
import '../painters/plate_charge_painter.dart';
import '../painters/switch_tip_painter.dart';
import '../painters/wire_painter.dart';
import '../render/circuit_render_data.dart';
import 'bulb_node_overlay.dart';

/// Static circuit scene — CustomPaint layers + Image.asset overlays.
///
/// Layer order mirrors `CLBCircuitNode.js` / `CapacitorNode.js`:
/// bottomWire → battery → bottomPlate → bottomCharges → eField →
/// topPlate → topCharges → topWire → tips → cue / voltmeter.
class StaticCircuitView extends StatelessWidget {
  const StaticCircuitView({
    super.key,
    required this.data,
    this.showPlateHandles = false,
    this.showVoltmeterOverlays,
  });

  final CircuitRenderData data;

  /// When null, uses [CircuitRenderData.voltmeterVisible].
  final bool? showVoltmeterOverlays;
  final bool showPlateHandles;

  @override
  Widget build(BuildContext context) {
    final showVm = showVoltmeterOverlays ?? data.voltmeterVisible;
    const canvasSize = Size(
      ClbConstants.canvasWidth,
      ClbConstants.canvasHeight,
    );

    return SizedBox(
      width: ClbConstants.canvasWidth,
      height: ClbConstants.canvasHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: canvasSize,
            painter: WirePainter(segments: data.bottomWireSegments),
          ),
          CustomPaint(
            size: canvasSize,
            painter: BatteryPainter(data: data),
          ),
          if (data.hasLightBulb) BulbNodeOverlay(data: data),
          CustomPaint(
            size: canvasSize,
            painter: CapacitorPlatesPainter(
              data: data,
              paintBottom: true,
              paintTop: false,
            ),
          ),
          CustomPaint(
            size: canvasSize,
            painter: PlateChargePainter(data: data, isTopPlate: false),
          ),
          CustomPaint(
            size: canvasSize,
            painter: EFieldPainter(data: data),
          ),
          CustomPaint(
            size: canvasSize,
            painter: CapacitorPlatesPainter(
              data: data,
              paintBottom: false,
              paintTop: true,
            ),
          ),
          CustomPaint(
            size: canvasSize,
            painter: PlateChargePainter(data: data, isTopPlate: true),
          ),
          CustomPaint(
            size: canvasSize,
            painter: WirePainter(segments: data.topWireSegments),
          ),
          CustomPaint(
            size: canvasSize,
            painter: SwitchTipPainter(data: data),
          ),
          if (showVm) ..._voltmeterOverlays(),
        ],
      ),
    );
  }

  List<Widget> _voltmeterOverlays() {
    return [
      Positioned(
        left: data.voltmeterBodyTopLeft.dx,
        top: data.voltmeterBodyTopLeft.dy,
        child: Transform.scale(
          alignment: Alignment.topLeft,
          scale: data.voltmeterBodyScale,
          child: Image.asset(
            ClbConstants.assetVoltmeterBody,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
      _probe(
        asset: ClbConstants.assetProbeRed,
        topCenter: data.positiveProbeTopCenter,
      ),
      _probe(
        asset: ClbConstants.assetProbeBlack,
        topCenter: data.negativeProbeTopCenter,
      ),
    ];
  }

  Widget _probe({
    required String asset,
    required Offset topCenter,
  }) {
    return Positioned(
      left: topCenter.dx,
      top: topCenter.dy,
      child: Transform.rotate(
        angle: data.probeRotationRad,
        alignment: Alignment.topCenter,
        child: Transform.scale(
          alignment: Alignment.topCenter,
          scale: data.probeScale,
          child: FractionalTranslation(
            translation: const Offset(-0.5, 0),
            child: Image.asset(
              asset,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}

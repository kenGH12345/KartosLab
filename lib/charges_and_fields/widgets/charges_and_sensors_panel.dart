import 'package:flutter/material.dart';

import '../caf_assets.dart';
import '../caf_colors.dart';
import '../caf_constants.dart';
import '../caf_strings.dart';
import '../painters/caf_scene_painters.dart';

/// Bottom bin: +1 nC / -1 nC / Sensors.
class ChargesAndSensorsPanel extends StatelessWidget {
  const ChargesAndSensorsPanel({
    super.key,
    required this.onPositiveDown,
    required this.onNegativeDown,
    required this.onSensorDown,
  });

  final GestureDragDownCallback onPositiveDown;
  final GestureDragDownCallback onNegativeDown;
  final GestureDragDownCallback onSensorDown;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CafColors.enclosureFill,
        border: Border.all(
          color: CafColors.enclosureBorder,
          width: CafConstants.panelLineWidth,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(
            painter: ChargePainter(positive: true),
            label: CafStrings.plusOneNanoC,
            onDown: onPositiveDown,
          ),
          const SizedBox(width: 60),
          _item(
            painter: ChargePainter(positive: false),
            label: CafStrings.minusOneNanoC,
            onDown: onNegativeDown,
          ),
          const SizedBox(width: 60),
          _item(
            child: Container(
              width: CafConstants.electricFieldSensorCircleRadius * 2,
              height: CafConstants.electricFieldSensorCircleRadius * 2,
              decoration: BoxDecoration(
                color: CafColors.electricFieldSensorCircleFill,
                shape: BoxShape.circle,
                border: Border.all(
                  color: CafColors.electricFieldSensorCircleStroke,
                ),
              ),
            ),
            label: CafStrings.sensors,
            onDown: onSensorDown,
          ),
        ],
      ),
    );
  }

  Widget _item({
    CustomPainter? painter,
    Widget? child,
    required String label,
    required GestureDragDownCallback onDown,
  }) {
    final diameter = CafConstants.chargeRadius * 2;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) {
        onDown(DragDownDetails(
          globalPosition: e.position,
          localPosition: e.localPosition,
        ));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (painter != null)
            SizedBox(
              width: diameter,
              height: diameter,
              child: CustomPaint(painter: painter),
            )
          else
            child!,
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: CafColors.enclosureText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// Toolbox layout constants from ChargesAndFieldsToolboxPanel.ts
class CafToolboxLayout {
  CafToolboxLayout._();

  static const double panelXMargin = 12;
  static const double panelYMargin = 10;
  static const double iconSpacing = 20;
  static const double sensorIconCircleRadius = 10; // CIRCLE_RADIUS in toolbox
  static const double outlineScale = 0.5 * 6 / 25; // ≈ 0.12

  /// MeasuringTapeNode defaults + toolbox Node.scale(0.8).
  static const double tapeIconUnspooled = 30; // tip offset before Node.scale
  static const double tapeBaseScale = 0.8; // MeasuringTapeNode.baseScale
  static const double tapeNodeScale = 0.8; // createMeasuringTapeIcon scale
  static const double tapePngSize = 51; // measuringTape.png intrinsic
  static const double tapeTipCircleRadius = 10;
  static const double tapeCrosshairSize = 5;
  static const double tapeCrosshairLineWidth = 2;
  static const double tapeLineWidth = 2;
  static const Color tapeLineColor = Color(0xFF808080);
  static const Color tapeCrosshairColor = Color(0xFFE05F20);
  static const Color tapeTipCircleColor = Color(0x1A000000);
}

/// Right toolbox: voltmeter icon + measuring tape icon (source layout).
class CafToolboxPanel extends StatelessWidget {
  const CafToolboxPanel({
    super.key,
    required this.voltmeterInToolbox,
    required this.tapeInToolbox,
    required this.onVoltmeterDown,
    required this.onTapeDown,
  });

  final bool voltmeterInToolbox;
  final bool tapeInToolbox;
  final GestureDragDownCallback onVoltmeterDown;
  final GestureDragDownCallback onTapeDown;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CafColors.controlPanelFill,
        border: Border.all(
          color: CafColors.controlPanelBorder,
          width: CafConstants.panelLineWidth,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: CafToolboxLayout.panelXMargin,
        vertical: CafToolboxLayout.panelYMargin,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: voltmeterInToolbox ? 1 : 0,
            child: IgnorePointer(
              ignoring: !voltmeterInToolbox,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (e) {
                  onVoltmeterDown(DragDownDetails(
                    globalPosition: e.position,
                    localPosition: e.localPosition,
                  ));
                },
                child: const _VoltmeterToolboxIcon(),
              ),
            ),
          ),
          const SizedBox(height: CafToolboxLayout.iconSpacing),
          Opacity(
            opacity: tapeInToolbox ? 1 : 0,
            child: IgnorePointer(
              ignoring: !tapeInToolbox,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (e) {
                  onTapeDown(DragDownDetails(
                    globalPosition: e.position,
                    localPosition: e.localPosition,
                  ));
                },
                child: const _MeasuringTapeToolboxIcon(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Port of ChargesAndFieldsToolboxPanel.createElectricPotentialSensorIcon
class _VoltmeterToolboxIcon extends StatelessWidget {
  const _VoltmeterToolboxIcon();

  static const double _r = CafToolboxLayout.sensorIconCircleRadius;

  @override
  Widget build(BuildContext context) {
    // Intrinsic layout from source: circle origin at top center.
    // outlineImage.scale(0.5*6/25); mount below circle; body below mount.
    return SizedBox(
      width: 72,
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Crosshair circle + cross at y=0 center
          Positioned(
            top: 0,
            left: 36 - _r,
            child: CustomPaint(
              size: const Size(_r * 2, _r * 2),
              painter: _IconCrosshairPainter(radius: _r, lineWidth: 2),
            ),
          ),
          // Mount: 0.4R × 0.4R below circle
          Positioned(
            top: _r * 2,
            left: 36 - 0.2 * _r,
            child: Container(
              width: 0.4 * _r,
              height: 0.4 * _r,
              color: CafColors.electricPotentialSensorCrosshairStroke,
            ),
          ),
          // Panel outline below mount
          Positioned(
            top: _r * 2 + 0.4 * _r,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                CafAssets.electricPotentialPanelOutline,
                width: 499 * CafToolboxLayout.outlineScale,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          // Readout "0.0 V" — outlineImage.top + 20 in source
          Positioned(
            top: _r * 2 + 0.4 * _r + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  '0.0 V',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCrosshairPainter extends CustomPainter {
  _IconCrosshairPainter({required this.radius, required this.lineWidth});

  final double radius;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final stroke = Paint()
      ..color = CafColors.electricPotentialSensorCrosshairStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;
    canvas.drawCircle(c, radius, stroke);
    canvas.drawLine(Offset(c.dx - radius, c.dy), Offset(c.dx + radius, c.dy), stroke);
    canvas.drawLine(Offset(c.dx, c.dy - radius), Offset(c.dx, c.dy + radius), stroke);
  }

  @override
  bool shouldRepaint(covariant _IconCrosshairPainter oldDelegate) => false;
}

/// Port of ChargesAndFieldsToolboxPanel.createMeasuringTapeIcon geometry.
///
/// MeasuringTapeNode(tip=(30,0), hasValue:false, baseScale:0.8) then Node.scale(0.8).
/// basePosition = rightBottom of measuringTape.png; tip = base + (unspooled, 0).
class _MeasuringTapeToolboxIcon extends StatelessWidget {
  const _MeasuringTapeToolboxIcon();

  @override
  Widget build(BuildContext context) {
    const baseScale = CafToolboxLayout.tapeBaseScale;
    const nodeScale = CafToolboxLayout.tapeNodeScale;
    const unspooled = CafToolboxLayout.tapeIconUnspooled;
    const tipR = CafToolboxLayout.tapeTipCircleRadius;
    final img = CafToolboxLayout.tapePngSize * baseScale; // 40.8
    // Local (pre-nodeScale): image at (0,0), base = rightBottom = (img, img)
    final localW = img + unspooled + tipR;
    final localH = img + tipR;

    return SizedBox(
      width: localW * nodeScale,
      height: localH * nodeScale,
      child: Transform.scale(
        scale: nodeScale,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: localW,
          height: localH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: img,
                height: img,
                child: Image.asset(
                  CafAssets.measuringTape,
                  width: img,
                  height: img,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              CustomPaint(
                size: Size(localW, localH),
                painter: _MeasuringTapeIconPainter(
                  base: Offset(img, img),
                  tip: Offset(img + unspooled, img),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasuringTapeIconPainter extends CustomPainter {
  _MeasuringTapeIconPainter({required this.base, required this.tip});

  final Offset base;
  final Offset tip;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      base,
      tip,
      Paint()
        ..color = CafToolboxLayout.tapeLineColor
        ..strokeWidth = CafToolboxLayout.tapeLineWidth,
    );

    canvas.drawCircle(
      tip,
      CafToolboxLayout.tapeTipCircleRadius,
      Paint()..color = CafToolboxLayout.tapeTipCircleColor,
    );

    final cross = Paint()
      ..color = CafToolboxLayout.tapeCrosshairColor
      ..strokeWidth = CafToolboxLayout.tapeCrosshairLineWidth
      ..strokeCap = StrokeCap.butt;
    const cs = CafToolboxLayout.tapeCrosshairSize;
    // Base crosshair at rightBottom (MeasuringTapeNode)
    canvas.drawLine(base + const Offset(-cs, 0), base + const Offset(cs, 0), cross);
    canvas.drawLine(base + const Offset(0, -cs), base + const Offset(0, cs), cross);
    // Tip crosshair
    canvas.drawLine(tip + const Offset(-cs, 0), tip + const Offset(cs, 0), cross);
    canvas.drawLine(tip + const Offset(0, -cs), tip + const Offset(0, cs), cross);
  }

  @override
  bool shouldRepaint(covariant _MeasuringTapeIconPainter oldDelegate) =>
      oldDelegate.base != base || oldDelegate.tip != tip;
}

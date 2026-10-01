import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/assets/esp_assets.dart';
import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/render/esp_mvt.dart';

/// MeasuringTapeNode.ts — PNG base + gray line + orange crosshairs + tip halo.
class MeasuringTapeOverlay extends StatelessWidget {
  const MeasuringTapeOverlay({
    super.key,
    required this.controller,
    required this.mvt,
    required this.onHandleDown,
    required this.onHandleMove,
    required this.onHandleUp,
  });

  final EspController controller;
  final EspMvt mvt;
  final void Function(MeasuringTapeHandle handle) onHandleDown;
  final void Function(MeasuringTapeHandle handle, Offset local) onHandleMove;
  final void Function(MeasuringTapeHandle handle) onHandleUp;

  static const Color _crosshairColor = Color(0xFFE05F20);
  static const double _baseScale = 0.8;
  static const double _crosshairSize = 5;
  static const double _crosshairLineWidth = 2;
  static const double _tipCircleRadius = 10;

  @override
  Widget build(BuildContext context) {
    if (!controller.model.measuringTapeVisible) {
      return const SizedBox.shrink();
    }

    final base = mvt.modelToView(controller.model.measuringTapeBase);
    final tip = mvt.modelToView(controller.model.measuringTapeTip);
    final dist = controller.model.measuringTapeDistance;
    final angle =
        math.atan2(tip.dy - base.dy, tip.dx - base.dx);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _TapeLinePainter(base: base, tip: tip),
          ),
        ),
        Positioned(
          left: base.dx + 30 * _baseScale,
          top: base.dy + 24 * _baseScale,
          child: IgnorePointer(
            child: Text(
              '${dist.toStringAsFixed(1)} ${EspStrings.metersUnit}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(1, 1)),
                ],
              ),
            ),
          ),
        ),
        _Crosshair(center: base, angle: angle),
        _TipHandle(
          center: tip,
          angle: angle,
          onDown: () => onHandleDown(MeasuringTapeHandle.tip),
          onMove: (local) => onHandleMove(MeasuringTapeHandle.tip, local),
          onUp: () => onHandleUp(MeasuringTapeHandle.tip),
        ),
        _BaseHandle(
          base: base,
          angle: angle,
          onDown: () => onHandleDown(MeasuringTapeHandle.base),
          onMove: (local) => onHandleMove(MeasuringTapeHandle.base, local),
          onUp: () => onHandleUp(MeasuringTapeHandle.base),
        ),
        Positioned(
          left: (base.dx + tip.dx) / 2 - 20,
          top: (base.dy + tip.dy) / 2 - 20,
          width: 40,
          height: 40,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) => onHandleDown(MeasuringTapeHandle.body),
            onPanUpdate: (d) =>
                onHandleMove(MeasuringTapeHandle.body, d.localPosition),
            onPanEnd: (_) => onHandleUp(MeasuringTapeHandle.body),
          ),
        ),
      ],
    );
  }
}

enum MeasuringTapeHandle { base, tip, body }

class _Crosshair extends StatelessWidget {
  const _Crosshair({required this.center, required this.angle});

  final Offset center;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - MeasuringTapeOverlay._crosshairSize,
      top: center.dy - MeasuringTapeOverlay._crosshairSize,
      width: MeasuringTapeOverlay._crosshairSize * 2,
      height: MeasuringTapeOverlay._crosshairSize * 2,
      child: Transform.rotate(
        angle: angle,
        child: CustomPaint(
          painter: _CrosshairPainter(),
          size: Size(
            MeasuringTapeOverlay._crosshairSize * 2,
            MeasuringTapeOverlay._crosshairSize * 2,
          ),
        ),
      ),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = MeasuringTapeOverlay._crosshairSize;
    final paint = Paint()
      ..color = MeasuringTapeOverlay._crosshairColor
      ..strokeWidth = MeasuringTapeOverlay._crosshairLineWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx - s, c.dy), Offset(c.dx + s, c.dy), paint);
    canvas.drawLine(Offset(c.dx, c.dy - s), Offset(c.dx, c.dy + s), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BaseHandle extends StatelessWidget {
  const _BaseHandle({
    required this.base,
    required this.angle,
    required this.onDown,
    required this.onMove,
    required this.onUp,
  });

  final Offset base;
  final double angle;
  final VoidCallback onDown;
  final void Function(Offset local) onMove;
  final VoidCallback onUp;

  static const double _imgSize = 51;
  static const double _scale = MeasuringTapeOverlay._baseScale;

  @override
  Widget build(BuildContext context) {
    final w = _imgSize * _scale;
    final h = _imgSize * _scale;
    return Positioned(
      left: base.dx - w - 20,
      top: base.dy - h - 20,
      width: w + 40,
      height: h + 40,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => onDown(),
        onPanUpdate: (d) => onMove(d.localPosition),
        onPanEnd: (_) => onUp(),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Transform.rotate(
            angle: angle,
            alignment: Alignment.bottomRight,
            child: Image.asset(
              EspAssets.measuringTape,
              width: w,
              height: h,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _TipHandle extends StatelessWidget {
  const _TipHandle({
    required this.center,
    required this.angle,
    required this.onDown,
    required this.onMove,
    required this.onUp,
  });

  final Offset center;
  final double angle;
  final VoidCallback onDown;
  final void Function(Offset local) onMove;
  final VoidCallback onUp;

  @override
  Widget build(BuildContext context) {
    const r = MeasuringTapeOverlay._tipCircleRadius;
    return Positioned(
      left: center.dx - r - 15,
      top: center.dy - r - 15,
      width: (r + 15) * 2,
      height: (r + 15) * 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => onDown(),
        onPanUpdate: (d) => onMove(d.localPosition),
        onPanEnd: (_) => onUp(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: r * 2,
              height: r * 2,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1A000000),
              ),
            ),
            Transform.rotate(
              angle: angle,
              child: CustomPaint(
                size: const Size(20, 20),
                painter: _CrosshairPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TapeLinePainter extends CustomPainter {
  _TapeLinePainter({required this.base, required this.tip});

  final Offset base;
  final Offset tip;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      base,
      tip,
      Paint()
        ..color = Colors.grey
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TapeLinePainter old) =>
      old.base != base || old.tip != tip;
}

/// Toolbox icon — MeasuringTapeNode.createIcon (scale 0.7 in ToolboxPanel.ts).
class PhetMeasuringTapeAssetIcon extends StatelessWidget {
  const PhetMeasuringTapeAssetIcon({super.key, this.scale = 0.7});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      EspAssets.measuringTape,
      width: 51 * scale,
      height: 51 * scale,
      fit: BoxFit.contain,
    );
  }
}

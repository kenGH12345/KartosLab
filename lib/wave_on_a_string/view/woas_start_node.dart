import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/woas_mode.dart';
import '../model/woas_model.dart';
import '../woas_constants.dart';
import 'woas_layout.dart';

/// Left apparatus (`StartNode`): wrench / oscillator wheel / pulse box.
class WoasStartNode extends StatelessWidget {
  const WoasStartNode({
    super.key,
    required this.model,
    required this.onWrenchDrag,
  });

  final WoasModel model;
  final void Function(double modelY) onWrenchDrag;

  @override
  Widget build(BuildContext context) {
    final mode = model.waveMode;
    final yModel = model.yNowAt(0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (mode != WoasMode.manual) _OscillatorPost(yModel: yModel),
        if (mode == WoasMode.pulse) _PulseBox(model: model),
        if (mode == WoasMode.manual)
          _WrenchLayer(
            yModel: yModel,
            arrowsVisible: model.wrenchArrowsVisible,
            onDrag: onWrenchDrag,
          ),
        if (mode == WoasMode.oscillate) _OscillatorWheel(angle: model.angle),
      ],
    );
  }
}

class _WrenchLayer extends StatelessWidget {
  const _WrenchLayer({
    required this.yModel,
    required this.arrowsVisible,
    required this.onDrag,
  });

  final double yModel;
  final bool arrowsVisible;
  final void Function(double modelY) onDrag;

  @override
  Widget build(BuildContext context) {
    // Source `WrenchNode`: Image(x:-40, y:-24, scale:0.9/4) inside StartNode
    // at (VIEW_ORIGIN, scale:SCALE_FROM_ORIGINAL). Image x/y are NOT multiplied
    // by the image content scale — only by StartNode scale.
    const imageContentScale = 0.9 / 4;
    const imageOffsetX = -40.0;
    const imageOffsetY = -24.0;
    const intrinsicW = 240.0;
    const intrinsicH = 846.0;
    const arrowXOffset = 8.0;
    const arrowYOffset = 10.0;
    const arrowLength = 30.0; // ArrowNode tip distance along shaft

    final s = scaleFromOriginal;
    final imgLocalW = intrinsicW * imageContentScale;
    final imgLocalH = intrinsicH * imageContentScale;
    final left = viewOriginX + imageOffsetX * s;
    final top = modelToViewY(yModel) + imageOffsetY * s;
    final displayW = imgLocalW * s;
    final displayH = imgLocalH * s;

    // Arrows: centerX + 8; above image.top / below image.bottom (WrenchNode.ts).
    final arrowLocalX = imageOffsetX + imgLocalW / 2 + arrowXOffset;
    final arrowLeft = viewOriginX + arrowLocalX * s - (22 * s) / 2;
    final topArrowTipLocalY = imageOffsetY - arrowYOffset - arrowLength;
    final bottomArrowBaseLocalY = imageOffsetY + imgLocalH + arrowYOffset;
    final topArrowTop = modelToViewY(yModel) + topArrowTipLocalY * s;
    final bottomArrowTop = modelToViewY(yModel) + bottomArrowBaseLocalY * s;
    final arrowPaintH = arrowLength * s;

    return Positioned(
      left: 0,
      top: 0,
      width: woasLayoutWidth,
      height: woasLayoutHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (d) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          onDrag(viewToModelY(box.globalToLocal(d.globalPosition).dy));
        },
        onVerticalDragStart: (d) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          onDrag(viewToModelY(box.globalToLocal(d.globalPosition).dy));
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: left,
              top: top,
              child: Image.asset(
                WoasAssets.wrench,
                width: displayW,
                height: displayH,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
              ),
            ),
            if (arrowsVisible) ...[
              Positioned(
                left: arrowLeft,
                top: topArrowTop,
                child: CustomPaint(
                  size: Size(22 * s, arrowPaintH),
                  painter: _ArrowPainter(up: true),
                ),
              ),
              Positioned(
                left: arrowLeft,
                top: bottomArrowTop,
                child: CustomPaint(
                  size: Size(22 * s, arrowPaintH),
                  painter: _ArrowPainter(up: false),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.up});
  final bool up;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3399EE);
    final path = Path();
    if (up) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height * 0.55);
      path.lineTo(size.width * 0.65, size.height * 0.55);
      path.lineTo(size.width * 0.65, size.height);
      path.lineTo(size.width * 0.35, size.height);
      path.lineTo(size.width * 0.35, size.height * 0.55);
      path.lineTo(0, size.height * 0.55);
    } else {
      path.moveTo(size.width / 2, size.height);
      path.lineTo(size.width, size.height * 0.45);
      path.lineTo(size.width * 0.65, size.height * 0.45);
      path.lineTo(size.width * 0.65, 0);
      path.lineTo(size.width * 0.35, 0);
      path.lineTo(size.width * 0.35, size.height * 0.45);
      path.lineTo(0, size.height * 0.45);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) => oldDelegate.up != up;
}

class _OscillatorPost extends StatelessWidget {
  const _OscillatorPost({required this.yModel});
  final double yModel;

  @override
  Widget build(BuildContext context) {
    const beadPostOffset = 7.0;
    final wheelViewY = viewOriginY + scaleFromOriginal * 150;
    final beadViewY = modelToViewY(yModel) + beadPostOffset * scaleFromOriginal;
    final height = (wheelViewY - beadViewY).abs().clamp(1.0, 400.0);
    final top = math.min(wheelViewY, beadViewY);

    return Positioned(
      left: viewOriginX - 5 * scaleFromOriginal,
      top: top,
      child: Container(
        width: 10 * scaleFromOriginal,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF666666), Color(0xFFFFFFFF), Color(0xFF666666)],
            stops: [0, 0.3, 1],
          ),
        ),
      ),
    );
  }
}

class _OscillatorWheel extends StatelessWidget {
  const _OscillatorWheel({required this.angle});
  final double angle;

  @override
  Widget build(BuildContext context) {
    const r = 29.5;
    return Positioned(
      left: viewOriginX - r * scaleFromOriginal,
      top: viewOriginY + scaleFromOriginal * (150 - r),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: r * 2 * scaleFromOriginal,
          height: r * 2 * scaleFromOriginal,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD7D2D2),
            border: Border.all(color: const Color(0xFF333333), width: 1.5),
          ),
          child: Center(
            child: Container(
              width: 9.6 * scaleFromOriginal,
              height: 9.6 * scaleFromOriginal,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFF333333), width: 1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseBox extends StatelessWidget {
  const _PulseBox({required this.model});
  final WoasModel model;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: viewOriginX - 40 * scaleFromOriginal,
      top: viewOriginY + scaleFromOriginal * (150 - 25),
      child: Material(
        color: const Color(0xFFC8C8C8),
        borderRadius: BorderRadius.circular(6 * scaleFromOriginal),
        elevation: 2,
        child: SizedBox(
          width: 80 * scaleFromOriginal,
          height: 50 * scaleFromOriginal,
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF33DD33),
                minimumSize: Size(48 * scaleFromOriginal, 32 * scaleFromOriginal),
                padding: EdgeInsets.zero,
              ),
              onPressed: model.isPulseActive ? null : model.triggerPulse,
              child: Text(
                'Pulse',
                style: TextStyle(fontSize: 11 * scaleFromOriginal, color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

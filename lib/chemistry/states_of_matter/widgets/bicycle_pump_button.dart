import 'package:flutter/material.dart';

/// Bicycle pump — PhET `BicyclePumpNode` (handle drags ns; inject on down-stroke).
class BicyclePumpButton extends StatefulWidget {
  const BicyclePumpButton({
    super.key,
    required this.enabled,
    required this.onPump,
    this.width = 90,
    this.height = 110,
    this.drawHose = true,
    this.particlesPerStroke = 3,
  });

  final bool enabled;

  /// Inject [count] molecules (PhET `numberOfParticlesPerPumpAction`).
  final void Function(int count) onPump;
  final double width;
  final double height;

  /// When false, hose is drawn by [PumpHosePainter] at scene level.
  final bool drawHose;

  /// Full handle down-stroke injects this many particles.
  final int particlesPerStroke;

  /// Extra space above the visual pump so the handle can be pulled up.
  static double handleStroke(double height) => height * 0.38;

  @override
  State<BicyclePumpButton> createState() => _BicyclePumpButtonState();
}

class _BicyclePumpButtonState extends State<BicyclePumpButton> {
  /// 0 = rest (lowest); positive = pulled up, in view px.
  double _handleLift = 0;
  double _downAccum = 0;

  double get _maxStroke => BicyclePumpButton.handleStroke(widget.height);

  double get _distPerParticle =>
      (_maxStroke / widget.particlesPerStroke).clamp(4.0, 80.0);

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;
    final next = (_handleLift - details.delta.dy).clamp(0.0, _maxStroke);
    if (next < _handleLift) {
      _downAccum += _handleLift - next;
      var injected = 0;
      while (_downAccum >= _distPerParticle) {
        injected++;
        _downAccum -= _distPerParticle;
      }
      if (injected > 0) {
        widget.onPump(injected);
      }
    } else {
      _downAccum = 0;
    }
    setState(() => _handleLift = next);
  }

  @override
  Widget build(BuildContext context) {
    final pad = _maxStroke;
    return SizedBox(
      width: widget.width,
      height: widget.height + pad,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.45,
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.resizeUpDown
              : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled
                ? () => widget.onPump(widget.particlesPerStroke)
                : null,
            onVerticalDragUpdate: widget.enabled ? _onDragUpdate : null,
            child: CustomPaint(
              size: Size(widget.width, widget.height + pad),
              painter: _BicyclePumpPainter(
                drawHose: widget.drawHose,
                visualHeight: widget.height,
                handleLift: _handleLift,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BicyclePumpPainter extends CustomPainter {
  const _BicyclePumpPainter({
    this.drawHose = true,
    required this.visualHeight,
    this.handleLift = 0,
  });

  final bool drawHose;
  final double visualHeight;
  final double handleLift;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = visualHeight;
    final y0 = size.height - h;

    // PhET BicyclePumpNode proportions (width/height of node).
    final baseW = w * 0.55;
    final baseH = h * 0.075;
    final bodyW = w * 0.22; // thicker red barrel (reads like PhET screenshot)
    final bodyH = h * 0.62;
    final shaftW = bodyW * 0.28;
    final handleH = h * 0.055;
    final coneH = h * 0.10;
    final hoseConnectorW = w * 0.08;
    final hoseConnectorH = h * 0.04;

    // Center pump in widget; hose leaves left toward container.
    final cx = w * 0.55;
    final baseBottom = y0 + h - 3;
    final baseTop = baseBottom - baseH;
    final coneBottom = baseTop + 4;
    final coneTop = coneBottom - coneH;
    final bodyBottom = coneTop + 12;
    final bodyTop = bodyBottom - bodyH;
    final handleY = bodyTop - 12 - handleLift;

    // Soft ground shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, baseBottom - 1),
        width: baseW * 1.15,
        height: baseH * 0.85,
      ),
      Paint()
        ..color = const Color(0x44000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    final hoseAttach = Offset(cx - bodyW * 0.65, coneTop + coneH * 0.4);

    if (drawHose) {
      final hoseEnd = Offset(4, y0 + h * 0.5);
      final hosePath = Path()
        ..moveTo(hoseAttach.dx, hoseAttach.dy)
        ..cubicTo(
          hoseAttach.dx - w * 0.3,
          hoseAttach.dy,
          hoseEnd.dx + 10,
          hoseEnd.dy - h * 0.05,
          hoseEnd.dx + hoseConnectorW,
          hoseEnd.dy,
        );
      canvas.drawPath(
        hosePath,
        Paint()
          ..color = const Color(0xFFB3B3B3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
      _drawHoseConnector(
        canvas,
        Rect.fromCenter(
          center: hoseEnd,
          width: hoseConnectorW,
          height: hoseConnectorH,
        ),
      );
    }

    _drawHoseConnector(
      canvas,
      Rect.fromCenter(
        center: hoseAttach,
        width: hoseConnectorW,
        height: hoseConnectorH,
      ),
    );

    // Footplate
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, (baseTop + baseBottom) / 2),
        width: baseW,
        height: baseH,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      baseRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC8C8C8), Color(0xFF8A8A8A)],
        ).createShader(baseRect.outerRect),
    );

    // Conical base under barrel
    final cone = Path()
      ..moveTo(cx - bodyW * 0.62, coneTop)
      ..lineTo(cx + bodyW * 0.62, coneTop)
      ..lineTo(cx + baseW * 0.32, coneBottom)
      ..lineTo(cx - baseW * 0.32, coneBottom)
      ..close();
    canvas.drawPath(
      cone,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFFB8B8B8),
            Color(0xFFAAAAAA),
            Color(0xFF7A7A7A),
          ],
        ).createShader(Rect.fromLTRB(
          cx - baseW * 0.32,
          coneTop,
          cx + baseW * 0.32,
          coneBottom,
        )),
    );

    // Shaft
    final shaftTop = handleY + handleH * 0.45;
    final shaftBottom = bodyTop + 8;
    if (shaftBottom > shaftTop) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            cx - shaftW / 2,
            shaftTop,
            cx + shaftW / 2,
            shaftBottom,
          ),
          const Radius.circular(1),
        ),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFE0E0E0), Color(0xFFCACACA), Color(0xFF9A9A9A)],
          ).createShader(
            Rect.fromLTRB(cx - shaftW / 2, shaftTop, cx + shaftW / 2, shaftBottom),
          ),
      );
    }

    // Red barrel — PhET bodyFill `#d50000`
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, (bodyTop + bodyBottom) / 2),
        width: bodyW,
        height: bodyH,
      ),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFF5555),
            Color(0xFFD50000),
            Color(0xFF9A0000),
          ],
          stops: [0.0, 0.4, 0.75],
        ).createShader(bodyRect.outerRect),
    );

    // Segmented capacity indicator (PhET SegmentedBarGraphNode look)
    final indW = bodyW * 0.55;
    final indH = bodyH * 0.72;
    final indRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, (bodyTop + bodyBottom) / 2),
        width: indW,
        height: indH,
      ),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(indRect, Paint()..color = const Color(0xFF443333));
    const segments = 28;
    final litH = indH * 0.55; // remaining capacity fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          indRect.left,
          indRect.bottom - litH,
          indW,
          litH,
        ),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xFF999999),
    );
    final tickPaint = Paint()
      ..color = const Color(0xFF2A1A1A)
      ..strokeWidth = 1;
    for (var i = 1; i < segments; i++) {
      final ty = indRect.top + indH * (i / segments);
      canvas.drawLine(
        Offset(indRect.left + 1, ty),
        Offset(indRect.right - 1, ty),
        tickPaint,
      );
    }

    // Body top ellipse
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bodyTop),
        width: bodyW * 1.15,
        height: 7,
      ),
      Paint()..color = const Color(0xFF997677),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bodyTop),
        width: bodyW * 1.15,
        height: 7,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = const Color(0xFF5A4545),
    );

    // T-handle with grip bumps (PhET PumpHandleNode style)
    final handleW = w * 0.58;
    final handleRadius = handleH * 0.35;
    final handleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, handleY),
        width: handleW,
        height: handleH,
      ),
      Radius.circular(handleRadius),
    );
    canvas.drawRRect(
      handleRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD0D2D4),
            Color(0xFFADAFB1),
            Color(0xFF7A7C7E),
          ],
        ).createShader(handleRect.outerRect),
    );
    // Center hub
    canvas.drawCircle(
      Offset(cx, handleY),
      handleH * 0.55,
      Paint()..color = const Color(0xFF9A9C9E),
    );
    // Grip notches on each side
    final notch = Paint()
      ..color = const Color(0xFF5A5C5E)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (final side in [-1.0, 1.0]) {
      for (var i = 1; i <= 3; i++) {
        final x = cx + side * (handleW * 0.12 + i * handleW * 0.08);
        canvas.drawLine(
          Offset(x, handleY - handleH * 0.28),
          Offset(x, handleY + handleH * 0.28),
          notch,
        );
      }
    }
  }

  void _drawHoseConnector(Canvas canvas, Rect rect) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFFC0C0C0), Color(0xFF8A8A8A)],
        ).createShader(rect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..color = const Color(0xFF666666),
    );
  }

  @override
  bool shouldRepaint(covariant _BicyclePumpPainter oldDelegate) =>
      oldDelegate.drawHose != drawHose ||
      oldDelegate.visualHeight != visualHeight ||
      oldDelegate.handleLift != handleLift;
}

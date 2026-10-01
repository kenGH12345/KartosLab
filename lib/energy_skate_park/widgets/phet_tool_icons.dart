import 'package:flutter/material.dart';

/// Stopwatch toolbox icon — rasterized StopwatchNode preview (ToolboxPanel.ts scale 0.4).
class PhetStopwatchIcon extends StatelessWidget {
  const PhetStopwatchIcon({super.key, this.scale = 1.0});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(72 * scale, 36 * scale),
      painter: _StopwatchIconPainter(),
    );
  }
}

class _StopwatchIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height * 0.18),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..color = const Color(0xFF4A90C8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      r.deflate(2),
      Paint()..color = const Color(0xFFE8F4FC),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '00:00.0',
        style: TextStyle(
          fontSize: size.height * 0.42,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Measuring tape toolbox icon — MeasuringTapeNode.createIcon (ToolboxPanel.ts scale 0.7).
class PhetMeasuringTapeIcon extends StatelessWidget {
  const PhetMeasuringTapeIcon({super.key, this.scale = 1.0});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(48 * scale, 40 * scale),
      painter: _MeasuringTapeIconPainter(),
    );
  }
}

class _MeasuringTapeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.35;
    final cy = size.height * 0.55;
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.28,
      Paint()..color = const Color(0xFFFFEB3B),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.28,
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final hx = size.width * 0.82;
    final hy = size.height * 0.35;
    canvas.drawLine(
      Offset(hx - 6, hy),
      Offset(hx + 6, hy),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(hx, hy - 6),
      Offset(hx, hy + 6),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(cx, cy),
      Offset(hx, hy),
      Paint()
        ..color = const Color(0xFFFFF176)
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Eraser button icon — EraserButton.ts (Playground bottom bar).
class PhetEraserIcon extends StatelessWidget {
  const PhetEraserIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EraserIconPainter(),
    );
  }
}

class _EraserIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.35, w * 0.55, h * 0.45),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFEF5350));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.55, h * 0.25, w * 0.3, h * 0.35),
        Radius.circular(w * 0.06),
      ),
      Paint()..color = const Color(0xFFBBDEFB),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

/// Shared LaserPointer-style emitter (scenery-phet chrome).
///
/// Used by Experiment overhead, High Intensity source beam, etc.
class QwiLaserPointer extends StatelessWidget {
  const QwiLaserPointer({
    super.key,
    required this.emitting,
    required this.onToggle,
    this.isPhoton = true,
    this.beamColor = const Color(0xFFFF0000),
    this.sourceScale = 1.0,
    this.width,
    this.height,
  });

  final bool emitting;
  final VoidCallback onToggle;
  final bool isPhoton;
  final Color beamColor;
  final double sourceScale;
  final double? width;
  final double? height;

  static double bodyWidth(double scale) => (88 + 16) * scale;
  static double bodyHeight(double scale) => 40 * scale;

  @override
  Widget build(BuildContext context) {
    final w = width ?? bodyWidth(sourceScale);
    final h = height ?? bodyHeight(sourceScale);
    return GestureDetector(
      onTap: onToggle,
      child: CustomPaint(
        size: Size(w, h),
        painter: QwiLaserPointerPainter(
          emitting: emitting,
          beamColor: beamColor,
          isPhoton: isPhoton,
          sourceScale: sourceScale,
        ),
      ),
    );
  }
}

class QwiLaserPointerPainter extends CustomPainter {
  QwiLaserPointerPainter({
    required this.emitting,
    required this.beamColor,
    required this.isPhoton,
    required this.sourceScale,
  });

  final bool emitting;
  final Color beamColor;
  final bool isPhoton;
  final double sourceScale;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyW = 88 * sourceScale;
    final bodyH = 40 * sourceScale;
    final nozzleW = 16 * sourceScale;
    final nozzleH = 32 * sourceScale;
    final buttonR = 14 * sourceScale;
    const corner = 5.0;

    final cy = size.height / 2;
    final nozzleLeft = bodyW - corner;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, cy - bodyH / 2, bodyW, bodyH),
      const Radius.circular(corner),
    );
    final nozzleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(nozzleLeft, cy - nozzleH / 2, nozzleW + corner, nozzleH),
      const Radius.circular(3),
    );

    final top = isPhoton ? const Color(0xFFAAAAAA) : const Color(0xFF6478B4);
    final mid = isPhoton ? const Color(0xFFF5F5F5) : const Color(0xFFC8D0E8);
    final bot = isPhoton ? const Color(0xFF282828) : const Color(0xFF283048);

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, mid, bot],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final nozzlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, mid, bot],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(nozzleRect.outerRect);
    canvas.drawRRect(nozzleRect, nozzlePaint);
    canvas.drawRRect(
      nozzleRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final btnCenter = Offset(bodyW / 2, cy);
    final btnFill = emitting ? const Color(0xFFE53935) : const Color(0xFFC62828);
    canvas.drawCircle(btnCenter, buttonR, Paint()..color = btnFill);
    canvas.drawCircle(
      btnCenter.translate(-buttonR * 0.25, -buttonR * 0.25),
      buttonR * 0.35,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      btnCenter,
      buttonR,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (emitting) {
      final tipX = nozzleLeft + nozzleW + corner;
      final beam = Path()
        ..moveTo(tipX, cy - 5)
        ..lineTo(size.width, cy - 8)
        ..lineTo(size.width, cy + 8)
        ..lineTo(tipX, cy + 5)
        ..close();
      canvas.drawPath(beam, Paint()..color = beamColor.withValues(alpha: 0.55));
    }
  }

  @override
  bool shouldRepaint(covariant QwiLaserPointerPainter oldDelegate) {
    return oldDelegate.emitting != emitting ||
        oldDelegate.beamColor != beamColor ||
        oldDelegate.isPhoton != isPhoton ||
        oldDelegate.sourceScale != sourceScale;
  }
}

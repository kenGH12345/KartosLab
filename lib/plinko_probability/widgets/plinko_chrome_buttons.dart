import 'package:flutter/material.dart';

import '../plinko_colors.dart';
import '../plinko_constants.dart';

/// Green circular play button — `PlayButton.js` / RoundPushButton.
///
/// Triangle sized relative to [radius]; slight +X content offset.
/// [baseColor] = `rgb(0, 224, 121)`.
class PlinkoPlayButton extends StatelessWidget {
  const PlinkoPlayButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.radius = PlinkoConstants.playPauseButtonRadius,
  });

  final VoidCallback? onPressed;
  final bool enabled;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: CustomPaint(
        size: Size(radius * 2, radius * 2),
        painter: _PlayPainter(enabled: enabled, radius: radius),
      ),
    );
  }
}

class _PlayPainter extends CustomPainter {
  _PlayPainter({required this.enabled, required this.radius});
  final bool enabled;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = radius;
    // ThreeDAppearanceStrategy-ish radial highlight on baseColor
    final base = enabled
        ? const Color.fromRGBO(0, 224, 121, 1)
        : const Color(0xFF9E9E9E);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.05,
          colors: [
            Color.lerp(base, Colors.white, 0.45)!,
            base,
            Color.lerp(base, Colors.black, 0.25)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // PlayButton.js: triangleHeight = radius, triangleWidth = radius * 0.8
    // + xContentOffset ≈ 0.1 * triangleWidth. Vertically fills content
    // (radius − yMargin)*2 with yMargin=15 → height ≈ radius.
    final th = r;
    final tw = r * 0.8;
    final xOff = 0.1 * tw;
    final path = Path()
      ..moveTo(c.dx - tw / 2 + xOff, c.dy - th / 2)
      ..lineTo(c.dx + tw / 2 + xOff, c.dy)
      ..lineTo(c.dx - tw / 2 + xOff, c.dy + th / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _PlayPainter oldDelegate) =>
      oldDelegate.enabled != enabled || oldDelegate.radius != radius;
}

/// Pause button — `PauseButton.js` baseColor **red**.
class PlinkoPauseButton extends StatelessWidget {
  const PlinkoPauseButton({
    super.key,
    required this.onPressed,
    this.radius = PlinkoConstants.playPauseButtonRadius,
  });

  final VoidCallback? onPressed;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        size: Size(radius * 2, radius * 2),
        painter: _PausePainter(radius: radius),
      ),
    );
  }
}

class _PausePainter extends CustomPainter {
  _PausePainter({required this.radius});
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = radius;
    const base = Color.fromRGBO(237, 28, 36, 1);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.05,
          colors: [
            Color.lerp(base, Colors.white, 0.4)!,
            base,
            Color.lerp(base, Colors.black, 0.2)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // barWidth = 0.2 r, barHeight = r, gap = barWidth between bars
    final barW = r * 0.2;
    final barH = r;
    final paint = Paint()..color = Colors.black;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(c.dx - 1.5 * barW, c.dy),
        width: barW,
        height: barH,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(c.dx + 1.5 * barW, c.dy),
        width: barW,
        height: barH,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PausePainter oldDelegate) =>
      oldDelegate.radius != radius;
}

/// Eraser button (yellow square with eraser glyph).
class PlinkoEraserButton extends StatelessWidget {
  const PlinkoEraserButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFE066),
      borderRadius: BorderRadius.circular(6),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: CustomPaint(painter: _EraserIconPainter()),
        ),
      ),
    );
  }
}

class _EraserIconPainter extends CustomPainter {
  const _EraserIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 22,
        height: 14,
      ),
      const Radius.circular(2),
    );
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.4);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawRRect(rect, Paint()..color = Colors.white);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Sound toggle — speaker with optional mute X (drawn, not Material icon as sim chrome).
class PlinkoSoundToggle extends StatelessWidget {
  const PlinkoSoundToggle({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFE066),
      borderRadius: BorderRadius.circular(6),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 44,
          height: 44,
          child: CustomPaint(painter: _SpeakerPainter(muted: !enabled)),
        ),
      ),
    );
  }
}

class _SpeakerPainter extends CustomPainter {
  _SpeakerPainter({required this.muted});
  final bool muted;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final path = Path()
      ..moveTo(c.dx - 8, c.dy - 5)
      ..lineTo(c.dx - 2, c.dy - 5)
      ..lineTo(c.dx + 6, c.dy - 10)
      ..lineTo(c.dx + 6, c.dy + 10)
      ..lineTo(c.dx - 2, c.dy + 5)
      ..lineTo(c.dx - 8, c.dy + 5)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black87);
    if (muted) {
      canvas.drawLine(
        Offset(c.dx - 10, c.dy - 10),
        Offset(c.dx + 12, c.dy + 10),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpeakerPainter oldDelegate) =>
      oldDelegate.muted != muted;
}

/// N = readout panel.
class NumberBallsDisplay extends StatelessWidget {
  const NumberBallsDisplay({super.key, required this.n});

  final int n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: PlinkoColors.panelBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        'N = $n',
        style: const TextStyle(
          color: PlinkoColors.sampleFont,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

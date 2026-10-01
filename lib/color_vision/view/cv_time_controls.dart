import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// PhET Color Vision `TimeControlNode` — play/pause + step only (no speed radios).
///
/// `playPauseStepXSpacing ≈ 14`.
class CvTimeControls extends StatelessWidget {
  const CvTimeControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onStep,
    this.playPauseRadius = 20,
    this.stepRadius = 15,
  });

  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onStep;
  final double playPauseRadius;
  final double stepRadius;

  static const double playPauseStepXSpacing = 14;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundButton(
          key: const Key('color_vision_play_pause'),
          radius: playPauseRadius,
          baseColor: const Color(0xFF6CC4E8),
          onTap: onPlayPause,
          child: CustomPaint(
            size: Size(playPauseRadius * 2, playPauseRadius * 2),
            painter: isPlaying ? const _PauseIconPainter() : const _PlayIconPainter(),
          ),
        ),
        const SizedBox(width: playPauseStepXSpacing),
        _RoundButton(
          key: const Key('color_vision_step'),
          radius: stepRadius,
          baseColor: const Color(0xFFB0B0B0),
          onTap: isPlaying ? null : onStep,
          enabled: !isPlaying,
          child: CustomPaint(
            size: Size(stepRadius * 2, stepRadius * 2),
            painter: _StepIconPainter(enabled: !isPlaying),
          ),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    super.key,
    required this.radius,
    required this.baseColor,
    required this.child,
    required this.onTap,
    this.enabled = true,
  });

  final double radius;
  final Color baseColor;
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: CustomPaint(
          size: Size(d, d),
          painter: _SphereButtonPainter(baseColor),
          child: SizedBox(width: d, height: d, child: Center(child: child)),
        ),
      ),
    );
  }
}

class _SphereButtonPainter extends CustomPainter {
  const _SphereButtonPainter(this.base);

  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final highlight = center + Offset(-r * 0.38, -r * 0.42);
    final hsl = HSLColor.fromColor(base);
    final light = hsl.withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0)).toColor();
    final dark = hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + r * 0.42),
        width: r * 1.55,
        height: r * 0.4,
      ),
      Paint()
        ..color = const Color(0x44000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          highlight,
          r * 1.55,
          [Colors.white, light, base, dark],
          const [0.0, 0.22, 0.55, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _SphereButtonPainter oldDelegate) =>
      oldDelegate.base != base;
}

class _PlayIconPainter extends CustomPainter {
  const _PlayIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF222222);
    final path = Path()
      ..moveTo(size.width * 0.34, size.height * 0.24)
      ..lineTo(size.width * 0.78, size.height * 0.5)
      ..lineTo(size.width * 0.34, size.height * 0.76)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PauseIconPainter extends CustomPainter {
  const _PauseIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF222222);
    final w = size.width * 0.16;
    final gap = size.width * 0.12;
    final left = size.width * 0.3;
    final top = size.height * 0.24;
    final h = size.height * 0.52;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, w, h),
        const Radius.circular(1.5),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + w + gap, top, w, h),
        const Radius.circular(1.5),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StepIconPainter extends CustomPainter {
  _StepIconPainter({required this.enabled});

  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = enabled ? const Color(0xFF222222) : const Color(0xFF888888);
    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.24)
      ..lineTo(size.width * 0.58, size.height * 0.5)
      ..lineTo(size.width * 0.22, size.height * 0.76)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.64,
          size.height * 0.24,
          size.width * 0.12,
          size.height * 0.52,
        ),
        const Radius.circular(1),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _StepIconPainter oldDelegate) =>
      oldDelegate.enabled != enabled;
}

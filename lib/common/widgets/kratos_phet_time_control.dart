import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// scenery-phet `TimeControlNode` — PlayPauseButton + StepForwardButton.
///
/// L0 chrome: `RoundPushButton` + `ThreeDAppearanceStrategy`. No Material icons.
/// Defaults: play/pause radius 20, step radius 15 (TimeControlNode).
class KratosPhetTimeControl extends StatelessWidget {
  const KratosPhetTimeControl({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onStep,
    this.playPauseRadius = 20,
    this.stepRadius = 15,
    this.spacing = 10,
  });

  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onStep;
  final double playPauseRadius;
  final double stepRadius;
  final double spacing;

  double get intrinsicWidth => playPauseRadius * 2 + spacing + stepRadius * 2;
  double get intrinsicHeight => playPauseRadius * 2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundControlButton(
          key: const Key('phet_play_pause'),
          radius: playPauseRadius,
          onTap: onPlayPause,
          child: CustomPaint(
            size: Size(playPauseRadius * 2, playPauseRadius * 2),
            painter:
                isPlaying ? const _PauseIconPainter() : const _PlayIconPainter(),
          ),
        ),
        SizedBox(width: spacing),
        _RoundControlButton(
          key: const Key('phet_step'),
          radius: stepRadius,
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

const Color _kButtonBlue = Color(0xFF6CC4E8);
const Color _kButtonBlueDark = Color(0xFF3A9BC4);
const Color _kButtonBlueLight = Color(0xFFB8E6F6);
const Color _kIconFill = Color(0xFF222222);

class _RoundControlButton extends StatelessWidget {
  const _RoundControlButton({
    super.key,
    required this.radius,
    required this.child,
    required this.onTap,
    this.enabled = true,
  });

  final double radius;
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
          painter: const _BlueRoundButtonPainter(),
          child: SizedBox(
            width: d,
            height: d,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _BlueRoundButtonPainter extends CustomPainter {
  const _BlueRoundButtonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);

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

    final highlight = center + Offset(-r * 0.38, -r * 0.42);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          highlight,
          r * 1.55,
          const [
            Color(0xFFE8F7FC),
            _kButtonBlueLight,
            _kButtonBlue,
            _kButtonBlueDark,
          ],
          const [0.0, 0.22, 0.55, 1.0],
        ),
    );

    canvas.drawCircle(
      center,
      r - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x66034670),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayIconPainter extends CustomPainter {
  const _PlayIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _kIconFill;
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
    final paint = Paint()..color = _kIconFill;
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
      ..color = enabled ? _kIconFill : const Color(0xFF888888);
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

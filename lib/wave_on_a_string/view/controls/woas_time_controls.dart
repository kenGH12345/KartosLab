import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../model/woas_model.dart';
import '../../model/woas_time_speed.dart';

/// Play/Pause + Step + Normal/Slow (`TimeControlNode`).
class WoasTimeControls extends StatelessWidget {
  const WoasTimeControls({
    super.key,
    required this.model,
    required this.onStep,
  });

  final WoasModel model;
  final VoidCallback onStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundIconButton(
          key: const Key('play_pause_button'),
          diameter: model.isPlaying ? 48 : 48 * 1.25,
          color: const Color(0xFF4A90D9),
          onTap: () => model.setPlaying(!model.isPlaying),
          child: CustomPaint(
            size: const Size(22, 22),
            painter: _PlayPausePainter(playing: model.isPlaying),
          ),
        ),
        const SizedBox(width: 8),
        _RoundIconButton(
          key: const Key('step_button'),
          diameter: 36,
          color: const Color(0xFF9E9E9E),
          onTap: onStep,
          child: CustomPaint(
            size: const Size(16, 16),
            painter: _StepPainter(),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SpeedRow(
              key: const Key('speed_normal'),
              label: 'Normal',
              selected: model.timeSpeed == WoasTimeSpeed.normal,
              onTap: () => model.setTimeSpeed(WoasTimeSpeed.normal),
            ),
            _SpeedRow(
              key: const Key('speed_slow'),
              label: 'Slow Motion',
              selected: model.timeSpeed == WoasTimeSpeed.slow,
              onTap: () => model.setTimeSpeed(WoasTimeSpeed.slow),
            ),
          ],
        ),
      ],
    );
  }
}

class _SpeedRow extends StatelessWidget {
  const _SpeedRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(14, 14),
              painter: _DotRadioPainter(selected: selected),
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _DotRadioPainter extends CustomPainter {
  _DotRadioPainter({required this.selected});
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      6,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    if (selected) {
      canvas.drawCircle(c, 3.5, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(covariant _DotRadioPainter oldDelegate) =>
      oldDelegate.selected != selected;
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    super.key,
    required this.diameter,
    required this.color,
    required this.onTap,
    required this.child,
  });

  final double diameter;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: const [
            BoxShadow(blurRadius: 3, offset: Offset(0, 1), color: Colors.black26),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _PlayPausePainter extends CustomPainter {
  _PlayPausePainter({required this.playing});
  final bool playing;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    if (playing) {
      // Pause bars
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.28, size.height * 0.2, size.width * 0.16,
              size.height * 0.6),
          const Radius.circular(2),
        ),
        p,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.56, size.height * 0.2, size.width * 0.16,
              size.height * 0.6),
          const Radius.circular(2),
        ),
        p,
      );
    } else {
      final path = Path()
        ..moveTo(size.width * 0.32, size.height * 0.2)
        ..lineTo(size.width * 0.78, size.height * 0.5)
        ..lineTo(size.width * 0.32, size.height * 0.8)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _PlayPausePainter oldDelegate) =>
      oldDelegate.playing != playing;
}

class _StepPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.65, size.height * 0.5)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..close();
    canvas.drawPath(path, p);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.7, size.height * 0.2, size.width * 0.12,
          size.height * 0.6),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Light-blue Restart — scenery-phet `RestartUndoButton` / `RectangularPushButton`.
///
/// Rounded rectangle + FontAwesome-style black undo glyph (not a round white-arrow button).
class WoasRestartButton extends StatelessWidget {
  const WoasRestartButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  /// Approximate content + `xMargin:6` / `yMargin:5` from RestartUndoButton.
  static const Size buttonSize = Size(42, 36);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Restart String',
      child: GestureDetector(
        key: const Key('restart_button'),
        onTap: onPressed,
        child: CustomPaint(
          size: buttonSize,
          painter: _RestartUndoPainter(),
        ),
      ),
    );
  }
}

/// `ColorConstants.LIGHT_BLUE` base + ThreeD-ish bevel + black undo icon.
class _RestartUndoPainter extends CustomPainter {
  // sun ColorConstants.LIGHT_BLUE ≈ sky blue used by RestartUndoButton
  static const Color _base = Color(0xFF6CC4E8);
  static const Color _light = Color(0xFFB8E6F6);
  static const Color _dark = Color(0xFF3A9BC4);
  static const Color _icon = Color(0xFF222222);

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.shortestSide * 0.22),
    );

    // Raised rectangular body (lighter top-left, darker bottom-right).
    final body = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_light, _base, _dark],
        stops: [0.0, 0.45, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(rrect, body);

    // Soft outer outline
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF2A5A70).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Top highlight edge
    final highlight = RRect.fromRectAndRadius(
      Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height * 0.42),
      Radius.circular(size.shortestSide * 0.18),
    );
    canvas.drawRRect(
      highlight,
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );

    _paintUndoIcon(canvas, size);
  }

  /// FontAwesome `undoSolid` silhouette: CCW arc, arrowhead pointing left.
  void _paintUndoIcon(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.shortestSide * 0.28;
    final stroke = size.shortestSide * 0.125;

    final arcPaint = Paint()
      ..color = _icon
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Gap near top-right; sweep CCW ending on the left (arrow points ←).
    // Canvas: 0=east, positive=CW → negative sweep = CCW.
    const arcStart = math.pi * 0.15;
    const arcSweep = -math.pi * 1.55;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      arcStart,
      arcSweep,
      false,
      arcPaint,
    );

    final endAngle = arcStart + arcSweep;
    final tip = Offset(
      cx + r * math.cos(endAngle),
      cy + r * math.sin(endAngle),
    );
    final hw = size.shortestSide * 0.20;
    final path = Path()
      ..moveTo(tip.dx - hw * 0.35, tip.dy)
      ..lineTo(tip.dx + hw * 0.65, tip.dy - hw * 0.7)
      ..lineTo(tip.dx + hw * 0.65, tip.dy + hw * 0.7)
      ..close();
    canvas.drawPath(path, Paint()..color = _icon);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Convenience wrapper exposing Reset All L0.
class WoasResetAllControl extends StatelessWidget {
  const WoasResetAllControl({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return KratosResetAllButton(
      key: const Key('reset_all_button'),
      onPressed: onPressed,
      radius: 20.5,
      tooltip: 'Reset All',
    );
  }
}

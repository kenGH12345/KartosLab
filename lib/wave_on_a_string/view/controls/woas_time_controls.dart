import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../model/woas_model.dart';
import '../../model/woas_time_speed.dart';
import 'package:kratos/wave_on_a_string/woas_strings.dart';

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
              label: WoasStrings.normal,
              selected: model.timeSpeed == WoasTimeSpeed.normal,
              onTap: () => model.setTimeSpeed(WoasTimeSpeed.normal),
            ),
            _SpeedRow(
              key: const Key('speed_slow'),
              label: WoasStrings.slowMotion,
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

/// Light-blue Restart — scenery-phet `RestartUndoButton` chrome
/// (`ColorConstants.LIGHT_BLUE` + 3D rounded rect) with ResetShape-style
/// black circular arrow, matching the published WOAS control.
class WoasRestartButton extends StatelessWidget {
  const WoasRestartButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const Size buttonSize = Size(40, 40);

  /// `sun/js/ColorConstants.ts` LIGHT_BLUE
  static const Color lightBlue = Color.fromARGB(255, 153, 206, 255);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: WoasStrings.restartString,
      child: GestureDetector(
        key: const Key('restart_button'),
        onTap: onPressed,
        child: CustomPaint(
          size: buttonSize,
          painter: const _RestartUndoPainter(),
        ),
      ),
    );
  }
}

class _RestartUndoPainter extends CustomPainter {
  const _RestartUndoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      const Radius.circular(8),
    );

    canvas.drawRRect(
      rrect.shift(const Offset(0, 1.2)),
      Paint()
        ..color = const Color.fromRGBO(0, 0, 0, 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.42, -0.55),
          radius: 1.05,
          colors: [
            const Color(0xFFE8F7FF),
            WoasRestartButton.lightBlue,
            Color.lerp(WoasRestartButton.lightBlue, const Color(0xFF3A7FB8), 0.45)!,
          ],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(Offset.zero & size),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.5),
          radius: 0.55,
          colors: [
            Color.fromRGBO(255, 255, 255, 0.62),
            Color(0x00FFFFFF),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color.fromRGBO(40, 90, 130, 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 + 0.5);
    canvas.drawPath(_circularUndoPath(size.shortestSide * 0.32), Paint()..color = Colors.black);
    canvas.restore();
  }

  /// Filled CCW circular arrow (same family as scenery-phet `ResetShape`),
  /// gap at upper-right, head pointing left — matches the WOAS screenshot.
  static Path _circularUndoPath(double radius) {
    const adj = 0.35;
    final innerR = radius * 0.62 - adj;
    final outerR = radius * 1.05 + adj;
    final headWidth = 2.05 * (outerR - innerR);
    const startAngle = -math.pi * 0.28;
    const endToNeck = -2 * math.pi * 0.78;
    const arrowHeadSpan = -math.pi * 0.20;
    final neckAngle = startAngle + endToNeck;
    final extrusion = (headWidth - (outerR - innerR)) / 2;
    final path = Path()
      ..moveTo(innerR * math.cos(startAngle), innerR * math.sin(startAngle))
      ..lineTo(outerR * math.cos(startAngle), outerR * math.sin(startAngle));
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: outerR),
      startAngle,
      endToNeck,
      false,
    );
    path
      ..lineTo(
        (outerR + extrusion) * math.cos(neckAngle),
        (outerR + extrusion) * math.sin(neckAngle),
      )
      ..lineTo(
        ((outerR + innerR) * 0.52) * math.cos(neckAngle + arrowHeadSpan),
        ((outerR + innerR) * 0.52) * math.sin(neckAngle + arrowHeadSpan),
      )
      ..lineTo(
        (innerR - extrusion) * math.cos(neckAngle),
        (innerR - extrusion) * math.sin(neckAngle),
      )
      ..lineTo(innerR * math.cos(neckAngle), innerR * math.sin(neckAngle));
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: innerR),
      neckAngle,
      -endToNeck,
      false,
    );
    path.close();
    return path;
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
      tooltip: WoasStrings.resetAll,
    );
  }
}

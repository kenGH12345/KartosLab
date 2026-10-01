import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/enums.dart';
import '../screens/stage_scale.dart';
import '../phet_font.dart';

/// `LaserTypeAquaRadioButtonGroup`: `AquaRadioButton` radius 6, `PhetFont` 12,
/// vertical spacing 10.
///
/// `sun/js/AquaRadioButton.ts` is not in the local tree. The circle and the
/// selected center are the call-site structure. The aqua gradient is
/// `VERSION_DELTA` / not local.
class PhetAquaRadio extends StatelessWidget {
  const PhetAquaRadio({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.radius = 6,
    this.fontSize = 12,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    final r = radius * view;
    return Semantics(
      container: true,
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onSelected,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: Size(r * 2, r * 2),
              painter: _RadioPainter(selected: selected),
            ),
            SizedBox(width: 6 * view),
            Text(label, style: PhetFont.of(fontSize)),
          ],
        ),
      ),
    );
  }
}

class _RadioPainter extends CustomPainter {
  _RadioPainter({required this.selected});

  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius - 0.5, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawCircle(
      center,
      radius - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF000000),
    );
    if (selected) {
      canvas.drawCircle(center, radius * 0.55, Paint()..color = const Color(0xFF000000));
    }
  }

  @override
  bool shouldRepaint(covariant _RadioPainter oldDelegate) => oldDelegate.selected != selected;
}

/// `Checkbox` call site: `boxWidth` 15, spacing 5.
///
/// `sun/js/Checkbox.ts` is not local. The box size is the call site. The check
/// path is not in the tree (`VERSION_DELTA`); it is two segments, not `Icons.check`.
class PhetCheckbox extends StatelessWidget {
  const PhetCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.boxWidth = 15,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final double boxWidth;

  @override
  Widget build(BuildContext context) {
    final side = boxWidth * StageScale.of(context);
    return Semantics(
      checked: checked,
      label: checked ? 'checked' : 'unchecked',
      child: GestureDetector(
        onTap: () => onChanged(!checked),
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          size: Size(side, side),
          painter: _CheckPainter(checked: checked),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.checked});

  final bool checked;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect.deflate(0.5), Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawRect(
      rect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF000000),
    );
    if (!checked) return;
    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.74)
      ..lineTo(size.width * 0.78, size.height * 0.28);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.square
        ..color = const Color(0xFF000000),
    );
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) => oldDelegate.checked != checked;
}

/// Dashed normal icon (`NormalLine` height 17, dash `[4, 3]`).
class NormalLineIcon extends StatelessWidget {
  const NormalLineIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(2, 17),
      painter: _DashPainter(),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dash = 4.0;
    const gap = 3.0;
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 1;
    var y = 0.0;
    while (y < size.height) {
      final end = math.min(y + dash, size.height);
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, end), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// `AngleIcon`: edge 15, angle `pi/4`, arc radius `15 * 0.55`.
class AngleMarkIcon extends StatelessWidget {
  const AngleMarkIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 16),
      painter: _AnglePainter(),
    );
  }
}

class _AnglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const edge = 15.0;
    final angle = math.pi * 3 / 4 - math.pi / 2;
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..moveTo(edge, 0)
      ..lineTo(0, 0)
      ..lineTo(edge * math.cos(angle), -edge * math.sin(angle));
    canvas.save();
    canvas.translate(1, 14);
    canvas.drawPath(path, paint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: edge * 0.55),
      math.pi / 12,
      -angle - math.pi / 12,
      false,
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// `TimeControlNode` layout from `IntroScreenView`:
/// speed radios on the left, spacing 10, then play/pause (radius 20.8) and
/// step (radius 15). Icons are local `PlayIconShape` / `PauseIconShape` /
/// `StepButton`. `RoundPushButton` bevel is sun and is not painted.
///
/// Time itself stays on the model callbacks. This widget starts no timer.
class SourceTimeControl extends StatelessWidget {
  const SourceTimeControl({
    super.key,
    required this.isPlaying,
    required this.speed,
    required this.onPlayPause,
    required this.onStep,
    required this.onSpeed,
  });

  final bool isPlaying;
  final TimeSpeed speed;
  final VoidCallback onPlayPause;
  final VoidCallback onStep;
  final ValueChanged<TimeSpeed> onSpeed;

  static const double playRadius = 20.8;
  static const double stepRadius = 15;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhetAquaRadio(
              label: 'Normal',
              selected: speed == TimeSpeed.normal,
              fontSize: 14,
              radius: 7,
              onSelected: () => onSpeed(TimeSpeed.normal),
            ),
            const SizedBox(height: 9),
            PhetAquaRadio(
              label: 'Slow',
              selected: speed == TimeSpeed.slow,
              fontSize: 14,
              radius: 7,
              onSelected: () => onSpeed(TimeSpeed.slow),
            ),
          ],
        ),
        const SizedBox(width: 10),
        _RoundIconButton(
          radius: playRadius,
          semanticsLabel: isPlaying ? 'Pause' : 'Play',
          onPressed: onPlayPause,
          painter: _PlayPausePainter(playing: isPlaying, radius: playRadius),
        ),
        const SizedBox(width: 10),
        _RoundIconButton(
          radius: stepRadius,
          semanticsLabel: 'Step',
          enabled: !isPlaying,
          onPressed: onStep,
          painter: _StepPainter(radius: stepRadius),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.radius,
    required this.semanticsLabel,
    required this.onPressed,
    required this.painter,
    this.enabled = true,
  });

  final double radius;
  final String semanticsLabel;
  final VoidCallback onPressed;
  final CustomPainter painter;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: semanticsLabel,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: CustomPaint(
            size: Size(radius * 2, radius * 2),
            painter: painter,
          ),
        ),
      ),
    );
  }
}

class _PlayPausePainter extends CustomPainter {
  _PlayPausePainter({required this.playing, required this.radius});

  final bool playing;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius - 0.5, Paint()..color = const Color(0xFFE6E6E6));
    canvas.drawCircle(
      center,
      radius - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF000000),
    );
    final fill = Paint()..color = const Color(0xFF000000);
    if (playing) {
      final pauseHeight = radius;
      final pauseWidth = radius * 0.6;
      final bar = pauseWidth / 3;
      final left = center.dx - pauseWidth / 2;
      final top = center.dy - pauseHeight / 2;
      canvas.drawRect(Rect.fromLTWH(left, top, bar, pauseHeight), fill);
      canvas.drawRect(Rect.fromLTWH(left + 2 * bar, top, bar, pauseHeight), fill);
    } else {
      final playWidth = radius * 0.8;
      final playHeight = radius;
      final path = Path()
        ..moveTo(center.dx - playWidth / 2, center.dy - playHeight / 2)
        ..lineTo(center.dx + playWidth / 2, center.dy)
        ..lineTo(center.dx - playWidth / 2, center.dy + playHeight / 2)
        ..close();
      canvas.drawPath(path, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _PlayPausePainter oldDelegate) => oldDelegate.playing != playing;
}

class _StepPainter extends CustomPainter {
  _StepPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius - 0.5, Paint()..color = const Color(0xFFE6E6E6));
    canvas.drawCircle(
      center,
      radius - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF000000),
    );
    final barWidth = radius * 0.15;
    final barHeight = radius * 0.9;
    final triangleWidth = radius * 0.65;
    final fill = Paint()..color = const Color(0xFF000000);
    final left = center.dx - (barWidth + barWidth + triangleWidth) / 2;
    final top = center.dy - barHeight / 2;
    canvas.drawRect(Rect.fromLTWH(left, top, barWidth, barHeight), fill);
    final path = Path()
      ..moveTo(left + barWidth * 2, center.dy)
      ..lineTo(left + barWidth * 2 + triangleWidth, center.dy - barHeight / 2)
      ..lineTo(left + barWidth * 2 + triangleWidth, center.dy + barHeight / 2)
      ..close();
    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

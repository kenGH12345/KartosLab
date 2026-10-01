import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/pendulum_lab/controller/pendulum_lab_controller.dart';
import 'package:kratos/pendulum_lab/pl_colors.dart';
import 'package:kratos/pendulum_lab/pl_constants.dart';
import 'package:kratos/pendulum_lab/pl_strings.dart';
import 'package:kratos/pendulum_lab/widgets/pl_controls.dart';

/// Source: `PlaybackControlsNode.js`.
class PlaybackControls extends StatelessWidget {
  const PlaybackControls({super.key, required this.controller});

  final PendulumLabController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PendulaCountGroup(
          value: m.numberOfPendula,
          onChanged: m.setNumberOfPendula,
        ),
        const SizedBox(width: 80),
        _StopButton(onPressed: m.returnPendula),
        const SizedBox(width: 80),
        _PlayPauseButton(
          playing: m.isPlaying,
          onPressed: () => controller.setPlaying(!m.isPlaying),
        ),
        const SizedBox(width: 10),
        _StepButton(
          enabled: !m.isPlaying,
          onPressed: controller.stepManual,
        ),
        const SizedBox(width: 40),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlAquaRadio<double>(
              value: PlConstants.normalTimeSpeed,
              groupValue: m.timeSpeed,
              onChanged: m.setTimeSpeed,
              label: PlStrings.normal,
            ),
            PlAquaRadio<double>(
              value: PlConstants.slowTimeSpeed,
              groupValue: m.timeSpeed,
              onChanged: m.setTimeSpeed,
              label: PlStrings.slowMotion,
            ),
          ],
        ),
      ],
    );
  }
}

class _PendulaCountGroup extends StatelessWidget {
  const _PendulaCountGroup({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CountBtn(
          selected: value == 1,
          onTap: () => onChanged(1),
          child: const _PendulaIcon(count: 1),
        ),
        const SizedBox(width: 9),
        _CountBtn(
          selected: value == 2,
          onTap: () => onChanged(2),
          child: const _PendulaIcon(count: 2),
        ),
      ],
    );
  }
}

class _CountBtn extends StatelessWidget {
  const _CountBtn({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 41,
        height: 41,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: PlColors.rectangularButtonBase,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? Colors.black : const Color(0xFF999999),
            width: selected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _PendulaIcon extends StatelessWidget {
  const _PendulaIcon({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(35, 35),
      painter: _PendulaIconPainter(count: count),
    );
  }
}

class _PendulaIconPainter extends CustomPainter {
  _PendulaIconPainter({required this.count});

  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    void mini({
      required double lineLength,
      required double angle,
      required double rectHeight,
      required Color color,
    }) {
      final rectWidth = rectHeight * 0.8;
      canvas.save();
      canvas.translate(size.width / 2, 4);
      canvas.rotate(angle);
      canvas.drawLine(
        Offset.zero,
        Offset(0, lineLength),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1,
      );
      final rect = Rect.fromLTWH(-rectWidth / 2, lineLength, rectWidth, rectHeight);
      final shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          PlColors.brighter(color, 0.2),
          PlColors.brighter(color, 0.7),
          color,
        ],
        stops: const [0.0, 0.2, 0.7],
      ).createShader(rect);
      canvas.drawRect(rect, Paint()..shader = shader);
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      canvas.restore();
    }

    mini(
      lineLength: 35 * 0.6,
      angle: PlConstants.toRadians(-10),
      rectHeight: 35 * 0.4,
      color: PlColors.firstPendulum,
    );
    if (count == 2) {
      mini(
        lineLength: 35 * 0.5,
        angle: PlConstants.toRadians(20),
        rectHeight: 35 * 0.25,
        color: PlColors.secondPendulum,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PendulaIconPainter oldDelegate) =>
      oldDelegate.count != count;
}

class _StopButton extends StatelessWidget {
  const _StopButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: PlColors.stopButtonBase,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF999999)),
        ),
        child: CustomPaint(
          size: const Size(22, 22),
          painter: _StopSignPainter(),
        ),
      ),
    );
  }
}

class _StopSignPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 1;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 8 + i * math.pi / 4;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFCC0000));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF660000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.playing, required this.onPressed});

  final bool playing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        size: const Size(42, 42),
        painter: _PlayPausePainter(playing: playing),
      ),
    );
  }
}

class _PlayPausePainter extends CustomPainter {
  _PlayPausePainter({required this.playing});

  final bool playing;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    const r = 20.0;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.35),
          colors: [Color(0xFFFFEE66), PlColors.playPauseFace, Color(0xFFE0B000)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r - 0.5,
      Paint()
        ..color = PlColors.playPauseEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final icon = Paint()..color = Colors.black;
    if (playing) {
      canvas.drawRect(Rect.fromCenter(center: Offset(c.dx - 5, c.dy), width: 5, height: 16), icon);
      canvas.drawRect(Rect.fromCenter(center: Offset(c.dx + 5, c.dy), width: 5, height: 16), icon);
    } else {
      final path = Path()
        ..moveTo(c.dx - 5, c.dy - 9)
        ..lineTo(c.dx + 10, c.dy)
        ..lineTo(c.dx - 5, c.dy + 9)
        ..close();
      canvas.drawPath(path, icon);
    }
  }

  @override
  bool shouldRepaint(covariant _PlayPausePainter oldDelegate) =>
      oldDelegate.playing != playing;
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: CustomPaint(
          size: const Size(30, 30),
          painter: _StepPainter(),
        ),
      ),
    );
  }
}

class _StepPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    const r = 15.0;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.35),
          colors: [Color(0xFFFFEE66), PlColors.playPauseFace, Color(0xFFE0B000)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r - 0.5,
      Paint()
        ..color = PlColors.playPauseEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final icon = Paint()..color = Colors.black;
    final path = Path()
      ..moveTo(c.dx - 6, c.dy - 7)
      ..lineTo(c.dx + 5, c.dy)
      ..lineTo(c.dx - 6, c.dy + 7)
      ..close();
    canvas.drawPath(path, icon);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(c.dx + 7, c.dy), width: 3, height: 14),
      icon,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

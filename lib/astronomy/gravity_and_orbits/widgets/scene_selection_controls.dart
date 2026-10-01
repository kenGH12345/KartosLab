/// Four scene icon buttons (vertical) + scene-reset arrow.
///
/// Layout matches `SceneSelectionControls.ts`: RectangularRadioButtonGroup
/// stacks scenes vertically; reset sits to the right of the selected row.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/gao_controller.dart';
import '../gao_colors.dart';
import '../gao_strings.dart';

class SceneSelectionControls extends StatelessWidget {
  const SceneSelectionControls({super.key, required this.controller});

  final GaoController controller;

  /// [sun, earth, moon, station] visibility — `SceneFactory.createIconImage`
  static const _sceneMasks = <List<bool>>[
    [true, true, false, false],
    [true, true, true, false],
    [false, true, true, false],
    [false, true, false, true],
  ];

  static const _assets = [
    GaoConstants.sunAsset,
    GaoConstants.earthAsset,
    GaoConstants.moonAsset,
    GaoConstants.spaceStationAsset,
  ];

  @override
  Widget build(BuildContext context) {
    final selected = controller.model.sceneIndex;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _sceneMasks.length; i++) ...[
                if (i > 0) const SizedBox(height: 2),
                _SceneIconButton(
                  masks: _sceneMasks[i],
                  assets: _assets,
                  selected: selected == i,
                  onTap: () => controller.selectScene(i),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Align reset with the selected row (source: rightCenter of selected button)
        Padding(
          padding: EdgeInsets.only(top: selected * 38.0 + 4),
          child: _SceneResetButton(
            onPressed: controller.resetActiveScene,
            tooltip: GaoStrings.resetScene,
          ),
        ),
      ],
    );
  }
}

class _SceneIconButton extends StatelessWidget {
  const _SceneIconButton({
    required this.masks,
    required this.assets,
    required this.selected,
    required this.onTap,
  });

  final List<bool> masks;
  final List<String> assets;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: selected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              for (var i = 0; i < 4; i++)
                if (masks[i])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.asset(assets[i], width: 22, height: 22),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SceneResetButton extends StatelessWidget {
  const _SceneResetButton({required this.onPressed, required this.tooltip});

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFDCDCDC),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 28,
            height: 24,
            child: CustomPaint(painter: _CircularArrowPainter()),
          ),
        ),
      ),
    );
  }
}

class _CircularArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.28;
    final paint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi * 0.2,
      math.pi * 1.55,
      false,
      paint,
    );
    final tipAngle = -math.pi * 0.2;
    final tip = Offset(c.dx + r * math.cos(tipAngle), c.dy + r * math.sin(tipAngle));
    final path = Path()
      ..moveTo(tip.dx - 3.5, tip.dy - 1.5)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - 1.5, tip.dy + 3.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

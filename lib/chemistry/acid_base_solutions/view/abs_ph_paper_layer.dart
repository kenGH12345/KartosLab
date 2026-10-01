import 'package:flutter/material.dart';

import '../model/abs_beaker.dart';
import '../model/abs_colors.dart';
import '../model/abs_ph_paper.dart';
import '../model/abs_view_properties.dart';

/// pH paper + color key — PhET `PHPaperNode` / `PHColorKeyNode`.
class AbsPhPaperLayer extends StatelessWidget {
  const AbsPhPaperLayer({
    super.key,
    required this.paper,
    required this.beaker,
    required this.toolMode,
    required this.onDrag,
    required this.onPressedChanged,
  });

  final AbsPhPaper paper;
  final AbsBeaker beaker;
  final AbsToolMode toolMode;
  final ValueChanged<Offset> onDrag;
  final ValueChanged<bool> onPressedChanged;

  @override
  Widget build(BuildContext context) {
    if (toolMode != AbsToolMode.pHPaper) return const SizedBox.shrink();

    final size = paper.paperSize;
    final pos = paper.position; // bottom-center
    final coloredH = paper.percentColored * size.height;

    return Stack(
      children: [
        // Color key above beaker
        Positioned(
          left: beaker.left + 3,
          top: beaker.top - 50 - 40,
          child: AbsPhColorKey(paperWidth: size.width),
        ),
        Positioned(
          left: pos.dx - size.width / 2,
          top: pos.dy - size.height,
          child: GestureDetector(
            onPanStart: (_) => onPressedChanged(true),
            onPanEnd: (_) => onPressedChanged(false),
            onPanCancel: () => onPressedChanged(false),
            onPanUpdate: (d) {
              onDrag(Offset(pos.dx + d.delta.dx, pos.dy + d.delta.dy));
            },
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AbsColors.phPaperFill,
                      border: Border.all(
                        color: const Color(0xFF666666),
                        width: 0.5,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: coloredH,
                    child: ColoredBox(color: paper.color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// pH color key chips 0–14.
class AbsPhColorKey extends StatelessWidget {
  const AbsPhColorKey({super.key, required this.paperWidth});

  final double paperWidth;

  @override
  Widget build(BuildContext context) {
    const chipW = 14.0;
    const chipH = 18.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'pH Color Key',
          style: TextStyle(fontFamily: 'Arial', fontSize: 12),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < AbsColors.phPaperColors.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 1),
                child: Column(
                  children: [
                    Text(
                      '$i',
                      style: const TextStyle(fontFamily: 'Arial', fontSize: 9),
                    ),
                    Container(
                      width: chipW,
                      height: chipH,
                      color: AbsColors.phPaperColors[i],
                      foregroundDecoration: BoxDecoration(
                        border: Border.all(color: Colors.black26, width: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Tools radio icon for pH paper.
class AbsPhPaperIcon extends StatelessWidget {
  const AbsPhPaperIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
      height: 30,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AbsColors.phPaperFill,
              border: Border.all(color: Colors.black54, width: 0.5),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 12,
            child: ColoredBox(color: AbsColors.phPaperColors[2]),
          ),
        ],
      ),
    );
  }
}

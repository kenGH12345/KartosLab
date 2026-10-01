import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/render/esp_mvt.dart';

/// Draggable reference-height line (ReferenceHeightLine.ts).
///
/// Origin at left edge; vertical drag updates skater.referenceHeight in model m.
class ReferenceHeightLineOverlay extends StatelessWidget {
  const ReferenceHeightLineOverlay({
    super.key,
    required this.controller,
    required this.mvt,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final EspController controller;
  final EspMvt mvt;
  final VoidCallback onDragStart;
  final void Function(double modelY) onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    if (!controller.view.referenceHeightVisible) {
      return const SizedBox.shrink();
    }

    final href = controller.model.skater.referenceHeight;
    final lineY = mvt.modelToViewXY(0, href).dy;
    final lineLen = mvt.modelToViewDeltaX(EspConstants.referenceHeightLineModelLength);

    return Stack(
      children: [
        Positioned(
          left: 0,
          top: lineY - 3,
          width: lineLen,
          height: 6,
          child: CustomPaint(
            painter: _DashedLinePainter(),
            size: Size(lineLen, 6),
          ),
        ),
        Positioned(
          left: 28,
          top: lineY - 18,
          child: GestureDetector(
            onVerticalDragStart: (_) => onDragStart(),
            onVerticalDragUpdate: (d) {
              final dyModel = -d.delta.dy / mvt.scale;
              final next = (controller.model.skater.referenceHeight + dyModel)
                  .clamp(
                EspConstants.referenceHeightMin,
                EspConstants.referenceHeightMax,
              );
              onDragUpdate(next);
            },
            onVerticalDragEnd: (_) => onDragEnd(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_arrow_up,
                    size: 16, color: EspColors.referenceLineFill),
                Container(
                  width: 8,
                  height: 20,
                  decoration: BoxDecoration(
                    color: EspColors.referenceLineFill,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down,
                    size: 16, color: EspColors.referenceLineFill),
              ],
            ),
          ),
        ),
        Positioned(
          left: 52,
          top: lineY - 10,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                href == 0 ? 'h=0 m' : 'h=${href.toStringAsFixed(1)} m',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: EspColors.referenceLineFill,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dash = 12.0;
    const gap = 9.0;
    final y = size.height / 2;
    final back = Paint()
      ..color = Colors.black
      ..strokeWidth = 6;
    final front = Paint()
      ..color = EspColors.referenceLineFill
      ..strokeWidth = 4;
    double x = 0;
    while (x < size.width) {
      final end = (x + dash).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), back);
      canvas.drawLine(Offset(x, y), Offset(end, y), front);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

import '../../domain/detector_screen_scale.dart';
import '../common/qwi_layout.dart';
import 'experiment_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';

/// Detector ruler — display-only; calibrated to [DetectorScreenScale].
class ExperimentRulerView extends StatelessWidget {
  const ExperimentRulerView({super.key, required this.controller});

  final ExperimentController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.model.ruler.visible) {
      return const SizedBox.shrink();
    }
    final detector = QwiLayout.frontFacingDetectorRect;
    final fullMm = DetectorScreenScale.visibleFullWidthMm(controller.model.detectorScreenScaleIndex);
    final halfMm = fullMm / 2;
    final x = controller.model.ruler.positionX != 0
        ? controller.model.ruler.positionX
        : detector.left;
    final y = controller.model.ruler.positionY != 0
        ? controller.model.ruler.positionY
        : detector.top - 28;

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        key: const Key('qwi_ruler'),
        onPanUpdate: (d) {
          controller.setRulerPosition(
            (controller.model.ruler.positionX == 0 ? detector.left : controller.model.ruler.positionX) + d.delta.dx,
            (controller.model.ruler.positionY == 0 ? detector.top - 28 : controller.model.ruler.positionY) +
                d.delta.dy,
          );
        },
        child: Container(
          width: detector.width,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFF5E6B8),
            border: Border.all(color: Colors.black54),
          ),
          child: CustomPaint(
            painter: _RulerTickPainter(halfMm: halfMm),
            child: Center(
              child: Text(
                '±${halfMm.toStringAsFixed(0)} mm',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RulerTickPainter extends CustomPainter {
  _RulerTickPainter({required this.halfMm});

  final double halfMm;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1;
    const ticks = 8;
    for (var i = 0; i <= ticks; i++) {
      final x = size.width * i / ticks;
      final h = i == ticks / 2 ? 14.0 : 8.0;
      canvas.drawLine(Offset(x, size.height - h), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RulerTickPainter oldDelegate) => oldDelegate.halfMm != halfMm;
}

class ExperimentRulerCheckbox extends StatelessWidget {
  const ExperimentRulerCheckbox({super.key, required this.controller});

  final ExperimentController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Checkbox(
            key: const Key('qwi_ruler_checkbox'),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            value: controller.model.ruler.visible,
            onChanged: (v) => controller.setRulerVisible(v ?? false),
          ),
        ),
        Text(QwiStrings.ruler, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

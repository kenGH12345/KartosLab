import 'package:flutter/material.dart';

import '../collision_lab_colors.dart';
import '../collision_lab_strings.dart';
import '../controller/collision_lab_controller.dart';
import '../painters/momenta_diagram_painter.dart';
import '../render/cl_render_builder.dart';

class MomentaDiagramPanel extends StatelessWidget {
  const MomentaDiagramPanel({super.key, required this.controller});

  final CollisionLabController controller;

  @override
  Widget build(BuildContext context) {
    final md = controller.model.momentaDiagram;
    final data = ClRenderBuilder.build(controller);

    return Container(
      decoration: BoxDecoration(
        color: CollisionLabColors.panelFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: CollisionLabColors.panelStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => controller.setMomentaExpanded(!md.expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    md.expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      CollisionLabStrings.momentaDiagram,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (md.expanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: '缩小',
                    onPressed: controller.zoomMomentaOut,
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                  ),
                  Text(
                    '×${md.zoom.toStringAsFixed(md.zoom >= 1 ? 0 : 3)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  IconButton(
                    tooltip: '放大',
                    onPressed: controller.zoomMomentaIn,
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: AspectRatio(
                aspectRatio: 7 / 5.7,
                child: CustomPaint(
                  painter: MomentaDiagramPainter(data: data),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

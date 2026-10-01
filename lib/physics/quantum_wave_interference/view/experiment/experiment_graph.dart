import 'package:flutter/material.dart';

import '../../data/graph_data.dart';
import '../../domain/detector_mode.dart';
import '../../domain/detector_screen_scale.dart';
import '../../render/experiment/graph_renderer.dart';
import '../../render_data/experiment/fraunhofer_render_data.dart';
import '../common/qwi_colors.dart';
import 'experiment_controller.dart';

/// PhET `GraphAccordionBox`.
///
/// - Title expand/collapse
/// - Chart X window follows detector horizontal zoom
/// - Vertical ± = graph **Y** zoom only (not detector scale)
class ExperimentGraphAccordion extends StatelessWidget {
  const ExperimentGraphAccordion({super.key, required this.controller});

  final ExperimentController controller;

  static const double _chartHeight = 103;

  @override
  Widget build(BuildContext context) {
    final expanded = controller.graphExpanded;
    final hits = controller.scene.detectionMode == DetectorMode.hits;
    final title = hits ? 'Hits Graph' : 'Intensity Graph';
    final yLabel = hits ? 'Count' : 'Intensity';
    final zoom = controller.model.graphZoom;
    final detZoom = controller.model.detectorScreenScaleIndex;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: const Key('qwi_graph_toggle'),
          onTap: () => controller.setGraphExpanded(!expanded),
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: QwiColors.panelFill,
              borderRadius: expanded
                  ? const BorderRadius.vertical(top: Radius.circular(5))
                  : BorderRadius.circular(5),
              border: Border.all(color: QwiColors.graphAccordionStroke),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(
                  expanded ? '−' : '+',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: expanded ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        if (expanded)
          Container(
            height: _chartHeight + 12,
            decoration: BoxDecoration(
              color: QwiColors.panelFill,
              border: Border.all(color: QwiColors.graphAccordionStroke),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5)),
            ),
            padding: const EdgeInsets.fromLTRB(2, 4, 4, 4),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      yLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Arial', fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      final visibleHalf = DetectorScreenScale.visibleHalfWidthMeters(detZoom);
                      return CustomPaint(
                        key: ValueKey('qwi_graph_${detZoom}_${zoom.level}'),
                        size: Size(w, h),
                        painter: ExperimentGraphPainter(
                          mode: controller.scene.detectionMode,
                          fraunhofer: FraunhoferRenderData.fromScene(
                            controller.scene,
                            visibleHalfWidthM: visibleHalf,
                          ),
                          histogram: HitsHistogramData.fromHitsInVisibleWindow(
                            controller.scene.hits.hits,
                            visibleHalfWidthM: visibleHalf,
                            fullHalfWidthM: controller.scene.fullScreenHalfWidthM,
                          ),
                          graphRect: Rect.fromLTWH(0, 0, w, h),
                          graphZoomLevel: zoom.level,
                          maxGraphZoomLevel: zoom.maxLevel,
                          minGraphZoomLevel: zoom.minLevel,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _ZoomBtn(
                      key: const Key('qwi_graph_zoom_in'),
                      label: '+',
                      enabled: zoom.level < zoom.maxLevel,
                      onTap: () => controller.setGraphZoomLevel(zoom.level + 1),
                    ),
                    _ZoomBtn(
                      key: const Key('qwi_graph_zoom_out'),
                      label: '−',
                      enabled: zoom.level > zoom.minLevel,
                      onTap: () => controller.setGraphZoomLevel(zoom.level - 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  const _ZoomBtn({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 26,
          height: 26,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: enabled ? Colors.black87 : Colors.black26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

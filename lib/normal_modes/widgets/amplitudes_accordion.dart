import 'package:flutter/material.dart';

import '../controller/two_dimensions_controller.dart';
import '../model/amplitude_direction.dart';
import '../normal_modes_colors.dart';
import '../normal_modes_constants.dart';
import '../normal_modes_strings.dart';
import '../render/nm_render_data.dart';
import 'nm_accordion.dart';
import 'spectrum_accordion.dart';

class AmplitudesAccordion extends StatelessWidget {
  const AmplitudesAccordion({
    super.key,
    required this.controller,
    required this.data,
  });

  final TwoDimensionsController controller;
  final NmRenderData data;

  @override
  Widget build(BuildContext context) {
    return NmAccordion(
      title: NormalModesStrings.normalModeAmplitudes,
      expanded: controller.amplitudesExpanded,
      onExpandedChanged: controller.setAmplitudesExpanded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : NormalModesConstants.amplitudesPanelSize + 64;
          const radiosW = 56.0;
          final gridSide = (maxW - radiosW - 8)
              .clamp(120.0, NormalModesConstants.amplitudesPanelSize);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AmplitudeDirectionGroup(
                value: data.amplitudeDirection,
                onChanged: controller.setAmplitudeDirection,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: gridSide,
                height: gridSide,
                child: CustomPaint(
                  painter: _GridPainter(data: data),
                  child: GestureDetector(
                    onTapUp: (d) {
                      final n = data.numberOfMasses;
                      final ratio = gridSide /
                          (NormalModesConstants.rectGridUnits * n +
                              NormalModesConstants.paddingGridUnits *
                                  (n - 1));
                      final cell = (NormalModesConstants.rectGridUnits +
                              NormalModesConstants.paddingGridUnits) *
                          ratio;
                      final col = (d.localPosition.dx / cell)
                          .floor()
                          .clamp(0, n - 1);
                      final row = (d.localPosition.dy / cell)
                          .floor()
                          .clamp(0, n - 1);
                      controller.toggleAmplitudeCell(row, col);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.data});
  final NmRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    final n = data.numberOfMasses;
    final ratio = size.width /
        (NormalModesConstants.rectGridUnits * n +
            NormalModesConstants.paddingGridUnits * (n - 1));
    final rectSize = NormalModesConstants.rectGridUnits * ratio;
    final pad = NormalModesConstants.paddingGridUnits * ratio;
    final fill = data.amplitudeDirection == AmplitudeDirection.vertical
        ? NormalModesColors.selectorVertical
        : NormalModesColors.selectorHorizontal;
    final grid = data.amplitudeDirection == AmplitudeDirection.vertical
        ? data.ampY
        : data.ampX;
    for (var row = 0; row < n; row++) {
      for (var col = 0; col < n; col++) {
        final left = col * (rectSize + pad);
        final top = row * (rectSize + pad);
        final rect = Rect.fromLTWH(left, top, rectSize, rectSize);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
        canvas.drawRRect(rrect, Paint()..color = fill);
        final amp = grid[row][col];
        final factor = (amp / data.maxAmplitude2D).clamp(0.0, 1.0);
        final coverH = rect.height * (1 - factor);
        if (coverH > 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(left, top, rectSize, coverH),
              const Radius.circular(2),
            ),
            Paint()..color = NormalModesColors.selectorBackground,
          );
        }
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = NormalModesColors.buttonStroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';

import '../../data/measurement_plots_state.dart';
import '../../domain/wave_display_mode.dart';
import 'qwi_wave_plot_chart.dart';
import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';

/// PhET `PositionPlotNode` — horizontal aperture + chart below linked by a short wire.
class QwiPositionPlotOverlay extends StatelessWidget {
  const QwiPositionPlotOverlay({
    super.key,
    required this.state,
    required this.waveRect,
    required this.regionWidthM,
    required this.mode,
    required this.onChanged,
  });

  final MeasurementPlotsState state;
  final Rect waveRect;
  final double regionWidthM;
  final WaveDisplayMode mode;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final fraction = state.lineYFraction.clamp(
      QwiPlotConstants.minYFraction,
      QwiPlotConstants.maxYFraction,
    );
    final apertureCenterY = waveRect.top + fraction * waveRect.height;
    final apertureOuterH =
        QwiPlotConstants.apertureHeight + 2 * QwiPlotConstants.apertureFrame;
    final chartTop = apertureCenterY + apertureOuterH / 2 + QwiPlotConstants.apertureToPanelGap;
    final panelW = waveRect.width +
        QwiPlotConstants.panelLeftPad +
        QwiPlotConstants.panelRightPad;
    final panelH = QwiPlotConstants.chartHeight +
        QwiPlotConstants.panelTopPad +
        QwiPlotConstants.panelBottomPad;
    final chartLeft = waveRect.left - QwiPlotConstants.panelLeftPad;

    void dragFraction(double dy) {
      final next = (state.lineYFraction + dy / waveRect.height).clamp(
        QwiPlotConstants.minYFraction,
        QwiPlotConstants.maxYFraction,
      );
      if (next != state.lineYFraction) {
        state.lineYFraction = next;
        onChanged();
      }
    }

    return Stack(
      children: [
        // Vertical wire at horizontal center.
        Positioned(
          left: waveRect.left + waveRect.width / 2 - 2.5,
          top: apertureCenterY + apertureOuterH / 2,
          width: 5,
          height: QwiPlotConstants.apertureToPanelGap,
          child: Container(color: QwiPlotConstants.wireColor),
        ),
        // Aperture probe
        Positioned(
          left: waveRect.left - 4,
          top: apertureCenterY - apertureOuterH / 2,
          width: waveRect.width + 8,
          height: apertureOuterH,
          child: GestureDetector(
            onVerticalDragUpdate: (d) => dragFraction(d.delta.dy),
            child: CustomPaint(
              key: const Key('qwi_position_plot_aperture'),
              painter: _AperturePainter(),
            ),
          ),
        ),
        // Chart panel (also vertically draggable to move the row)
        Positioned(
          left: chartLeft,
          top: chartTop,
          child: GestureDetector(
            onVerticalDragUpdate: (d) => dragFraction(d.delta.dy),
            child: Material(
              elevation: 2,
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: panelW,
                height: panelH,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    QwiPlotConstants.panelLeftPad,
                    QwiPlotConstants.panelTopPad,
                    QwiPlotConstants.panelRightPad,
                    QwiPlotConstants.panelBottomPad,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        QwiStrings.position,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      QwiWavePlotChart(
                        key: const Key('qwi_position_plot_chart'),
                        width: waveRect.width,
                        points: state.positionPoints,
                        xMin: 0,
                        xMax: regionWidthM <= 0 ? 1 : regionWidthM,
                        mode: mode,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AperturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frame = QwiPlotConstants.apertureFrame;
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(5),
    );
    final fill = Paint()..color = QwiPlotConstants.probeColor;
    final stroke = Paint()
      ..color = QwiPlotConstants.wireColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Top / bottom bars + side posts (hollow aperture).
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, frame), const Radius.circular(2)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height - frame, size.width, frame),
        const Radius.circular(2),
      ),
      fill,
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, 4, size.height), fill);
    canvas.drawRect(Rect.fromLTWH(size.width - 4, 0, 4, size.height), fill);
    canvas.drawRRect(outer, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

import '../fmw_colors.dart';
import '../fmw_constants.dart';
import '../painters/amplitudes_bars_painter.dart';
import '../painters/chart_frame_painter.dart';
import '../painters/waveform_line_painter.dart';
import '../render/fmw_render_data.dart';

/// Title + CustomPaint chart (frame + optional polylines or amplitude bars).
class FmwChartPanel extends StatelessWidget {
  const FmwChartPanel({
    super.key,
    required this.title,
    this.chart,
    this.bars,
    this.barsYMin = -FmwConstants.maxAmplitude,
    this.barsYMax = FmwConstants.maxAmplitude,
    this.fillColor = FmwColors.chartBackground,
    this.width = FmwConstants.chartWidth,
    this.height = FmwConstants.chartHeight,
  });

  final String title;
  final FmwChartRenderData? chart;
  final List<FmwAmplitudeBarData>? bars;
  final double barsYMin;
  final double barsYMax;
  final Color fillColor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ),
        SizedBox(
          width: width,
          height: height,
          child: ClipRect(
            child: CustomPaint(
              size: Size(width, height),
              painter: bars != null
                  ? AmplitudesBarsPainter(
                      bars: bars!,
                      yMin: barsYMin,
                      yMax: barsYMax,
                    )
                  : ChartFramePainter(chart: chart!, fillColor: fillColor),
              foregroundPainter: bars == null && chart != null
                  ? WaveformLinePainter(polylines: chart!.polylines)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

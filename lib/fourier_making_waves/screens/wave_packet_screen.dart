import 'package:flutter/material.dart';

import '../controller/wave_packet_controller.dart';
import '../fmw_colors.dart';
import '../fmw_constants.dart';
import '../fmw_strings.dart';
import '../painters/chart_frame_painter.dart';
import '../painters/waveform_line_painter.dart';
import '../render/fmw_render_builder.dart';
import '../render/fmw_render_data.dart';
import '../widgets/fmw_page_shell.dart';
import '../widgets/harmonics_chart_with_tools.dart';
import '../widgets/wave_packet_control_panel.dart';

class WavePacketScreen extends StatelessWidget {
  const WavePacketScreen({
    super.key,
    required this.controller,
    this.embedded = false,
  });

  final WavePacketController controller;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = Material(
      color: FmwColors.wavePacketScreenBackground,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final m = controller.model;
          final data = FmwRenderBuilder.fromWavePacket(controller);

          return FmwPageShell(
            backgroundColor: FmwColors.wavePacketScreenBackground,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                FmwConstants.screenViewXMargin,
                FmwConstants.screenViewYMargin,
                FmwConstants.screenViewXMargin,
                8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            FmwStrings.amplitudes,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: FmwConstants.chartWidth,
                            height: FmwConstants.chartHeight,
                            child: CustomPaint(
                              painter: WavePacketAmplitudesPainter(
                                bars: data.amplitudeBars,
                                xMin: data.amplitudesXMin,
                                xMax: data.amplitudesXMax,
                                yMin: data.amplitudesYMin,
                                yMax: data.amplitudesYMax,
                                continuous: data.continuousPolyline,
                                widthIndicator: data.amplitudesWidthIndicator,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            FmwStrings.components,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: FmwConstants.chartWidth,
                            height: FmwConstants.chartHeight,
                            child: CustomPaint(
                              painter: ChartFramePainter(
                                chart: data.componentsChart,
                                fillColor: FmwColors.chartBackgroundCream,
                              ),
                              foregroundPainter: WaveformLinePainter(
                                polylines: data.componentsChart.polylines,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            FmwStrings.sum,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: FmwConstants.chartWidth,
                            height: FmwConstants.chartHeight,
                            child: CustomPaint(
                              painter: ChartFramePainter(
                                chart: data.sumChart,
                                fillColor: FmwColors.chartBackgroundCream,
                              ),
                              foregroundPainter: _SumLinesAndWidthPainter(
                                chart: data.sumChart,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  WavePacketControlPanel(
                    domain: m.domain,
                    seriesType: m.seriesType,
                    componentSpacing: m.wavePacket.componentSpacing,
                    center: m.wavePacket.center,
                    standardDeviation: m.wavePacket.standardDeviation,
                    widthIndicatorsVisible: m.widthIndicatorsVisible,
                    waveformEnvelopeVisible: m.waveformEnvelopeVisible,
                    continuousWaveformVisible: m.continuousWaveformVisible,
                    onDomain: controller.setDomain,
                    onSeriesType: controller.setSeriesType,
                    onComponentSpacing: controller.setComponentSpacing,
                    onCenter: controller.setCenter,
                    onStandardDeviation: controller.setStandardDeviation,
                    onWidthIndicators: controller.setWidthIndicatorsVisible,
                    onEnvelope: controller.setWaveformEnvelopeVisible,
                    onContinuous: controller.setContinuousWaveformVisible,
                    onZoomIn: controller.zoomIn,
                    onZoomOut: controller.zoomOut,
                    onReset: controller.reset,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text(FmwStrings.tabWavePacket)),
      body: body,
    );
  }
}

class _SumLinesAndWidthPainter extends CustomPainter {
  _SumLinesAndWidthPainter({required this.chart});

  final FmwChartRenderData chart;

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in chart.polylines) {
      if (line.points.length < 2) continue;
      final path = Path()..moveTo(line.points.first.dx, line.points.first.dy);
      for (var i = 1; i < line.points.length; i++) {
        path.lineTo(line.points[i].dx, line.points[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = line.color
          ..strokeWidth = line.strokeWidth
          ..style = PaintingStyle.stroke,
      );
    }
    final ind = chart.widthIndicator;
    if (ind != null) {
      final c = ind.centerView;
      final half = ind.halfWidthView;
      canvas.drawLine(
        Offset(c.dx - half, c.dy),
        Offset(c.dx + half, c.dy),
        Paint()
          ..color = FmwColors.widthIndicatorsColor
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SumLinesAndWidthPainter oldDelegate) =>
      oldDelegate.chart != chart;
}

import 'package:flutter/material.dart';

import '../controller/discrete_controller.dart';
import '../fmw_colors.dart';
import '../fmw_constants.dart';
import '../fmw_strings.dart';
import '../render/fmw_render_builder.dart';
import '../widgets/amplitude_slider_row.dart';
import '../widgets/discrete_control_panel.dart';
import '../widgets/fmw_chart_panel.dart';
import '../widgets/fmw_page_shell.dart';
import '../widgets/fmw_time_control.dart';
import '../widgets/harmonics_chart_with_tools.dart';

class DiscreteScreen extends StatelessWidget {
  const DiscreteScreen({
    super.key,
    required this.controller,
    this.embedded = false,
  });

  final DiscreteController controller;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = Material(
      color: FmwColors.discreteScreenBackground,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (controller.oopsMessage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              if (!controller.oopsMessage) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(FmwStrings.oopsSawtoothCos)),
              );
              controller.clearOops();
            });
          }

          final data = FmwRenderBuilder.fromDiscrete(controller);
          final m = controller.model;
          final n = m.fourierSeries.numberOfHarmonics;
          final ampValues = [
            for (var i = 0; i < n; i++) m.fourierSeries.amplitudes[i],
          ];

          return FmwPageShell(
            backgroundColor: FmwColors.discreteScreenBackground,
            footer: FmwTimeControl(
              domain: m.domain,
              isPlaying: m.isPlaying,
              onPlayPause: controller.playPause,
              onStep: controller.stepOnce,
            ),
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
                          if (data.equationText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                data.equationText,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          FmwChartPanel(
                            title: FmwStrings.amplitudes,
                            bars: data.bars,
                            barsYMin: data.amplitudesYMin,
                            barsYMax: data.amplitudesYMax,
                          ),
                          const SizedBox(height: 6),
                          AmplitudeSliderRow(
                            values: ampValues,
                            step: FmwConstants.discreteAmplitudeStep,
                            onChanged: (pair) =>
                                controller.setAmplitude(pair.$1, pair.$2),
                            height: 120,
                          ),
                          const SizedBox(height: 8),
                          HarmonicsChartWithTools(
                            title: FmwStrings.harmonics,
                            chart: data.harmonicsChart,
                            wavelengthCalipers: data.wavelengthCalipers,
                            periodCalipers: data.periodCalipers,
                            periodClock: data.periodClock,
                            onDragWavelength:
                                controller.dragWavelengthCalipers,
                            onDragPeriodCalipers: controller.dragPeriodCalipers,
                            onDragPeriodClock: controller.dragPeriodClock,
                          ),
                          const SizedBox(height: 8),
                          FmwChartPanel(
                            title: FmwStrings.sum,
                            chart: data.sumChart,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DiscreteControlPanel(
                    waveform: m.waveform,
                    numberOfHarmonics: n,
                    domain: m.domain,
                    seriesType: m.seriesType,
                    equationForm: m.equationForm,
                    infiniteHarmonicsVisible: m.infiniteHarmonicsVisible,
                    wavelengthSelected: m.wavelengthTool.isSelected,
                    periodSelected: m.periodTool.isSelected,
                    wavelengthOrder: m.wavelengthTool.order,
                    periodOrder: m.periodTool.order,
                    onWaveform: controller.setWaveform,
                    onHarmonics: controller.setNumberOfHarmonics,
                    onDomain: controller.setDomain,
                    onSeriesType: controller.setSeriesType,
                    onEquationForm: controller.setEquationForm,
                    onInfiniteHarmonics: controller.setInfiniteHarmonicsVisible,
                    onWavelengthSelected: controller.setWavelengthToolSelected,
                    onPeriodSelected: controller.setPeriodToolSelected,
                    onWavelengthOrder: controller.setWavelengthToolOrder,
                    onPeriodOrder: controller.setPeriodToolOrder,
                    onErase: controller.eraseAmplitudes,
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
      appBar: AppBar(title: const Text(FmwStrings.tabDiscrete)),
      body: body,
    );
  }
}

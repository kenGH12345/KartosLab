import 'package:flutter/material.dart';

import '../../model/molarity_constants.dart';
import '../../model/molarity_state.dart';
import '../molarity_layout.dart';
import 'molarity_beaker.dart';
import 'molarity_concentration_display.dart';
import 'molarity_solute_combo.dart';
import 'molarity_solution_values_checkbox.dart';
import 'molarity_vertical_slider.dart';
import '../../../../common/widgets/kratos_reset_all_button.dart';

/// Saturated! — source `SaturatedIndicator`.
class MolaritySaturatedBanner extends StatelessWidget {
  const MolaritySaturatedBanner({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(240, 240, 240, 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Saturated!',
        style: TextStyle(fontSize: 22, color: Colors.black),
      ),
    );
  }
}

/// Source-faithful play area (1100×700 content). No Shaker/Dropper/Faucet/Probe.
///
/// Layout constants follow `MolarityScreenView.js` relative placement, then the
/// whole cluster is centered on the canvas (source `center: layoutBounds.center`).
class MolarityPlayArea extends StatelessWidget {
  const MolarityPlayArea({
    super.key,
    required this.state,
    required this.onSoluteAmount,
    required this.onVolume,
    required this.onSoluteIndex,
    required this.onValuesVisible,
    required this.onReset,
    this.onDragStart,
    this.onDragEnd,
    this.randomSeed = 42,
  });

  final MolarityState state;
  final ValueChanged<double> onSoluteAmount;
  final ValueChanged<double> onVolume;
  final ValueChanged<int> onSoluteIndex;
  final ValueChanged<bool> onValuesVisible;
  final VoidCallback onReset;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  /// Deterministic precipitate layout for golden / visual QA.
  final int randomSeed;

  @override
  Widget build(BuildContext context) {
    final solution = state.solution;
    final cylH = MolarityLayout.cylinderSize.height;
    final valuesOn = state.valuesVisible;
    // Concentration column approximate height for bottom-alignment to beaker.
    // Title 24 + subtitle 22 + gaps + range 20 + bar + min 20.
    final concDisplayH =
        24 + 22 + 8 + 20 + 6 + MolarityLayout.concentrationBarSize.height + 5 + 20;
    final cluster = MolarityLayout.contentClusterSizeFor(valuesOn);

    return Semantics(
      container: true,
      label: '摩尔浓度模拟。烧杯、溶质量滑块、溶液体积滑块、浓度显示、溶质选择、显示数值、重置。',
      child: SizedBox(
        width: MolarityLayout.canvas.width,
        height: MolarityLayout.canvas.height,
        child: ColoredBox(
          color: MolarityLayout.background,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: cluster.width,
                  height: cluster.height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: MolarityLayout.soluteSliderLeft,
                        top: 0,
                        child: MolarityVerticalSlider(
                          title: '溶质量',
                          subtitle: '(摩尔)',
                          minLabel: '无',
                          maxLabel: '多',
                          value: solution.soluteAmount,
                          min: MolarityConstants.soluteAmountMin,
                          max: MolarityConstants.soluteAmountMax,
                          decimalPlaces:
                              MolarityConstants.soluteAmountDecimalPlaces,
                          unit: 'mol',
                          trackHeight: MolarityLayout.soluteSliderTrackHeight,
                          valuesVisible: valuesOn,
                          onChanged: onSoluteAmount,
                          onChangeStart: (_) => onDragStart?.call(),
                          onChangeEnd: (_) => onDragEnd?.call(),
                          semanticLabel: '溶质量',
                        ),
                      ),
                      Positioned(
                        left: MolarityLayout.volumeSliderLeftFor(valuesOn),
                        top: 0,
                        child: MolarityVerticalSlider(
                          title: '溶液体积',
                          subtitle: '(升)',
                          minLabel: '低',
                          maxLabel: '满',
                          value: solution.volume,
                          min: MolarityConstants.volumeMin,
                          max: MolarityConstants.volumeMax,
                          decimalPlaces: MolarityConstants.volumeDecimalPlaces,
                          unit: 'L',
                          trackHeight: MolarityLayout.volumeSliderTrackHeight,
                          valuesVisible: valuesOn,
                          onChanged: onVolume,
                          onChangeStart: (_) => onDragStart?.call(),
                          onChangeEnd: (_) => onDragEnd?.call(),
                          semanticLabel: '溶液体积',
                        ),
                      ),
                      Positioned(
                        left: MolarityLayout.beakerLeftFor(valuesOn),
                        top: MolarityLayout.beakerTop,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Semantics(
                              label:
                                  '烧杯。溶质 ${solution.solute.name}。体积 ${solution.volume.toStringAsFixed(3)} 升。浓度 ${solution.concentration.toStringAsFixed(3)} 摩尔每升。${solution.isSaturated ? '已饱和。' : ''}',
                              child: MolarityBeaker(
                                solution: solution,
                                valuesVisible: valuesOn,
                                randomSeed: randomSeed,
                              ),
                            ),
                            // Saturated!: source bottom = beaker.bottom − 0.2·cylinderH.
                            Positioned(
                              bottom: 0.2 * cylH,
                              child: MolaritySaturatedBanner(
                                visible: solution.isSaturated,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Source: left = beaker.right + 40, bottom = beaker.bottom.
                      Positioned(
                        left: MolarityLayout.concentrationLeftFor(valuesOn),
                        top: MolarityLayout.concentrationTop(concDisplayH),
                        child: Semantics(
                          label:
                              '溶液浓度 ${solution.concentration.toStringAsFixed(3)} 摩尔每升',
                          child: MolarityConcentrationDisplay(
                            solution: solution,
                            valuesVisible: valuesOn,
                          ),
                        ),
                      ),
                      // Bottom controls: checkbox · combo (centered under beaker) · reset.
                      Positioned(
                        left: 0,
                        right: 0,
                        top: MolarityLayout.controlsTop,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MolaritySolutionValuesCheckbox(
                              value: valuesOn,
                              onChanged: onValuesVisible,
                            ),
                            SizedBox(width: MolarityLayout.checkboxComboGap),
                            MolaritySoluteCombo(
                              state: state,
                              onSelected: onSoluteIndex,
                            ),
                            const SizedBox(width: 24),
                            Semantics(
                              button: true,
                              label: '全部重置',
                              child: KratosResetAllButton(
                                onPressed: onReset,
                                radius: MolarityLayout.resetRadius,
                                tooltip: '全部重置',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

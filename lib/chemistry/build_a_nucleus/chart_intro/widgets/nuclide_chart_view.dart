/// 稀疏核素图静态视图。格子不可点、无 hover。
///
/// Zoom / Focused 的窗来自 [NuclideChartRender.viewport]，Painter 不持有状态。
library;

import 'package:flutter/material.dart';

import '../../data/nuclide_repository.dart';
import '../chart_intro_visuals.dart';
import '../controller/chart_intro_controller.dart';
import '../model/chart_intro_state.dart';
import '../painters/nuclide_chart_painter.dart';
import 'chart_intro_decay_controls.dart';
import 'decay_equation_view.dart';
import 'full_chart_dialog.dart';
import '../render/chart_focus_memory.dart';
import '../render/chart_intro_projection.dart';
import '../render/chart_viewport.dart';
import '../render/nuclide_chart_render.dart';

class NuclideChartView extends StatelessWidget {
  const NuclideChartView({
    super.key,
    required this.render,
    this.axisInset = const EdgeInsets.fromLTRB(44, 16, 12, 36),
  });

  factory NuclideChartView.fromState(
    ChartIntroState state,
    NuclideRepository repository, {
    Key? key,
    double? cellSize,
    NuclideChartPresentation presentation = NuclideChartPresentation.partial,
    ChartFocusMemory? focus,
  }) =>
      NuclideChartView(
        key: key,
        render: NuclideChartRender.from(
          state,
          repository,
          cellSize: cellSize,
          presentation: presentation,
          focus: focus,
        ),
        axisInset: presentation == NuclideChartPresentation.partial
            ? const EdgeInsets.fromLTRB(44, 16, 12, 36)
            : EdgeInsets.zero,
      );

  final NuclideChartRender render;
  final EdgeInsets axisInset;

  @override
  Widget build(BuildContext context) {
    final clip = render.presentation == NuclideChartPresentation.zoomIn
        ? render.viewport?.clipLocal
        : null;
    final grid = render.gridSize;
    final size = clip != null
        ? clip.size
        : Size(
            grid.width + axisInset.horizontal,
            grid.height + axisInset.vertical,
          );
    return IgnorePointer(
      child: CustomPaint(
        size: size,
        painter: NuclideChartPainter(
          render: render,
          proj: const ChartIntroProjection(origin: Offset.zero),
          axisInset: axisInset,
        ),
      ),
    );
  }
}

class NuclideChartLegend extends StatelessWidget {
  const NuclideChartLegend({super.key});

  static const _items = <(String, Color)>[
    ('Stable', ChartIntroVisuals.stable),
    ('Alpha Decay', ChartIntroVisuals.alpha),
    ('Beta Minus Decay', ChartIntroVisuals.betaMinus),
    ('Beta Plus Decay', ChartIntroVisuals.betaPlus),
    ('Proton Emission', ChartIntroVisuals.protonEmission),
    ('Neutron Emission', ChartIntroVisuals.neutronEmission),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ChartIntroVisuals.legendKeyBoxSize * 2 +
          ChartIntroVisuals.legendItemSpacing * 2 +
          ChartIntroVisuals.legendGridXSpacing +
          220,
      child: Wrap(
        spacing: ChartIntroVisuals.legendGridXSpacing,
        runSpacing: ChartIntroVisuals.legendGridYSpacing,
        children: [
          for (final item in _items)
            SizedBox(
              width: 110 +
                  ChartIntroVisuals.legendKeyBoxSize +
                  ChartIntroVisuals.legendItemSpacing,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: ChartIntroVisuals.legendKeyBoxSize,
                    height: ChartIntroVisuals.legendKeyBoxSize,
                    decoration: BoxDecoration(
                      color: item.$2,
                      border: Border.all(color: ChartIntroVisuals.cellBorder),
                    ),
                  ),
                  const SizedBox(width: ChartIntroVisuals.legendItemSpacing),
                  Flexible(
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: ChartIntroVisuals.legendFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Partial 或 Zoom：方程 + Zoom-in + Focused + Decay 键 + Full Chart 按钮。
class ChartIntroChartPanel extends StatelessWidget {
  const ChartIntroChartPanel({super.key, required this.controller});

  final ChartIntroController controller;

  @override
  Widget build(BuildContext context) {
    final s = controller.state;
    final zoom = s.selectedChart == ChartIntroChartType.zoom;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: ChartIntroVisuals.chartAccordionFill,
            border: Border.all(color: ChartIntroVisuals.panelStroke),
            borderRadius:
                BorderRadius.circular(ChartIntroVisuals.panelCornerRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ChartIntroVisuals.accordionContentSpacing),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  ChartIntroVisuals.partialNuclideChartTitle,
                  key: ValueKey('chart_intro_chart_title'),
                  style: TextStyle(
                    fontSize: ChartIntroVisuals.regularFontSize,
                  ),
                ),
                const SizedBox(height: ChartIntroVisuals.accordionContentSpacing),
                if (zoom) ...[
                  DecayEquationView(render: controller.decayEquation),
                  const SizedBox(height: ChartIntroVisuals.accordionContentSpacing),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NuclideChartView.fromState(
                        s,
                        controller.repository,
                        presentation: NuclideChartPresentation.zoomIn,
                        focus: controller.chartFocus,
                      ),
                      const SizedBox(width: ChartIntroVisuals.accordionContentSpacing),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ChartIntroDecayControls(controller: controller),
                          const SizedBox(
                            height: ChartIntroVisuals.accordionContentSpacing,
                          ),
                          NuclideChartView.fromState(
                            s,
                            controller.repository,
                            presentation: NuclideChartPresentation.focused,
                            focus: controller.chartFocus,
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else
                  NuclideChartView.fromState(s, controller.repository),
                const SizedBox(height: ChartIntroVisuals.accordionContentSpacing),
                const NuclideChartLegend(),
              ],
            ),
          ),
        ),
        const SizedBox(height: ChartIntroVisuals.accordionContentSpacing),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChartModeRadio(controller: controller),
            const SizedBox(width: 8),
            const FullChartButton(),
          ],
        ),
      ],
    );
  }
}

class _ChartModeRadio extends StatelessWidget {
  const _ChartModeRadio({required this.controller});

  final ChartIntroController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.state.selectedChart;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _modeButton(
          key: const ValueKey('chart_intro_chart_partial'),
          selected: selected == ChartIntroChartType.partial,
          label: 'Partial',
          onTap: () => controller.selectChart(ChartIntroChartType.partial),
        ),
        const SizedBox(width: 8),
        _modeButton(
          key: const ValueKey('chart_intro_chart_zoom'),
          selected: selected == ChartIntroChartType.zoom,
          label: 'Zoom',
          onTap: () => controller.selectChart(ChartIntroChartType.zoom),
        ),
      ],
    );
  }

  Widget _modeButton({
    required Key key,
    required bool selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: ChartIntroVisuals.chartRadioBackground,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? Colors.black87 : Colors.black26,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        key: key,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(fontSize: ChartIntroVisuals.legendFontSize),
          ),
        ),
      ),
    );
  }
}

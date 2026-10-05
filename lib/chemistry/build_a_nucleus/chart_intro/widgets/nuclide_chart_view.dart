/// 稀疏核素图静态视图。格子不可点、无 hover。
///
/// Zoom / Focused 的窗来自 [NuclideChartRender.viewport]，Painter 不持有状态。
library;

import 'package:flutter/material.dart';

import '../../ban_constants.dart';
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
    bool showMagicNumbers = false,
  }) =>
      NuclideChartView(
        key: key,
        render: NuclideChartRender.from(
          state,
          repository,
          cellSize: cellSize,
          presentation: presentation,
          focus: focus,
          showMagicNumbers: showMagicNumbers,
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

  /// 左列 Stable / β⁻ / Proton emission，右列 α / β⁺ / Neutron emission。
  /// [已确认] `NuclideChartLegendNode` 无 “Most likely decay type” 标题。
  static const _left = <(String, Color)>[
    ('Stable', ChartIntroVisuals.stable),
    ('β⁻ decay', ChartIntroVisuals.betaMinus),
    ('Proton emission', ChartIntroVisuals.protonEmission),
  ];
  static const _right = <(String, Color)>[
    ('α decay', ChartIntroVisuals.alpha),
    ('β⁺ decay', ChartIntroVisuals.betaPlus),
    ('Neutron emission', ChartIntroVisuals.neutronEmission),
  ];

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _column(_left),
        const SizedBox(width: 28),
        _column(_right),
      ],
      ),
    );
  }

  Widget _column(List<(String, Color)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(
              bottom: ChartIntroVisuals.legendGridYSpacing,
            ),
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
                Text(
                  item.$1,
                  style: const TextStyle(
                    fontSize: ChartIntroVisuals.legendFontSize,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Partial 或 Zoom：方程 + Zoom-in + Focused + Decay 键 + Full Chart 按钮。
class ChartIntroChartPanel extends StatelessWidget {
  const ChartIntroChartPanel({
    super.key,
    required this.controller,
    this.showMagicNumbers = false,
    this.onMagicChanged,
    this.accordionExpanded = true,
    this.onAccordionToggle,
  });

  final ChartIntroController controller;
  final bool showMagicNumbers;
  final ValueChanged<bool>? onMagicChanged;
  final bool accordionExpanded;
  final VoidCallback? onAccordionToggle;

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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onAccordionToggle,
                      child: Container(
                        key: const ValueKey('chart_intro_accordion_toggle'),
                        width: 18,
                        height: 18,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(BanConstants.decayButtonColorValue),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          accordionExpanded ? '−' : '+',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      ChartIntroVisuals.partialNuclideChartTitle,
                      key: ValueKey('chart_intro_chart_title'),
                      style: TextStyle(
                        fontSize: ChartIntroVisuals.regularFontSize,
                      ),
                    ),
                  ],
                ),
                if (accordionExpanded) ...[
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
                          showMagicNumbers: showMagicNumbers,
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
                              showMagicNumbers: showMagicNumbers,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ] else
                    NuclideChartView.fromState(
                      s,
                      controller.repository,
                      showMagicNumbers: showMagicNumbers,
                    ),
                  const SizedBox(height: ChartIntroVisuals.accordionContentSpacing),
                  const NuclideChartLegend(),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: ChartIntroVisuals.accordionContentSpacing),
        Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ChartModeRadio(controller: controller),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          key: const ValueKey('chart_intro_magic_numbers'),
                          value: showMagicNumbers,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          side: const BorderSide(
                            color: Colors.black87,
                            width: 1.2,
                          ),
                          onChanged: onMagicChanged == null
                              ? null
                              : (v) {
                                  if (v != null) onMagicChanged!(v);
                                },
                        ),
                        const Text(
                          ChartIntroVisuals.magicNumbersLabel,
                          style: TextStyle(
                            fontSize: ChartIntroVisuals.legendFontSize,
                          ),
                        ),
                      ],
                    ),
                    const FullChartButton(),
                  ],
                ),
              ],
            ),
          ),
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
          zoomThumb: false,
          onTap: () => controller.selectChart(ChartIntroChartType.partial),
        ),
        const SizedBox(width: 8),
        _modeButton(
          key: const ValueKey('chart_intro_chart_zoom'),
          selected: selected == ChartIntroChartType.zoom,
          zoomThumb: true,
          onTap: () => controller.selectChart(ChartIntroChartType.zoom),
        ),
      ],
    );
  }

  Widget _modeButton({
    required Key key,
    required bool selected,
    required VoidCallback onTap,
    required bool zoomThumb,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black,
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: InkWell(
        key: key,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: CustomPaint(
            size: const Size(52, 40),
            painter: _ChartThumbPainter(zoom: zoomThumb),
          ),
        ),
      ),
    );
  }
}

class _ChartThumbPainter extends CustomPainter {
  const _ChartThumbPainter({required this.zoom});

  final bool zoom;

  /// 与 Partial 图相同的稀疏占用（质子行 → 中子列）。
  static const _partialNs = <List<int>>[
    [1, 4, 6],
    [0, 1, 2, 3, 4, 5, 6],
    [1, 2, 3, 4, 5, 6, 7, 8],
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    [3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    [3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    [4, 5, 6, 7, 8, 9, 10, 11, 12],
    [5, 6, 7, 8, 9, 10, 11, 12],
  ];

  static const _palette = [
    ChartIntroVisuals.stable,
    ChartIntroVisuals.betaMinus,
    ChartIntroVisuals.betaPlus,
    ChartIntroVisuals.alpha,
    ChartIntroVisuals.protonEmission,
    ChartIntroVisuals.neutronEmission,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (zoom) {
      _paintZoom(canvas, size);
    } else {
      _paintPartial(canvas, size);
    }
  }

  void _paintPartial(Canvas canvas, Size size) {
    const cols = 13;
    const rows = 11;
    final cell = size.width / cols < size.height / rows
        ? size.width / cols
        : size.height / rows;
    final originY = size.height - cell * rows;
    for (var p = 0; p < rows; p++) {
      for (final n in _partialNs[p]) {
        final rect = Rect.fromLTWH(
          n * cell,
          originY + (rows - 1 - p) * cell,
          cell,
          cell,
        );
        canvas.drawRect(
          rect,
          Paint()..color = _palette[(p + n) % _palette.length],
        );
      }
    }
  }

  void _paintZoom(Canvas canvas, Size size) {
    const cols = 5;
    const rows = 4;
    final cell = size.width / cols < size.height / rows
        ? size.width / cols
        : size.height / rows;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final rect = Rect.fromLTWH(x * cell, y * cell, cell, cell);
        canvas.drawRect(
          rect,
          Paint()..color = _palette[(x + y * 2) % _palette.length],
        );
        canvas.drawRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.4
            ..color = ChartIntroVisuals.cellBorder,
        );
      }
    }
    canvas.drawRect(
      Rect.fromLTWH(cell * 1.6, cell * 0.9, cell * 1.6, cell * 1.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _ChartThumbPainter old) => old.zoom != zoom;
}


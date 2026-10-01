/// Chart Intro 同位素符号盒。对标 shred `SymbolNode`，无电荷、无交互。
library;

import 'package:flutter/material.dart';

import '../../data/nuclide_table.dart';
import '../chart_intro_visuals.dart';
import '../model/chart_intro_state.dart';
import '../model/periodic_table_reading.dart';
import '../painters/chart_intro_symbol_painter.dart';
import '../render/chart_intro_symbol_render.dart';
import '../render/periodic_table_panel_geometry.dart';
import '../render/periodic_table_render.dart';
import 'periodic_table_view.dart';

class ChartIntroSymbolView extends StatelessWidget {
  const ChartIntroSymbolView({super.key, required this.render});

  factory ChartIntroSymbolView.fromCounts({
    required int protonCount,
    required int massNumber,
    required List<ElementInfo> elements,
    Key? key,
  }) =>
      ChartIntroSymbolView(
        key: key,
        render: ChartIntroSymbolRender.fromCounts(
          protonCount: protonCount,
          massNumber: massNumber,
          elements: elements,
        ),
      );

  final ChartIntroSymbolRender render;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: PeriodicTablePanelGeometry.symbolPaintedSize,
        painter: ChartIntroSymbolPainter(render: render),
      ),
    );
  }
}

/// 右上角面板：周期表 + 符号盒。对标 `PeriodicTableAndIsotopeSymbol`。
///
/// 150×100 只是原版经验父矩形，这里按真实子节点外包；不裁切。
class PeriodicTableAndSymbolView extends StatelessWidget {
  const PeriodicTableAndSymbolView({
    super.key,
    required this.table,
    required this.symbol,
  });

  /// [elements] 只提供符号；高亮只看 [ChartIntroState.protonCount]。
  factory PeriodicTableAndSymbolView.fromState(
    ChartIntroState state,
    List<ElementInfo> elements, {
    Key? key,
  }) {
    final reading = PeriodicTableReading.from(
      protonCount: state.protonCount,
      elements: elements,
    );
    return PeriodicTableAndSymbolView(
      key: key,
      table: PeriodicTableRender.from(reading),
      symbol: ChartIntroSymbolRender.fromCounts(
        protonCount: state.protonCount,
        massNumber: state.massNumber,
        elements: elements,
      ),
    );
  }

  final PeriodicTableRender table;
  final ChartIntroSymbolRender symbol;

  @override
  Widget build(BuildContext context) {
    final g = PeriodicTablePanelGeometry.contentSize;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ChartIntroVisuals.panelBackground,
          border: Border.all(color: ChartIntroVisuals.panelStroke),
          borderRadius:
              BorderRadius.circular(ChartIntroVisuals.panelCornerRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ChartIntroVisuals.panelXMargin,
            ChartIntroVisuals.panelYMargin,
            ChartIntroVisuals.panelXMargin,
            ChartIntroVisuals.panelYMargin,
          ),
          child: SizedBox(
            width: g.width,
            height: g.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: PeriodicTablePanelGeometry.tableLeft,
                  top: PeriodicTablePanelGeometry.tableTop,
                  child: PeriodicTableView(render: table),
                ),
                Positioned(
                  left: PeriodicTablePanelGeometry.symbolLeft,
                  top: PeriodicTablePanelGeometry.symbolTop,
                  child: ChartIntroSymbolView(
                    key: const ValueKey('chart_intro_isotope_symbol'),
                    render: symbol,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `PeriodicTableAndIsotopeSymbol` 叠层几何。不负责画、不算高亮。
library;

import 'package:flutter/material.dart';

import '../chart_intro_visuals.dart';
import '../model/periodic_table_layout.dart';

class PeriodicTablePanelGeometry {
  const PeriodicTablePanelGeometry._();

  static Size get tablePaintedSize => Size(
        PeriodicTableLayout.columnCount *
            ChartIntroVisuals.periodicTableCellSize *
            ChartIntroVisuals.periodicTableScale,
        PeriodicTableLayout.rowCount *
            ChartIntroVisuals.periodicTableCellSize *
            ChartIntroVisuals.periodicTableScale,
      );

  static Size get symbolPaintedSize => Size(
        ChartIntroVisuals.isotopeSymbolBoxWidth *
            ChartIntroVisuals.isotopeSymbolScale,
        ChartIntroVisuals.isotopeSymbolBoxHeight *
            ChartIntroVisuals.isotopeSymbolScale,
      );

  /// [已确认] `symbolNode.centerX = (7.5/18) * periodicTable.width`
  static double get symbolCenterX =>
      (ChartIntroVisuals.isotopeSymbolCenterColumn /
          PeriodicTableLayout.columnCount) *
      tablePaintedSize.width;

  static double get symbolLeft =>
      symbolCenterX - symbolPaintedSize.width / 2;

  static double get symbolTop => 0;

  /// [已确认] `periodicTable.top = symbol.bottom - (height/7)*2.5`
  static double get tableTop =>
      symbolPaintedSize.height -
      (tablePaintedSize.height / PeriodicTableLayout.rowCount) *
          ChartIntroVisuals.periodicTableSymbolOverlapRows;

  static double get tableLeft => 0;

  static Size get contentSize {
    final tableBottom = tableTop + tablePaintedSize.height;
    final symbolBottom = symbolTop + symbolPaintedSize.height;
    final height = tableBottom > symbolBottom ? tableBottom : symbolBottom;
    return Size(tablePaintedSize.width, height);
  }
}

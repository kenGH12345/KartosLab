/// 周期表像素快照：只消化 [PeriodicTableReading]，不读 State、不查 Repository。
///
/// 高亮已经在 Reading 里定好；本类只映射填色 / 描边 / 字色。
library;

import 'package:flutter/material.dart';

import '../chart_intro_visuals.dart';
import '../model/periodic_table_layout.dart';
import '../model/periodic_table_reading.dart';

class PeriodicTableCellVisual {
  const PeriodicTableCellVisual({
    required this.atomicNumber,
    required this.column,
    required this.row,
    required this.symbol,
    required this.rect,
    required this.highlighted,
    required this.fill,
    required this.stroke,
    required this.strokeWidth,
    required this.labelColor,
    required this.labelWeight,
  });

  final int atomicNumber;
  final int column;
  final int row;
  final String symbol;
  final Rect rect;
  final bool highlighted;
  final Color fill;
  final Color stroke;
  final double strokeWidth;
  final Color labelColor;
  final FontWeight labelWeight;
}

class PeriodicTableRender {
  const PeriodicTableRender({
    required this.cells,
    required this.highlightedAtomicNumber,
    required this.cellSize,
  });

  /// [reading] 已含座位 / 符号 / 高亮 Z。这里不再算 Z、不再决定高亮对象。
  factory PeriodicTableRender.from(
    PeriodicTableReading reading, {
    double cellSize = ChartIntroVisuals.periodicTableCellSize,
  }) {
    final highlightZ = reading.highlightedAtomicNumber;
    return PeriodicTableRender(
      cells: [
        for (final cell in reading.cells)
          _visual(cell, cellSize, highlighted: cell.atomicNumber == highlightZ),
      ],
      highlightedAtomicNumber: highlightZ,
      cellSize: cellSize,
    );
  }

  final List<PeriodicTableCellVisual> cells;
  final int? highlightedAtomicNumber;
  final double cellSize;

  /// 未缩放主表外框。[已确认] 18×7 格，无 gap
  Size get tableSize => Size(
        PeriodicTableLayout.columnCount * cellSize,
        PeriodicTableLayout.rowCount * cellSize,
      );

  /// 画布尺寸（已含 `scale(0.75)`）。
  Size get paintedSize => tableSize * ChartIntroVisuals.periodicTableScale;

  PeriodicTableCellVisual? cellAtAtomicNumber(int z) {
    for (final c in cells) {
      if (c.atomicNumber == z) return c;
    }
    return null;
  }

  PeriodicTableCellVisual? cellAtGrid(int column, int row) {
    for (final c in cells) {
      if (c.column == column && c.row == row) return c;
    }
    return null;
  }

  Iterable<PeriodicTableCellVisual> cellsInRow(int row) =>
      cells.where((c) => c.row == row);

  Iterable<PeriodicTableCellVisual> cellsInColumn(int column) =>
      cells.where((c) => c.column == column);

  PeriodicTableCellVisual? get highlightedCell {
    final z = highlightedAtomicNumber;
    if (z == null) return null;
    return cellAtAtomicNumber(z);
  }

  static PeriodicTableCellVisual _visual(
    PeriodicTableCellData cell,
    double cellSize, {
    required bool highlighted,
  }) {
    return PeriodicTableCellVisual(
      atomicNumber: cell.atomicNumber,
      column: cell.column,
      row: cell.row,
      symbol: cell.symbol,
      rect: Rect.fromLTWH(
        cell.column * cellSize,
        cell.row * cellSize,
        cellSize,
        cellSize,
      ),
      highlighted: highlighted,
      fill: highlighted
          ? ChartIntroVisuals.periodicTableHighlightFill
          : ChartIntroVisuals.periodicTableDisabledFill,
      stroke: highlighted
          ? ChartIntroVisuals.periodicTableHighlightStroke
          : ChartIntroVisuals.periodicTableCellStroke,
      strokeWidth: highlighted
          ? ChartIntroVisuals.periodicTableHighlightStrokeWidth
          : ChartIntroVisuals.periodicTableCellStrokeWidth,
      labelColor: highlighted
          ? ChartIntroVisuals.periodicTableHighlightLabel
          : ChartIntroVisuals.periodicTableLabel,
      labelWeight: highlighted ? FontWeight.bold : FontWeight.normal,
    );
  }
}

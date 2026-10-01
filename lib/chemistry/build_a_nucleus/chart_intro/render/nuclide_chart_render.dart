/// 稀疏核素图的不可变渲染快照。
///
/// 格子颜色走 [NuclideRepository.availableDecays].first，不另存一份表。
/// 空白格不进入 [cells]（稀疏，不是满 11×13）。
library;

import 'package:flutter/material.dart';

import '../../ban_constants.dart';
import '../../data/decay_type.dart';
import '../../data/nuclide_repository.dart';
import '../chart_intro_visuals.dart';
import '../model/chart_intro_state.dart';
import '../model/populated_cells.dart';
import 'chart_focus_memory.dart';
import 'chart_viewport.dart';

enum ChartCellKind {
  stable,
  unstable,
  unknown,
}

class ChartCellVisual {
  const ChartCellVisual({
    required this.protonNumber,
    required this.neutronNumber,
    required this.kind,
    required this.color,
    required this.decayType,
    required this.isCurrent,
    this.opacity = 1,
  });

  final int protonNumber;
  final int neutronNumber;
  final ChartCellKind kind;
  final Color color;
  final NucleusDecayType? decayType;
  final bool isCurrent;
  final double opacity;

  /// 图上 X。[已确认] modelToViewX(neutronNumber)
  int get x => neutronNumber;

  /// 图上 Y。[已确认] 竖直 spacing 的 protonNumber
  int get y => protonNumber;
}

class NuclideChartRender {
  const NuclideChartRender({
    required this.cells,
    required this.currentProton,
    required this.currentNeutron,
    required this.currentExists,
    required this.currentSymbol,
    required this.currentLabelFill,
    required this.cellSize,
    this.presentation = NuclideChartPresentation.partial,
    this.viewport,
  });

  factory NuclideChartRender.from(
    ChartIntroState state,
    NuclideRepository repository, {
    double? cellSize,
    NuclideChartPresentation presentation = NuclideChartPresentation.partial,
    ChartFocusMemory? focus,
  }) {
    final resolvedSize = cellSize ?? _cellSizeFor(presentation);
    final p = state.protonCount;
    final n = state.neutronCount;
    final memory = focus ?? ChartFocusMemory()
      ..sync(
        protonCount: p,
        neutronCount: n,
        exists: state.nuclideExists,
      );
    final viewport = presentation == NuclideChartPresentation.partial
        ? null
        : ChartViewport.from(memory, cellSize: resolvedSize);

    final cells = <ChartCellVisual>[
      for (final ref in PopulatedCells.allCells)
        _cell(
          ref,
          repository,
          isCurrent: ref.protonNumber == p && ref.neutronNumber == n,
          opacity: presentation == NuclideChartPresentation.focused
              ? viewport?.opacityFor(ref.protonNumber, ref.neutronNumber) ?? 1
              : 1,
        ),
    ];

    NucleusDecayType? currentDecay;
    var currentStable = false;
    if (state.nuclideExists) {
      currentStable = state.isStable;
      final branches = repository.availableDecays(p, n);
      currentDecay = branches.isEmpty ? null : branches.first.type;
    }

    return NuclideChartRender(
      cells: List.unmodifiable(cells),
      currentProton: p,
      currentNeutron: n,
      currentExists: state.nuclideExists,
      currentSymbol: state.nuclideExists ? state.elementSymbol : '',
      currentLabelFill: ChartIntroVisuals.labelFillFor(
        isStable: currentStable,
        decayType: currentDecay,
      ),
      cellSize: resolvedSize,
      presentation: presentation,
      viewport: viewport,
    );
  }

  final List<ChartCellVisual> cells;
  final int currentProton;
  final int currentNeutron;
  final bool currentExists;
  final String currentSymbol;
  final Color currentLabelFill;
  final double cellSize;
  final NuclideChartPresentation presentation;
  final ChartViewport? viewport;

  bool get showAxes => presentation == NuclideChartPresentation.partial;

  static double _cellSizeFor(NuclideChartPresentation presentation) {
    switch (presentation) {
      case NuclideChartPresentation.partial:
        return ChartIntroVisuals.partialCellSize;
      case NuclideChartPresentation.focused:
        return ChartIntroVisuals.focusedCellSize;
      case NuclideChartPresentation.zoomIn:
        return ChartIntroVisuals.zoomCellSize;
    }
  }

  static const int maxProton = BanConstants.chartMaxProtons;
  static const int maxNeutron = BanConstants.chartMaxNeutrons;

  /// 含溢出的最后一行/列：p=0…10、n=0…12 各一格。
  /// bamboo viewHeight = 10 * scale，最后一行会超出；这里按可观察格子包住。
  /// [推测] 精确 bamboo 溢出与 Flutter 画布对齐，实现时按格子完整可见处理
  Size get gridSize => Size(
        (maxNeutron + 1) * cellSize,
        (maxProton + 1) * cellSize,
      );

  /// 格子左上角（网格局部，未含数轴边距）。
  /// Y 翻转：质子增大朝上。[已确认] ChartTransform inverted Y + Y_SHIFT = -0.5
  Offset cellTopLeft(int protonNumber, int neutronNumber) => Offset(
        neutronNumber * cellSize,
        (maxProton - protonNumber) * cellSize,
      );

  Offset cellCenter(int protonNumber, int neutronNumber) =>
      cellTopLeft(protonNumber, neutronNumber) + Offset(cellSize / 2, cellSize / 2);

  ChartCellVisual? get currentCellVisual {
    for (final c in cells) {
      if (c.isCurrent) return c;
    }
    return null;
  }

  static ChartCellVisual _cell(
    ChartCellRef ref,
    NuclideRepository repository, {
    required bool isCurrent,
    double opacity = 1,
  }) {
    final stable = repository.isStable(ref.protonNumber, ref.neutronNumber);
    final branches =
        repository.availableDecays(ref.protonNumber, ref.neutronNumber);
    final decay = branches.isEmpty ? null : branches.first.type;
    final kind = stable
        ? ChartCellKind.stable
        : decay == null
            ? ChartCellKind.unknown
            : ChartCellKind.unstable;
    return ChartCellVisual(
      protonNumber: ref.protonNumber,
      neutronNumber: ref.neutronNumber,
      kind: kind,
      color: ChartIntroVisuals.colorForDecay(decay, isStable: stable),
      decayType: decay,
      isCurrent: isCurrent,
      opacity: opacity,
    );
  }
}

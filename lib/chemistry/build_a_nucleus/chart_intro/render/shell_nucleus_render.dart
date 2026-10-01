/// 壳层主核的不可变渲染快照。
///
/// `ChartIntroState` → 本类 → Painter。淡入淡出来自可选 [ShellFadeAnimator]。
library;

import 'package:flutter/material.dart';

import '../../model/nucleon.dart';
import '../chart_intro_visuals.dart';
import '../model/chart_intro_state.dart';
import '../model/energy_level.dart';
import '../model/shell_model_nucleus.dart';
import 'shell_fade.dart';
import 'shell_layout.dart';

class ShellNucleonVisual {
  const ShellNucleonVisual({
    required this.id,
    required this.type,
    required this.center,
    required this.bound,
    this.opacity = 1,
  });

  final int id;
  final NucleonType type;
  final Offset center;
  final bool bound;
  final double opacity;
}

class EnergyLevelVisual {
  const EnergyLevelVisual({
    required this.yPosition,
    required this.start,
    required this.end,
    required this.stroke,
    required this.strokeWidth,
    required this.occupied,
    required this.capacity,
  });

  final int yPosition;
  final Offset start;
  final Offset end;
  final Color stroke;
  final double strokeWidth;
  final int occupied;
  final int capacity;
}

class ShellColumnVisual {
  const ShellColumnVisual({
    required this.type,
    required this.xOffset,
    required this.nucleons,
    required this.levels,
  });

  final NucleonType type;
  final double xOffset;
  final List<ShellNucleonVisual> nucleons;
  final List<EnergyLevelVisual> levels;
}

class ShellNucleusRender {
  const ShellNucleusRender({
    required this.protonColumn,
    required this.neutronColumn,
  });

  factory ShellNucleusRender.from(
    ChartIntroState state, {
    ShellFadeAnimator? fades,
  }) {
    return ShellNucleusRender(
      protonColumn: _column(
        type: NucleonType.proton,
        nucleons: state.shell.protons,
        xOffset: 0,
        fades: fades,
      ),
      neutronColumn: _column(
        type: NucleonType.neutron,
        nucleons: state.shell.neutrons,
        xOffset: ChartIntroVisuals.energyLevelColumnGap,
        fades: fades,
      ),
    );
  }

  final ShellColumnVisual protonColumn;
  final ShellColumnVisual neutronColumn;

  List<ShellColumnVisual> get columns => [protonColumn, neutronColumn];

  /// 两列并排后的内容尺寸（含中子偏移与列包围盒）。
  Size get contentSize {
    final b = ShellLayout.columnBounds;
    return Size(
      ChartIntroVisuals.energyLevelColumnGap + b.right - b.left,
      b.height,
    );
  }

  Offset get contentOrigin => -ShellLayout.columnBounds.topLeft;

  static ShellColumnVisual _column({
    required NucleonType type,
    required List<ShellNucleon> nucleons,
    required double xOffset,
    ShellFadeAnimator? fades,
  }) {
    final visuals = <ShellNucleonVisual>[];
    for (var i = 0; i < nucleons.length; i++) {
      final n = nucleons[i];
      final local = ShellLayout.nucleonCenter(
        index: i,
        xPosition: n.xPosition,
        yPosition: n.yPosition,
        bound: n.bound,
      );
      visuals.add(ShellNucleonVisual(
        id: n.id,
        type: n.type,
        center: Offset(local.dx + xOffset, local.dy),
        bound: n.bound,
        opacity: fades?.opacityOf(n.id) ?? 1,
      ));
    }
    if (fades != null) {
      for (final g in fades.ghosts) {
        if (g.type != type) continue;
        visuals.add(ShellNucleonVisual(
          id: g.id,
          type: g.type,
          center: g.center,
          bound: false,
          opacity: g.opacity,
        ));
      }
    }

    final count = nucleons.length;
    final levels = [
      for (final level in EnergyLevel.levels)
        () {
          final line = ShellLayout.energyLine(level);
          return EnergyLevelVisual(
            yPosition: level.yPosition,
            start: Offset(line.$1.dx + xOffset, line.$1.dy),
            end: Offset(line.$2.dx + xOffset, line.$2.dy),
            stroke: ShellLayout.energyStroke(
              type: type,
              level: level,
              count: count,
            ),
            strokeWidth: ShellLayout.energyStrokeWidth(level, count),
            occupied: ShellLayout.occupancy(level, count),
            capacity: level.capacity,
          );
        }(),
    ];

    return ShellColumnVisual(
      type: type,
      xOffset: xOffset,
      nucleons: List.unmodifiable(visuals),
      levels: List.unmodifiable(levels),
    );
  }
}

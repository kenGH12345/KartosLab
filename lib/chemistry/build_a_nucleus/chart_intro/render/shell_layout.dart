/// 壳层座位 → 像素。对标 `ShellModelNucleus.PARTICLE_POSITIONING_TRANSFORM`。
///
/// [已确认] `createRectangleInvertedYMapping(
///   Bounds2(0,0,5,2),
///   Bounds2(0,0, (20+10)*5, (20+80)*2) )`
/// 即 viewX = x * 30，viewY = 200 - y * 100（模型 Y 向上 = 更高能级）。
library;

import 'package:flutter/material.dart';

import '../../model/nucleon.dart';
import '../chart_intro_visuals.dart';
import '../model/energy_level.dart';

class ShellLayout {
  const ShellLayout._();

  /// n1 行座位数 − 1。[已确认] NUMBER_OF_RADII_SPACES_BETWEEN_PARTICLES
  static const int xModelMax = EnergyLevel.n1Capacity - 1;

  static const int yModelMax = 2;

  static const double viewWidth = (ChartIntroVisuals.nucleonDiameter +
          ChartIntroVisuals.particleXSpacing) *
      xModelMax;

  static const double viewHeight = (ChartIntroVisuals.nucleonDiameter +
          ChartIntroVisuals.particleYSpacing) *
      yModelMax;

  static double get _xScale => viewWidth / xModelMax;

  static double get _yScale => viewHeight / yModelMax;

  /// 未绑定座位中心（列内局部坐标，尚未加中子列偏移）。
  static Offset unboundCenter(int xPosition, int yPosition) => Offset(
        xPosition * _xScale,
        viewHeight - yPosition * _yScale,
      );

  /// n1 行宽度，绑定靠拢用。[已确认] modelToViewX(5) - modelToViewX(0)
  static double get n1LevelWidth =>
      unboundCenter(EnergyLevel.n1.allowedX.last, 1).dx -
      unboundCenter(EnergyLevel.n1.allowedX.first, 1).dx;

  /// 绑定后中心。[已确认] updateNucleonPositions 的 boundOffset / centerOffset
  static Offset boundCenter({
    required int index,
    required int yPosition,
    required int xPosition,
  }) {
    final unbound = unboundCenter(xPosition, yPosition);
    final levelIndex =
        yPosition == EnergyLevel.n0.yPosition ? index : index - EnergyLevel.n0Capacity;
    final boundOffset = n1LevelWidth * (levelIndex / (3 * EnergyLevel.n1Capacity - 1));
    final numberOfRadiusSpaces = yPosition == EnergyLevel.n0.yPosition
        ? EnergyLevel.n0Capacity - 1
        : EnergyLevel.n1Capacity - 1;
    final centerOffset =
        ChartIntroVisuals.nucleonRadius * numberOfRadiusSpaces / 2;
    return Offset(unbound.dx - boundOffset + centerOffset, unbound.dy);
  }

  static Offset nucleonCenter({
    required int index,
    required int xPosition,
    required int yPosition,
    required bool bound,
  }) =>
      bound
          ? boundCenter(
              index: index,
              yPosition: yPosition,
              xPosition: xPosition,
            )
          : unboundCenter(xPosition, yPosition);

  /// 能级线：在核子下方一个半径，左右各伸出一个半径。
  /// n0 从 x=2 起，不是 x=0。[已确认] NucleonShellView
  static (Offset start, Offset end) energyLine(EnergyLevel level) {
    final firstX = level.yPosition == 0 ? level.allowedX.first : 0;
    final lastX = level.allowedX.last;
    final y = unboundCenter(0, level.yPosition).dy + ChartIntroVisuals.nucleonRadius;
    return (
      Offset(
        unboundCenter(firstX, level.yPosition).dx - ChartIntroVisuals.nucleonRadius,
        y,
      ),
      Offset(
        unboundCenter(lastX, level.yPosition).dx + ChartIntroVisuals.nucleonRadius,
        y,
      ),
    );
  }

  /// 该层占用数。独立从计数派生，不复制原版 `nucleonCountProperty.link`
  /// 只改当前层、卸载后留下旧描边的增量残留。
  /// [已确认] 插值公式 NucleonShellView；[推测] 按 occupancy 独立算
  static int occupancy(EnergyLevel level, int count) {
    final below = EnergyLevel.levels
        .where((l) => l.yPosition < level.yPosition)
        .fold<int>(0, (sum, l) => sum + l.capacity);
    final remaining = count - below;
    if (remaining <= 0) return 0;
    return remaining > level.capacity ? level.capacity : remaining;
  }

  static Color energyStroke({
    required NucleonType type,
    required EnergyLevel level,
    required int count,
  }) {
    final filled = occupancy(level, count);
    final t = filled / level.capacity;
    final full = type == NucleonType.proton
        ? ChartIntroVisuals.proton
        : ChartIntroVisuals.neutron;
    return Color.lerp(ChartIntroVisuals.emptyEnergyLevel, full, t)!;
  }

  static double energyStrokeWidth(EnergyLevel level, int count) =>
      occupancy(level, count) == level.capacity
          ? ChartIntroVisuals.energyLevelBoldWidth
          : ChartIntroVisuals.energyLevelDefaultWidth;

  /// 一列内容包围盒（含线伸出与核子半径）。
  static Rect get columnBounds {
    const pad = ChartIntroVisuals.nucleonRadius;
    return Rect.fromLTRB(-pad * 2, -pad, viewWidth + pad * 2, viewHeight + pad * 2);
  }
}

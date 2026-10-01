import 'package:flutter/material.dart';

import '../model/density_block.dart';
import '../model/density_material.dart';
import '../render/density_mvt.dart';
import '../solver/density_relation.dart';

class DensityHit {
  const DensityHit({required this.blockId, required this.localOffset});

  final String blockId;

  /// Pointer world − block center at grab time.
  final Offset localOffset;
}

class PointerDrag {
  PointerDrag._();

  static DensityHit? hitTest({
    required List<DensityBlock> blocks,
    required DensityMvt mvt,
    required Offset screen,
  }) {
    DensityBlock? best;
    for (final block in blocks) {
      if (!block.visible) continue;
      final rect = mvt.cubeFrontRect(block.position, block.volume);
      if (!rect.contains(screen)) continue;
      if (best == null || block.position.y >= best.position.y) {
        best = block;
      }
    }
    if (best == null) return null;
    final pointer = mvt.toWorld(screen);
    return DensityHit(
      blockId: best.id,
      localOffset: Offset(
        pointer.x - best.position.x,
        pointer.y - best.position.y,
      ),
    );
  }

  static DensityBlock beginGrab(DensityBlock block) {
    return block.copyWith(
      position: block.position.copyWith(
        y: block.position.y + 0.0001,
      ),
    );
  }
}

class DensityMaterialLooks {
  DensityMaterialLooks._();

  static Color colorFor(DensityBlock block) {
    if (block.colorArgb != null) {
      return Color(block.colorArgb!);
    }
    switch (block.materialId) {
      case DensityMaterialId.styrofoam:
        return const Color(0xFFE8E4D4);
      case DensityMaterialId.wood:
        return const Color(0xFF8B5A2B);
      case DensityMaterialId.ice:
        return const Color(0xFFB9E0F0);
      case DensityMaterialId.pvc:
        return const Color(0xFF6B7C8A);
      case DensityMaterialId.brick:
        return const Color(0xFFB55239);
      case DensityMaterialId.aluminum:
        return const Color(0xFFC5CCD3);
      case DensityMaterialId.custom:
        final d = block.customDensity ?? 400;
        final t = ((d - 50) / 10000).clamp(0.0, 1.0);
        return Color.lerp(
          const Color(0xFFE5E7EB),
          const Color(0xFF111827),
          t,
        )!;
      default:
        return const Color(0xFF9CA3AF);
    }
  }
}

class DensityRelationRanges {
  DensityRelationRanges._();

  static ({double min, double max}) massRange(DensityBlock block) {
    const limits = DensityRelationLimits.intro;
    if (block.isCustom) {
      return (min: limits.minCustomMass, max: limits.maxCustomMass);
    }
    final d = DensityRelation.catalogDensity(block.materialId);
    final min = (d * limits.minVolume).clamp(limits.minMass, limits.maxMass);
    final max = (d * limits.maxVolume).clamp(limits.minMass, limits.maxMass);
    return (min: min, max: max);
  }
}

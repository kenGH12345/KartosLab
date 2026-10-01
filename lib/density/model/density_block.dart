import 'density_material.dart';
import 'density_vec.dart';

/// One cuboid. SSOT is [materialId] + [volume] (+ [customDensity] when custom).
///
/// Mass is derived: `roundToInterval(density * volume, 1e-7)` (`Mass.ts`).
class DensityBlock {
  const DensityBlock({
    required this.id,
    required this.tag,
    required this.materialId,
    required this.volume,
    this.customDensity,
    this.position = DensityVec.zero,
    this.velocity = DensityVec.zero,
    this.visible = true,
    this.colorArgb,
  });

  final String id;
  final String tag;
  final DensityMaterialId materialId;
  final double volume;
  final double? customDensity;
  final DensityVec position;
  final DensityVec velocity;
  final bool visible;

  /// Packed ARGB for Compare / Mystery custom colours. Null → material texture.
  final int? colorArgb;

  bool get isCustom => materialId == DensityMaterialId.custom;

  DensityBlock copyWith({
    String? id,
    String? tag,
    DensityMaterialId? materialId,
    double? volume,
    double? customDensity,
    bool clearCustomDensity = false,
    DensityVec? position,
    DensityVec? velocity,
    bool? visible,
    int? colorArgb,
    bool clearColor = false,
  }) {
    return DensityBlock(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      materialId: materialId ?? this.materialId,
      volume: volume ?? this.volume,
      customDensity: clearCustomDensity
          ? null
          : (customDensity ?? this.customDensity),
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      visible: visible ?? this.visible,
      colorArgb: clearColor ? null : (colorArgb ?? this.colorArgb),
    );
  }
}

enum TwoBlockMode { oneBlock, twoBlocks }

enum CompareBlockSet { sameMass, sameVolume, sameDensity }

enum MysteryBlockSet { set1, set2, set3, random }

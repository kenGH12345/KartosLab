import '../density_colors.dart';
import '../density_constants.dart';
import '../model/density_block.dart';
import '../model/density_material.dart';
import '../solver/density_relation.dart';

class CompareCubeSpec {
  const CompareCubeSpec({
    required this.sameMassVolume,
    required this.sameVolumeMass,
    required this.sameDensityVolume,
    required this.colorArgb,
    required this.sameMassTag,
    required this.sameVolumeTag,
    required this.sameDensityTag,
  });

  final double sameMassVolume;
  final double sameVolumeMass;
  final double sameDensityVolume;
  final int colorArgb;
  final String sameMassTag;
  final String sameVolumeTag;
  final String sameDensityTag;
}

/// `DensityCompareModel.cubesData` + lock ranges.
class CompareConstraint {
  CompareConstraint._();

  static const double sameMassValue = 5;
  static const double sameMassMin = 1;
  static const double sameMassMax = 10;

  static const double sameVolumeValue = 0.005;
  static const double sameVolumeMin = DensityConstants.minVolume;
  static const double sameVolumeMax = DensityConstants.maxVolume;

  /// Density sim override (`DensityCompareModel.ts`). Base class default 400 is unused.
  static const double sameDensityValue = 500;
  static const double sameDensityMin = 100;
  static const double sameDensityMax = 2000;

  static const List<CompareCubeSpec> cubesData = [
    CompareCubeSpec(
      sameMassVolume: 0.01,
      sameVolumeMass: 8,
      sameDensityVolume: 0.006,
      colorArgb: DensityColors.compareYellow,
      sameMassTag: 'B',
      sameVolumeTag: 'A',
      sameDensityTag: 'B',
    ),
    CompareCubeSpec(
      sameMassVolume: 0.005,
      sameVolumeMass: 6,
      sameDensityVolume: 0.004,
      colorArgb: DensityColors.compareBlue,
      sameMassTag: 'A',
      sameVolumeTag: 'C',
      sameDensityTag: 'A',
    ),
    CompareCubeSpec(
      sameMassVolume: 0.0025,
      sameVolumeMass: 4,
      sameDensityVolume: 0.002,
      colorArgb: DensityColors.compareGreen,
      sameMassTag: 'C',
      sameVolumeTag: 'D',
      sameDensityTag: 'C',
    ),
    CompareCubeSpec(
      sameMassVolume: 0.00125,
      sameVolumeMass: 2,
      sameDensityVolume: 0.001,
      colorArgb: DensityColors.compareRed,
      sameMassTag: 'D',
      sameVolumeTag: 'B',
      sameDensityTag: 'D',
    ),
  ];

  static List<DensityBlock> createSet({
    required CompareBlockSet set,
    required double lockedMass,
    required double lockedVolume,
    required double lockedDensity,
  }) {
    return [
      for (var i = 0; i < cubesData.length; i++)
        applyToIndex(
          set: set,
          index: i,
          lockedMass: lockedMass,
          lockedVolume: lockedVolume,
          lockedDensity: lockedDensity,
        ),
    ];
  }

  static DensityBlock applyToIndex({
    required CompareBlockSet set,
    required int index,
    required double lockedMass,
    required double lockedVolume,
    required double lockedDensity,
    DensityBlock? previous,
  }) {
    final spec = cubesData[index];
    switch (set) {
      case CompareBlockSet.sameMass:
        final volume = spec.sameMassVolume;
        return DensityRelation.createWithVolume(
          id: previous?.id ?? 'compare-sameMass-$index',
          tag: spec.sameMassTag,
          materialId: DensityMaterialId.custom,
          volume: volume,
          customDensity: lockedMass / volume,
          colorArgb: spec.colorArgb,
        ).copyWith(
          position: previous?.position,
          velocity: previous?.velocity,
          visible: true,
        );
      case CompareBlockSet.sameVolume:
        return DensityRelation.createWithVolume(
          id: previous?.id ?? 'compare-sameVolume-$index',
          tag: spec.sameVolumeTag,
          materialId: DensityMaterialId.custom,
          volume: lockedVolume,
          customDensity: spec.sameVolumeMass / lockedVolume,
          colorArgb: spec.colorArgb,
        ).copyWith(
          position: previous?.position,
          velocity: previous?.velocity,
          visible: true,
        );
      case CompareBlockSet.sameDensity:
        return DensityRelation.createWithVolume(
          id: previous?.id ?? 'compare-sameDensity-$index',
          tag: spec.sameDensityTag,
          materialId: DensityMaterialId.custom,
          volume: spec.sameDensityVolume,
          customDensity: lockedDensity,
          colorArgb: spec.colorArgb,
        ).copyWith(
          position: previous?.position,
          velocity: previous?.velocity,
          visible: true,
        );
    }
  }

  static List<DensityBlock> applyLocked({
    required CompareBlockSet set,
    required List<DensityBlock> blocks,
    required double lockedMass,
    required double lockedVolume,
    required double lockedDensity,
  }) {
    return [
      for (var i = 0; i < blocks.length; i++)
        applyToIndex(
          set: set,
          index: i,
          lockedMass: lockedMass,
          lockedVolume: lockedVolume,
          lockedDensity: lockedDensity,
          previous: blocks[i],
        ),
    ];
  }
}

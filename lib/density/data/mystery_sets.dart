import 'dart:math' as math;

import '../density_colors.dart';
import '../density_constants.dart';
import '../model/density_block.dart';
import '../model/density_material.dart';
import '../solver/density_relation.dart';

class MysteryBlockSpec {
  const MysteryBlockSpec({
    required this.tag,
    required this.volume,
    required this.density,
    required this.colorArgb,
  });

  final String tag;
  final double volume;
  final double density;
  final int colorArgb;
}

/// `DensityMysteryModel.ts` createMasses + Random.
class MysterySets {
  MysterySets._();

  static const mysterySet2LeadDensity = 11340.0;

  static List<DensityBlock> set1() => _fromVolumeSpecs(const [
        MysteryBlockSpec(
          tag: '1D',
          volume: 0.005,
          density: DensityConstants.waterDensity,
          colorArgb: DensityColors.compareRed,
        ),
        MysteryBlockSpec(
          tag: '1B',
          volume: 0.001,
          density: 400,
          colorArgb: DensityColors.compareBlue,
        ),
        MysteryBlockSpec(
          tag: '1E',
          volume: 0.007,
          density: 400,
          colorArgb: DensityColors.compareGreen,
        ),
        MysteryBlockSpec(
          tag: '1C',
          volume: 0.001,
          density: 19320,
          colorArgb: DensityColors.compareYellow,
        ),
        MysteryBlockSpec(
          tag: '1A',
          volume: 0.0055,
          density: 3510,
          colorArgb: DensityColors.comparePurple,
        ),
      ]);

  static List<DensityBlock> set2() {
    return [
      DensityRelation.createWithMass(
        id: 'mystery-2D',
        tag: '2D',
        materialId: DensityMaterialId.custom,
        mass: 18,
        customDensity: 4500,
        colorArgb: DensityColors.mysteryPink,
      ),
      DensityRelation.createWithMass(
        id: 'mystery-2A',
        tag: '2A',
        materialId: DensityMaterialId.custom,
        mass: 18,
        customDensity: mysterySet2LeadDensity,
        colorArgb: DensityColors.mysteryOrange,
      ),
      DensityRelation.createWithVolume(
        id: 'mystery-2E',
        tag: '2E',
        materialId: DensityMaterialId.custom,
        volume: 0.005,
        customDensity: DensityMaterials.copper.density,
        colorArgb: DensityColors.mysteryLightPurple,
      ),
      DensityRelation.createWithMass(
        id: 'mystery-2C',
        tag: '2C',
        materialId: DensityMaterialId.custom,
        mass: 2.7,
        customDensity: 2700,
        colorArgb: DensityColors.mysteryLightGreen,
      ),
      DensityRelation.createWithMass(
        id: 'mystery-2B',
        tag: '2B',
        materialId: DensityMaterialId.custom,
        mass: 10.8,
        customDensity: 2700,
        colorArgb: DensityColors.mysteryBrown,
      ),
    ];
  }

  static List<DensityBlock> set3() {
    return [
      DensityRelation.createWithMass(
        id: 'mystery-3E',
        tag: '3E',
        materialId: DensityMaterialId.custom,
        mass: 6,
        customDensity: 950,
        colorArgb: DensityColors.mysteryWhite,
      ),
      DensityRelation.createWithMass(
        id: 'mystery-3B',
        tag: '3B',
        materialId: DensityMaterialId.custom,
        mass: 6,
        customDensity: 1000,
        colorArgb: DensityColors.mysteryGray,
      ),
      DensityRelation.createWithMass(
        id: 'mystery-3D',
        tag: '3D',
        materialId: DensityMaterialId.custom,
        mass: 2,
        customDensity: 400,
        colorArgb: DensityColors.mysteryMustard,
      ),
      DensityRelation.createWithMass(
        id: 'mystery-3C',
        tag: '3C',
        materialId: DensityMaterialId.custom,
        mass: 23.4,
        customDensity: 7800,
        colorArgb: DensityColors.mysteryPeach,
      ),
      DensityRelation.createWithMass(
        id: 'mystery-3A',
        tag: '3A',
        materialId: DensityMaterialId.custom,
        mass: 2.85,
        customDensity: 950,
        colorArgb: DensityColors.mysteryMaroon,
      ),
    ];
  }

  static const List<int> randomPalette = [
    DensityColors.compareYellow,
    DensityColors.compareBlue,
    DensityColors.compareGreen,
    DensityColors.compareRed,
    DensityColors.comparePurple,
    DensityColors.mysteryPink,
    DensityColors.mysteryOrange,
    DensityColors.mysteryLightPurple,
    DensityColors.mysteryLightGreen,
    DensityColors.mysteryBrown,
    DensityColors.mysteryWhite,
    DensityColors.mysteryGray,
    DensityColors.mysteryMustard,
    DensityColors.mysteryPeach,
    DensityColors.mysteryMaroon,
  ];

  static const List<String> randomTags = ['C', 'D', 'E', 'A', 'B'];

  /// Shuffle 1–6 L take 3, 7–10 L take 2, then sort (`createMysteryVolumes`).
  static List<double> createMysteryVolumes(math.Random random) {
    final small = _shuffle([1, 2, 3, 4, 5, 6], random).take(3).toList();
    final large = _shuffle([7, 8, 9, 10], random).take(2).toList();
    final liters = [...small, ...large]..sort();
    return [
      for (final l in liters) DensityConstants.cubicMetersFromLiters(l.toDouble()),
    ];
  }

  static List<DensityBlock> randomSet(math.Random random) {
    final densities = _shuffle(
      [
        for (final m in DensityMaterials.mysteryTableMaterials) m.density!,
      ],
      random,
    ).take(5).toList();
    final colors = _shuffle(List<int>.from(randomPalette), random).take(5).toList();
    final volumes = createMysteryVolumes(random);
    return [
      for (var i = 0; i < 5; i++)
        DensityRelation.createWithVolume(
          id: 'mystery-random-${randomTags[i]}',
          tag: randomTags[i],
          materialId: DensityMaterialId.custom,
          volume: volumes[i],
          customDensity: densities[i],
          colorArgb: colors[i],
        ),
    ];
  }

  static List<DensityBlock> forSet(MysteryBlockSet set, {math.Random? random}) {
    switch (set) {
      case MysteryBlockSet.set1:
        return set1();
      case MysteryBlockSet.set2:
        return set2();
      case MysteryBlockSet.set3:
        return set3();
      case MysteryBlockSet.random:
        return randomSet(random ?? math.Random());
    }
  }

  static List<DensityBlock> _fromVolumeSpecs(List<MysteryBlockSpec> specs) {
    return [
      for (final spec in specs)
        DensityRelation.createWithVolume(
          id: 'mystery-${spec.tag}',
          tag: spec.tag,
          materialId: DensityMaterialId.custom,
          volume: spec.volume,
          customDensity: spec.density,
          colorArgb: spec.colorArgb,
        ),
    ];
  }

  static List<T> _shuffle<T>(List<T> source, math.Random random) {
    final list = List<T>.from(source);
    for (var i = list.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
    return list;
  }
}

class DensityTableRow {
  const DensityTableRow(this.material);

  final DensityMaterial material;

  double get kgPerLiter => material.density! / DensityConstants.litersInCubicMeter;

  String get kgPerLiterDisplay => kgPerLiter.toStringAsFixed(2);
}

/// `DensityTableNode.ts`: sort `DENSITY_MYSTERY_SCREEN_MATERIALS` by density.
class DensityTable {
  DensityTable._();

  static List<DensityTableRow> rows() {
    final materials = List<DensityMaterial>.from(
      DensityMaterials.mysteryTableMaterials,
    )..sort((a, b) => a.density!.compareTo(b.density!));
    return [for (final m in materials) DensityTableRow(m)];
  }
}

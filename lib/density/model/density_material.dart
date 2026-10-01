import '../density_constants.dart';

/// Material identities used by Density screens.
///
/// Intro picker = [simpleMassMaterials] + [custom].
/// Mystery table = [mysteryTableMaterials] (sorted by density at use site).
enum DensityMaterialId {
  styrofoam,
  wood,
  ice,
  pvc,
  brick,
  aluminum,
  custom,
  gasoline,
  apple,
  human,
  water,
  glass,
  diamond,
  titanium,
  steel,
  copper,
  lead,
  gold,
}

class DensityMaterial {
  const DensityMaterial({
    required this.id,
    required this.nameEn,
    required this.stringKey,
    this.density,
    this.custom = false,
  });

  final DensityMaterialId id;
  final String nameEn;
  final String stringKey;

  /// SI kg/m³. Null only for [DensityMaterialId.custom].
  final double? density;
  final bool custom;
}

class DensityMaterials {
  DensityMaterials._();

  static const styrofoam = DensityMaterial(
    id: DensityMaterialId.styrofoam,
    nameEn: 'Styrofoam',
    stringKey: 'density.material.styrofoam',
    density: 150,
  );

  static const wood = DensityMaterial(
    id: DensityMaterialId.wood,
    nameEn: 'Wood',
    stringKey: 'density.material.wood',
    density: 400,
  );

  static const ice = DensityMaterial(
    id: DensityMaterialId.ice,
    nameEn: 'Ice',
    stringKey: 'density.material.ice',
    density: 919,
  );

  static const pvc = DensityMaterial(
    id: DensityMaterialId.pvc,
    nameEn: 'PVC',
    stringKey: 'density.material.pvc',
    density: 1440,
  );

  static const brick = DensityMaterial(
    id: DensityMaterialId.brick,
    nameEn: 'Brick',
    stringKey: 'density.material.brick',
    density: 2000,
  );

  static const aluminum = DensityMaterial(
    id: DensityMaterialId.aluminum,
    nameEn: 'Aluminum',
    stringKey: 'density.material.aluminum',
    density: 2700,
  );

  static const custom = DensityMaterial(
    id: DensityMaterialId.custom,
    nameEn: 'Custom',
    stringKey: 'density.material.custom',
    custom: true,
  );

  static const gasoline = DensityMaterial(
    id: DensityMaterialId.gasoline,
    nameEn: 'Gasoline',
    stringKey: 'density.material.gasoline',
    density: 680,
  );

  static const apple = DensityMaterial(
    id: DensityMaterialId.apple,
    nameEn: 'Apple',
    stringKey: 'density.material.apple',
    density: 832,
  );

  static const human = DensityMaterial(
    id: DensityMaterialId.human,
    nameEn: 'Human',
    stringKey: 'density.material.human',
    density: 950,
  );

  static const water = DensityMaterial(
    id: DensityMaterialId.water,
    nameEn: 'Water',
    stringKey: 'density.material.water',
    density: DensityConstants.waterDensity,
  );

  static const glass = DensityMaterial(
    id: DensityMaterialId.glass,
    nameEn: 'Glass',
    stringKey: 'density.material.glass',
    density: 2700,
  );

  static const diamond = DensityMaterial(
    id: DensityMaterialId.diamond,
    nameEn: 'Diamond',
    stringKey: 'density.material.diamond',
    density: 3510,
  );

  static const titanium = DensityMaterial(
    id: DensityMaterialId.titanium,
    nameEn: 'Titanium',
    stringKey: 'density.material.titanium',
    density: 4500,
  );

  static const steel = DensityMaterial(
    id: DensityMaterialId.steel,
    nameEn: 'Steel',
    stringKey: 'density.material.steel',
    density: 7800,
  );

  static const copper = DensityMaterial(
    id: DensityMaterialId.copper,
    nameEn: 'Copper',
    stringKey: 'density.material.copper',
    density: 8960,
  );

  /// Table uses this catalog value. Mystery Set 2 block 2A uses 11340 instead.
  static const lead = DensityMaterial(
    id: DensityMaterialId.lead,
    nameEn: 'Lead',
    stringKey: 'density.material.lead',
    density: 11342,
  );

  static const gold = DensityMaterial(
    id: DensityMaterialId.gold,
    nameEn: 'Gold',
    stringKey: 'density.material.gold',
    density: 19320,
  );

  static const List<DensityMaterial> simpleMassMaterials = [
    styrofoam,
    wood,
    ice,
    pvc,
    brick,
    aluminum,
  ];

  /// `Material.DENSITY_MYSTERY_SCREEN_MATERIALS` source order (sort by density in Table).
  static const List<DensityMaterial> mysteryTableMaterials = [
    wood,
    gasoline,
    apple,
    ice,
    human,
    water,
    glass,
    diamond,
    titanium,
    steel,
    copper,
    lead,
    gold,
  ];

  static const List<DensityMaterial> _all = [
    styrofoam,
    wood,
    ice,
    pvc,
    brick,
    aluminum,
    custom,
    gasoline,
    apple,
    human,
    water,
    glass,
    diamond,
    titanium,
    steel,
    copper,
    lead,
    gold,
  ];

  static DensityMaterial byId(DensityMaterialId id) {
    for (final m in _all) {
      if (m.id == id) return m;
    }
    throw StateError('Unknown material: $id');
  }
}

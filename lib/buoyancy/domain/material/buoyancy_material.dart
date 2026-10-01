/// Named solid/liquid materials from `Material.ts`.
///
/// Densities are kg/m³. Viscosity Pa·s.
class BuoyancyMaterial {
  const BuoyancyMaterial({
    required this.id,
    required this.density,
    this.viscosity = 1e-3,
    this.custom = false,
    this.hidden = false,
    this.isFluid = false,
  });

  final String id;
  final double density;
  final double viscosity;
  final bool custom;
  final bool hidden;
  final bool isFluid;

  BuoyancyMaterial copyWithDensity(double d) => BuoyancyMaterial(
        id: id,
        density: d,
        viscosity: viscosity,
        custom: custom,
        hidden: hidden,
        isFluid: isFluid,
      );

  // —— Solids (SIMPLE_MASS_MATERIALS + buoyancy-only) ——
  static const styrofoam = BuoyancyMaterial(id: 'styrofoam', density: 150);
  static const wood = BuoyancyMaterial(id: 'wood', density: 400);
  static const ice = BuoyancyMaterial(id: 'ice', density: 919);
  static const pvc = BuoyancyMaterial(id: 'pvc', density: 1440);
  static const brick = BuoyancyMaterial(id: 'brick', density: 2000);
  static const aluminum = BuoyancyMaterial(id: 'aluminum', density: 2700);
  static const boatHull = BuoyancyMaterial(id: 'boatHull', density: 2700);
  static const concrete = BuoyancyMaterial(id: 'concrete', density: 3150);
  static const copper = BuoyancyMaterial(id: 'copper', density: 8960);
  static const gold = BuoyancyMaterial(id: 'gold', density: 19320);
  static const platinum = BuoyancyMaterial(id: 'platinum', density: 21450);
  static const pyrite = BuoyancyMaterial(id: 'pyrite', density: 5010);
  static const sand =
      BuoyancyMaterial(id: 'sand', density: 1442, viscosity: 0.03);
  static const silver = BuoyancyMaterial(id: 'silver', density: 10490);
  static const steel = BuoyancyMaterial(id: 'steel', density: 7800);
  static const tantalum = BuoyancyMaterial(id: 'tantalum', density: 16650);
  static const diamond = BuoyancyMaterial(id: 'diamond', density: 3510);
  static const human = BuoyancyMaterial(id: 'human', density: 950);
  static const titanium = BuoyancyMaterial(id: 'titanium', density: 4500);
  static const lead = BuoyancyMaterial(id: 'lead', density: 11342);

  static const materialR =
      BuoyancyMaterial(id: 'materialR', density: 5010, hidden: true);
  static const materialS =
      BuoyancyMaterial(id: 'materialS', density: 19320, hidden: true);
  static const materialT =
      BuoyancyMaterial(id: 'materialT', density: 950, hidden: true);
  static const materialU =
      BuoyancyMaterial(id: 'materialU', density: 3510, hidden: true);
  static const materialV =
      BuoyancyMaterial(id: 'materialV', density: 919, hidden: true);
  static const materialW =
      BuoyancyMaterial(id: 'materialW', density: 11342, hidden: true);
  static const materialX =
      BuoyancyMaterial(id: 'materialX', density: 4500, hidden: true);
  static const materialY =
      BuoyancyMaterial(id: 'materialY', density: 13593, hidden: true);

  // —— Fluids ——
  static const air =
      BuoyancyMaterial(id: 'air', density: 1.2, viscosity: 0, isFluid: true);
  static const gasoline = BuoyancyMaterial(
      id: 'gasoline', density: 680, viscosity: 6e-4, isFluid: true);
  static const oil = BuoyancyMaterial(
      id: 'oil', density: 920, viscosity: 0.02, isFluid: true);
  static const water = BuoyancyMaterial(
      id: 'water', density: 1000, viscosity: 8.9e-4, isFluid: true);
  static const seawater = BuoyancyMaterial(
      id: 'seawater', density: 1029, viscosity: 1.88e-3, isFluid: true);
  static const honey = BuoyancyMaterial(
      id: 'honey', density: 1440, viscosity: 0.03, isFluid: true);
  static const mercury = BuoyancyMaterial(
      id: 'mercury', density: 13593, viscosity: 1.53e-3, isFluid: true);
  static const fluidA = BuoyancyMaterial(
      id: 'fluidA', density: 3100, hidden: true, isFluid: true);
  static const fluidB = BuoyancyMaterial(
      id: 'fluidB', density: 790, hidden: true, isFluid: true);
  static const fluidC = BuoyancyMaterial(
      id: 'fluidC', density: 490, hidden: true, isFluid: true);
  static const fluidD = BuoyancyMaterial(
      id: 'fluidD', density: 2890, hidden: true, isFluid: true);
  static const fluidE = BuoyancyMaterial(
      id: 'fluidE', density: 1260, hidden: true, isFluid: true);
  static const fluidF = BuoyancyMaterial(
      id: 'fluidF', density: 6440, hidden: true, isFluid: true);

  static BuoyancyMaterial customSolid(double density) => BuoyancyMaterial(
        id: 'custom',
        density: density,
        custom: true,
      );

  static BuoyancyMaterial customFluid(double density) => BuoyancyMaterial(
        id: 'customFluid',
        density: density,
        custom: true,
        isFluid: true,
      );

  static const List<BuoyancyMaterial> simpleMassMaterials = [
    styrofoam,
    wood,
    ice,
    pvc,
    brick,
    aluminum,
  ];

  static const List<BuoyancyMaterial> buoyancyFluidMaterials = [
    gasoline,
    oil,
    water,
    seawater,
    honey,
    mercury,
  ];

  static const List<BuoyancyMaterial> buoyancyFluidMysteryMaterials = [
    fluidA,
    fluidB,
    fluidC,
    fluidD,
    fluidE,
    fluidF,
  ];

  static BuoyancyMaterial? byId(String id) {
    for (final m in allKnown) {
      if (m.id == id) {
        return m;
      }
    }
    return null;
  }

  static const List<BuoyancyMaterial> allKnown = [
    styrofoam,
    wood,
    ice,
    pvc,
    brick,
    aluminum,
    boatHull,
    concrete,
    copper,
    gold,
    platinum,
    pyrite,
    sand,
    silver,
    steel,
    tantalum,
    diamond,
    human,
    titanium,
    lead,
    materialR,
    materialS,
    materialT,
    materialU,
    materialV,
    materialW,
    materialX,
    materialY,
    air,
    gasoline,
    oil,
    water,
    seawater,
    honey,
    mercury,
    fluidA,
    fluidB,
    fluidC,
    fluidD,
    fluidE,
    fluidF,
  ];
}

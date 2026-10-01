import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../circuit/screens/circuit_screen.dart';
import '../optics/screens/optics_screen.dart';
import '../forces/screens/forces_home.dart';
import '../chemistry/molarity/view/screens/molarity_screen.dart';
import '../chemistry/ph_scale/view/screens/ph_scale_screen.dart';
import '../chemistry/acid_base_solutions/screens/acid_base_solutions_home.dart';
import '../chemistry/build_a_nucleus/screens/build_a_nucleus_home.dart';
import '../chemistry/isotopes_and_atomic_mass/screens/isotopes_and_atomic_mass_home.dart';
import '../chemistry/build_an_atom/screens/build_an_atom_home.dart';
import '../rutherford_scattering/screens/rutherford_scattering_home.dart';
import '../chemistry/build_a_molecule/screens/build_a_molecule_home.dart';
import '../chemistry/molecule_polarity/screens/molecule_polarity_home.dart';
import '../chemistry/states_of_matter/screens/states_of_matter_home.dart';
import '../color_vision/screens/color_vision_home.dart';
import '../sound/screens/sound_screen.dart';
import '../radio_waves/screens/radio_waves_screen.dart';
import '../wave_interference/screens/wave_interference_screen.dart';
import '../physics/quantum_wave_interference/screens/quantum_wave_interference_home.dart';
import '../quantum_coin_toss/screens/quantum_coin_toss_home.dart';
import '../magnetism/magnet_and_compass/screens/magnet_and_compass_screen.dart';
import '../faradays_law/view/faradays_law_screen.dart';
import '../ohms_law/view/ohms_law_screen.dart';
import '../resistance_in_a_wire/view/resistance_in_a_wire_screen.dart';
import '../friction/view/friction_screen.dart';
import '../astronomy/keplers_laws/screens/keplers_laws_home.dart';
import '../astronomy/my_solar_system/screens/my_solar_system_home.dart';
import '../astronomy/gravity_and_orbits/screens/gravity_and_orbits_home.dart';
import '../density/view/screens/density_home.dart';
import '../buoyancy/buoyancy_module.dart';
import '../buoyancy/screens/buoyancy_home.dart';
import '../under_pressure/screens/under_pressure_home.dart';
import '../cck_ac_virtual_lab/screens/cck_ac_virtual_lab_screen.dart';
import '../capacitor_lab_basics/screens/capacitor_lab_basics_home.dart';
import '../charges_and_fields/screens/charges_and_fields_home.dart';
import '../john_travoltage/view/john_travoltage_screen.dart';
import '../balloons_and_static_electricity/view/balloons_static_electricity_screen.dart';
import '../normal_modes/screens/normal_modes_home.dart';
import '../fourier_making_waves/screens/fourier_making_waves_home.dart';
import '../collision_lab/screens/collision_lab_home.dart';
import '../collision_lab/collision_lab_colors.dart';
import '../collision_lab/collision_lab_strings.dart';
import '../vector_addition/screens/vector_addition_home.dart';
import '../vector_addition/vector_addition_colors.dart';
import '../vector_addition/vector_addition_strings.dart';
import '../energy_skate_park/screens/energy_skate_park_home.dart';
import '../energy_skate_park/esp_colors.dart';
import '../energy_skate_park/esp_strings.dart';
import '../curve_fitting/screens/curve_fitting_home.dart';
import '../curve_fitting/curve_fitting_colors.dart';
import '../curve_fitting/curve_fitting_strings.dart';
import '../gravity_force_lab_basics/screens/gflb_home.dart';
import '../gravity_force_lab_basics/gflb_colors.dart';
import '../gravity_force_lab_basics/gflb_strings.dart';
import '../gravity_force_lab/screens/gravity_force_lab_screen.dart';
import '../gravity_force_lab/gfl_colors.dart';
import '../gravity_force_lab/gfl_strings.dart';
import '../waves_intro/screens/waves_intro_home.dart';
import '../diffusion/screens/diffusion_home.dart';
import '../gases_intro/screens/gases_intro_home.dart';
import '../gas_properties/screens/gas_properties_home.dart';
import '../blackbody_spectrum/screens/blackbody_spectrum_home.dart';
import '../energy_forms_and_changes/screens/energy_forms_and_changes_home.dart';
import '../masses_and_springs_basics/screens/masb_home.dart';
import '../pendulum_lab/screens/pendulum_lab_home.dart';
import '../pendulum_lab/pl_colors.dart';
import '../pendulum_lab/pl_strings.dart';
import '../hookes_law/screens/hookes_law_home.dart';
import '../projectile_motion/screens/projectile_motion_home.dart';
import '../plinko_probability/screens/plinko_probability_home.dart';
import '../bending_light/screens/bending_light_home.dart';
import '../molecules_and_light/view/molecules_and_light_screen.dart';
import '../molecule_shapes/screens/molecule_shapes_home.dart';
import '../reactants_products_and_leftovers/screens/reactants_products_and_leftovers_home.dart';
import '../balancing_chemical_equations/screens/balancing_chemical_equations_home.dart';
import '../balancing_chemical_equations/bce_strings.dart';
import '../balancing_act/screens/balancing_act_home.dart';
import '../wave_on_a_string/view/woas_screen.dart';
import '../concentration/concentration_assets.dart';
import '../beers_law_lab/screens/beers_law_lab_home.dart';
import '../membrane_transport/screens/membrane_transport_home.dart';
import '../common/simulation/simulation_registry.dart';
import '../quantum_measurement/quantum_measurement_module.dart';
import '../quantum_measurement/screens/quantum_measurement_home.dart';

/// 单个 sim 入口的展示元数据 + 目标屏构造器。
class _SimEntry {
  const _SimEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
    this.iconAsset,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  /// Optional original PhET screen icon (preferred over [icon] when set).
  final String? iconAsset;
  final Color color;
  final WidgetBuilder builder;
}

/// 学科下的二级子领域分组（力学 / 密度与浮力 / 电学 / 光学与波动 / 溶液与浓度）。
class _SubjectGroup {
  const _SubjectGroup({required this.name, required this.sims});

  final String name;
  final List<_SimEntry> sims;
}

/// 一级学科（物理 / 化学）。
class _Discipline {
  const _Discipline({
    required this.name,
    required this.englishName,
    required this.color,
    required this.groups,
  });

  final String name;
  final String englishName;
  final Color color;
  final List<_SubjectGroup> groups;

  int get simCount =>
      groups.fold<int>(0, (sum, group) => sum + group.sims.length);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<_Discipline> _disciplines = <_Discipline>[
    _Discipline(
      name: '物理',
      englishName: 'Physics',
      color: const Color(0xFF1177AA),
      groups: <_SubjectGroup>[
        _SubjectGroup(
          name: '力学',
          sims: <_SimEntry>[
            _SimEntry(
              title: '力与运动',
              subtitle: '合力 · 摩擦 · 加速度',
              icon: Icons.sports_kabaddi_rounded,
              color: Color(0xFF166534),
              builder: _buildForces,
            ),
            _SimEntry(
              title: CollisionLabHome.title,
              subtitle: CollisionLabStrings.subtitle,
              icon: Icons.sports_baseball_rounded,
              color: CollisionLabColors.accent,
              builder: _buildCollisionLab,
            ),
            _SimEntry(
              title: VectorAdditionHome.title,
              subtitle: VectorAdditionStrings.subtitle,
              icon: Icons.north_east_rounded,
              color: VectorAdditionColors.accent,
              builder: _buildVectorAddition,
            ),
            _SimEntry(
              title: EnergySkateParkHome.title,
              subtitle: EspStrings.subtitle,
              icon: Icons.skateboarding_rounded,
              color: EspColors.accent,
              builder: _buildEnergySkatePark,
            ),
            _SimEntry(
              title: CurveFittingHome.title,
              subtitle: CurveFittingStrings.subtitle,
              icon: Icons.show_chart_rounded,
              color: CurveFittingColors.accent,
              builder: _buildCurveFitting,
            ),
            _SimEntry(
              title: GflbHome.title,
              subtitle: GflbStrings.subtitle,
              icon: Icons.public_rounded,
              color: GflbColors.accent,
              builder: _buildGravityForceLabBasics,
            ),
            _SimEntry(
              title: GravityForceLabScreen.title,
              subtitle: GflStrings.subtitle,
              icon: GravityForceLabScreen.homeIcon,
              color: GflColors.accent,
              builder: _buildGravityForceLab,
            ),
            _SimEntry(
              title: MasbHome.title,
              subtitle: MasbHome.subtitle,
              icon: Icons.vertical_align_center_rounded,
              color: MasbHome.accentColor,
              builder: _buildMassesAndSpringsBasics,
            ),
            _SimEntry(
              title: HookesLawHome.title,
              subtitle: HookesLawHome.subtitle,
              icon: Icons.swap_vert_rounded,
              color: HookesLawHome.accentColor,
              builder: _buildHookesLaw,
            ),
            _SimEntry(
              title: PendulumLabHome.title,
              subtitle: PlStrings.subtitle,
              icon: Icons.timelapse_rounded,
              color: PlColors.accent,
              builder: _buildPendulumLab,
            ),
            _SimEntry(
              title: ProjectileMotionHome.title,
              subtitle: ProjectileMotionHome.subtitle,
              icon: Icons.sports_baseball_rounded,
              color: ProjectileMotionHome.accentColor,
              builder: _buildProjectileMotion,
            ),
            _SimEntry(
              title: BalancingActHome.title,
              subtitle: BalancingActHome.subtitle,
              icon: Icons.scale_rounded,
              color: BalancingActHome.accentColor,
              builder: _buildBalancingAct,
            ),
            _SimEntry(
              title: FrictionScreen.title,
              subtitle: FrictionScreen.subtitle,
              icon: Icons.menu_book_rounded,
              color: FrictionScreen.accentColor,
              builder: _buildFriction,
            ),
          ],
        ),
        _SubjectGroup(
          name: '数学与概率',
          sims: <_SimEntry>[
            _SimEntry(
              title: PlinkoProbabilityHome.title,
              subtitle: PlinkoProbabilityHome.subtitle,
              icon: Icons.bubble_chart_rounded,
              color: PlinkoProbabilityHome.accentColor,
              builder: _buildPlinkoProbability,
            ),
          ],
        ),
        _SubjectGroup(
          name: '密度与浮力',
          sims: <_SimEntry>[
            _SimEntry(
              title: '密度',
              subtitle: '质量 · 体积 · 材料',
              icon: Icons.water_drop_rounded,
              color: Color(0xFF0F766E),
              builder: _buildDensity,
            ),
            _SimEntry(
              title: BuoyancyHome.title,
              subtitle: BuoyancyHome.subtitle,
              icon: Icons.waves_rounded,
              iconAsset: BuoyancyHome.homeIconAsset,
              color: BuoyancyHome.accentColor,
              builder: _buildBuoyancy,
            ),
            _SimEntry(
              title: UnderPressureHome.title,
              subtitle: UnderPressureHome.subtitle,
              icon: UnderPressureHome.homeIcon,
              color: UnderPressureHome.accentColor,
              builder: _buildUnderPressure,
            ),
          ],
        ),
        _SubjectGroup(
          name: '电学与电路',
          sims: <_SimEntry>[
            _SimEntry(
              title: '电路搭建',
              subtitle: '串并联 · 电流路径',
              icon: Icons.electric_bolt_rounded,
              color: Color(0xFF0C4A6E),
              builder: _buildCircuit,
            ),
            _SimEntry(
              title: 'AC 虚拟实验室',
              subtitle: '交流 · 电容 · 电感',
              icon: Icons.bolt_rounded,
              color: Color(0xFF0369A1),
              builder: _buildCckAcVirtualLab,
            ),
            _SimEntry(
              title: CapacitorLabBasicsHome.title,
              subtitle: '电容 · 电荷 · 灯泡放电',
              icon: Icons.battery_charging_full_rounded,
              color: CapacitorLabBasicsHome.accentColor,
              builder: _buildCapacitorLabBasics,
            ),
            _SimEntry(
              title: OhmsLawScreen.title,
              subtitle: OhmsLawScreen.subtitle,
              icon: OhmsLawScreen.homeIcon,
              color: OhmsLawScreen.accentColor,
              builder: _buildOhmsLaw,
            ),
            _SimEntry(
              title: ResistanceInAWireScreen.title,
              subtitle: ResistanceInAWireScreen.subtitle,
              icon: ResistanceInAWireScreen.homeIcon,
              color: ResistanceInAWireScreen.accentColor,
              builder: _buildResistanceInAWire,
            ),
            _SimEntry(
              title: ChargesAndFieldsHome.title,
              subtitle: ChargesAndFieldsHome.subtitle,
              icon: Icons.flash_on_rounded,
              color: ChargesAndFieldsHome.accentColor,
              builder: _buildChargesAndFields,
            ),
            _SimEntry(
              title: JohnTravoltageScreen.title,
              subtitle: JohnTravoltageScreen.subtitle,
              icon: Icons.electric_bolt_outlined,
              color: JohnTravoltageScreen.accentColor,
              builder: _buildJohnTravoltage,
            ),
            _SimEntry(
              title: BalloonsStaticElectricityScreen.title,
              subtitle: BalloonsStaticElectricityScreen.subtitle,
              icon: BalloonsStaticElectricityScreen.homeIcon,
              color: BalloonsStaticElectricityScreen.accentColor,
              builder: _buildBalloonsAndStaticElectricity,
            ),
          ],
        ),
        _SubjectGroup(
          name: '电磁学',
          sims: <_SimEntry>[
            _SimEntry(
              title: '磁铁与罗盘',
              subtitle: '条形磁铁 · 磁场 · 罗盘',
              icon: Icons.explore_rounded,
              color: Color(0xFF1565C0),
              builder: _buildMagnetAndCompass,
            ),
            _SimEntry(
              title: FaradaysLawScreen.title,
              subtitle: FaradaysLawScreen.subtitle,
              icon: Icons.bolt_rounded,
              color: FaradaysLawScreen.accentColor,
              builder: _buildFaradaysLaw,
            ),
          ],
        ),
        _SubjectGroup(
          name: '天体力学',
          sims: <_SimEntry>[
            _SimEntry(
              title: "Kepler's Laws",
              subtitle: '椭圆轨道 · 面积定律 · 周期定律',
              icon: Icons.public_rounded,
              color: Color(0xFF1A365D),
              builder: _buildKeplersLaws,
            ),
            _SimEntry(
              title: MySolarSystemHome.title,
              subtitle: 'N-body 引力 · 轨道系统',
              icon: Icons.wb_sunny_rounded,
              color: Color(0xFF7C3AED),
              builder: _buildMySolarSystem,
            ),
            _SimEntry(
              title: GravityAndOrbitsHome.title,
              subtitle: '引力 · 轨道 · Model / To Scale',
              icon: Icons.public_outlined,
              color: Color(0xFF0EA5E9),
              builder: _buildGravityAndOrbits,
            ),
          ],
        ),
        _SubjectGroup(
          name: '光学与波动',
          sims: <_SimEntry>[
            _SimEntry(
              title: '几何光学',
              subtitle: '透镜 · 镜面 · 成像',
              icon: Icons.play_arrow_rounded,
              color: Color(0xFF1177AA),
              builder: _buildOptics,
            ),
            _SimEntry(
              title: '色觉',
              subtitle: 'Single Bulb · RGB Bulbs',
              icon: Icons.palette_rounded,
              color: Color(0xFFDB2777),
              builder: _buildColorVision,
            ),
            _SimEntry(
              title: '波的干涉',
              subtitle: '双缝 · 叠加原理',
              icon: Icons.waves_rounded,
              color: Color(0xFF2563EB),
              builder: _buildWaveInterference,
            ),
            _SimEntry(
              title: QuantumWaveInterferenceHome.title,
              subtitle: QuantumWaveInterferenceHome.subtitle,
              icon: Icons.blur_on_rounded,
              iconAsset: QuantumWaveInterferenceHome.homeIconAsset,
              color: QuantumWaveInterferenceHome.accentColor,
              builder: _buildQuantumWaveInterference,
            ),
            _SimEntry(
              title: QuantumCoinTossHome.title,
              subtitle: QuantumCoinTossHome.subtitle,
              icon: Icons.monetization_on_outlined,
              color: QuantumCoinTossHome.accentColor,
              builder: _buildQuantumCoinToss,
            ),
            _SimEntry(
              title: QuantumMeasurementHome.title,
              subtitle: QuantumMeasurementHome.subtitle,
              icon: Icons.science_outlined,
              iconAsset: QuantumMeasurementHome.homeIconAsset,
              color: QuantumMeasurementHome.accentColor,
              builder: _buildQuantumMeasurement,
            ),
            _SimEntry(
              title: 'Waves Intro',
              subtitle: '水波 · 声波 · 光波',
              icon: Icons.water_rounded,
              color: Color(0xFF1177AA),
              builder: _buildWavesIntro,
            ),
            _SimEntry(
              title: '声波',
              subtitle: '频率 · 振幅 · 波形',
              icon: Icons.graphic_eq_rounded,
              color: Color(0xFF0D9488),
              builder: _buildSound,
            ),
            _SimEntry(
              title: NormalModesHome.title,
              subtitle: '耦合振子 · 简正模',
              icon: Icons.linear_scale_rounded,
              color: Color(0xFF0E7490),
              builder: _buildNormalModes,
            ),
            _SimEntry(
              title: FourierMakingWavesHome.title,
              subtitle: '傅里叶合成 · 波包',
              icon: Icons.auto_graph_rounded,
              color: Color(0xFF0F766E),
              builder: _buildFourierMakingWaves,
            ),
            _SimEntry(
              title: '电磁波',
              subtitle: '天线 · 传播',
              icon: Icons.sensors_rounded,
              color: Color(0xFF7C3AED),
              builder: _buildRadioWaves,
            ),
            _SimEntry(
              title: BendingLightHome.title,
              subtitle: BendingLightHome.subtitle,
              icon: Icons.lens_outlined,
              color: BendingLightHome.accentColor,
              builder: _buildBendingLight,
            ),
            _SimEntry(
              title: WoasScreen.title,
              subtitle: WoasScreen.subtitle,
              icon: Icons.timeline_rounded,
              color: WoasScreen.accentColor,
              builder: _buildWaveOnAString,
            ),
          ],
        ),
        _SubjectGroup(
          name: '热学与气体',
          sims: <_SimEntry>[
            _SimEntry(
              title: DiffusionHome.title,
              subtitle: '粒子扩散 · 隔板 · 质量/半径',
              icon: Icons.blur_on_rounded,
              color: DiffusionHome.accentColor,
              builder: _buildDiffusion,
            ),
            _SimEntry(
              title: MembraneTransportHome.title,
              subtitle: MembraneTransportHome.subtitle,
              icon: Icons.blur_on_rounded,
              iconAsset: MembraneTransportHome.homeIconAsset,
              color: MembraneTransportHome.accentColor,
              builder: _buildMembraneTransport,
            ),
            _SimEntry(
              title: GasesIntroHome.title,
              subtitle: '理想气体 · Intro / Laws',
              icon: Icons.bubble_chart_rounded,
              color: GasesIntroHome.accentColor,
              builder: _buildGasesIntro,
            ),
            _SimEntry(
              title: GasPropertiesHome.title,
              subtitle: 'Ideal · Explore · Energy · Diffusion',
              icon: Icons.science_rounded,
              color: GasPropertiesHome.accentColor,
              builder: _buildGasProperties,
            ),
            _SimEntry(
              title: BlackbodySpectrumHome.title,
              subtitle: '黑体辐射 · Planck · Wien',
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFDC2626),
              builder: _buildBlackbodySpectrum,
            ),
            _SimEntry(
              title: EnergyFormsAndChangesHome.title,
              subtitle: 'Intro · Systems · 能量形式与转化',
              icon: Icons.whatshot_rounded,
              color: EnergyFormsAndChangesHome.accentColor,
              builder: _buildEnergyFormsAndChanges,
            ),
          ],
        ),
      ],
    ),
    _Discipline(
      name: '化学',
      englishName: 'Chemistry',
      color: const Color(0xFF0891B2),
      groups: <_SubjectGroup>[
        _SubjectGroup(
          name: '溶液与浓度',
          sims: <_SimEntry>[
            _SimEntry(
              title: '摩尔浓度',
              subtitle: '溶液配比 · 浓度计算',
              icon: Icons.science_rounded,
              color: Color(0xFF0891B2),
              builder: _buildMolarity,
            ),
            _SimEntry(
              title: BeersLawLabHome.title,
              subtitle: BeersLawLabHome.subtitle,
              icon: Icons.science_rounded,
              iconAsset: ConcentrationAssets.screenIcon,
              color: BeersLawLabHome.accentColor,
              builder: _buildBeersLawLab,
            ),
            _SimEntry(
              title: 'pH 标度',
              subtitle: '酸 · 碱 · 浓度 · Macro/Micro',
              icon: Icons.science_outlined,
              color: Color(0xFF0E7490),
              builder: _buildPhScale,
            ),
            _SimEntry(
              title: AcidBaseSolutionsHome.title,
              subtitle: AcidBaseSolutionsHome.subtitle,
              icon: Icons.science_outlined,
              color: AcidBaseSolutionsHome.accentColor,
              builder: _buildAcidBaseSolutions,
            ),
          ],
        ),
        _SubjectGroup(
          name: '原子核',
          sims: <_SimEntry>[
            _SimEntry(
              title: '构建原子核',
              subtitle: '质子 · 中子 · 衰变',
              icon: Icons.blur_circular_rounded,
              color: Color(0xFFB45309),
              builder: _buildBuildANucleus,
            ),
            _SimEntry(
              title: RutherfordScatteringHome.title,
              subtitle: RutherfordScatteringHome.subtitle,
              icon: Icons.radio_button_checked,
              color: RutherfordScatteringHome.accentColor,
              builder: _buildRutherfordScattering,
            ),
          ],
        ),
        _SubjectGroup(
          name: '原子结构',
          sims: <_SimEntry>[
            _SimEntry(
              title: BuildAnAtomHome.title,
              subtitle: BuildAnAtomHome.subtitle,
              icon: Icons.blur_on,
              iconAsset: BuildAnAtomHome.homeIconAsset,
              color: BuildAnAtomHome.accentColor,
              builder: _buildBuildAnAtom,
            ),
            _SimEntry(
              title: IsotopesAndAtomicMassHome.title,
              subtitle: IsotopesAndAtomicMassHome.subtitle,
              icon: Icons.science_outlined,
              color: IsotopesAndAtomicMassHome.accentColor,
              builder: _buildIsotopesAndAtomicMass,
            ),
          ],
        ),
        _SubjectGroup(
          name: '分子搭建',
          sims: <_SimEntry>[
            _SimEntry(
              title: '搭建分子',
              subtitle: '原子 · 成键 · 收集',
              icon: Icons.hub_rounded,
              color: Color(0xFF0D9488),
              builder: _buildBuildAMolecule,
            ),
          ],
        ),
        _SubjectGroup(
          name: '分子极性',
          sims: <_SimEntry>[
            _SimEntry(
              title: MoleculePolarityHome.title,
              subtitle: 'Two · Three · Real Molecules',
              icon: Icons.science_outlined,
              color: MoleculePolarityHome.accentColor,
              builder: _buildMoleculePolarity,
            ),
          ],
        ),
        _SubjectGroup(
          name: '分子形状',
          sims: <_SimEntry>[
            _SimEntry(
              title: MoleculeShapesHome.title,
              subtitle: MoleculeShapesHome.subtitle,
              icon: Icons.hub_outlined,
              color: MoleculeShapesHome.accentColor,
              builder: _buildMoleculeShapes,
            ),
          ],
        ),
        _SubjectGroup(
          name: '光与分子',
          sims: <_SimEntry>[
            _SimEntry(
              title: MoleculesAndLightScreen.title,
              subtitle: MoleculesAndLightScreen.subtitle,
              icon: Icons.flare_rounded,
              color: MoleculesAndLightScreen.accentColor,
              builder: _buildMoleculesAndLight,
            ),
          ],
        ),
        _SubjectGroup(
          name: '反应物与生成物',
          sims: <_SimEntry>[
            _SimEntry(
              title: ReactantsProductsAndLeftoversHome.title,
              subtitle: ReactantsProductsAndLeftoversHome.subtitle,
              icon: Icons.restaurant_outlined,
              color: ReactantsProductsAndLeftoversHome.accentColor,
              builder: _buildReactantsProductsAndLeftovers,
            ),
          ],
        ),
        _SubjectGroup(
          name: BceStrings.homeSubjectGroup,
          sims: <_SimEntry>[
            _SimEntry(
              title: BalancingChemicalEquationsHome.title,
              subtitle: BalancingChemicalEquationsHome.subtitle,
              icon: Icons.balance_outlined,
              color: BalancingChemicalEquationsHome.accentColor,
              builder: _buildBalancingChemicalEquations,
            ),
          ],
        ),
        _SubjectGroup(
          name: '物态',
          sims: <_SimEntry>[
            _SimEntry(
              title: 'States of Matter',
              subtitle: 'States · Phase Changes · Interaction',
              icon: Icons.water_drop_outlined,
              color: Color(0xFF1177AA),
              builder: _buildStatesOfMatter,
            ),
          ],
        ),
      ],
    ),
  ];

  static Widget _buildForces(BuildContext _) => const ForcesHome();
  static Widget _buildDensity(BuildContext _) => const DensityHome();

  static Widget _buildBuoyancy(BuildContext _) {
    BuoyancyModule.register();
    return const BuoyancyHome();
  }
  static Widget _buildUnderPressure(BuildContext _) =>
      const UnderPressureHome();
  static Widget _buildCircuit(BuildContext _) => const CircuitScreen();
  static Widget _buildCckAcVirtualLab(BuildContext _) =>
      const CckAcVirtualLabScreen();
  static Widget _buildCapacitorLabBasics(BuildContext _) =>
      const CapacitorLabBasicsHome();
  static Widget _buildOhmsLaw(BuildContext _) => const OhmsLawScreen();
  static Widget _buildResistanceInAWire(BuildContext _) =>
      const ResistanceInAWireScreen();

  static Widget _buildChargesAndFields(BuildContext _) =>
      const ChargesAndFieldsHome();
  static Widget _buildJohnTravoltage(BuildContext _) =>
      const JohnTravoltageScreen();
  static Widget _buildBalloonsAndStaticElectricity(BuildContext _) =>
      const BalloonsStaticElectricityScreen();
  static Widget _buildMagnetAndCompass(BuildContext _) =>
      const MagnetAndCompassScreen();
  static Widget _buildFaradaysLaw(BuildContext _) => const FaradaysLawScreen();
  static Widget _buildFriction(BuildContext _) => const FrictionScreen();
  static Widget _buildKeplersLaws(BuildContext _) => const KeplersLawsHome();
  static Widget _buildMySolarSystem(BuildContext _) =>
      const MySolarSystemHome();
  static Widget _buildGravityAndOrbits(BuildContext _) =>
      const GravityAndOrbitsHome();
  static Widget _buildOptics(BuildContext _) => const OpticsScreen();
  static Widget _buildColorVision(BuildContext _) => const ColorVisionHome();
  static Widget _buildWaveInterference(BuildContext _) =>
      const WaveInterferenceScreen();
  static Widget _buildQuantumWaveInterference(BuildContext _) =>
      const QuantumWaveInterferenceHome();
  static Widget _buildQuantumCoinToss(BuildContext _) =>
      const QuantumCoinTossHome();
  /// Resolves via SimulationRegistry — Home does not construct QM Models.
  static Widget _buildQuantumMeasurement(BuildContext context) {
    QuantumMeasurementModule.register();
    final d = SimulationRegistry.instance.require(QuantumMeasurementModule.id);
    if (!d.enabled) {
      return const Scaffold(
        body: Center(child: Text('Quantum Measurement unavailable')),
      );
    }
    return d.builder(context);
  }

  static Widget _buildWavesIntro(BuildContext _) => const WavesIntroHome();
  static Widget _buildDiffusion(BuildContext _) => const DiffusionHome();
  static Widget _buildMembraneTransport(BuildContext _) =>
      const MembraneTransportHome();
  static Widget _buildGasesIntro(BuildContext _) => const GasesIntroHome();
  static Widget _buildGasProperties(BuildContext _) =>
      const GasPropertiesHome();
  static Widget _buildSound(BuildContext _) => const SoundScreen();
  static Widget _buildNormalModes(BuildContext _) => const NormalModesHome();
  static Widget _buildFourierMakingWaves(BuildContext _) =>
      const FourierMakingWavesHome();
  static Widget _buildCollisionLab(BuildContext _) => const CollisionLabHome();
  static Widget _buildVectorAddition(BuildContext _) =>
      const VectorAdditionHome();
  static Widget _buildEnergySkatePark(BuildContext _) =>
      const EnergySkateParkHome();
  static Widget _buildCurveFitting(BuildContext _) => const CurveFittingHome();
  static Widget _buildGravityForceLabBasics(BuildContext _) => const GflbHome();
  static Widget _buildGravityForceLab(BuildContext _) =>
      const GravityForceLabScreen();
  static Widget _buildMassesAndSpringsBasics(BuildContext _) =>
      const MasbHome();
  static Widget _buildHookesLaw(BuildContext _) => const HookesLawHome();
  static Widget _buildPendulumLab(BuildContext _) => const PendulumLabHome();
  static Widget _buildProjectileMotion(BuildContext _) =>
      const ProjectileMotionHome();
  static Widget _buildBalancingAct(BuildContext _) => const BalancingActHome();
  static Widget _buildPlinkoProbability(BuildContext _) =>
      const PlinkoProbabilityHome();
  static Widget _buildRadioWaves(BuildContext _) => const RadioWavesScreen();
  static Widget _buildBendingLight(BuildContext _) => const BendingLightHome();
  static Widget _buildWaveOnAString(BuildContext _) => const WoasScreen();
  static Widget _buildMolarity(BuildContext _) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Text('摩尔浓度'),
      backgroundColor: const Color(0xFF0891B2),
      foregroundColor: Colors.white,
    ),
    body: const MolarityScreen(),
  );
  static Widget _buildBeersLawLab(BuildContext _) =>
      BeersLawLabHome(concentrationAudio: BeersLawLabHome.debugTestAudio);
  static Widget _buildPhScale(BuildContext _) => const PhScaleScreen();
  static Widget _buildAcidBaseSolutions(BuildContext _) =>
      const AcidBaseSolutionsHome();
  static Widget _buildBuildANucleus(BuildContext _) =>
      const BuildANucleusHome();
  static Widget _buildIsotopesAndAtomicMass(BuildContext _) =>
      const IsotopesAndAtomicMassHome();
  static Widget _buildBuildAnAtom(BuildContext _) => const BuildAnAtomHome();
  static Widget _buildRutherfordScattering(BuildContext _) =>
      const RutherfordScatteringHome();
  static Widget _buildBuildAMolecule(BuildContext _) =>
      const BuildAMoleculeHome();
  static Widget _buildMoleculePolarity(BuildContext _) =>
      const MoleculePolarityHome();
  static Widget _buildMoleculeShapes(BuildContext _) =>
      const MoleculeShapesHome();
  static Widget _buildMoleculesAndLight(BuildContext _) =>
      const MoleculesAndLightScreen();
  static Widget _buildReactantsProductsAndLeftovers(BuildContext _) =>
      const ReactantsProductsAndLeftoversHome();
  static Widget _buildBalancingChemicalEquations(BuildContext _) =>
      const BalancingChemicalEquationsHome();
  static Widget _buildStatesOfMatter(BuildContext _) =>
      const StatesOfMatterHome();
  static Widget _buildBlackbodySpectrum(BuildContext _) =>
      const BlackbodySpectrumHome();
  static Widget _buildEnergyFormsAndChanges(BuildContext _) =>
      const EnergyFormsAndChangesHome();

  int get _totalSimCount =>
      _disciplines.fold<int>(0, (sum, discipline) => sum + discipline.simCount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    for (var i = 0; i < _disciplines.length; i++) ...[
                      _DisciplineBlock(discipline: _disciplines[i]),
                      if (i != _disciplines.length - 1)
                        const SizedBox(height: 28),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/lens_convex.svg', width: 56),
            const SizedBox(width: 18),
            SvgPicture.asset('assets/images/battery.svg', width: 40),
            const SizedBox(width: 18),
            SvgPicture.asset('assets/images/drop.svg', width: 44),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Kratos 仿真实验室',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF073B54),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '物理 · 化学 交互式仿真实验合集 · 共 $_totalSimCount 个实验',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: const Color(0xFF48616E)),
        ),
      ],
    );
  }
}

/// 一级学科块：学科 header + 各子领域分组。
class _DisciplineBlock extends StatelessWidget {
  const _DisciplineBlock({required this.discipline});

  final _Discipline discipline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DisciplineHeader(discipline: discipline),
        const SizedBox(height: 14),
        for (var i = 0; i < discipline.groups.length; i++) ...[
          _SubjectGroupBlock(group: discipline.groups[i]),
          if (i != discipline.groups.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }
}

/// 一级学科 header（色条 + 中英文名 + 实验计数）。
class _DisciplineHeader extends StatelessWidget {
  const _DisciplineHeader({required this.discipline});

  final _Discipline discipline;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 28,
          decoration: BoxDecoration(
            color: discipline.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          discipline.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF073B54),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          discipline.englishName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: discipline.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: discipline.color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${discipline.simCount} 个实验',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: discipline.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// 子领域块：分组名 + 自适应卡片网格。
class _SubjectGroupBlock extends StatelessWidget {
  const _SubjectGroupBlock({required this.group});

  final _SubjectGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            group.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF48616E),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1000
                ? 4
                : width >= 720
                ? 3
                : width >= 460
                ? 2
                : 1;
            const spacing = 12.0;
            final cardWidth = (width - (columns - 1) * spacing) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final sim in group.sims)
                  SizedBox(
                    width: cardWidth,
                    child: _SimCard(sim: sim),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// 单个 sim 入口卡片。
class _SimCard extends StatelessWidget {
  const _SimCard({required this.sim});

  final _SimEntry sim;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: sim.title,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: sim.builder));
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 88,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: sim.color.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: sim.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: sim.iconAsset != null
                      ? (sim.iconAsset!.toLowerCase().endsWith('.svg')
                          ? SvgPicture.asset(
                              sim.iconAsset!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              sim.iconAsset!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ))
                      : Icon(sim.icon, color: sim.color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sim.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF073B54),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sim.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B8291),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: sim.color.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

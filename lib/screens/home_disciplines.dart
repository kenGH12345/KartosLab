import 'package:flutter/material.dart';
import 'package:kratos/l10n/kartos_localization.dart';

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
import '../vector_addition/screens/vector_addition_home.dart';
import '../vector_addition/vector_addition_colors.dart';
import '../energy_skate_park/screens/energy_skate_park_home.dart';
import '../energy_skate_park/esp_colors.dart';
import '../curve_fitting/screens/curve_fitting_home.dart';
import '../curve_fitting/curve_fitting_colors.dart';
import '../gravity_force_lab_basics/screens/gflb_home.dart';
import '../gravity_force_lab_basics/gflb_colors.dart';
import '../gravity_force_lab/screens/gravity_force_lab_screen.dart';
import '../gravity_force_lab/gfl_colors.dart';
import '../waves_intro/screens/waves_intro_home.dart';
import '../diffusion/screens/diffusion_home.dart';
import '../gases_intro/screens/gases_intro_home.dart';
import '../gas_properties/screens/gas_properties_home.dart';
import '../blackbody_spectrum/screens/blackbody_spectrum_home.dart';
import '../energy_forms_and_changes/screens/energy_forms_and_changes_home.dart';
import '../masses_and_springs_basics/screens/masb_home.dart';
import '../pendulum_lab/screens/pendulum_lab_home.dart';
import '../pendulum_lab/pl_colors.dart';
import '../hookes_law/screens/hookes_law_home.dart';
import '../projectile_motion/screens/projectile_motion_home.dart';
import '../plinko_probability/screens/plinko_probability_home.dart';
import '../bending_light/screens/bending_light_home.dart';
import '../molecules_and_light/view/molecules_and_light_screen.dart';
import '../molecule_shapes/screens/molecule_shapes_home.dart';
import '../reactants_products_and_leftovers/screens/reactants_products_and_leftovers_home.dart';
import '../balancing_chemical_equations/screens/balancing_chemical_equations_home.dart';
import '../balancing_act/screens/balancing_act_home.dart';
import '../wave_on_a_string/view/woas_screen.dart';
import '../concentration/concentration_assets.dart';
import '../beers_law_lab/screens/beers_law_lab_home.dart';
import '../membrane_transport/screens/membrane_transport_home.dart';
import '../common/simulation/simulation_registry.dart';
import '../quantum_measurement/quantum_measurement_module.dart';
import '../quantum_measurement/screens/quantum_measurement_home.dart';

/// Home card metadata (display strings come from [loc.sim]).
class HomeSimEntry {
  const HomeSimEntry({
    required this.id,
    required this.icon,
    required this.color,
    required this.builder,
    this.iconAsset,
  });

  /// Stable registry-style id (English kebab-case, never localized).
  final String id;
  final IconData icon;
  final String? iconAsset;
  final Color color;
  final WidgetBuilder builder;

  String get title => loc.sim.title(id);
  String get subtitle => loc.sim.subtitle(id);
}

class HomeSubjectGroup {
  const HomeSubjectGroup({required this.name, required this.sims});

  final String name;
  final List<HomeSimEntry> sims;
}

class HomeDiscipline {
  const HomeDiscipline({
    required this.name,
    required this.color,
    required this.groups,
  });

  final String name;
  final Color color;
  final List<HomeSubjectGroup> groups;

  int get simCount =>
      groups.fold<int>(0, (sum, group) => sum + group.sims.length);
}

/// Builds the localized Home catalog. Simulation IDs stay English.
List<HomeDiscipline> buildHomeDisciplines() {
  final h = loc.home;
  return [
    HomeDiscipline(
      name: h.physics,
      color: const Color(0xFF1177AA),
      groups: [
        HomeSubjectGroup(
          name: h.mechanics,
          sims: [
            HomeSimEntry(
              id: 'forces-and-motion-basics',
              icon: Icons.sports_kabaddi_rounded,
              color: const Color(0xFF166534),
              builder: (_) => const ForcesHome(),
            ),
            HomeSimEntry(
              id: 'collision-lab',
              icon: Icons.sports_baseball_rounded,
              color: CollisionLabColors.accent,
              builder: (_) => const CollisionLabHome(),
            ),
            HomeSimEntry(
              id: 'vector-addition',
              icon: Icons.north_east_rounded,
              color: VectorAdditionColors.accent,
              builder: (_) => const VectorAdditionHome(),
            ),
            HomeSimEntry(
              id: 'energy-skate-park',
              icon: Icons.skateboarding_rounded,
              color: EspColors.accent,
              builder: (_) => const EnergySkateParkHome(),
            ),
            HomeSimEntry(
              id: 'curve-fitting',
              icon: Icons.show_chart_rounded,
              color: CurveFittingColors.accent,
              builder: (_) => const CurveFittingHome(),
            ),
            HomeSimEntry(
              id: 'gravity-force-lab-basics',
              icon: Icons.public_rounded,
              color: GflbColors.accent,
              builder: (_) => const GflbHome(),
            ),
            HomeSimEntry(
              id: 'gravity-force-lab',
              icon: GravityForceLabScreen.homeIcon,
              color: GflColors.accent,
              builder: (_) => const GravityForceLabScreen(),
            ),
            HomeSimEntry(
              id: 'masses-and-springs-basics',
              icon: Icons.vertical_align_center_rounded,
              color: MasbHome.accentColor,
              builder: (_) => const MasbHome(),
            ),
            HomeSimEntry(
              id: 'hookes-law',
              icon: Icons.swap_vert_rounded,
              color: HookesLawHome.accentColor,
              builder: (_) => const HookesLawHome(),
            ),
            HomeSimEntry(
              id: 'pendulum-lab',
              icon: Icons.timelapse_rounded,
              color: PlColors.accent,
              builder: (_) => const PendulumLabHome(),
            ),
            HomeSimEntry(
              id: 'projectile-motion',
              icon: Icons.sports_baseball_rounded,
              color: ProjectileMotionHome.accentColor,
              builder: (_) => const ProjectileMotionHome(),
            ),
            HomeSimEntry(
              id: 'balancing-act',
              icon: Icons.scale_rounded,
              color: BalancingActHome.accentColor,
              builder: (_) => const BalancingActHome(),
            ),
            HomeSimEntry(
              id: 'friction',
              icon: Icons.menu_book_rounded,
              color: FrictionScreen.accentColor,
              builder: (_) => const FrictionScreen(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.mathProbability,
          sims: [
            HomeSimEntry(
              id: 'plinko-probability',
              icon: Icons.bubble_chart_rounded,
              color: PlinkoProbabilityHome.accentColor,
              builder: (_) => const PlinkoProbabilityHome(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.densityBuoyancy,
          sims: [
            HomeSimEntry(
              id: 'density',
              icon: Icons.water_drop_rounded,
              color: const Color(0xFF0F766E),
              builder: (_) => const DensityHome(),
            ),
            HomeSimEntry(
              id: 'buoyancy',
              icon: Icons.waves_rounded,
              iconAsset: BuoyancyHome.homeIconAsset,
              color: BuoyancyHome.accentColor,
              builder: (_) {
                BuoyancyModule.register();
                return const BuoyancyHome();
              },
            ),
            HomeSimEntry(
              id: 'under-pressure',
              icon: UnderPressureHome.homeIcon,
              color: UnderPressureHome.accentColor,
              builder: (_) => const UnderPressureHome(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.electricityCircuits,
          sims: [
            HomeSimEntry(
              id: 'circuit',
              icon: Icons.electric_bolt_rounded,
              color: const Color(0xFF0C4A6E),
              builder: (_) => const CircuitScreen(),
            ),
            HomeSimEntry(
              id: 'cck-ac-virtual-lab',
              icon: Icons.bolt_rounded,
              color: const Color(0xFF0369A1),
              builder: (_) => const CckAcVirtualLabScreen(),
            ),
            HomeSimEntry(
              id: 'capacitor-lab-basics',
              icon: Icons.battery_charging_full_rounded,
              color: CapacitorLabBasicsHome.accentColor,
              builder: (_) => const CapacitorLabBasicsHome(),
            ),
            HomeSimEntry(
              id: 'ohms-law',
              icon: OhmsLawScreen.homeIcon,
              color: OhmsLawScreen.accentColor,
              builder: (_) => const OhmsLawScreen(),
            ),
            HomeSimEntry(
              id: 'resistance-in-a-wire',
              icon: ResistanceInAWireScreen.homeIcon,
              color: ResistanceInAWireScreen.accentColor,
              builder: (_) => const ResistanceInAWireScreen(),
            ),
            HomeSimEntry(
              id: 'charges-and-fields',
              icon: Icons.flash_on_rounded,
              color: ChargesAndFieldsHome.accentColor,
              builder: (_) => const ChargesAndFieldsHome(),
            ),
            HomeSimEntry(
              id: 'john-travoltage',
              icon: Icons.electric_bolt_outlined,
              color: JohnTravoltageScreen.accentColor,
              builder: (_) => const JohnTravoltageScreen(),
            ),
            HomeSimEntry(
              id: 'balloons-and-static-electricity',
              icon: BalloonsStaticElectricityScreen.homeIcon,
              color: BalloonsStaticElectricityScreen.accentColor,
              builder: (_) => const BalloonsStaticElectricityScreen(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.electromagnetism,
          sims: [
            HomeSimEntry(
              id: 'magnet-and-compass',
              icon: Icons.explore_rounded,
              color: const Color(0xFF1565C0),
              builder: (_) => const MagnetAndCompassScreen(),
            ),
            HomeSimEntry(
              id: 'faradays-law',
              icon: Icons.bolt_rounded,
              color: FaradaysLawScreen.accentColor,
              builder: (_) => const FaradaysLawScreen(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.astronomy,
          sims: [
            HomeSimEntry(
              id: 'keplers-laws',
              icon: Icons.public_rounded,
              color: const Color(0xFF1A365D),
              builder: (_) => const KeplersLawsHome(),
            ),
            HomeSimEntry(
              id: 'my-solar-system',
              icon: Icons.wb_sunny_rounded,
              color: const Color(0xFF7C3AED),
              builder: (_) => const MySolarSystemHome(),
            ),
            HomeSimEntry(
              id: 'gravity-and-orbits',
              icon: Icons.public_outlined,
              color: const Color(0xFF0EA5E9),
              builder: (_) => const GravityAndOrbitsHome(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.opticsWaves,
          sims: [
            HomeSimEntry(
              id: 'optics',
              icon: Icons.play_arrow_rounded,
              color: const Color(0xFF1177AA),
              builder: (_) => const OpticsScreen(),
            ),
            HomeSimEntry(
              id: 'color-vision',
              icon: Icons.palette_rounded,
              color: const Color(0xFFDB2777),
              builder: (_) => const ColorVisionHome(),
            ),
            HomeSimEntry(
              id: 'wave-interference',
              icon: Icons.waves_rounded,
              color: const Color(0xFF2563EB),
              builder: (_) => const WaveInterferenceScreen(),
            ),
            HomeSimEntry(
              id: 'quantum-wave-interference',
              icon: Icons.blur_on_rounded,
              iconAsset: QuantumWaveInterferenceHome.homeIconAsset,
              color: QuantumWaveInterferenceHome.accentColor,
              builder: (_) => const QuantumWaveInterferenceHome(),
            ),
            HomeSimEntry(
              id: 'quantum-coin-toss',
              icon: Icons.monetization_on_outlined,
              color: QuantumCoinTossHome.accentColor,
              builder: (_) => const QuantumCoinTossHome(),
            ),
            HomeSimEntry(
              id: 'quantum-measurement',
              icon: Icons.science_outlined,
              iconAsset: QuantumMeasurementHome.homeIconAsset,
              color: QuantumMeasurementHome.accentColor,
              builder: _buildQuantumMeasurement,
            ),
            HomeSimEntry(
              id: 'waves-intro',
              icon: Icons.water_rounded,
              color: const Color(0xFF1177AA),
              builder: (_) => const WavesIntroHome(),
            ),
            HomeSimEntry(
              id: 'sound',
              icon: Icons.graphic_eq_rounded,
              color: const Color(0xFF0D9488),
              builder: (_) => const SoundScreen(),
            ),
            HomeSimEntry(
              id: 'normal-modes',
              icon: Icons.linear_scale_rounded,
              color: const Color(0xFF0E7490),
              builder: (_) => const NormalModesHome(),
            ),
            HomeSimEntry(
              id: 'fourier-making-waves',
              icon: Icons.auto_graph_rounded,
              color: const Color(0xFF0F766E),
              builder: (_) => const FourierMakingWavesHome(),
            ),
            HomeSimEntry(
              id: 'radio-waves',
              icon: Icons.sensors_rounded,
              color: const Color(0xFF7C3AED),
              builder: (_) => const RadioWavesScreen(),
            ),
            HomeSimEntry(
              id: 'bending-light',
              icon: Icons.lens_outlined,
              color: BendingLightHome.accentColor,
              builder: (_) => const BendingLightHome(),
            ),
            HomeSimEntry(
              id: 'wave-on-a-string',
              icon: Icons.timeline_rounded,
              color: WoasScreen.accentColor,
              builder: (_) => const WoasScreen(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.heatGases,
          sims: [
            HomeSimEntry(
              id: 'diffusion',
              icon: Icons.blur_on_rounded,
              color: DiffusionHome.accentColor,
              builder: (_) => const DiffusionHome(),
            ),
            HomeSimEntry(
              id: 'membrane-transport',
              icon: Icons.blur_on_rounded,
              iconAsset: MembraneTransportHome.homeIconAsset,
              color: MembraneTransportHome.accentColor,
              builder: (_) => const MembraneTransportHome(),
            ),
            HomeSimEntry(
              id: 'gases-intro',
              icon: Icons.bubble_chart_rounded,
              color: GasesIntroHome.accentColor,
              builder: (_) => const GasesIntroHome(),
            ),
            HomeSimEntry(
              id: 'gas-properties',
              icon: Icons.science_rounded,
              color: GasPropertiesHome.accentColor,
              builder: (_) => const GasPropertiesHome(),
            ),
            HomeSimEntry(
              id: 'blackbody-spectrum',
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFDC2626),
              builder: (_) => const BlackbodySpectrumHome(),
            ),
            HomeSimEntry(
              id: 'energy-forms-and-changes',
              icon: Icons.whatshot_rounded,
              color: EnergyFormsAndChangesHome.accentColor,
              builder: (_) => const EnergyFormsAndChangesHome(),
            ),
          ],
        ),
      ],
    ),
    HomeDiscipline(
      name: h.chemistry,
      color: const Color(0xFF0891B2),
      groups: [
        HomeSubjectGroup(
          name: h.solutions,
          sims: [
            HomeSimEntry(
              id: 'molarity',
              icon: Icons.science_rounded,
              color: const Color(0xFF0891B2),
              builder: (_) => Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  title: Text(loc.sim.title('molarity')),
                  backgroundColor: const Color(0xFF0891B2),
                  foregroundColor: Colors.white,
                ),
                body: const MolarityScreen(),
              ),
            ),
            HomeSimEntry(
              id: 'beers-law-lab',
              icon: Icons.science_rounded,
              iconAsset: ConcentrationAssets.screenIcon,
              color: BeersLawLabHome.accentColor,
              builder: (_) => BeersLawLabHome(
                concentrationAudio: BeersLawLabHome.debugTestAudio,
              ),
            ),
            HomeSimEntry(
              id: 'ph-scale',
              icon: Icons.science_outlined,
              color: const Color(0xFF0E7490),
              builder: (_) => const PhScaleScreen(),
            ),
            HomeSimEntry(
              id: 'acid-base-solutions',
              icon: Icons.science_outlined,
              color: AcidBaseSolutionsHome.accentColor,
              builder: (_) => const AcidBaseSolutionsHome(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.nucleus,
          sims: [
            HomeSimEntry(
              id: 'build-a-nucleus',
              icon: Icons.blur_circular_rounded,
              color: const Color(0xFFB45309),
              builder: (_) => const BuildANucleusHome(),
            ),
            HomeSimEntry(
              id: 'rutherford-scattering',
              icon: Icons.radio_button_checked,
              color: RutherfordScatteringHome.accentColor,
              builder: (_) => const RutherfordScatteringHome(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.atomicStructure,
          sims: [
            HomeSimEntry(
              id: 'build-an-atom',
              icon: Icons.blur_on,
              iconAsset: BuildAnAtomHome.homeIconAsset,
              color: BuildAnAtomHome.accentColor,
              builder: (_) => const BuildAnAtomHome(),
            ),
            HomeSimEntry(
              id: 'isotopes-and-atomic-mass',
              icon: Icons.science_outlined,
              color: IsotopesAndAtomicMassHome.accentColor,
              builder: (_) => const IsotopesAndAtomicMassHome(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.moleculeBuilding,
          sims: [
            HomeSimEntry(
              id: 'build-a-molecule',
              icon: Icons.hub_rounded,
              color: const Color(0xFF0D9488),
              builder: (_) => const BuildAMoleculeHome(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.moleculePolarity,
          sims: [
            HomeSimEntry(
              id: 'molecule-polarity',
              icon: Icons.science_outlined,
              color: MoleculePolarityHome.accentColor,
              builder: (_) => const MoleculePolarityHome(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.moleculeShapes,
          sims: [
            HomeSimEntry(
              id: 'molecule-shapes',
              icon: Icons.hub_outlined,
              color: MoleculeShapesHome.accentColor,
              builder: (_) => const MoleculeShapesHome(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.moleculesAndLight,
          sims: [
            HomeSimEntry(
              id: 'molecules-and-light',
              icon: Icons.flare_rounded,
              color: MoleculesAndLightScreen.accentColor,
              builder: (_) => const MoleculesAndLightScreen(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.reactantsProducts,
          sims: [
            HomeSimEntry(
              id: 'reactants-products-and-leftovers',
              icon: Icons.restaurant_outlined,
              color: ReactantsProductsAndLeftoversHome.accentColor,
              builder: (_) => const ReactantsProductsAndLeftoversHome(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.balancingEquations,
          sims: [
            HomeSimEntry(
              id: 'balancing-chemical-equations',
              icon: Icons.balance_outlined,
              color: BalancingChemicalEquationsHome.accentColor,
              builder: (_) => const BalancingChemicalEquationsHome(),
            ),
          ],
        ),
        HomeSubjectGroup(
          name: h.statesOfMatter,
          sims: [
            HomeSimEntry(
              id: 'states-of-matter',
              icon: Icons.water_drop_outlined,
              color: const Color(0xFF1177AA),
              builder: (_) => const StatesOfMatterHome(),
            ),
          ],
        ),
      ],
    ),
  ];
}

Widget _buildQuantumMeasurement(BuildContext context) {
  QuantumMeasurementModule.register();
  final d = SimulationRegistry.instance.require(QuantumMeasurementModule.id);
  if (!d.enabled) {
    return Scaffold(
      body: Center(
        child: Text(loc.home.unavailable(loc.sim.title(QuantumMeasurementModule.id))),
      ),
    );
  }
  return d.builder(context);
}

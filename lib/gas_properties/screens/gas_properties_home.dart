import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../../common/widgets/nine_grid_layout.dart';
import '../controller/gas_simulation_controller.dart';
import '../gas_properties_colors.dart';
import '../model/ideal_gas_law_model.dart';
import '../transform/gas_coordinate_transform.dart';
import '../widgets/gas_ideal_family_shell.dart';
import '../widgets/gas_properties_diffusion_tab.dart';
import 'gas_properties_perf_harness.dart';

/// Gas Properties — Ideal | Explore | Energy | Diffusion.
///
/// Diffusion tab embeds `lib/diffusion` [DiffusionShell] via
/// [GasPropertiesDiffusionTab] (original diffusion sources are not modified).
/// Tabs switch by click with a soft fade (no horizontal swipe).
class GasPropertiesHome extends StatefulWidget {
  const GasPropertiesHome({super.key});

  static const String title = 'Gas Properties';
  static const Color accentColor = Color(GasPropertiesColors.accent);

  /// Phase 4.1 K8: `flutter run --dart-define=GP_PERF_N=1000`
  static const int perfParticleCount =
      int.fromEnvironment('GP_PERF_N', defaultValue: 0);

  @override
  State<GasPropertiesHome> createState() => _GasPropertiesHomeState();
}

class _GasPropertiesHomeState extends State<GasPropertiesHome>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final GasSimulationController ideal;
  late final GasSimulationController explore;
  late final GasSimulationController energy;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 4,
      vsync: this,
      animationDuration: const Duration(milliseconds: 480),
    );
    ideal = GasSimulationController(profile: IdealGasProfile.ideal);
    explore = GasSimulationController(profile: IdealGasProfile.explore);
    energy = GasSimulationController(profile: IdealGasProfile.energy);
  }

  @override
  void dispose() {
    _tabs.dispose();
    ideal.dispose();
    explore.dispose();
    energy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (GasPropertiesHome.perfParticleCount > 0) {
      return GasPropertiesPerfHarness(
        particleCount: GasPropertiesHome.perfParticleCount,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(GasPropertiesHome.title),
        backgroundColor: GasPropertiesHome.accentColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          tabs: const [
            Tab(text: 'Ideal'),
            Tab(text: 'Explore'),
            Tab(text: 'Energy'),
            Tab(text: 'Diffusion'),
          ],
        ),
      ),
      body: ColoredBox(
        color: const Color(GasPropertiesColors.screenBackground),
        child: NineGridLayout(
          backgroundColor: const Color(GasPropertiesColors.screenBackground),
          center: LayoutBuilder(
            builder: (context, constraints) {
              final scale = GasLayoutPolicy.fitScale(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final size = GasLayoutPolicy.physicalSize(scale);
              return Center(
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: KratosTabSwitcher(
                    controller: _tabs,
                    duration: const Duration(milliseconds: 480),
                    curve: Curves.easeInOutCubic,
                    backdropColor:
                        const Color(GasPropertiesColors.screenBackground),
                    fadeThrough: true,
                    children: [
                      GasIdealFamilyShell(controller: ideal, layoutScale: scale),
                      GasIdealFamilyShell(
                        controller: explore,
                        layoutScale: scale,
                      ),
                      GasIdealFamilyShell(
                        controller: energy,
                        layoutScale: scale,
                      ),
                      GasPropertiesDiffusionTab(layoutScale: scale),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

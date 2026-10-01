import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common/widgets/kratos_tab_bar.dart';
import '../assets/qwi_assets.dart';
import '../view/experiment/experiment_screen.dart';
import '../view/high_intensity/high_intensity_screen.dart';
import '../view/single_particles/single_particles_screen.dart';

/// Formal KartosLab Home entry for Quantum Wave Interference.
///
/// PhET screens: Experiment → High Intensity → Single Particles.
/// Slim chrome (back + tabs only) to maximize play-area height.
class QuantumWaveInterferenceHome extends StatefulWidget {
  const QuantumWaveInterferenceHome({super.key, this.initialTab = 0});

  /// 0 = Experiment, 1 = High Intensity, 2 = Single Particles.
  final int initialTab;

  static const String title = '量子波干涉';

  static const String subtitle = 'Experiment · High Intensity · Single Particles';

  static const Color accentColor = Color(0xFF2563EB);

  static const String homeIconAsset = QwiAssets.experimentScreenIcon;

  static const String experimentTabLabel = 'Experiment';
  static const String highIntensityTabLabel = 'High Intensity';
  static const String singleParticlesTabLabel = 'Single Particles';

  @override
  State<QuantumWaveInterferenceHome> createState() => _QuantumWaveInterferenceHomeState();
}

class _QuantumWaveInterferenceHomeState extends State<QuantumWaveInterferenceHome>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 3,
      initialIndex: widget.initialTab.clamp(0, 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: QuantumWaveInterferenceHome.accentColor,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: QuantumWaveInterferenceHome.accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          // PhET has no title bar — keep only back + thin tab strip.
          toolbarHeight: 32,
          titleSpacing: 0,
          title: const Text(
            QuantumWaveInterferenceHome.title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(34),
            child: Material(
              color: Colors.white,
              child: TabBar(
                controller: _tabs,
                labelColor: QuantumWaveInterferenceHome.accentColor,
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: QuantumWaveInterferenceHome.accentColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                tabs: const [
                  Tab(
                    height: 32,
                    child: _QwiNavTab(
                      asset: QwiAssets.experimentScreenIcon,
                      label: QuantumWaveInterferenceHome.experimentTabLabel,
                    ),
                  ),
                  Tab(
                    height: 32,
                    child: _QwiNavTab(
                      asset: QwiAssets.highIntensityScreenIcon,
                      label: QuantumWaveInterferenceHome.highIntensityTabLabel,
                    ),
                  ),
                  Tab(
                    height: 32,
                    child: _QwiNavTab(
                      asset: QwiAssets.singleParticlesScreenIcon,
                      label: QuantumWaveInterferenceHome.singleParticlesTabLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: KratosTabSwitcher(
            controller: _tabs,
            children: const [
              ExperimentScreen(key: Key('qwi_tab_experiment')),
              HighIntensityScreen(key: Key('qwi_tab_high_intensity')),
              SingleParticlesScreen(key: Key('qwi_tab_single_particles')),
            ],
          ),
        ),
      ),
    );
  }
}

class _QwiNavTab extends StatelessWidget {
  const _QwiNavTab({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          asset,
          width: 26,
          height: 16,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

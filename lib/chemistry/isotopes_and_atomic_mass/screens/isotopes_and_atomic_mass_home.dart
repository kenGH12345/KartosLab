/// Isotopes and Atomic Mass home — compact screen tabs (Isotopes | Mixtures).
library;

import 'package:flutter/material.dart';

import '../controller/make_isotopes_controller.dart';
import '../controller/mixtures_controller.dart';
import '../iaam_constants.dart';
import 'make_isotopes_screen.dart';
import 'mix_isotopes_screen.dart';

class IsotopesAndAtomicMassHome extends StatefulWidget {
  const IsotopesAndAtomicMassHome({
    super.key,
    this.makeController,
    this.mixController,
    this.initialTab = 0,
  });

  final MakeIsotopesController? makeController;
  final MixturesController? mixController;
  final int initialTab;

  static const String title = '同位素与原子质量';
  static const String subtitle = 'Isotopes · Atomic Mass';
  static const Color accentColor = Color(0xFF0E7490);

  /// Compact PhET-style screen selector height (was ~112 with title+TabBar).
  static const double tabBarHeight = 44;

  @override
  State<IsotopesAndAtomicMassHome> createState() =>
      _IsotopesAndAtomicMassHomeState();
}

class _IsotopesAndAtomicMassHomeState extends State<IsotopesAndAtomicMassHome>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          IsotopesAndAtomicMassHome.tabBarHeight,
        ),
        child: AppBar(
          toolbarHeight: IsotopesAndAtomicMassHome.tabBarHeight,
          backgroundColor: IsotopesAndAtomicMassHome.accentColor,
          foregroundColor: Colors.white,
          elevation: 1,
          titleSpacing: 0,
          // Single compact row: back + screen tabs (no tall title+icon stack).
          title: TabBar(
            controller: _tabs,
            indicatorColor: Colors.white,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(
                height: IsotopesAndAtomicMassHome.tabBarHeight,
                child: _ScreenTab(
                  asset: IaamConstants.isotopesIconAsset,
                  label: 'Isotopes',
                ),
              ),
              Tab(
                height: IsotopesAndAtomicMassHome.tabBarHeight,
                child: _ScreenTab(
                  asset: IaamConstants.mixturesIconAsset,
                  label: 'Mixtures',
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          MakeIsotopesScreen(
            embedded: true,
            controller: widget.makeController,
          ),
          MixIsotopesScreen(
            embedded: true,
            controller: widget.mixController,
          ),
        ],
      ),
    );
  }
}

class _ScreenTab extends StatelessWidget {
  const _ScreenTab({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          asset,
          width: 20,
          height: 20,
          errorBuilder: (context, error, stackTrace) =>
              const SizedBox(width: 20, height: 20),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

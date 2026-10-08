import 'package:flutter/material.dart';

import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/hookes_law/hookes_law_strings.dart';
import 'package:kratos/hookes_law/model/energy_model.dart';
import 'package:kratos/hookes_law/model/intro_model.dart';
import 'package:kratos/hookes_law/model/systems_model.dart';
import 'package:kratos/hookes_law/view/energy/energy_screen.dart';
import 'package:kratos/hookes_law/view/energy/energy_view_properties.dart';
import 'package:kratos/hookes_law/view/intro/intro_screen.dart';
import 'package:kratos/hookes_law/view/intro/intro_view_properties.dart';
import 'package:kratos/hookes_law/view/systems/systems_screen.dart';
import 'package:kratos/hookes_law/view/systems/systems_view_properties.dart';

/// Home route for Hooke's Law. `hookes-law.title` is "Hooke's Law".
///
/// The route owns one Intro model, one Systems model, and one Energy model.
/// [KratosTabSwitcher] keeps all three screens mounted, so changing tabs does
/// not reset them. Popping this route disposes the screens and these models.
/// The next visit constructs new defaults. This is the same lifecycle as the
/// other multi-screen Home entries.
class HookesLawHome extends StatefulWidget {
  const HookesLawHome({super.key});

  static const String title = HookesLawStrings.title;
  static const String subtitle = HookesLawStrings.subtitle;
  static const Color accentColor = Color(0xFF1E3A8A);

  @override
  State<HookesLawHome> createState() => HookesLawHomeState();
}

class HookesLawHomeState extends State<HookesLawHome> {
  late final IntroModel intro;
  late final IntroViewProperties introView;
  late final SystemsModel systems;
  late final SystemsViewProperties systemsView;
  late final EnergyModel energy;
  late final EnergyViewProperties energyView;

  @override
  void initState() {
    super.initState();
    intro = IntroModel();
    introView = IntroViewProperties();
    systems = SystemsModel();
    systemsView = SystemsViewProperties();
    energy = EnergyModel();
    energyView = EnergyViewProperties();
  }

  @override
  void dispose() {
    introView.dispose();
    systemsView.dispose();
    energyView.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: HookesLawHome.title,
      accentColor: HookesLawHome.accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: '介绍',
          child: IntroScreen(model: intro, viewProperties: introView),
        ),
        KratosTab(
          label: '系统',
          child: SystemsScreen(model: systems, viewProperties: systemsView),
        ),
        KratosTab(
          label: '能量',
          child: EnergyScreen(model: energy, viewProperties: energyView),
        ),
      ],
    );
  }
}

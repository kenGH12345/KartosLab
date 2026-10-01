import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/pendulum_lab/controller/pendulum_lab_controller.dart';
import 'package:kratos/pendulum_lab/model/energy_model.dart';
import 'package:kratos/pendulum_lab/model/lab_model.dart';
import 'package:kratos/pendulum_lab/model/pendulum_lab_model.dart';
import 'package:kratos/pendulum_lab/pl_assets.dart';
import 'package:kratos/pendulum_lab/pl_colors.dart';
import 'package:kratos/pendulum_lab/pl_strings.dart';
import 'package:kratos/pendulum_lab/widgets/pendulum_lab_screen_layout.dart';
import 'package:kratos/pendulum_lab/widgets/pl_simulation_shell.dart';

class PendulumLabHome extends StatelessWidget {
  const PendulumLabHome({super.key});

  static const String title = PlStrings.title;
  static const String subtitle = PlStrings.subtitle;
  static const Color accentColor = PlColors.accent;

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      tabs: const [
        KratosTab(
          label: PlStrings.screenIntro,
          tabIcon: _TabIcon(PlAssets.introNavbarIcon),
          child: _IntroBody(),
        ),
        KratosTab(
          label: PlStrings.screenEnergy,
          tabIcon: _TabIcon(PlAssets.energyScreenIcon),
          child: _EnergyBody(),
        ),
        KratosTab(
          label: PlStrings.screenLab,
          tabIcon: _TabIcon(PlAssets.labNavbarIcon),
          child: _LabBody(),
        ),
      ],
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(asset, height: 22, fit: BoxFit.contain);
  }
}

class _IntroBody extends StatefulWidget {
  const _IntroBody();

  @override
  State<_IntroBody> createState() => _IntroBodyState();
}

class _IntroBodyState extends State<_IntroBody>
    with TickerProviderStateMixin {
  late final PendulumLabController controller;

  @override
  void initState() {
    super.initState();
    controller = PendulumLabController(PendulumLabModel())..attach(this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlSimulationShell(
      child: ListenableBuilder(
        listenable: controller,
        builder: (_, _) => PendulumLabScreenLayout(controller: controller),
      ),
    );
  }
}

class _EnergyBody extends StatefulWidget {
  const _EnergyBody();

  @override
  State<_EnergyBody> createState() => _EnergyBodyState();
}

class _EnergyBodyState extends State<_EnergyBody>
    with TickerProviderStateMixin {
  late final PendulumLabController controller;

  @override
  void initState() {
    super.initState();
    controller = PendulumLabController(EnergyModel())..attach(this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlSimulationShell(
      child: ListenableBuilder(
        listenable: controller,
        builder: (_, _) => PendulumLabScreenLayout(
          controller: controller,
          showEnergyGraph: true,
        ),
      ),
    );
  }
}

class _LabBody extends StatefulWidget {
  const _LabBody();

  @override
  State<_LabBody> createState() => _LabBodyState();
}

class _LabBodyState extends State<_LabBody> with TickerProviderStateMixin {
  late final PendulumLabController controller;

  @override
  void initState() {
    super.initState();
    controller = PendulumLabController(LabModel())..attach(this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlSimulationShell(
      child: ListenableBuilder(
        listenable: controller,
        builder: (_, _) => PendulumLabScreenLayout(
          controller: controller,
          hasGravityTweakers: true,
          showEnergyGraph: true,
          showArrowPanel: true,
        ),
      ),
    );
  }
}

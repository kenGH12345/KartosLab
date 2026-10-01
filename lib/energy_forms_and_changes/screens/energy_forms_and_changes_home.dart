import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/energy_forms_and_changes/efac_colors.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';
import 'package:kratos/energy_forms_and_changes/intro/controller/intro_controller.dart';
import 'package:kratos/energy_forms_and_changes/intro/screens/intro_screen_body.dart';
import 'package:kratos/energy_forms_and_changes/systems/controller/systems_controller.dart';
import 'package:kratos/energy_forms_and_changes/systems/screens/systems_screen_body.dart';
import 'package:kratos/energy_forms_and_changes/widgets/efac_simulation_shell.dart';

/// Home shell — PhET dual screen (Intro / Systems).
///
/// EFAC intentionally bypasses [NineGridLayout]: the sim receives the full
/// tab-body viewport, then [EfacSimulationShell] applies PhET `layout()`.
class EnergyFormsAndChangesHome extends StatefulWidget {
  const EnergyFormsAndChangesHome({super.key});

  static const String title = EfacStrings.title;
  static const Color accentColor = EfacColors.accent;

  @override
  State<EnergyFormsAndChangesHome> createState() =>
      EnergyFormsAndChangesHomeState();
}

class EnergyFormsAndChangesHomeState extends State<EnergyFormsAndChangesHome>
    with TickerProviderStateMixin {
  late final IntroController intro;
  late final SystemsController systems;

  @override
  void initState() {
    super.initState();
    intro = IntroController()..attach(this);
    systems = SystemsController()..attach(this);
  }

  @override
  void dispose() {
    intro.dispose();
    systems.dispose();
    super.dispose();
  }

  /// Test hook: recreate models after pop/push.
  void reinitializeForTest() {
    intro.dispose();
    systems.dispose();
    intro = IntroController()..attach(this);
    systems = SystemsController()..attach(this);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: EnergyFormsAndChangesHome.title,
      accentColor: EnergyFormsAndChangesHome.accentColor,
      tabs: [
        KratosTab(
          label: EfacStrings.intro,
          child: EfacSimulationShell(
            child: IntroScreenBody(controller: intro),
          ),
        ),
        KratosTab(
          label: EfacStrings.systems,
          child: EfacSimulationShell(
            child: SystemsScreenBody(controller: systems),
          ),
        ),
      ],
    );
  }
}

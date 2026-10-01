import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_tab_bar.dart';
import '../controller/atomic_interactions_controller.dart';
import '../controller/phase_changes_controller.dart';
import '../controller/states_of_matter_controller.dart';
import '../som_strings.dart';
import 'atomic_interactions_screen.dart';
import 'phase_changes_screen.dart';
import 'states_screen.dart';

/// Home shell for States of Matter — three screens live.
class StatesOfMatterHome extends StatefulWidget {
  const StatesOfMatterHome({super.key});

  @override
  State<StatesOfMatterHome> createState() => _StatesOfMatterHomeState();
}

class _StatesOfMatterHomeState extends State<StatesOfMatterHome>
    with TickerProviderStateMixin {
  late final StatesOfMatterController _statesController;
  late final PhaseChangesController _phaseChangesController;
  late final AtomicInteractionsController _interactionsController;

  @override
  void initState() {
    super.initState();
    _statesController = StatesOfMatterController();
    _phaseChangesController = PhaseChangesController();
    _interactionsController = AtomicInteractionsController();
    _statesController.attach(this);
    _phaseChangesController.attach(this);
    _interactionsController.attach(this);
  }

  @override
  void dispose() {
    _statesController.dispose();
    _phaseChangesController.dispose();
    _interactionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: 'States of Matter',
      accentColor: const Color(0xFF1177AA),
      tabs: [
        KratosTab(
          label: SomStrings.states,
          child: StatesScreen(controller: _statesController),
        ),
        KratosTab(
          label: SomStrings.phaseChanges,
          child: PhaseChangesScreen(controller: _phaseChangesController),
        ),
        KratosTab(
          label: SomStrings.interaction,
          child: AtomicInteractionsScreen(controller: _interactionsController),
        ),
      ],
    );
  }
}

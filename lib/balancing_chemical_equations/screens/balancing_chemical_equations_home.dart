import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../bce_strings.dart';
import '../equations/equations_model.dart';
import '../equations/equations_screen.dart';
import '../game/game_model.dart';
import '../game/game_screen.dart';
import '../intro/intro_model.dart';
import '../intro/intro_screen.dart';

/// Home → 化学 → 配平化学方程式 → BCE production entry.
///
/// Three screens (Intro / Equations / Game). Models are owned here and disposed
/// on Back (RPL / Plinko pattern). Re-entry creates a fresh Home instance.
class BalancingChemicalEquationsHome extends StatefulWidget {
  const BalancingChemicalEquationsHome({
    super.key,
    this.introModel,
    this.equationsModel,
    this.gameModel,
  });

  static const String title = BceStrings.title;
  static const String subtitle = BceStrings.subtitle;

  /// PhET Intro / Equations chrome bar blue (`#3376C4`).
  static const Color accentColor = Color(0xFF3376C4);

  /// Optional injection for tests; when null, Home creates and owns instances.
  final IntroModel? introModel;
  final EquationsModel? equationsModel;
  final GameModel? gameModel;

  @override
  State<BalancingChemicalEquationsHome> createState() =>
      BalancingChemicalEquationsHomeState();
}

class BalancingChemicalEquationsHomeState
    extends State<BalancingChemicalEquationsHome> {
  late final IntroModel intro;
  late final EquationsModel equations;
  late final GameModel game;
  late final bool _ownsIntro;
  late final bool _ownsEquations;
  late final bool _ownsGame;

  @override
  void initState() {
    super.initState();
    _ownsIntro = widget.introModel == null;
    _ownsEquations = widget.equationsModel == null;
    _ownsGame = widget.gameModel == null;
    intro = widget.introModel ?? IntroModel();
    equations = widget.equationsModel ?? EquationsModel();
    game = widget.gameModel ?? GameModel();
  }

  @override
  void dispose() {
    if (_ownsIntro) intro.dispose();
    if (_ownsEquations) equations.dispose();
    if (_ownsGame) game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: BalancingChemicalEquationsHome.title,
      accentColor: BalancingChemicalEquationsHome.accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: BceStrings.screenIntro,
          icon: Icons.science_outlined,
          child: IntroScreen(model: intro),
        ),
        KratosTab(
          label: BceStrings.screenEquations,
          icon: Icons.functions_outlined,
          child: EquationsScreen(model: equations),
        ),
        KratosTab(
          label: BceStrings.screenGame,
          icon: Icons.sports_esports_outlined,
          child: GameScreen(model: game),
        ),
      ],
    );
  }
}

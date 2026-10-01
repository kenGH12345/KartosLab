import 'package:flutter/material.dart';
import 'package:kratos/balancing_act/ba_colors.dart';
import 'package:kratos/balancing_act/ba_strings.dart';
import 'package:kratos/balancing_act/view/ba_balance_lab_controller.dart';
import 'package:kratos/balancing_act/view/ba_balance_lab_screen.dart';
import 'package:kratos/balancing_act/view/ba_game_controller.dart';
import 'package:kratos/balancing_act/view/ba_game_screen.dart';
import 'package:kratos/balancing_act/view/ba_intro_controller.dart';
import 'package:kratos/balancing_act/view/ba_intro_screen.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';

/// Home → 物理 → 力学 → Balancing Act production entry.
///
/// Three screens (Intro / Balance Lab / Game). Controllers are owned here and
/// disposed on Back (Plinko / BCE pattern). Re-entry creates a fresh Home.
class BalancingActHome extends StatefulWidget {
  const BalancingActHome({
    super.key,
    this.introController,
    this.labController,
    this.gameController,
  });

  static const String title = BaStrings.title;
  static const String subtitle = BaStrings.subtitle;

  /// SkyNode top — matches sim chrome.
  static const Color accentColor = BaColors.skyTop;

  /// Optional injection for tests; when null, Home creates and owns instances.
  final BaIntroController? introController;
  final BaBalanceLabController? labController;
  final BaGameController? gameController;

  @override
  State<BalancingActHome> createState() => BalancingActHomeState();
}

class BalancingActHomeState extends State<BalancingActHome> {
  late final BaIntroController intro;
  late final BaBalanceLabController lab;
  late final BaGameController game;
  late final bool _ownsIntro;
  late final bool _ownsLab;
  late final bool _ownsGame;

  @override
  void initState() {
    super.initState();
    _ownsIntro = widget.introController == null;
    _ownsLab = widget.labController == null;
    _ownsGame = widget.gameController == null;
    intro = widget.introController ?? BaIntroController();
    lab = widget.labController ?? BaBalanceLabController();
    game = widget.gameController ?? BaGameController();
  }

  @override
  void dispose() {
    if (_ownsIntro) intro.dispose();
    if (_ownsLab) lab.dispose();
    if (_ownsGame) game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: BalancingActHome.title,
      accentColor: BalancingActHome.accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: BaStrings.screenIntro,
          icon: Icons.balance_outlined,
          child: BaIntroScreen(controller: intro),
        ),
        KratosTab(
          label: BaStrings.screenBalanceLab,
          icon: Icons.science_outlined,
          child: BaBalanceLabScreen(controller: lab),
        ),
        KratosTab(
          label: BaStrings.screenGame,
          icon: Icons.sports_esports_outlined,
          child: BaGameScreen(controller: game),
        ),
      ],
    );
  }
}

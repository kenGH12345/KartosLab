import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../rpal_colors.dart';
import '../rpal_strings.dart';
import '../view/game_controller.dart';
import '../view/game_screen.dart';
import '../view/molecules_controller.dart';
import '../view/molecules_screen.dart';
import '../view/sandwiches_controller.dart';
import '../view/sandwiches_screen.dart';

/// Home → 化学 → 反应物与生成物 → RPL entry.
///
/// Three independent screens (Sandwiches / Molecules / Game). Controllers are
/// owned here and disposed on Back (Plinko / SoM pattern). Inactive tabs pause
/// tickers via [KratosTabSwitcher].
class ReactantsProductsAndLeftoversHome extends StatefulWidget {
  const ReactantsProductsAndLeftoversHome({
    super.key,
    this.sandwichesController,
    this.moleculesController,
    this.gameController,
  });

  static const String title = RpalStrings.title;
  static const String subtitle = '三明治 · 分子 · 游戏';
  static const Color accentColor = RpalColors.statusBarFill;

  /// Optional injection for tests; when null, Home creates and owns instances.
  final SandwichesController? sandwichesController;
  final MoleculesController? moleculesController;
  final GameController? gameController;

  @override
  State<ReactantsProductsAndLeftoversHome> createState() =>
      ReactantsProductsAndLeftoversHomeState();
}

class ReactantsProductsAndLeftoversHomeState
    extends State<ReactantsProductsAndLeftoversHome> {
  late final SandwichesController sandwiches;
  late final MoleculesController molecules;
  late final GameController game;
  late final bool _ownsSandwiches;
  late final bool _ownsMolecules;
  late final bool _ownsGame;

  @override
  void initState() {
    super.initState();
    _ownsSandwiches = widget.sandwichesController == null;
    _ownsMolecules = widget.moleculesController == null;
    _ownsGame = widget.gameController == null;
    sandwiches = widget.sandwichesController ?? SandwichesController();
    molecules = widget.moleculesController ?? MoleculesController();
    game = widget.gameController ?? GameController();
  }

  @override
  void dispose() {
    if (_ownsSandwiches) sandwiches.dispose();
    if (_ownsMolecules) molecules.dispose();
    if (_ownsGame) game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: ReactantsProductsAndLeftoversHome.title,
      accentColor: ReactantsProductsAndLeftoversHome.accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: RpalStrings.sandwiches,
          icon: Icons.lunch_dining_outlined,
          child: SandwichesScreen(controller: sandwiches),
        ),
        KratosTab(
          label: RpalStrings.molecules,
          icon: Icons.science_outlined,
          child: MoleculesScreen(controller: molecules),
        ),
        KratosTab(
          label: RpalStrings.game,
          icon: Icons.sports_esports_outlined,
          child: GameScreen(controller: game),
        ),
      ],
    );
  }
}

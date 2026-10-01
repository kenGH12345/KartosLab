import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/model/game_enums.dart';
import 'package:kratos/reactants_products_and_leftovers/model/game_model.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_strings.dart';
import 'package:kratos/reactants_products_and_leftovers/view/game_controller.dart';
import 'package:kratos/reactants_products_and_leftovers/view/molecules_controller.dart';
import 'package:kratos/reactants_products_and_leftovers/view/sandwiches_controller.dart';

void main() {
  group('Cross-screen state isolation', () {
    test('mutating each screen does not affect the others', () {
      final sandwiches = SandwichesController();
      final molecules = MoleculesController();
      final game = GameController(model: GameModel(random: Random(42)));

      // Sandwiches mutate
      sandwiches.selectRecipe(sandwiches.recipes[1]);
      sandwiches.setReactantQuantity(sandwiches.selected.bread, 6);
      sandwiches.toggleBeforeExpanded();

      // Molecules mutate
      molecules.selectReaction(molecules.reactions[1]);
      molecules.setReactantQuantity(molecules.selected.reactants[0], 3);

      // Game mutate
      game.play(1);
      game.model.challenge!.showAnswer();
      game.check();

      // Sandwiches unchanged by others
      expect(sandwiches.selected.name, RpalStrings.meatAndCheese);
      expect(sandwiches.selected.bread.quantity, 6);
      expect(sandwiches.beforeExpanded, isFalse);

      // Molecules unchanged by others
      expect(molecules.selected.name, RpalStrings.makeAmmonia);
      expect(molecules.selected.reactants[0].quantity, 3);

      // Game independent
      expect(game.model.gamePhase, GamePhase.play);
      expect(game.model.score, 2);
      expect(game.model.level, 1);

      // Back to sandwiches — still same
      expect(sandwiches.selected.bread.quantity, 6);
    });

    test('fresh screen instances start at source defaults', () {
      final dirtyS = SandwichesController();
      dirtyS.selectRecipe(dirtyS.recipes[2]);
      dirtyS.setCoefficient(dirtyS.selected.bread, 2);

      final dirtyM = MoleculesController();
      dirtyM.selectReaction(dirtyM.reactions[2]);

      final dirtyG = GameController(model: GameModel(random: Random(1)));
      dirtyG.play(0);

      final freshS = SandwichesController();
      final freshM = MoleculesController();
      final freshG = GameController(model: GameModel(random: Random(2)));

      expect(freshS.selected.name, RpalStrings.cheese);
      expect(freshS.selected.bread.quantity, 0);
      expect(freshS.beforeExpanded, isTrue);

      expect(freshM.selected.name, RpalStrings.makeWater);
      expect(freshM.selected.reactants[0].quantity, 0);

      expect(freshG.model.gamePhase, GamePhase.settings);
      expect(freshG.model.score, 0);
      expect(freshG.model.challenge, isNull);

      // dirty instances still dirty — no global singleton
      expect(dirtyS.selected.name, RpalStrings.custom);
      expect(dirtyM.selected.name, RpalStrings.combustMethane);
      expect(dirtyG.model.gamePhase, GamePhase.play);
    });

    test('no shared ChangeNotifier between screens', () {
      final s = SandwichesController();
      final m = MoleculesController();
      final g = GameController();
      expect(identical(s, m), isFalse);
      expect(identical(s.model, m.model), isFalse);
      expect(identical(g.model, s.model), isFalse);
    });
  });
}

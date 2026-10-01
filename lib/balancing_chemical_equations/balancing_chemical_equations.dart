export 'bce_constants.dart';
export 'bce_strings.dart';
export 'data/equations_datasets.dart';
export 'data/game_equation_pool1.dart';
export 'data/game_equation_pool2.dart';
export 'data/game_equation_pool3.dart';
export 'data/intro_equations.dart';
export 'equations/equations_model.dart';
export 'equations/equations_screen.dart';
export 'game/game_model.dart';
export 'game/game_screen.dart';
export 'game/game_state.dart';
export 'intro/intro_model.dart';
export 'intro/intro_screen.dart';
export 'model/atom_count.dart';
export 'model/bce_atom.dart';
export 'model/bce_element.dart';
export 'model/bce_molecule.dart';
export 'model/equation.dart';
export 'model/equation_term.dart';
export 'model/view_mode.dart';
export 'screens/balancing_chemical_equations_home.dart';

import 'data/equations_datasets.dart';
import 'data/game_equation_pool1.dart';
import 'data/game_equation_pool2.dart';
import 'data/game_equation_pool3.dart';
import 'data/intro_equations.dart';

/// Aggregate source equation counts for integrity tests.
abstract final class BceDatasetCounts {
  static const intro = IntroEquations.sourceCount; // 3
  static const equations = EquationsDatasets.sourceCount; // 12
  static const gameLevel1 = GameEquationPool1.sourceCount; // 21
  static const gameLevel2 = GameEquationPool2.sourceCount; // 11
  static const gameLevel3 = GameEquationPool3.sourceCount; // 14
  static const total =
      intro + equations + gameLevel1 + gameLevel2 + gameLevel3; // 61
}

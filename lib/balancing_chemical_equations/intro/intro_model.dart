import 'package:flutter/foundation.dart';

import '../data/intro_equations.dart';
import '../model/equation.dart';
import '../model/equation_term.dart';
import '../model/view_mode.dart';

/// PhET `IntroModel` + `IntroViewProperties` combined for the Intro screen.
///
/// Equation switching only changes [selectedEquation] — coefficients are
/// **preserved** per equation (source: IntroModel.equationProperty does not
/// call equation.reset on switch). [reset] restores all equations + selection
/// + view properties to defaults.
class IntroModel extends ChangeNotifier {
  IntroModel({int? initialCoefficient}) {
    equations = IntroEquations.createAll(
      initialCoefficient: initialCoefficient ?? BcePreferences.instance.initialCoefficient,
    );
    _selected = equations.first;
    _selected.addListener(_onEquationChanged);
  }

  late final List<Equation> equations;
  late Equation _selected;

  Equation get selectedEquation => _selected;

  /// Stable identity of the selected equation.
  String get selectedId => _selected.id;

  ViewMode viewMode = ViewMode.particles;
  bool reactantsExpanded = true;
  bool productsExpanded = true;

  static const CoefficientRange coefficientsRange = BceCoefficientRanges.intro;

  static const labels = <String, String>{
    'intro.makeAmmonia': 'Make Ammonia',
    'intro.separateWater': 'Separate Water',
    'intro.combustMethane': 'Combust Methane',
  };

  String labelFor(Equation equation) =>
      labels[equation.id] ?? equation.id;

  void selectEquation(Equation equation) {
    assert(equations.contains(equation));
    if (identical(_selected, equation)) return;
    _selected.removeListener(_onEquationChanged);
    _selected = equation;
    _selected.addListener(_onEquationChanged);
    notifyListeners();
  }

  void selectById(String id) {
    final match = equations.firstWhere((e) => e.id == id);
    selectEquation(match);
  }

  void setViewMode(ViewMode mode) {
    if (viewMode == mode) return;
    viewMode = mode;
    notifyListeners();
  }

  void setReactantsExpanded(bool expanded) {
    if (reactantsExpanded == expanded) return;
    reactantsExpanded = expanded;
    notifyListeners();
  }

  void setProductsExpanded(bool expanded) {
    if (productsExpanded == expanded) return;
    productsExpanded = expanded;
    notifyListeners();
  }

  void toggleReactants() => setReactantsExpanded(!reactantsExpanded);
  void toggleProducts() => setProductsExpanded(!productsExpanded);

  /// PhET Reset All: model.reset() + viewProperties.reset().
  void reset() {
    for (final e in equations) {
      e.reset();
    }
    _selected.removeListener(_onEquationChanged);
    _selected = equations.first;
    _selected.addListener(_onEquationChanged);
    viewMode = ViewMode.particles;
    reactantsExpanded = true;
    productsExpanded = true;
    notifyListeners();
  }

  void _onEquationChanged() => notifyListeners();

  @override
  void dispose() {
    _selected.removeListener(_onEquationChanged);
    for (final e in equations) {
      e.dispose();
    }
    super.dispose();
  }
}

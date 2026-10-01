import 'package:flutter/foundation.dart';

import '../data/equations_datasets.dart';
import '../model/equation.dart';
import '../model/equation_term.dart';
import '../model/view_mode.dart';

/// PhET `EquationsModel` + `EquationsViewProperties` for the Equations screen.
///
/// Reaction-type switch updates [selectedEquation] via per-type selection
/// properties — coefficients are **preserved** on each equation instance
/// (source does not call `equation.reset` on type/equation switch).
class EquationsModel extends ChangeNotifier {
  EquationsModel({int? initialCoefficient}) {
    final seed = initialCoefficient ?? BcePreferences.instance.initialCoefficient;
    synthesisEquations =
        EquationsDatasets.createSynthesis(initialCoefficient: seed);
    decompositionEquations =
        EquationsDatasets.createDecomposition(initialCoefficient: seed);
    combustionEquations =
        EquationsDatasets.createCombustion(initialCoefficient: seed);
    _synthesisSelected = synthesisEquations.first;
    _decompositionSelected = decompositionEquations.first;
    _combustionSelected = combustionEquations.first;
    _selected.addListener(_onEquationChanged);
  }

  late final List<Equation> synthesisEquations;
  late final List<Equation> decompositionEquations;
  late final List<Equation> combustionEquations;

  late Equation _synthesisSelected;
  late Equation _decompositionSelected;
  late Equation _combustionSelected;

  ReactionType reactionType = ReactionType.synthesis;
  ViewMode viewMode = ViewMode.particles;
  bool reactantsExpanded = true;
  bool productsExpanded = true;

  static const CoefficientRange coefficientsRange = BceCoefficientRanges.equations;

  List<Equation> get allEquations => [
        ...synthesisEquations,
        ...decompositionEquations,
        ...combustionEquations,
      ];

  List<Equation> equationsFor(ReactionType type) {
    switch (type) {
      case ReactionType.synthesis:
        return synthesisEquations;
      case ReactionType.decomposition:
        return decompositionEquations;
      case ReactionType.combustion:
        return combustionEquations;
    }
  }

  /// Currently visible equation (derived from reaction type + per-type selection).
  Equation get selectedEquation {
    switch (reactionType) {
      case ReactionType.synthesis:
        return _synthesisSelected;
      case ReactionType.decomposition:
        return _decompositionSelected;
      case ReactionType.combustion:
        return _combustionSelected;
    }
  }

  Equation get _selected => selectedEquation;

  String get selectedId => selectedEquation.id;

  Equation selectedFor(ReactionType type) {
    switch (type) {
      case ReactionType.synthesis:
        return _synthesisSelected;
      case ReactionType.decomposition:
        return _decompositionSelected;
      case ReactionType.combustion:
        return _combustionSelected;
    }
  }

  void setReactionType(ReactionType type) {
    if (reactionType == type) return;
    _selected.removeListener(_onEquationChanged);
    reactionType = type;
    _selected.addListener(_onEquationChanged);
    notifyListeners();
  }

  void selectEquation(Equation equation) {
    final pool = equationsFor(reactionType);
    assert(pool.contains(equation));
    final current = selectedFor(reactionType);
    if (identical(current, equation)) return;
    _selected.removeListener(_onEquationChanged);
    switch (reactionType) {
      case ReactionType.synthesis:
        _synthesisSelected = equation;
      case ReactionType.decomposition:
        _decompositionSelected = equation;
      case ReactionType.combustion:
        _combustionSelected = equation;
    }
    _selected.addListener(_onEquationChanged);
    notifyListeners();
  }

  void selectById(String id) {
    for (final e in allEquations) {
      if (e.id == id) {
        // Switch reaction type to the pool that contains this id.
        if (synthesisEquations.contains(e)) {
          setReactionType(ReactionType.synthesis);
        } else if (decompositionEquations.contains(e)) {
          setReactionType(ReactionType.decomposition);
        } else {
          setReactionType(ReactionType.combustion);
        }
        selectEquation(e);
        return;
      }
    }
    throw ArgumentError.value(id, 'id', 'Unknown equation id');
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

  /// PhET Reset All: `model.reset()` + `viewProperties.reset()`.
  void reset() {
    for (final e in allEquations) {
      e.reset();
    }
    _selected.removeListener(_onEquationChanged);
    reactionType = ReactionType.synthesis;
    _synthesisSelected = synthesisEquations.first;
    _decompositionSelected = decompositionEquations.first;
    _combustionSelected = combustionEquations.first;
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
    for (final e in allEquations) {
      e.dispose();
    }
    super.dispose();
  }
}

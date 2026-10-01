import 'package:flutter/foundation.dart';

import '../model/molecules_model.dart';
import '../model/reaction.dart';
import '../model/substance.dart';
import '../rpal_constants.dart';

/// View controller for Molecules screen — Model + accordion UI state.
class MoleculesController extends ChangeNotifier {
  MoleculesController({MoleculesModel? model})
      : model = model ?? MoleculesModel() {
    _wireModelNotifications();
  }

  final MoleculesModel model;

  bool beforeExpanded = true;
  bool afterExpanded = true;

  Reaction get selected => model.selectedReaction;

  List<Reaction> get reactions => model.reactions;

  void _wireModelNotifications() {
    final seen = <Substance>{};
    for (final reaction in model.reactions) {
      for (final substance in [
        ...reaction.reactants,
        ...reaction.products,
        ...reaction.leftovers,
      ]) {
        if (seen.add(substance)) {
          _chainNotify(substance);
        }
      }
    }
  }

  void _chainNotify(Substance substance) {
    final previous = substance.onChanged;
    substance.onChanged = () {
      previous?.call();
      notifyListeners();
    };
  }

  void selectReaction(Reaction reaction) {
    if (identical(model.selectedReaction, reaction)) {
      return;
    }
    model.selectReaction(reaction);
    notifyListeners();
  }

  void setReactantQuantity(Substance reactant, int quantity) {
    final clamped = quantity.clamp(
      RpalConstants.quantityMin,
      RpalConstants.quantityMax,
    );
    if (reactant.quantity == clamped) {
      return;
    }
    reactant.quantity = clamped;
  }

  void toggleBeforeExpanded() {
    beforeExpanded = !beforeExpanded;
    notifyListeners();
  }

  void toggleAfterExpanded() {
    afterExpanded = !afterExpanded;
    notifyListeners();
  }

  void reset() {
    model.reset();
    beforeExpanded = true;
    afterExpanded = true;
    notifyListeners();
  }
}

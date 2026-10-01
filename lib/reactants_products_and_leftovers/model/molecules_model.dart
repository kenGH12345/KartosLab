import 'reaction_factory.dart';
import 'rpal_base_model.dart';

/// Model for the Molecules screen — `MoleculesModel.ts`.
class MoleculesModel extends RpalBaseModel {
  MoleculesModel()
      : super([
          ReactionFactory.makeWater(),
          ReactionFactory.makeAmmonia(),
          ReactionFactory.combustMethane(),
        ]);
}

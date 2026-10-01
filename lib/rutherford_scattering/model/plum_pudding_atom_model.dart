import 'plum_pudding_atom_space.dart';
import 'rs_base_model.dart';

/// Plum Pudding Atom screen model — PlumPuddingAtomModel.ts
class PlumPuddingAtomModel extends RsBaseModel {
  PlumPuddingAtomModel() {
    plumPuddingSpace = PlumPuddingAtomSpace(bounds: bounds);
    plumPuddingSpace.isVisible = true;
    atomSpaces.add(plumPuddingSpace);
    wireSpace(plumPuddingSpace);
  }

  late final PlumPuddingAtomSpace plumPuddingSpace;
}

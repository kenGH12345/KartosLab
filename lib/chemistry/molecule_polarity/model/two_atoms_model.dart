import 'diatomic_molecule.dart';
import 'mp_model.dart';
import 'mp_preferences.dart';
import 'view_properties.dart';

/// Source: `js/twoatoms/model/TwoAtomsModel.ts`
class TwoAtomsModel extends MpModel {
  factory TwoAtomsModel({
    DiatomicMolecule? molecule,
    MpPreferences? preferences,
    TwoAtomsViewProperties? viewProperties,
  }) {
    final m = molecule ?? DiatomicMolecule();
    return TwoAtomsModel._(
      m,
      preferences: preferences,
      viewProperties: viewProperties ?? TwoAtomsViewProperties(),
    );
  }

  TwoAtomsModel._(
    DiatomicMolecule super.molecule, {
    super.preferences,
    required this.viewProperties,
  });

  DiatomicMolecule get diatomic => molecule as DiatomicMolecule;

  final TwoAtomsViewProperties viewProperties;

  @override
  void reset() {
    super.reset();
    molecule.reset();
    viewProperties.reset();
  }
}

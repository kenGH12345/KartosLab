import 'mp_model.dart';
import 'mp_preferences.dart';
import 'triatomic_molecule.dart';
import 'view_properties.dart';

/// Source: `js/threeatoms/model/ThreeAtomsModel.ts`
class ThreeAtomsModel extends MpModel {
  factory ThreeAtomsModel({
    TriatomicMolecule? molecule,
    MpPreferences? preferences,
    ThreeAtomsViewProperties? viewProperties,
  }) {
    final m = molecule ?? TriatomicMolecule();
    return ThreeAtomsModel._(
      m,
      preferences: preferences,
      viewProperties: viewProperties ?? ThreeAtomsViewProperties(),
    );
  }

  ThreeAtomsModel._(
    TriatomicMolecule super.molecule, {
    super.preferences,
    required this.viewProperties,
  });

  TriatomicMolecule get triatomic => molecule as TriatomicMolecule;

  final ThreeAtomsViewProperties viewProperties;

  @override
  void reset() {
    super.reset();
    molecule.reset();
    viewProperties.reset();
  }
}

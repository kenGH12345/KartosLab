import 'bam_atom.dart';

/// Bond between two atoms. Ported from Bond.ts.
class BamBond {
  BamBond(this.a, this.b) : assert(a != b, 'Bonds cannot connect an atom to itself');

  final BamAtom a;
  final BamAtom b;

  bool contains(BamAtom atom) => atom == a || atom == b;

  BamAtom other(BamAtom atom) {
    assert(contains(atom));
    return a == atom ? b : a;
  }

  /// Serial form used by MoleculeStructure.toSerial2 (index of other atom).
  String toSerial(int index) => '$index';
}

/// PubChem bond with order. Ported from PubChemBond in CompleteMolecule.ts.
class BamPubChemBond extends BamBond {
  BamPubChemBond(super.a, super.b, this.order);

  final int order;

  @override
  String toSerial(int index) => '$index-$order';
}

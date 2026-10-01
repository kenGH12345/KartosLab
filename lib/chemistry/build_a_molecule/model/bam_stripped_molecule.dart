import 'bam_atom.dart';
import 'bam_bond.dart';
import 'bam_molecule_structure.dart';

/// Molecule with hydrogens stripped, hydrogen counts retained.
/// Ported from StrippedMolecule.ts.
class BamStrippedMolecule {
  BamStrippedMolecule(BamMoleculeStructure original) {
    final atomsToAdd =
        original.atoms.where((atom) => !atom.isHydrogen()).toList();

    hydrogenCount = List<int>.filled(atomsToAdd.length, 0);

    final bondsToAdd = <BamBond>[];

    for (final bond in original.bonds) {
      final aIsHydrogen = bond.a.isHydrogen();
      final bIsHydrogen = bond.b.isHydrogen();

      if (!aIsHydrogen || !bIsHydrogen) {
        if (aIsHydrogen || bIsHydrogen) {
          final heavy = aIsHydrogen ? bond.b : bond.a;
          hydrogenCount[atomsToAdd.indexOf(heavy)]++;
        } else {
          bondsToAdd.add(bond);
        }
      }
    }

    stripped = BamMoleculeStructure(atomsToAdd.length, bondsToAdd.length);
    for (final atom in atomsToAdd) {
      stripped.addAtom(atom);
    }
    for (final bond in bondsToAdd) {
      stripped.addBond(bond);
    }
  }

  late final List<int> hydrogenCount;
  late final BamMoleculeStructure stripped;

  int _getIndex(BamAtom atom) {
    final index = stripped.atoms.indexOf(atom);
    assert(index != -1);
    return index;
  }

  int getHydrogenCount(BamAtom atom) => hydrogenCount[_getIndex(atom)];

  bool isEquivalent(BamStrippedMolecule other) {
    if (identical(this, other)) {
      return true;
    }
    if (stripped.atoms.isEmpty && other.stripped.atoms.isEmpty) {
      return true;
    }

    final myVisited = <BamAtom>[];
    final otherVisited = <BamAtom>[];
    final firstAtom = stripped.atoms[0];
    for (final otherAtom in other.stripped.atoms) {
      if (checkEquivalency(
          other, myVisited, otherVisited, firstAtom, otherAtom, false)) {
        return true;
      }
    }
    return false;
  }

  /// Whether [other] (with 0+ added hydrogens) matches this stripped molecule.
  bool isHydrogenSubmolecule(BamStrippedMolecule other) {
    if (identical(this, other)) {
      return true;
    }
    if (stripped.atoms.isEmpty) {
      return other.stripped.atoms.isEmpty;
    }

    final myVisited = <BamAtom>[];
    final otherVisited = <BamAtom>[];
    final firstAtom = stripped.atoms[0];
    for (final otherAtom in other.stripped.atoms) {
      if (checkEquivalency(
          other, myVisited, otherVisited, firstAtom, otherAtom, true)) {
        return true;
      }
    }
    return false;
  }

  /// Ported from StrippedMolecule.checkEquivalency including subCheck hydrogen rules.
  bool checkEquivalency(
    BamStrippedMolecule other,
    List<BamAtom> myVisited,
    List<BamAtom> otherVisited,
    BamAtom myAtom,
    BamAtom otherAtom,
    bool subCheck,
  ) {
    if (!myAtom.hasSameElement(otherAtom)) {
      return false;
    }

    if (!subCheck) {
      if (getHydrogenCount(myAtom) != other.getHydrogenCount(otherAtom)) {
        return false;
      }
    } else {
      if (getHydrogenCount(myAtom) < other.getHydrogenCount(otherAtom)) {
        return false;
      }
    }

    final myUnvisitedNeighbors =
        stripped.getNeighborsNotInSet(myAtom, myVisited);
    final otherUnvisitedNeighbors =
        other.stripped.getNeighborsNotInSet(otherAtom, otherVisited);
    if (myUnvisitedNeighbors.length != otherUnvisitedNeighbors.length) {
      return false;
    }
    if (myUnvisitedNeighbors.isEmpty) {
      return true;
    }
    final size = myUnvisitedNeighbors.length;

    myVisited.add(myAtom);
    otherVisited.add(otherAtom);

    final equivalences = List<bool>.filled(size * size, false);
    final availableIndices = <int>[];

    for (var myIndex = 0; myIndex < size; myIndex++) {
      availableIndices.add(myIndex);
      for (var otherIndex = 0; otherIndex < size; otherIndex++) {
        equivalences[myIndex * size + otherIndex] = checkEquivalency(
          other,
          myVisited,
          otherVisited,
          myUnvisitedNeighbors[myIndex],
          otherUnvisitedNeighbors[otherIndex],
          subCheck,
        );
      }
    }

    myVisited.removeLast();
    otherVisited.removeLast();

    return BamMoleculeStructure.checkEquivalencyMatrix(
      equivalences,
      0,
      availableIndices,
      size,
    );
  }

  BamStrippedMolecule getCopyWithAtomRemoved(BamAtom atom) {
    final result =
        BamStrippedMolecule(stripped.getCopyWithAtomRemoved(atom));
    for (final resultAtom in result.stripped.atoms) {
      result.hydrogenCount[result._getIndex(resultAtom)] =
          getHydrogenCount(resultAtom);
    }
    return result;
  }
}

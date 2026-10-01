import '../data/bam_element.dart';
import 'bam_atom.dart';
import 'bam_bond.dart';
import 'bam_element_histogram.dart';

int _nextMoleculeId = 0;

/// General molecular structure without play position.
/// Ported from MoleculeStructure.ts — algorithms must stay faithful.
class BamMoleculeStructure {
  BamMoleculeStructure([int? numAtoms, int? numBonds])
      : moleculeId = _nextMoleculeId++;

  final int moleculeId;
  final List<BamAtom> atoms = [];
  final List<BamBond> bonds = [];

  BamAtom addAtom(BamAtom atom) {
    assert(!atoms.contains(atom), 'Cannot add an already existing atom');
    atoms.add(atom);
    return atom;
  }

  void addBond(BamBond bond) {
    assert(atoms.contains(bond.a));
    assert(atoms.contains(bond.b));
    bonds.add(bond);
  }

  List<BamBond> getBondsInvolving(BamAtom atom) =>
      bonds.where((bond) => bond.contains(atom)).toList();

  List<BamAtom> getNeighbors(BamAtom atom) =>
      getBondsInvolving(atom).map((bond) => bond.other(atom)).toList();

  List<BamAtom> getNeighborsNotInSet(BamAtom atom, List<BamAtom> exclusionSet) =>
      getNeighbors(atom).where((other) => !exclusionSet.contains(other)).toList();

  BamBond getBond(BamAtom a, BamAtom b) {
    for (final bond in bonds) {
      if (bond.contains(a) && bond.contains(b)) {
        return bond;
      }
    }
    throw StateError('Could not find bond!');
  }

  BamElementHistogram getHistogram() => BamElementHistogram(this);

  bool containsElement(BamElement element) =>
      atoms.any((atom) => atom.element == element);

  bool isValid() => !hasWeirdHydrogenProperties() && !hasLoopsOrIsDisconnected();

  bool hasWeirdHydrogenProperties() {
    for (final atom in atoms) {
      if (atom.isHydrogen() && getNeighbors(atom).length > 1) {
        return true;
      }
    }
    return false;
  }

  /// Port of MoleculeStructure.hasLoopsOrIsDisconnected — BFS connectivity + loop detect.
  bool hasLoopsOrIsDisconnected() {
    if (atoms.isEmpty) {
      return false;
    }

    final visitedAtoms = <BamAtom>[];
    final dirtyAtoms = <BamAtom>[atoms[0]];

    while (dirtyAtoms.isNotEmpty) {
      final atom = dirtyAtoms.removeLast();

      var visitedCount = 0;
      for (final otherAtom in getNeighbors(atom)) {
        if (visitedAtoms.contains(otherAtom)) {
          visitedCount += 1;
        } else {
          dirtyAtoms.add(otherAtom);
        }
      }

      if (visitedCount > 1) {
        return true;
      }

      dirtyAtoms.removeWhere((item) => item == atom);
      visitedAtoms.add(atom);
    }

    return visitedAtoms.length != atoms.length;
  }

  BamMoleculeStructure copy() {
    final result = BamMoleculeStructure(atoms.length, bonds.length);
    for (final atom in atoms) {
      result.addAtom(atom);
    }
    for (final bond in bonds) {
      result.addBond(bond);
    }
    return result;
  }

  BamMoleculeStructure getCopyWithAtomRemoved(BamAtom atomToRemove) {
    final result = BamMoleculeStructure(atoms.length - 1, 12);
    for (final atom in atoms) {
      if (atom != atomToRemove) {
        result.addAtom(atom);
      }
    }
    for (final bond in bonds) {
      if (!bond.contains(atomToRemove)) {
        result.addBond(bond);
      }
    }
    return result;
  }

  /// Graph isomorphism check. Ported exactly from MoleculeStructure.isEquivalent.
  bool isEquivalent(BamMoleculeStructure other) {
    if (identical(this, other)) {
      return true;
    }
    if (atoms.length != other.atoms.length) {
      return false;
    }
    if (!getHistogram().equals(other.getHistogram())) {
      return false;
    }

    final myVisited = <BamAtom>[];
    final otherVisited = <BamAtom>[];
    final firstAtom = atoms[0];
    for (final otherAtom in other.atoms) {
      if (checkEquivalency(other, myVisited, otherVisited, firstAtom, otherAtom)) {
        return true;
      }
    }
    return false;
  }

  /// Ported from MoleculeStructure.checkEquivalency.
  bool checkEquivalency(
    BamMoleculeStructure other,
    List<BamAtom> myVisited,
    List<BamAtom> otherVisited,
    BamAtom myAtom,
    BamAtom otherAtom,
  ) {
    if (!myAtom.hasSameElement(otherAtom)) {
      return false;
    }
    final myUnvisitedNeighbors = getNeighborsNotInSet(myAtom, myVisited);
    final otherUnvisitedNeighbors =
        other.getNeighborsNotInSet(otherAtom, otherVisited);
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
        );
      }
    }

    myVisited.removeWhere((item) => item == myAtom);
    otherVisited.removeWhere((item) => item == otherAtom);

    return checkEquivalencyMatrix(equivalences, 0, availableIndices, size);
  }

  /// Ported from MoleculeStructure.checkEquivalencyMatrix (row-major).
  static bool checkEquivalencyMatrix(
    List<bool> equivalences,
    int myIndex,
    List<int> otherRemainingIndices,
    int size,
  ) {
    final arr = List<int>.from(otherRemainingIndices);
    for (var i = 0; i < arr.length; i++) {
      final otherIndex = arr[i];
      if (equivalences[myIndex * size + otherIndex]) {
        otherRemainingIndices.remove(otherIndex);

        final success = (myIndex == size - 1) ||
            checkEquivalencyMatrix(
              equivalences,
              myIndex + 1,
              otherRemainingIndices,
              size,
            );

        otherRemainingIndices.add(otherIndex);

        if (success) {
          return true;
        }
      }
    }
    return false;
  }

  List<BamElement> getElementList() =>
      atoms.map((atom) => atom.element).toList();

  /// Sum of atomic weights. Ported from MoleculeStructure.getApproximateMolecularWeight.
  double getApproximateMolecularWeight() =>
      atoms.fold<double>(0, (memo, atom) => memo + atom.atomicWeight);

  /// Hill-system formula fragment (plain text). Ported intent of getHillSystemFormulaFragment.
  String getHillSystemFormulaFragment() => hillOrderedSymbol(getElementList());

  static const Map<String, String> formulaExceptions = {
    'H3N': 'NH3',
    'CHN': 'HCN',
  };

  /// Ported from MoleculeStructure.getGeneralFormula (organic vs EN sort + exceptions).
  String getGeneralFormula() {
    final containsCarbon = atoms.any((a) => a.element.isCarbon());
    final containsHydrogen = atoms.any((a) => a.isHydrogen());
    final organic = containsCarbon && containsHydrogen;

    final list = List<BamElement>.from(getElementList());
    list.sort((a, b) {
      if (organic) {
        if (a.isCarbon() != b.isCarbon()) return a.isCarbon() ? -1 : 1;
        if (a.isHydrogen() != b.isHydrogen()) return a.isHydrogen() ? -1 : 1;
        return a.symbol.compareTo(b.symbol);
      }
      final ea = a.electronegativity ?? 999.0;
      final eb = b.electronegativity ?? 999.0;
      final cmp = ea.compareTo(eb);
      if (cmp != 0) return cmp;
      return a.symbol.compareTo(b.symbol);
    });

    final counts = <String, int>{};
    for (final e in list) {
      counts[e.symbol] = (counts[e.symbol] ?? 0) + 1;
    }
    // Preserve sort order of first occurrence.
    final ordered = <String>[];
    for (final e in list) {
      if (!ordered.contains(e.symbol)) ordered.add(e.symbol);
    }
    final buffer = StringBuffer();
    for (final symbol in ordered) {
      buffer.write(symbol);
      final n = counts[symbol]!;
      if (n > 1) buffer.write(n);
    }
    final formula = buffer.toString();
    return formulaExceptions[formula] ?? formula;
  }

  /// Plain-text formula with unicode subscripts (HTML subscripts in PhET).
  String getGeneralFormulaFragment() => toUnicodeSubscripts(getGeneralFormula());

  static String toUnicodeSubscripts(String formula) {
    const map = {
      '0': '₀',
      '1': '₁',
      '2': '₂',
      '3': '₃',
      '4': '₄',
      '5': '₅',
      '6': '₆',
      '7': '₇',
      '8': '₈',
      '9': '₉',
    };
    final out = StringBuffer();
    for (final ch in formula.split('')) {
      out.write(map[ch] ?? ch);
    }
    return out.toString();
  }

  static String hillOrderedSymbol(List<BamElement> elementList) {
    final counts = <String, int>{};
    for (final e in elementList) {
      counts[e.symbol] = (counts[e.symbol] ?? 0) + 1;
    }
    final hasCarbon = counts.containsKey('C');
    final symbols = counts.keys.toList();
    symbols.sort((a, b) {
      if (hasCarbon) {
        if (a == 'C') return -1;
        if (b == 'C') return 1;
        if (a == 'H') return -1;
        if (b == 'H') return 1;
      }
      return a.compareTo(b);
    });
    final buffer = StringBuffer();
    for (final symbol in symbols) {
      buffer.write(symbol);
      final n = counts[symbol]!;
      if (n > 1) {
        buffer.write(n);
      }
    }
    return buffer.toString();
  }

  String toSerial2() {
    final result = StringBuffer('${atoms.length}|${bonds.length}');
    for (var i = 0; i < atoms.length; i++) {
      result.write('|${atoms[i]}');
      result.write(_getBondSpecsForAtom(i));
    }
    return result.toString();
  }

  String _getBondSpecsForAtom(int atomIndex) {
    final atom = atoms[atomIndex];
    final bondSpecs = StringBuffer();
    for (final bond in bonds) {
      if (bond.contains(atom)) {
        final otherAtom = bond.other(atom);
        final index = atoms.indexOf(otherAtom);
        if (index < atomIndex) {
          bondSpecs.write(',${bond.toSerial(index)}');
        }
      }
    }
    return bondSpecs.toString();
  }

  static BamMoleculeStructure getCombinedMoleculeFromBond(
    BamMoleculeStructure molA,
    BamMoleculeStructure molB,
    BamAtom a,
    BamAtom b,
    BamMoleculeStructure result,
  ) {
    for (final atom in molA.atoms) {
      result.addAtom(atom);
    }
    for (final atom in molB.atoms) {
      result.addAtom(atom);
    }
    for (final bond in molA.bonds) {
      result.addBond(bond);
    }
    for (final bond in molB.bonds) {
      result.addBond(bond);
    }
    result.addBond(BamBond(a, b));
    return result;
  }

  /// Split a bond; remaining structures go into [molA]/[molB].
  /// Ported from MoleculeStructure.getMoleculesFromBrokenBond.
  static List<BamMoleculeStructure> getMoleculesFromBrokenBond(
    BamMoleculeStructure structure,
    BamBond bond,
    BamMoleculeStructure molA,
    BamMoleculeStructure molB,
  ) {
    final atomsInA = <BamAtom>[bond.a];
    final remainingAtoms = List<BamAtom>.from(structure.atoms)..remove(bond.a);
    final dirtyAtoms = <BamAtom>[bond.a];

    while (dirtyAtoms.isNotEmpty) {
      final atom = dirtyAtoms.removeLast();
      for (final otherBond in structure.bonds) {
        if (otherBond != bond && otherBond.contains(atom)) {
          final neighbor = otherBond.other(atom);
          if (remainingAtoms.contains(neighbor)) {
            remainingAtoms.remove(neighbor);
            dirtyAtoms.add(neighbor);
            atomsInA.add(neighbor);
          }
        }
      }
    }

    for (final atom in structure.atoms) {
      if (atomsInA.contains(atom)) {
        molA.addAtom(atom);
      } else {
        molB.addAtom(atom);
      }
    }

    for (final otherBond in structure.bonds) {
      if (otherBond != bond) {
        if (atomsInA.contains(otherBond.a)) {
          molA.addBond(otherBond);
        } else {
          molB.addBond(otherBond);
        }
      }
    }

    return [molA, molB];
  }

  static BamMoleculeStructure fromSerial2(
    String line,
    BamMoleculeStructure Function(int atomCount, int bondCount) moleculeGenerator,
    BamAtom Function(String atomString) atomParser,
    BamBond Function(
      String bondString,
      BamAtom connectedAtom,
      BamMoleculeStructure moleculeStructure,
    ) bondParser,
  ) {
    final tokens = line.split('|');
    var idx = 0;
    final atomCount = int.parse(tokens[idx++]);
    final bondCount = int.parse(tokens[idx++]);
    final molecule = moleculeGenerator(atomCount, bondCount);
    for (var i = 0; i < atomCount; i++) {
      final atomBondString = tokens[idx++];
      var subIdx = 0;
      final subTokens = atomBondString.split(',');
      final atom = atomParser(subTokens[subIdx++]);
      molecule.addAtom(atom);
      while (subIdx < subTokens.length) {
        final bond = bondParser(subTokens[subIdx++], atom, molecule);
        molecule.addBond(bond);
      }
    }
    return molecule;
  }

  static BamMoleculeStructure fromSerial2Basic(String line) {
    return fromSerial2(
      line,
      (atomCount, bondCount) => BamMoleculeStructure(atomCount, bondCount),
      defaultAtomParser,
      defaultBondParser,
    );
  }

  static BamAtom defaultAtomParser(String atomString) =>
      BamAtom(BamElement.getBySymbol(atomString));

  static BamBond defaultBondParser(
    String bondString,
    BamAtom connectedAtom,
    BamMoleculeStructure moleculeStructure,
  ) {
    return BamBond(
      connectedAtom,
      moleculeStructure.atoms[int.parse(bondString)],
    );
  }
}

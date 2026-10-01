import '../model/bam_atom.dart';
import '../model/bam_bond.dart';
import '../model/bam_molecule_structure.dart';
import 'bam_element.dart';

/// JS-compatible parseFloat for PubChem serial tokens (e.g. `2.8.0` → `2.8`).
double bamParseFloat(String s) {
  final trimmed = s.trim();
  final match = RegExp(r'^[+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?')
      .firstMatch(trimmed);
  if (match == null) {
    return double.nan;
  }
  return double.parse(match.group(0)!);
}

/// PubChem atom/bond parsers used by CompleteMolecule.fromSerial2.
/// Ported from CompleteMolecule.ts PubChemAtom / PubChemBond.
class BamSerialParser {
  BamSerialParser._();

  static BamPubChemAtom parse2d(String atomString) {
    final tokens = atomString.split(' ');
    final element = BamElement.getBySymbol(tokens[0]);
    final x2d = bamParseFloat(tokens[1]);
    final y2d = bamParseFloat(tokens[2]);
    return BamPubChemAtom(
      element,
      BamPubChemAtomType.twoDimension,
      x2d: x2d,
      y2d: y2d,
      x3d: x2d - BamPubChemAtom.offset,
      y3d: y2d,
      z3d: 0,
    );
  }

  static BamPubChemAtom parse3d(String atomString) {
    final tokens = atomString.split(' ');
    final element = BamElement.getBySymbol(tokens[0]);
    final x3d = bamParseFloat(tokens[1]);
    final y3d = bamParseFloat(tokens[2]);
    final z3d = bamParseFloat(tokens[3]);
    return BamPubChemAtom(
      element,
      BamPubChemAtomType.threeDimension,
      x2d: 0,
      y2d: 0,
      x3d: x3d,
      y3d: y3d,
      z3d: z3d,
    );
  }

  static BamPubChemAtom parseFull(String atomString) {
    final tokens = atomString.split(' ');
    final element = BamElement.getBySymbol(tokens[0]);
    final x2d = bamParseFloat(tokens[1]);
    final y2d = bamParseFloat(tokens[2]);
    final x3d = bamParseFloat(tokens[3]);
    final y3d = bamParseFloat(tokens[4]);
    final z3d = bamParseFloat(tokens[5]);
    return BamPubChemAtom(
      element,
      BamPubChemAtomType.full,
      x2d: x2d,
      y2d: y2d,
      x3d: x3d,
      y3d: y3d,
      z3d: z3d,
    );
  }

  static BamPubChemBond parseBond(
    String bondString,
    BamAtom connectedAtom,
    BamMoleculeStructure molecule,
  ) {
    final tokens = bondString.split('-');
    final index = int.parse(tokens[0]);
    final order = int.parse(tokens[1]);
    return BamPubChemBond(connectedAtom, molecule.atoms[index], order);
  }
}

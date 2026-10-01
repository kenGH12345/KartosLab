import '../data/bam_serial_parser.dart';
import '../data/bam_strings.dart';
import 'bam_atom.dart';
import 'bam_molecule_structure.dart';

/// Stable named molecule with PubChem metadata.
/// Ported from CompleteMolecule.ts.
class BamCompleteMolecule extends BamMoleculeStructure {
  BamCompleteMolecule(
    this.commonName,
    this.formula,
    int atomCount,
    int bondCount,
    this.has2d,
    this.has3d,
  ) : super(atomCount, bondCount);

  final String commonName;
  final String formula;
  int cid = 0;
  final bool has2d;
  final bool has3d;

  String get molecularFormula => formula;

  /// Strip leading "molecular " and capitalize words. Ported from filterCommonName.
  String filterCommonName() {
    var result = commonName;
    if (result.startsWith('molecular ')) {
      result = result.substring('molecular '.length);
    }
    return capitalize(result);
  }

  /// Localized display name when available in [BamStrings].
  String getDisplayName() {
    final camelCaseName = toCamelCase(commonName);
    final translated = BamStrings.lookup(camelCaseName);
    return translated ?? commonName;
  }

  @override
  String toSerial2() {
    final format = has3d ? (has2d ? 'full' : '3d') : '2d';
    return '$commonName|$formula|$cid|$format|${super.toSerial2()}';
  }

  static String capitalize(String str) {
    final characters = str.split('');
    var lastWasSpace = true;
    for (var i = 0; i < characters.length; i++) {
      final character = characters[i];
      if (RegExp(r'\s').hasMatch(character)) {
        lastWasSpace = true;
      } else {
        if (lastWasSpace && RegExp(r'[a-z]').hasMatch(character)) {
          characters[i] = character.toUpperCase();
        }
        lastWasSpace = false;
      }
    }
    return characters.join();
  }

  /// Convert "carbon dioxide" → "carbonDioxide" (lodash-like camelCase used by PhET).
  static String toCamelCase(String name) {
    return name.toLowerCase().replaceAllMapped(
      RegExp(r'[^a-zA-Z0-9]+(.)'),
      (m) => m.group(1)!.toUpperCase(),
    );
  }

  /// Ported from CompleteMolecule.fromSerial2.
  ///
  /// Format: `commonName|molecularFormula|cid|format|` then MoleculeStructure.fromSerial2
  /// with PubChemAtom.parseFull/2d/3d and PubChemBond.parse.
  static BamCompleteMolecule fromSerial2(String line) {
    final tokens = line.split('|');
    var idx = 0;
    final commonName = tokens[idx++];
    final molecularFormula = tokens[idx++];
    final cidString = tokens[idx++];
    final cid = int.parse(cidString);
    final format = tokens[idx++];

    final has2dAnd3d = format == 'full';
    final has2d = format == '2d' || has2dAnd3d;
    final has3d = format == '3d' || has2dAnd3d;
    final burnedLength = commonName.length +
        1 +
        molecularFormula.length +
        1 +
        cidString.length +
        1 +
        format.length +
        1;

    final BamAtom Function(String) atomParser = has3d
        ? (has2dAnd3d ? BamSerialParser.parseFull : BamSerialParser.parse3d)
        : BamSerialParser.parse2d;

    return BamMoleculeStructure.fromSerial2(
      line.substring(burnedLength),
      (atomCount, bondCount) {
        final molecule = BamCompleteMolecule(
          commonName,
          molecularFormula,
          atomCount,
          bondCount,
          has2d,
          has3d,
        );
        molecule.cid = cid;
        return molecule;
      },
      atomParser,
      BamSerialParser.parseBond,
    ) as BamCompleteMolecule;
  }
}

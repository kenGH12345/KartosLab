import '../data/bam_element.dart';
import 'bam_molecule_structure.dart';

/// Histogram of each supported element. Ported from ElementHistogram.ts.
class BamElementHistogram {
  BamElementHistogram(BamMoleculeStructure moleculeStructure) {
    for (final element in BamElement.supportedElements) {
      quantities[element.symbol] = 0;
    }
    addMolecule(moleculeStructure);
  }

  final Map<String, int> quantities = {};

  int getQuantity(BamElement element) => quantities[element.symbol] ?? 0;

  void addElement(BamElement element) {
    quantities[element.symbol] = getQuantity(element) + 1;
  }

  void addMolecule(BamMoleculeStructure molecule) {
    for (final atom in molecule.atoms) {
      addElement(atom.element);
    }
  }

  /// Unique hash for equivalent histograms. Format `_q_q_...` over SUPPORTED_ELEMENTS order.
  String getHashString() {
    final buffer = StringBuffer();
    for (final element in BamElement.supportedElements) {
      buffer.write('_${getQuantity(element)}');
    }
    return buffer.toString();
  }

  bool equals(BamElementHistogram other) {
    for (final element in BamElement.supportedElements) {
      if (getQuantity(element) != other.getQuantity(element)) {
        return false;
      }
    }
    return true;
  }
}

import 'dart:ui' show Rect;

import 'bam_box_feedback_state.dart';
import 'bam_complete_molecule.dart';
import 'bam_molecule.dart';
import 'bam_molecule_structure.dart';

/// Collection box for one molecule type. Ported from CollectionBox.ts.
class BamCollectionBox {
  BamCollectionBox(this.moleculeType, this.capacity);

  final BamCompleteMolecule moleculeType;
  final int capacity;
  final List<BamMolecule> molecules = [];
  int quantity = 0;

  /// Drop hit area in model coords (updated by view).
  Rect dropBounds = Rect.zero;

  /// Cue + blink feedback (model-owned; view only renders).
  final BamBoxFeedbackState feedback = BamBoxFeedbackState();

  /// Listeners for acceptedMoleculeCreationEmitter (KitCollection → View blink).
  final List<void Function(BamMolecule molecule)>
      acceptedMoleculeCreationListeners = [];

  bool get cueVisible => feedback.cueVisible;
  set cueVisible(bool value) => feedback.cueVisible = value;

  bool isFull() => capacity == quantity;

  /// Whether [moleculeStructure] may be dropped now.
  /// Uses CompleteMolecule.isEquivalent — not formula string compare.
  bool willAllowMoleculeDrop(BamMoleculeStructure moleculeStructure) {
    final equivalent = moleculeType.isEquivalent(moleculeStructure);
    return equivalent && quantity < capacity;
  }

  void addMolecule(BamMolecule molecule) {
    quantity++;
    molecules.add(molecule);
    // CollectionBoxNode.addMolecule → cancelBlinksInProgress
    feedback.cancelBlink();
  }

  void removeMolecule(BamMolecule molecule) {
    quantity--;
    molecules.remove(molecule);
    feedback.cancelBlink();
  }

  /// Emit acceptedMoleculeCreation (KitCollection when matching molecule appears).
  void emitAcceptedMoleculeCreation(BamMolecule molecule) {
    for (final listener in List.of(acceptedMoleculeCreationListeners)) {
      listener(molecule);
    }
  }

  void reset() {
    for (final m in List<BamMolecule>.from(molecules)) {
      removeMolecule(m);
    }
    feedback.reset();
  }
}

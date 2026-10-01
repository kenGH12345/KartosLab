import 'dart:ui' show Rect;

import 'bam_atom.dart';
import 'bam_collection_box.dart';
import 'bam_kit.dart';
import 'bam_molecule.dart';

int _collectionId = 0;

/// Kits + collection boxes for one collection page. Ported from KitCollection.ts.
class BamKitCollection {
  BamKitCollection({this.enableCues = false}) : id = _collectionId++;

  final int id;
  final bool enableCues;
  final List<BamKit> kits = [];
  final List<BamCollectionBox> collectionBoxes = [];

  /// Only show a blinking highlight once (KitCollection.hasBlinkedOnce).
  bool hasBlinkedOnce = false;
  bool allCollectionBoxesFilled = false;
  BamKit? currentKit;

  /// Fired when cue / blink-related model state changes (for ChangeNotifier).
  void Function()? onCueOrFeedbackChanged;

  void setCurrentKit(BamKit? kit) {
    if (currentKit != null) {
      currentKit!.active = false;
    }
    currentKit = kit;
    if (kit != null) {
      kit.active = true;
      if (enableCues) {
        for (final box in collectionBoxes) {
          box.cueVisible = false;
          for (final molecule in kit.molecules) {
            if (box.willAllowMoleculeDrop(molecule)) {
              box.cueVisible = true;
            }
          }
        }
        onCueOrFeedbackChanged?.call();
      }
    }
  }

  void addKit(BamKit kit, {bool triggerCue = false}) {
    kits.add(kit);

    kit.onMoleculeAdded = (_) {
      _onKitMoleculeAdded(kit, triggerCue: triggerCue);
    };
    kit.onMoleculeRemoved = (molecule) {
      _onKitMoleculeRemoved(kit, molecule, triggerCue: triggerCue);
    };

    if (currentKit == null) {
      setCurrentKit(kit);
    }
  }

  /// KitCollection.addedMoleculeEmitter listener body.
  void _onKitMoleculeAdded(BamKit kit, {required bool triggerCue}) {
    for (final box in collectionBoxes) {
      for (final molecule in kit.molecules) {
        if (box.willAllowMoleculeDrop(molecule) && triggerCue) {
          box.cueVisible = true;
          if (!hasBlinkedOnce) {
            box.emitAcceptedMoleculeCreation(molecule);
            hasBlinkedOnce = true;
          }
        }
      }
      if (box.isFull()) {
        box.cueVisible = false;
      }
    }
    onCueOrFeedbackChanged?.call();
  }

  /// KitCollection.removedMoleculeEmitter listener body.
  void _onKitMoleculeRemoved(
    BamKit kit,
    BamMolecule molecule, {
    required bool triggerCue,
  }) {
    for (final box in collectionBoxes) {
      if (box.willAllowMoleculeDrop(molecule) && triggerCue) {
        box.cueVisible = false;
      }
      for (final remaining in kit.molecules) {
        if (box.willAllowMoleculeDrop(remaining) && triggerCue) {
          box.cueVisible =
              box.willAllowMoleculeDrop(remaining) && triggerCue;
        }
        if (box.isFull()) {
          box.cueVisible = false;
        }
      }
    }
    onCueOrFeedbackChanged?.call();
  }

  void addCollectionBox(BamCollectionBox box) {
    collectionBoxes.add(box);
  }

  /// Wire acceptedMoleculeCreation → [onAccepted] for each box (idempotent).
  void wireAcceptedCreationListeners(
    void Function(BamCollectionBox box, BamMolecule molecule) onAccepted,
  ) {
    for (final box in collectionBoxes) {
      box.acceptedMoleculeCreationListeners
        ..clear()
        ..add((molecule) => onAccepted(box, molecule));
    }
  }

  /// Try drop of molecule containing [atom] into a collection box.
  bool tryDropIntoCollectionBox(BamPlayAtom atom) {
    final kit = currentKit;
    if (kit == null || !kit.isAtomInPlay(atom)) return false;
    final molecule = kit.getMolecule(atom);
    if (molecule == null) return false;

    for (final box in collectionBoxes) {
      if (box.dropBounds.overlaps(molecule.positionBounds) &&
          box.willAllowMoleculeDrop(molecule)) {
        kit.moleculePutInCollectionBox(molecule, box);
        _updateFilledFlag();
        return true;
      }
    }
    return false;
  }

  /// Collect molecule into first accepting box (tests / programmatic).
  bool tryCollectMolecule(BamMolecule molecule) {
    final kit = currentKit;
    if (kit == null) return false;
    for (final box in collectionBoxes) {
      if (box.willAllowMoleculeDrop(molecule)) {
        if (box.dropBounds == Rect.zero ||
            box.dropBounds.overlaps(molecule.positionBounds)) {
          kit.moleculePutInCollectionBox(molecule, box);
          _updateFilledFlag();
          return true;
        }
      }
    }
    return false;
  }

  void _updateFilledFlag() {
    if (collectionBoxes.isEmpty) {
      allCollectionBoxesFilled = false;
      return;
    }
    allCollectionBoxesFilled = collectionBoxes.every((b) => b.isFull());
  }

  void reset() {
    for (final box in collectionBoxes) {
      box.reset();
    }
    for (final kit in kits) {
      kit.reset();
    }
    hasBlinkedOnce = false;
    allCollectionBoxesFilled = false;
    onCueOrFeedbackChanged?.call();
  }

  void resetKitsAndBoxes() {
    for (final kit in kits) {
      kit.reset();
    }
    for (final box in collectionBoxes) {
      box.reset();
    }
    // PhET resetKitsAndBoxes does NOT clear hasBlinkedOnce.
    onCueOrFeedbackChanged?.call();
  }

  void selectNextKit() {
    if (kits.isEmpty || currentKit == null) return;
    final i = kits.indexOf(currentKit!);
    setCurrentKit(kits[(i + 1) % kits.length]);
  }

  void selectPreviousKit() {
    if (kits.isEmpty || currentKit == null) return;
    final i = kits.indexOf(currentKit!);
    setCurrentKit(kits[(i - 1 + kits.length) % kits.length]);
  }
}

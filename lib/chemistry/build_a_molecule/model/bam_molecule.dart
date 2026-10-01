import 'dart:ui' show Offset, Rect;

import 'bam_atom.dart';
import 'bam_molecule_structure.dart';

/// Playable molecule with position helpers. Ported from Molecule.ts.
class BamMolecule extends BamMoleculeStructure {
  BamMolecule([super.numAtoms, super.numBonds]);

  Rect get positionBounds {
    if (atoms.isEmpty) return Rect.zero;
    Rect? bounds;
    for (final atom in atoms) {
      final play = atom as BamPlayAtom;
      bounds = bounds == null
          ? play.positionBounds
          : bounds.expandToInclude(play.positionBounds);
    }
    return bounds!;
  }

  Rect get destinationBounds {
    if (atoms.isEmpty) return Rect.zero;
    Rect? bounds;
    for (final atom in atoms) {
      final play = atom as BamPlayAtom;
      bounds = bounds == null
          ? play.destinationBounds
          : bounds.expandToInclude(play.destinationBounds);
    }
    return bounds!;
  }

  void shiftDestination(Offset delta) {
    for (final atom in atoms) {
      final play = atom as BamPlayAtom;
      play.destination = play.destination + delta;
    }
  }

  void shiftPositionAndDestination(Offset delta) {
    for (final atom in atoms) {
      (atom as BamPlayAtom).translatePositionAndDestination(delta);
    }
  }
}

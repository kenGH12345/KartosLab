import '../rs_constants.dart';
import 'atom_space.dart';
import 'rutherford_atom.dart';
import 'rs_geometry.dart';

/// Atomic-scale space with 5 atoms — RutherfordAtomSpace.ts
class RutherfordAtomSpace extends AtomSpace {
  RutherfordAtomSpace({
    required RsBounds2 bounds,
    required int Function() protonCountGetter,
  }) : super(bounds: bounds, atomWidth: RsConstants.deflectionWidth) {
    final atomWidth = bounds.width / 2;
    final halfAtomWidth = atomWidth / 2;

    atoms.addAll([
      RutherfordAtom(
        space: this,
        protonCountGetter: protonCountGetter,
        position: RsVec2(-halfAtomWidth, halfAtomWidth),
        boundingWidth: RsConstants.deflectionWidth,
      ),
      RutherfordAtom(
        space: this,
        protonCountGetter: protonCountGetter,
        position: RsVec2(halfAtomWidth, halfAtomWidth),
        boundingWidth: RsConstants.deflectionWidth,
      ),
      RutherfordAtom(
        space: this,
        protonCountGetter: protonCountGetter,
        position: RsVec2(0, -halfAtomWidth),
        boundingWidth: RsConstants.deflectionWidth,
      ),
      RutherfordAtom(
        space: this,
        protonCountGetter: protonCountGetter,
        position: RsVec2(-atomWidth, -halfAtomWidth),
        boundingWidth: RsConstants.deflectionWidth,
      ),
      RutherfordAtom(
        space: this,
        protonCountGetter: protonCountGetter,
        position: RsVec2(atomWidth, -halfAtomWidth),
        boundingWidth: RsConstants.deflectionWidth,
      ),
    ]);
  }
}

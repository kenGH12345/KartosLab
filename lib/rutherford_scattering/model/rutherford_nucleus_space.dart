import 'atom_space.dart';
import 'rutherford_atom.dart';
import 'rs_geometry.dart';

/// Nuclear-scale space with one centered atom — RutherfordNucleusSpace.ts
///
/// Nucleus visual nucleons are view-layer; neutrons do not affect physics.
class RutherfordNucleusSpace extends AtomSpace {
  RutherfordNucleusSpace({
    required RsBounds2 bounds,
    required int Function() protonCountGetter,
  }) : super(bounds: bounds) {
    atoms.add(
      RutherfordAtom(
        space: this,
        protonCountGetter: protonCountGetter,
        position: RsVec2.zero,
        boundingWidth: bounds.width,
      ),
    );
  }
}

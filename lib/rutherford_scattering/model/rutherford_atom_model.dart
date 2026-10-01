import 'rs_base_model.dart';
import 'rutherford_atom_space.dart';
import 'rutherford_nucleus_space.dart';

enum RutherfordScene { atom, nucleus }

/// Rutherford Atom screen model — RutherfordAtomModel.ts
class RutherfordAtomModel extends RsBaseModel {
  RutherfordAtomModel() {
    atomSpace = RutherfordAtomSpace(
      bounds: bounds,
      protonCountGetter: () => protonCount,
    );
    nucleusSpace = RutherfordNucleusSpace(
      bounds: bounds,
      protonCountGetter: () => protonCount,
    );

    // Default visible: atomic scale
    atomSpace.isVisible = true;
    nucleusSpace.isVisible = false;

    atomSpaces.addAll([atomSpace, nucleusSpace]);
    wireSpace(atomSpace);
    wireSpace(nucleusSpace);
  }

  late final RutherfordAtomSpace atomSpace;
  late final RutherfordNucleusSpace nucleusSpace;

  RutherfordScene scene = RutherfordScene.atom;

  /// Switch Atomic ↔ Nuclear. PhET clears all particles on change.
  void setScene(RutherfordScene value) {
    if (scene == value) return;
    scene = value;
    final nucleusVisible = scene == RutherfordScene.nucleus;
    nucleusSpace.isVisible = nucleusVisible;
    atomSpace.isVisible = !nucleusVisible;
    removeAllParticles();
    notifyChanged();
  }

  @override
  void reset() {
    scene = RutherfordScene.atom;
    atomSpace.isVisible = true;
    nucleusSpace.isVisible = false;
    super.reset();
  }
}

import 'dart:math' as math;

import 'molecule.dart';
import 'pair_group.dart';
import 'real_molecule.dart';
import 'real_molecule_rebuild.dart';
import 'real_molecule_shape.dart';
import 'vec3.dart';

/// Sim preference from `MoleculeShapesGlobals.showOuterLonePairsProperty`.
///
/// Screen reset does not clear this. Outer lone pairs also require
/// Show Lone Pairs (`DerivedProperty.and` in source).
class MoleculeShapesPreferences {
  bool showOuterLonePairs = false;
}

/// Shared screen model: display toggles, view quaternion, one molecule.
class MoleculeShapesModel {
  MoleculeShapesModel({
    required Molecule initialMolecule,
    MoleculeShapesPreferences? preferences,
  })  : molecule = initialMolecule,
        preferences = preferences ?? MoleculeShapesPreferences();

  Molecule molecule;
  final MoleculeShapesPreferences preferences;

  bool showBondAngles = false;
  bool showLonePairs = true;
  bool showMoleculeGeometry = false;
  bool showElectronGeometry = false;

  /// View orientation. Local pair-group positions stay in the molecule frame.
  Quat quaternion = Quat.identity;

  bool get showOuterLonePairs => showLonePairs && preferences.showOuterLonePairs;

  String get moleculeGeometryLabel => molecule.centralConfiguration.molecule.label;

  String get electronGeometryLabel => molecule.centralConfiguration.electron.label;

  String get moleculeGeometryId => molecule.centralConfiguration.molecule.id;

  String get electronGeometryId => molecule.centralConfiguration.electron.id;

  /// World-space position after the view quaternion. Local [group.position] is unchanged.
  Vec3 worldPosition(PairGroup group) => quaternion.rotate(group.position);

  /// `MoleculeShapesScreenView` drag: left-multiply an XYZ euler increment.
  void rotateByPointer(double deltaX, double deltaY, {double activeScale = 1}) {
    final scale = 0.007 / activeScale;
    final delta = Quat.fromEulerXyz(deltaY * scale, deltaX * scale, 0);
    quaternion = delta.multiplied(quaternion);
  }

  /// Caps dt at 0.2s like `MoleculeShapesModel.step`.
  void step(double dt) {
    molecule.update(math.min(dt, 0.2));
  }

  void resetViewOptions() {
    showBondAngles = false;
    showLonePairs = true;
    showMoleculeGeometry = false;
    showElectronGeometry = false;
    quaternion = Quat.identity;
  }
}

/// Model screen. Starts with a central atom and two single bonds.
class ModelMoleculesModel extends MoleculeShapesModel {
  ModelMoleculesModel() : super(initialMolecule: _bareCentral()) {
    _setupInitialMoleculeState();
  }

  static VseprMolecule _bareCentral() {
    final molecule = VseprMolecule();
    molecule.addCentralAtom(PairGroup(position: Vec3.zero, isLonePair: false));
    return molecule;
  }

  VseprMolecule get vsepr => molecule as VseprMolecule;

  void _setupInitialMoleculeState() {
    final center = molecule.centralAtom!;
    molecule.addGroupAndBond(
      PairGroup(
        position: const Vec3(8, 0, 3).withMagnitude(PairGroup.bondedPairDistance),
        isLonePair: false,
      ),
      center,
      1,
      PairGroup.bondedPairDistance,
    );
    molecule.addGroupAndBond(
      PairGroup(
        position: const Vec3(2, 8, -5).withMagnitude(PairGroup.bondedPairDistance),
        isLonePair: false,
      ),
      center,
      1,
      PairGroup.bondedPairDistance,
    );
  }

  /// Button enablement: domain cap, and lone pairs also need Show Lone Pairs.
  bool canAddPairGroup(int bondOrder) {
    if (!molecule.wouldAllowBondOrder(bondOrder)) {
      return false;
    }
    if (bondOrder == 0 && !showLonePairs) {
      return false;
    }
    return true;
  }

  bool addPairGroup(int bondOrder, {Vec3? position}) {
    if (!canAddPairGroup(bondOrder)) {
      return false;
    }
    final lonePair = bondOrder == 0;
    final distance = lonePair ? PairGroup.lonePairDistance : PairGroup.bondedPairDistance;
    final start = position ?? Vec3(distance, 0, 0);
    molecule.addGroupAndBond(
      PairGroup(position: start.withMagnitude(distance), isLonePair: lonePair),
      molecule.centralAtom!,
      bondOrder,
      distance,
    );
    return true;
  }

  /// Deletes the last matching bond order, scanning from the end like the view.
  bool removePairGroup(int bondOrder) {
    final center = molecule.centralAtom!;
    final bonds = molecule.bondsAround(center);
    for (var i = bonds.length - 1; i >= 0; i--) {
      if (bonds[i].order == bondOrder) {
        molecule.removeGroup(bonds[i].other(center));
        return true;
      }
    }
    return false;
  }

  void removeAll() => molecule.removeAllGroups();

  void reset() {
    resetViewOptions();
    molecule.removeAllGroups();
    _setupInitialMoleculeState();
  }
}

/// Real Molecules screen. Default molecule is the first `TAB_2` entry (H2O), Real view.
class RealMoleculesModel extends MoleculeShapesModel {
  RealMoleculesModel({super.preferences})
      : shape = tab2Molecules.first,
        showRealView = true,
        super(initialMolecule: RealMolecule(tab2Molecules.first));

  RealMoleculeShape shape;
  bool showRealView;

  void selectMolecule(RealMoleculeShape next) {
    if (identical(next, shape)) {
      return;
    }
    shape = next;
    quaternion = Quat.identity;
    _rebuild(switchedRealMolecule: true);
  }

  void setShowRealView(bool real) {
    if (real == showRealView) {
      return;
    }
    showRealView = real;
    _rebuild(switchedRealMolecule: false);
  }

  void _rebuild({required bool switchedRealMolecule}) {
    molecule = rebuildRealMoleculesView(
      shape: shape,
      showRealView: showRealView,
      previous: molecule,
      switchedRealMolecule: switchedRealMolecule,
    );
  }

  void reset() {
    resetViewOptions();
    shape = tab2Molecules.first;
    showRealView = true;
    _rebuild(switchedRealMolecule: true);
  }
}

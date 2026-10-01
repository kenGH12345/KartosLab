import 'attractor_model.dart';
import 'molecule.dart';
import 'pair_group.dart';
import 'real_molecule.dart';
import 'real_molecule_shape.dart';
import 'geometry.dart';
import 'vec3.dart';

/// Rebuild Real / Model half with optional Attractor orientation match.
///
/// Port of `RealMoleculesModel.rebuildMolecule(switchedRealMolecule)`.
/// When [switchedRealMolecule] is false, the new molecule's radial frames are
/// rotated to best-match the previous molecule — coordinates stay Real vs
/// Model separate; only a rigid rotation is applied.
Molecule rebuildRealMoleculesView({
  required RealMoleculeShape shape,
  required bool showRealView,
  required Molecule previous,
  required bool switchedRealMolecule,
}) {
  final numRadialAtoms = shape.bonds.length;
  final numRadialLonePairs = shape.central.lonePairCount;
  final vseprConfiguration = VseprConfiguration.get(numRadialAtoms, numRadialLonePairs);

  final Molecule mappingMolecule =
      switchedRealMolecule ? RealMolecule(shape) : previous;

  if (showRealView) {
    final newMolecule = RealMolecule(shape);
    if (!switchedRealMolecule) {
      final idealGroups = RealMolecule(shape).radialGroups;
      final mapping = AttractorModel.findClosestMatchingConfiguration(
        currentOrientations:
            AttractorModel.orientationsFromOrigin(mappingMolecule.radialGroups),
        idealOrientations:
            idealGroups.map((group) => group.orientation).toList(),
        allowablePermutations:
            AttractorModel.vseprPermutations(mappingMolecule.radialGroups),
      );
      for (final group in newMolecule.groups) {
        if (group == newMolecule.centralAtom) {
          continue;
        }
        group.position = mapping.rotateVector(group.position);
      }
    }
    if (!switchedRealMolecule) {
      newMolecule.lastMidpoint = previous.lastMidpoint;
    }
    return newMolecule;
  }

  final mapping =
      vseprConfiguration.getIdealGroupRotationToPositions(mappingMolecule.radialGroups);
  final permutation = mapping.permutation.inverted();
  final idealUnitVectors = vseprConfiguration.allOrientations;

  final newMolecule = VseprMolecule();
  final newCentral = PairGroup(position: Vec3.zero, isLonePair: false, element: shape.central.symbol);
  newMolecule.addCentralAtom(newCentral);

  for (var i = 0; i < numRadialAtoms + numRadialLonePairs; i++) {
    final unitVector = mapping.rotateVector(idealUnitVectors[i]);
    if (i < numRadialLonePairs) {
      newMolecule.addGroupAndBond(
        PairGroup(
          position: unitVector.times(PairGroup.lonePairDistance),
          isLonePair: true,
        ),
        newCentral,
        0,
        PairGroup.lonePairDistance,
      );
    } else {
      final oldRadialGroup = mappingMolecule
          .radialAtoms[permutation.apply(i) - numRadialLonePairs];
      final bond = mappingMolecule.parentBond(oldRadialGroup)!;
      final group = PairGroup(
        position: unitVector.times(bond.length),
        isLonePair: false,
        element: oldRadialGroup.element ??
            shape.bonds[i - numRadialLonePairs].other(shape.central).symbol,
      );
      newMolecule.addGroupAndBond(group, newCentral, bond.order, bond.length);
      final terminalLonePairs = mappingMolecule
          .neighbors(oldRadialGroup)
          .where((g) => g.isLonePair)
          .length;
      newMolecule.addTerminalLonePairs(group, terminalLonePairs);
    }
  }

  if (!switchedRealMolecule) {
    newMolecule.lastMidpoint = previous.lastMidpoint;
  }
  return newMolecule;
}

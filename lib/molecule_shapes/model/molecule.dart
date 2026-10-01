import 'dart:math' as math;

import 'attractor_model.dart';
import 'bond.dart';
import 'geometry.dart';
import 'pair_group.dart';
import 'vec3.dart';

/// Angle between two radial atoms, in degrees, from their current orientations.
class BondAngleReading {
  BondAngleReading(this.a, this.b, this.degrees);

  final PairGroup a;
  final PairGroup b;
  final double degrees;

  String get label => formatBondAngleDegrees(degrees);
}

/// `Molecule.js`. Star-shaped around one central atom.
class Molecule {
  Molecule({required this.isReal});

  final bool isReal;

  /// Same default as `?maxConnections=6`. Instance-scoped so tests do not leak.
  int maxConnections = 6;

  final List<PairGroup> groups = [];
  final List<Bond> bonds = [];
  final List<PairGroup> atoms = [];
  final List<PairGroup> lonePairs = [];
  final List<PairGroup> radialGroups = [];
  final List<PairGroup> radialAtoms = [];
  final List<PairGroup> radialLonePairs = [];

  PairGroup? centralAtom;
  Vec3? lastMidpoint;

  int get bondedDomainCount => radialAtoms.length;

  int get lonePairDomainCount => radialLonePairs.length;

  int get domainCount => radialGroups.length;

  VseprConfiguration get centralConfiguration => VseprConfiguration.get(
        radialAtoms.length,
        radialLonePairs.length,
      );

  void addCentralAtom(PairGroup group) {
    centralAtom = group;
    group.isCentralAtom = true;
    _addGroup(group);
  }

  /// [bondOrder] 0 is a lone pair. [bondLength] defaults to the current separation.
  void addGroupAndBond(
    PairGroup group,
    PairGroup parent,
    int bondOrder, [
    double? bondLength,
  ]) {
    _addGroup(group);
    final length = bondLength ?? group.position.minus(parent.position).magnitude;
    _addBond(Bond(group, parent, bondOrder, length));
  }

  void _addGroup(PairGroup group) {
    assert(centralAtom != null);
    _insert(groups, group, group.isLonePair);
    if (group.isLonePair) {
      _insert(lonePairs, group, true);
    } else {
      atoms.add(group);
    }
  }

  void _addBond(Bond bond) {
    final lonePairBond = bond.order == 0;
    _insert(bonds, bond, lonePairBond);
    final center = centralAtom;
    if (center != null && bond.contains(center)) {
      final group = bond.other(center);
      _insert(radialGroups, group, lonePairBond);
      if (group.isLonePair) {
        _insert(radialLonePairs, group, true);
      } else {
        radialAtoms.add(group);
      }
    }
  }

  void _removeBond(Bond bond) {
    bonds.remove(bond);
    final center = centralAtom;
    if (center != null && bond.contains(center)) {
      final group = bond.other(center);
      radialGroups.remove(group);
      if (group.isLonePair) {
        radialLonePairs.remove(group);
      } else {
        radialAtoms.remove(group);
      }
    }
  }

  /// Removes [group] and the bonds touching it. Does not remove neighboring groups.
  void removeGroup(PairGroup group) {
    assert(group != centralAtom);
    final attached = bondsAround(group).toList();
    for (final bond in attached) {
      _removeBond(bond);
    }
    groups.remove(group);
    if (group.isLonePair) {
      lonePairs.remove(group);
    } else {
      atoms.remove(group);
    }
  }

  /// Drops every pair group except the central atom.
  void removeAllGroups() {
    final copy = groups.toList();
    for (final group in copy) {
      if (group != centralAtom) {
        removeGroup(group);
      }
    }
  }

  List<Bond> bondsAround(PairGroup group) =>
      bonds.where((bond) => bond.contains(group)).toList();

  List<PairGroup> neighbors(PairGroup group) =>
      bondsAround(group).map((bond) => bond.other(group)).toList();

  Bond? parentBond(PairGroup group) {
    if (group.isLonePair) {
      final around = bondsAround(group);
      return around.isEmpty ? null : around.first;
    }
    final center = centralAtom;
    for (final bond in bondsAround(group)) {
      if (bond.other(group) == center) {
        return bond;
      }
    }
    return null;
  }

  /// `wouldAllowBondOrder`: order is ignored. Only the domain cap matters.
  bool wouldAllowBondOrder(int bondOrder) => radialGroups.length < maxConnections;

  /// Lone pairs not attached to the central atom (outer / terminal).
  List<PairGroup> get distantLonePairs {
    final close = radialLonePairs.toSet();
    return lonePairs.where((pair) => !close.contains(pair)).toList();
  }

  /// Puts radial groups on `VSEPRConfiguration` slots (lone pairs first).
  ///
  /// This is the attractor's target at identity rotation, not a separate angle table.
  void placeRadialGroupsAtIdealSlots() {
    final config = centralConfiguration;
    final vectors = config.allOrientations;
    final lone = radialLonePairs.toList();
    final bonded = radialAtoms.toList();
    for (var i = 0; i < lone.length; i++) {
      lone[i].dragToPosition(vectors[i].times(PairGroup.lonePairDistance));
    }
    for (var i = 0; i < bonded.length; i++) {
      final bond = parentBond(bonded[i]);
      final length = bond?.length ?? PairGroup.bondedPairDistance;
      bonded[i].dragToPosition(vectors[lone.length + i].times(length));
    }
  }

  /// Base integrator: step + distance springs. Subclasses add repulsion.
  void update(double dt) {
    for (final group in groups) {
      if (group == centralAtom) {
        continue;
      }
      final bond = parentBond(group);
      if (bond == null) {
        continue;
      }
      final parent = bond.other(group);
      final oldDistance = group.position.distance(parent.position);
      group.stepForward(dt);
      group.attractToIdealDistance(dt, oldDistance, bond);
    }
  }

  /// Local VSEPR shape for attraction around [atom].
  ({List<PairGroup> groups, List<Vec3> ideals, List<Permutation> permutations})
      localVsepr(PairGroup atom) {
    final neighbors = this.neighbors(atom);
    var lone = 0;
    for (final group in neighbors) {
      if (group.isLonePair) {
        lone++;
      }
    }
    final atoms = neighbors.length - lone;
    return (
      groups: neighbors,
      ideals: VseprConfiguration.get(atoms, lone).electron.unitVectors,
      permutations: AttractorModel.vseprPermutations(neighbors),
    );
  }

  double applyAttraction(PairGroup atom, double dt) {
    final local = localVsepr(atom);
    return AttractorModel.applyAttractorForces(
      groups: local.groups,
      dt: dt,
      idealOrientations: local.ideals,
      allowablePermutations: local.permutations,
      center: atom.position,
    );
  }

  /// Every pair of radial atoms. Lone pairs are not bond-angle endpoints.
  List<BondAngleReading> bondAngles() {
    final atoms = radialAtoms;
    final readings = <BondAngleReading>[];
    for (var i = 0; i < atoms.length; i++) {
      for (var j = i + 1; j < atoms.length; j++) {
        final degrees = angleDegreesBetween(atoms[i].orientation, atoms[j].orientation);
        readings.add(BondAngleReading(atoms[i], atoms[j], degrees));
      }
    }
    return readings;
  }

  /// `Molecule.addTerminalLonePairs`.
  void addTerminalLonePairs(PairGroup atom, int quantity) {
    if (quantity <= 0) {
      return;
    }
    final orientations =
        VseprConfiguration.get(1, quantity).electron.unitVectors;
    final rotation = Quat.rotateAToB(
      orientations.last.negated(),
      atom.orientation,
    );
    for (var i = 0; i < quantity; i++) {
      final direction = rotation.rotate(orientations[i]);
      addGroupAndBond(
        PairGroup(
          position: atom.position.plus(direction.times(PairGroup.lonePairDistance)),
          isLonePair: true,
        ),
        atom,
        0,
        PairGroup.lonePairDistance,
      );
    }
  }

  static void _insert<T>(List<T> list, T item, bool atFront) {
    if (atFront) {
      list.insert(0, item);
    } else {
      list.add(item);
    }
  }
}

/// Model-screen molecule. Bond orders are not distinguished by the repeller.
class VseprMolecule extends Molecule {
  VseprMolecule() : super(isReal: false);

  double? bondLengthOverride;

  @override
  void update(double dt) {
    super.update(dt);
    final radial = radialGroups;
    for (final atom in atoms) {
      if (neighbors(atom).length <= 1) {
        continue;
      }
      if (atom.isCentralAtom) {
        final error = applyAttraction(atom, dt);
        final trueLengthsRatioOverride =
            math.max(0.0, math.min(1.0, math.log(error + 1) - 0.5));
        for (final group in radial) {
          for (final other in radial) {
            if (other != group && group != centralAtom) {
              group.repulseFrom(other, dt, trueLengthsRatioOverride);
            }
          }
        }
      } else {
        final local = localVsepr(atom);
        AttractorModel.applyAttractorForces(
          groups: local.groups,
          dt: dt,
          idealOrientations: local.ideals,
          allowablePermutations: local.permutations,
          center: atom.position,
          angleRepulsion: true,
        );
      }
    }
  }

  double get maximumBondLength =>
      bondLengthOverride ?? PairGroup.bondedPairDistance;
}

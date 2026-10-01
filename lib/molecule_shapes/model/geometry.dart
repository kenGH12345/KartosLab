import 'dart:math' as math;

import 'attractor_model.dart';
import 'pair_group.dart';
import 'vec3.dart';

/// `ElectronGeometry.js`. Unit vectors are ordered so lone pairs fill the
/// earlier, higher-repulsion slots.
class ElectronGeometry {
  const ElectronGeometry(this.id, this.label, this.unitVectors);

  final String id;
  final String label;
  final List<Vec3> unitVectors;

  static final empty = ElectronGeometry('EMPTY', '', const []);

  static final diatomic = ElectronGeometry('DIATOMIC', 'Linear', const [
    Vec3(1, 0, 0),
  ]);

  static final linear = ElectronGeometry('LINEAR', 'Linear', const [
    Vec3(1, 0, 0),
    Vec3(-1, 0, 0),
  ]);

  static final trigonalPlanar = ElectronGeometry(
    'TRIGONAL_PLANAR',
    'Trigonal Planar',
    [
      const Vec3(1, 0, 0),
      Vec3(math.cos(math.pi * 2 / 3), math.sin(math.pi * 2 / 3), 0),
      Vec3(math.cos(math.pi * 4 / 3), math.sin(math.pi * 4 / 3), 0),
    ],
  );

  static final tetrahedral = _tetrahedral();

  static final trigonalBipyramidal = ElectronGeometry(
    'TRIGONAL_BIPYRAMIDAL',
    'Trigonal Bipyramidal',
    [
      const Vec3(0, 1, 0),
      Vec3(0, math.cos(math.pi * 2 / 3), math.sin(math.pi * 2 / 3)),
      Vec3(0, math.cos(math.pi * 4 / 3), math.sin(math.pi * 4 / 3)),
      const Vec3(1, 0, 0),
      const Vec3(-1, 0, 0),
    ],
  );

  static final octahedral = ElectronGeometry(
    'OCTAHEDRAL',
    'Octahedral',
    const [
      Vec3(0, 0, 1),
      Vec3(0, 0, -1),
      Vec3(0, 1, 0),
      Vec3(0, -1, 0),
      Vec3(1, 0, 0),
      Vec3(-1, 0, 0),
    ],
  );

  static final Map<int, ElectronGeometry> byNumberOfGroups = {
    0: empty,
    1: diatomic,
    2: linear,
    3: trigonalPlanar,
    4: tetrahedral,
    5: trigonalBipyramidal,
    6: octahedral,
  };

  static ElectronGeometry byGroupCount(int numberOfGroups) {
    final geometry = byNumberOfGroups[numberOfGroups];
    if (geometry == null) {
      throw StateError('unknown electron geometry for $numberOfGroups groups');
    }
    return geometry;
  }

  static ElectronGeometry _tetrahedral() {
    // ElectronGeometry.js: TETRA_CONST = PI * -19.471220333 / 180
    const tetra = math.pi * -19.471220333 / 180;
    Vec3 at(double theta) => Vec3(
          math.cos(theta) * math.cos(tetra),
          math.sin(theta) * math.cos(tetra),
          math.sin(tetra),
        );
    return ElectronGeometry('TETRAHEDRAL', 'Tetrahedral', [
      const Vec3(0, 0, 1),
      at(0),
      at(math.pi * 2 / 3),
      at(math.pi * 4 / 3),
    ]);
  }
}

/// `MoleculeGeometry.js` name for the bonded-atom arrangement.
class MoleculeGeometry {
  const MoleculeGeometry(this.id, this.label, this.x);

  final String id;
  final String label;
  final int x;

  static const empty = MoleculeGeometry('EMPTY', '', 0);
  static const diatomic = MoleculeGeometry('DIATOMIC', 'Linear', 1);
  static const linear = MoleculeGeometry('LINEAR', 'Linear', 2);
  static const bent = MoleculeGeometry('BENT', 'Bent', 2);
  static const trigonalPlanar =
      MoleculeGeometry('TRIGONAL_PLANAR', 'Trigonal Planar', 3);
  static const trigonalPyramidal =
      MoleculeGeometry('TRIGONAL_PYRAMIDAL', 'Trigonal Pyramidal', 3);
  static const tShaped = MoleculeGeometry('T_SHAPED', 'T-shaped', 3);
  static const tetrahedral = MoleculeGeometry('TETRAHEDRAL', 'Tetrahedral', 4);
  static const seesaw = MoleculeGeometry('SEESAW', 'Seesaw', 4);
  static const squarePlanar =
      MoleculeGeometry('SQUARE_PLANAR', 'Square Planar', 4);
  static const trigonalBipyramidal = MoleculeGeometry(
    'TRIGONAL_BIPYRAMIDAL',
    'Trigonal Bipyramidal',
    5,
  );
  static const squarePyramidal =
      MoleculeGeometry('SQUARE_PYRAMIDAL', 'Square Pyramidal', 5);
  static const octahedral = MoleculeGeometry('OCTAHEDRAL', 'Octahedral', 6);

  /// Direct port of `MoleculeGeometry.getConfiguration`.
  static MoleculeGeometry configuration(int x, int e) {
    if (x == 0) {
      return empty;
    } else if (x == 1) {
      return diatomic;
    } else if (x == 2) {
      if (e == 0 || e == 3 || e == 4) {
        return linear;
      } else if (e == 1 || e == 2) {
        return bent;
      }
    } else if (x == 3) {
      if (e == 0) {
        return trigonalPlanar;
      } else if (e == 1) {
        return trigonalPyramidal;
      } else if (e == 2 || e == 3) {
        return tShaped;
      }
    } else if (x == 4) {
      if (e == 0) {
        return tetrahedral;
      } else if (e == 1) {
        return seesaw;
      } else if (e == 2) {
        return squarePlanar;
      }
    } else if (x == 5) {
      if (e == 0) {
        return trigonalBipyramidal;
      } else if (e == 1) {
        return squarePyramidal;
      }
    } else if (x == 6) {
      if (e == 0) {
        return octahedral;
      }
    } else {
      throw StateError('unknown VSEPR configuration x: $x, e: $e');
    }
    throw StateError('invalid x: $x, e: $e');
  }
}

/// `VSEPRConfiguration`: lone pairs take the first [e] electron-geometry slots.
class VseprConfiguration {
  VseprConfiguration(this.x, this.e)
      : molecule = MoleculeGeometry.configuration(x, e),
        electron = ElectronGeometry.byGroupCount(x + e) {
    final vectors = electron.unitVectors;
    for (var i = 0; i < x + e; i++) {
      if (i < e) {
        lonePairOrientations.add(vectors[i]);
      } else {
        bondOrientations.add(vectors[i]);
      }
    }
  }

  static final Map<String, VseprConfiguration> _cache = {};

  final int x;
  final int e;
  final MoleculeGeometry molecule;
  final ElectronGeometry electron;
  final List<Vec3> bondOrientations = [];
  final List<Vec3> lonePairOrientations = [];

  List<Vec3> get allOrientations => electron.unitVectors;

  static VseprConfiguration get(int x, int e) {
    final key = '$x,$e';
    return _cache.putIfAbsent(key, () => VseprConfiguration(x, e));
  }

  /// `VSEPRConfiguration.getIdealGroupRotationToPositions` — Kabsch match of
  /// [groups] onto electron-geometry slots (bond↔bond, lone↔lone permutations).
  AttractorMapping getIdealGroupRotationToPositions(List<PairGroup> groups) {
    assert((x + e) == groups.length);
    return AttractorModel.findClosestMatchingConfiguration(
      currentOrientations: AttractorModel.orientationsFromOrigin(groups),
      idealOrientations: electron.unitVectors,
      allowablePermutations: AttractorModel.vseprPermutations(groups),
    );
  }
}

/// `BondAngleView` label: `toFixed(angle, 1)` plus `°`, then pad to 5 chars.
String formatBondAngleDegrees(double degrees) {
  var label = '${degrees.toStringAsFixed(1)}°';
  while (label.length < 5) {
    label = '0$label';
  }
  return label;
}

double angleDegreesBetween(Vec3 a, Vec3 b) {
  final dot = a.normalized().dot(b.normalized()).clamp(-1.0, 1.0);
  return math.acos(dot) * 180 / math.pi;
}

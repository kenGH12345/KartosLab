import 'dart:math' as math;

import 'vec3.dart';

/// Atom in a `RealMoleculeShape`, before it becomes a [PairGroup].
class RealAtomPosition {
  RealAtomPosition(this.symbol, this.position, {this.lonePairCount = 0});

  final String symbol;
  Vec3 position;
  final int lonePairCount;

  Vec3 get orientation =>
      position.magnitude > 0 ? position.normalized() : Vec3.zero;
}

class ShapeBond {
  ShapeBond(this.a, this.b, this.order, this.length);

  final RealAtomPosition a;
  final RealAtomPosition b;
  final int order;
  final double length;

  RealAtomPosition other(RealAtomPosition atom) => a == atom ? b : a;
}

/// `RealMoleculeShape.js`. Radial bond lengths are rewritten to
/// `angstromOverride * 5.5` when [useSimplifiedBondLength] is true.
class RealMoleculeShape {
  RealMoleculeShape(this.displayName, double angstromOverride)
      : bondLengthOverride = angstromOverride * 5.5;

  static const useSimplifiedBondLength = true;

  final String displayName;
  final double bondLengthOverride;
  final List<RealAtomPosition> atoms = [];
  final List<ShapeBond> bonds = [];
  RealAtomPosition? centralAtom;
  int centralAtomCount = 0;

  RealAtomPosition get central {
    final atom = centralAtom;
    if (atom == null) {
      throw StateError('$displayName has no central atom');
    }
    return atom;
  }

  void addAtom(RealAtomPosition atom) {
    atoms.add(atom);
  }

  void addCentralAtom(RealAtomPosition atom) {
    addAtom(atom);
    centralAtom = atom;
  }

  void addBond(RealAtomPosition a, RealAtomPosition b, int order, double bondLength) {
    bonds.add(ShapeBond(a, b, order, bondLength));
    if (a == centralAtom || b == centralAtom) {
      centralAtomCount++;
    }
  }

  void addRadialAtom(RealAtomPosition atom, int bondOrder) {
    if (useSimplifiedBondLength) {
      atom.position = atom.position.normalized().times(bondLengthOverride);
    }
    addAtom(atom);
    addBond(
      atom,
      central,
      bondOrder,
      useSimplifiedBondLength ? bondLengthOverride : atom.position.magnitude,
    );
  }
}

RealMoleculeShape _shape(
  String name,
  double angstroms,
  void Function(RealMoleculeShape shape) build,
) {
  final shape = RealMoleculeShape(name, angstroms);
  build(shape);
  return shape;
}

final RealMoleculeShape berylliumChloride = _shape('BeCl2', 1.8, (shape) {
  shape.addCentralAtom(RealAtomPosition('Be', Vec3.zero));
  shape.addRadialAtom(RealAtomPosition('Cl', const Vec3(1.8, 0, 0), lonePairCount: 3), 1);
  shape.addRadialAtom(RealAtomPosition('Cl', const Vec3(-1.8, 0, 0), lonePairCount: 3), 1);
});

final RealMoleculeShape boronTrifluoride = _shape('BF3', 1.313, (shape) {
  shape.addCentralAtom(RealAtomPosition('B', Vec3.zero));
  const angle = 2 * math.pi / 3;
  const bondLength = 1.313;
  for (var i = 0; i < 3; i++) {
    shape.addRadialAtom(
      RealAtomPosition(
        'F',
        Vec3(bondLength * math.cos(i * angle), bondLength * math.sin(i * angle), 0),
        lonePairCount: 3,
      ),
      1,
    );
  }
});

final RealMoleculeShape brominePentafluoride = _shape('BrF5', 1.774, (shape) {
  shape.addCentralAtom(RealAtomPosition('Br', Vec3.zero, lonePairCount: 1));
  const axialBondLength = 1.689;
  const radialBondLength = 1.774;
  final angle = _radians(84.8);
  final radialDistance = math.sin(angle) * radialBondLength;
  final axialDistance = math.cos(angle) * radialBondLength;
  shape.addRadialAtom(
    RealAtomPosition('F', const Vec3(0, -axialBondLength, 0), lonePairCount: 3),
    1,
  );
  shape.addRadialAtom(
    RealAtomPosition('F', Vec3(radialDistance, -axialDistance, 0), lonePairCount: 3),
    1,
  );
  shape.addRadialAtom(
    RealAtomPosition('F', Vec3(0, -axialDistance, radialDistance), lonePairCount: 3),
    1,
  );
  shape.addRadialAtom(
    RealAtomPosition('F', Vec3(-radialDistance, -axialDistance, 0), lonePairCount: 3),
    1,
  );
  shape.addRadialAtom(
    RealAtomPosition('F', Vec3(0, -axialDistance, -radialDistance), lonePairCount: 3),
    1,
  );
});

final RealMoleculeShape methane = _shape('CH4', 1.087, (shape) {
  shape.addCentralAtom(RealAtomPosition('C', Vec3.zero));
  // Directions come from ElectronGeometry tetrahedral slots. Imported lazily
  // via the geometry table to avoid duplicating TETRA_CONST.
  // Filled in [RealMoleculeCatalog.ensureMethaneVectors] — see below.
});

final RealMoleculeShape chlorineTrifluoride = _shape('ClF3', 1.698, (shape) {
  shape.addCentralAtom(RealAtomPosition('Cl', Vec3.zero, lonePairCount: 2));
  shape.addRadialAtom(
    RealAtomPosition('F', const Vec3(0, -1.598, 0), lonePairCount: 3),
    1,
  );
  final radialAngle = _radians(87.5);
  const radialBondLength = 1.698;
  final radialDistance = math.sin(radialAngle) * radialBondLength;
  final axialDistance = math.cos(radialAngle) * radialBondLength;
  shape.addRadialAtom(
    RealAtomPosition('F', Vec3(radialDistance, -axialDistance, 0), lonePairCount: 3),
    1,
  );
  shape.addRadialAtom(
    RealAtomPosition('F', Vec3(-radialDistance, -axialDistance, 0), lonePairCount: 3),
    1,
  );
});

final RealMoleculeShape carbonDioxide = _shape('CO2', 1.163, (shape) {
  shape.addCentralAtom(RealAtomPosition('C', Vec3.zero));
  shape.addRadialAtom(
    RealAtomPosition('O', const Vec3(-1.163, 0, 0), lonePairCount: 2),
    2,
  );
  shape.addRadialAtom(
    RealAtomPosition('O', const Vec3(1.163, 0, 0), lonePairCount: 2),
    2,
  );
});

final RealMoleculeShape water = _shape('H2O', 0.957, (shape) {
  shape.addCentralAtom(RealAtomPosition('O', Vec3.zero, lonePairCount: 2));
  const radialBondLength = 0.957;
  final radialAngle = _radians(104.5) / 2;
  shape.addRadialAtom(
    RealAtomPosition(
      'H',
      Vec3(math.sin(radialAngle), -math.cos(radialAngle), 0).times(radialBondLength),
    ),
    1,
  );
  shape.addRadialAtom(
    RealAtomPosition(
      'H',
      Vec3(-math.sin(radialAngle), -math.cos(radialAngle), 0).times(radialBondLength),
    ),
    1,
  );
});

final RealMoleculeShape ammonia = _shape('NH3', 1.017, (shape) {
  shape.addCentralAtom(RealAtomPosition('N', Vec3.zero, lonePairCount: 1));
  const radialBondLength = 1.017;
  // RealMoleculeShape.js axial angle solved from the intra-bond angle.
  const axialAngle = 1.202623030417028;
  const radialAngle = 2 * math.pi / 3;
  final radialDistance = math.sin(axialAngle) * radialBondLength;
  final axialDistance = math.cos(axialAngle) * radialBondLength;
  for (var i = 0; i < 3; i++) {
    shape.addRadialAtom(
      RealAtomPosition(
        'H',
        Vec3(
          radialDistance * math.cos(i * radialAngle),
          -axialDistance,
          radialDistance * math.sin(i * radialAngle),
        ),
      ),
      1,
    );
  }
});

final RealMoleculeShape phosphorusPentachloride = _shape('PCl5', 2.02, (shape) {
  shape.addCentralAtom(RealAtomPosition('P', Vec3.zero));
  shape.addRadialAtom(RealAtomPosition('Cl', const Vec3(2.14, 0, 0), lonePairCount: 3), 1);
  shape.addRadialAtom(RealAtomPosition('Cl', const Vec3(-2.14, 0, 0), lonePairCount: 3), 1);
  const radialAngle = 2 * math.pi / 3;
  const radialBondLength = 2.02;
  for (var i = 0; i < 3; i++) {
    shape.addRadialAtom(
      RealAtomPosition(
        'Cl',
        Vec3(0, math.cos(i * radialAngle), math.sin(i * radialAngle)).times(radialBondLength),
        lonePairCount: 3,
      ),
      1,
    );
  }
});

final RealMoleculeShape sulfurTetrafluoride = _shape('SF4', 1.595, (shape) {
  shape.addCentralAtom(RealAtomPosition('S', Vec3.zero, lonePairCount: 1));
  final largeAngle = _radians(173.1) / 2;
  final smallAngle = _radians(101.6) / 2;
  shape.addRadialAtom(
    RealAtomPosition(
      'F',
      Vec3(math.sin(largeAngle), -math.cos(largeAngle), 0).times(1.646),
      lonePairCount: 3,
    ),
    1,
  );
  shape.addRadialAtom(
    RealAtomPosition(
      'F',
      Vec3(-math.sin(largeAngle), -math.cos(largeAngle), 0).times(1.646),
      lonePairCount: 3,
    ),
    1,
  );
  shape.addRadialAtom(
    RealAtomPosition(
      'F',
      Vec3(0, -math.cos(smallAngle), math.sin(smallAngle)).times(1.545),
      lonePairCount: 3,
    ),
    1,
  );
  shape.addRadialAtom(
    RealAtomPosition(
      'F',
      Vec3(0, -math.cos(smallAngle), -math.sin(smallAngle)).times(1.545),
      lonePairCount: 3,
    ),
    1,
  );
});

final RealMoleculeShape sulfurHexafluoride = _shape('SF6', 1.564, (shape) {
  shape.addCentralAtom(RealAtomPosition('S', Vec3.zero));
});

final RealMoleculeShape sulfurDioxide = _shape('SO2', 1.431, (shape) {
  final bondAngle = _radians(119) / 2;
  const bondLength = 1.431;
  shape.addCentralAtom(RealAtomPosition('S', Vec3.zero, lonePairCount: 1));
  shape.addRadialAtom(
    RealAtomPosition(
      'O',
      Vec3(math.sin(bondAngle), -math.cos(bondAngle), 0).times(bondLength),
      lonePairCount: 2,
    ),
    2,
  );
  shape.addRadialAtom(
    RealAtomPosition(
      'O',
      Vec3(-math.sin(bondAngle), -math.cos(bondAngle), 0).times(bondLength),
      lonePairCount: 2,
    ),
    2,
  );
});

final RealMoleculeShape xenonDifluoride = _shape('XeF2', 1.977, (shape) {
  shape.addCentralAtom(RealAtomPosition('Xe', Vec3.zero, lonePairCount: 3));
  shape.addRadialAtom(RealAtomPosition('F', const Vec3(1.977, 0, 0), lonePairCount: 3), 1);
  shape.addRadialAtom(RealAtomPosition('F', const Vec3(-1.977, 0, 0), lonePairCount: 3), 1);
});

final RealMoleculeShape xenonTetrafluoride = _shape('XeF4', 1.953, (shape) {
  const bondLength = 1.953;
  shape.addCentralAtom(RealAtomPosition('Xe', Vec3.zero, lonePairCount: 2));
  shape.addRadialAtom(RealAtomPosition('F', const Vec3(bondLength, 0, 0), lonePairCount: 3), 1);
  shape.addRadialAtom(RealAtomPosition('F', const Vec3(-bondLength, 0, 0), lonePairCount: 3), 1);
  shape.addRadialAtom(RealAtomPosition('F', const Vec3(0, 0, bondLength), lonePairCount: 3), 1);
  shape.addRadialAtom(RealAtomPosition('F', const Vec3(0, 0, -bondLength), lonePairCount: 3), 1);
});

double _radians(double degrees) => degrees * math.pi / 180;

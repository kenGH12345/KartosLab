import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../mp_assets.dart';
import '../../mp_colors.dart';
import '../mp_preferences.dart';
import '../view_properties.dart';

/// Display EN from `RealAtom.getDisplayElectronegativity`.
double displayElectronegativity(String symbol) {
  switch (symbol) {
    case 'H':
      return 2.2;
    case 'B':
      return 2.0;
    case 'C':
      return 2.6;
    case 'N':
      return 3.0;
    case 'O':
      return 3.4;
    case 'F':
      return 4.0;
    case 'Cl':
      return 3.2;
    default:
      throw ArgumentError('Unsupported element: $symbol');
  }
}

Color elementColor(String symbol) {
  switch (symbol) {
    case 'H':
      return MpColors.hydrogen;
    case 'B':
      return MpColors.boron;
    case 'C':
      return MpColors.carbon;
    case 'N':
      return MpColors.nitrogen;
    case 'O':
      return MpColors.oxygen;
    case 'F':
      return MpColors.fluorine;
    case 'Cl':
      return MpColors.chlorine;
    default:
      return Colors.grey;
  }
}

/// Van der Waals radius (pm) → display radius in Angstrom scene units.
/// Source: `RealAtom.getDisplayRadius` = 0.25 * (vdw/100).
double atomDisplayRadius(String symbol) {
  const vdwPm = {
    'H': 120.0,
    'B': 192.0,
    'C': 170.0,
    'N': 155.0,
    'O': 152.0,
    'F': 147.0,
    'Cl': 175.0,
  };
  final pm = vdwPm[symbol] ?? 150.0;
  return 0.25 * (pm / 100.0);
}

class RealAtomData {
  RealAtomData({
    required this.symbol,
    required this.x,
    required this.y,
    required this.z,
    required this.simplifiedPartialCharge,
    required this.hirshfeldPartialCharge,
  });

  final String symbol;
  final double x, y, z;
  final double simplifiedPartialCharge;
  final double hirshfeldPartialCharge;

  double get displayEN => displayElectronegativity(symbol);
  Color get color => elementColor(symbol);

  /// Display partial charge (`RealAtom.getPartialCharge` → hirshfeld).
  double get displayPartialCharge => hirshfeldPartialCharge;
}

class RealBondData {
  RealBondData({
    required this.indexA,
    required this.indexB,
    required this.bondType,
    this.dipoleX = 0,
    this.dipoleY = 0,
    this.dipoleZ = 0,
    this.dipoleMagnitude = 0,
  });

  final int indexA;
  final int indexB;
  final num bondType;
  final double dipoleX, dipoleY, dipoleZ, dipoleMagnitude;
}

/// Surface mesh from `RealMoleculeData` / `all-molecules.json`.
class RealMoleculeMesh {
  RealMoleculeMesh({
    required this.positions,
    required this.normals,
    required this.espValues,
    required this.densityValues,
    required this.faceIndices,
  });

  /// Flat xyz (length = 3 * vertexCount).
  final Float64ListView positions;
  final Float64ListView normals;
  final List<double> espValues;
  final List<double> densityValues;
  final List<List<int>> faceIndices;

  int get vertexCount => positions.length ~/ 3;
}

/// Thin wrapper so we don't allocate typed_data import noise in signatures.
class Float64ListView {
  Float64ListView(this.values);
  final List<double> values;
  int get length => values.length;
  double operator [](int i) => values[i];
}

class RealMoleculeDef {
  RealMoleculeDef({
    required this.symbol,
    required this.name,
    required this.geometry,
    required this.atoms,
    required this.bonds,
    required this.molecularDipole,
    this.mesh,
  });

  final String symbol;
  final String name;
  final String geometry;
  final List<RealAtomData> atoms;
  final List<RealBondData> bonds;
  final List<double> molecularDipole; // xyz Debye
  final RealMoleculeMesh? mesh;

  /// Port of `RealMolecule.getSimplifiedElectrostaticPotential`.
  double simplifiedElectrostaticPotential(double x, double y, double z) {
    var esp = 0.0;
    for (final atom in atoms) {
      final dx = x - atom.x;
      final dy = y - atom.y;
      final dz = z - atom.z;
      final distance = math.sqrt(dx * dx + dy * dy + dz * dz);
      if (distance < 1e-12) continue;
      esp += atom.simplifiedPartialCharge / distance;
    }
    return esp;
  }

  /// Port of `getElectrostaticPotential` / `getElectronDensity`.
  double sampleSurfaceValue(
    SurfaceType surface, {
    required bool isAdvanced,
    required int vertexIndex,
    required double x,
    required double y,
    required double z,
  }) {
    final m = mesh;
    if (surface == SurfaceType.electrostaticPotential) {
      if (isAdvanced && m != null) {
        return m.espValues[vertexIndex];
      }
      return simplifiedElectrostaticPotential(x, y, z);
    }
    // electronDensity
    if (isAdvanced && m != null) {
      return m.densityValues[vertexIndex];
    }
    // Basic: same hack as PhET — reuse simplified ESP as density input.
    return simplifiedElectrostaticPotential(x, y, z);
  }

  @override
  bool operator ==(Object other) =>
      other is RealMoleculeDef && other.symbol == symbol;

  @override
  int get hashCode => symbol.hashCode;
}

const _moleculeOrder = [
  'H2',
  'N2',
  'O2',
  'F2',
  'HF',
  'H2O',
  'CO2',
  'HCN',
  'O3',
  'NH3',
  'BH3',
  'BF3',
  'CH2O',
  'CH4',
  'CH3F',
  'CH2F2',
  'CHF3',
  'CF4',
  'CHCl3',
];

const _moleculeNames = {
  'H2': '氢气',
  'N2': '氮气',
  'O2': '氧气',
  'F2': '氟气',
  'HF': '氟化氢',
  'H2O': '水',
  'CO2': '二氧化碳',
  'HCN': '氰化氢',
  'O3': '臭氧',
  'NH3': '氨',
  'BH3': '硼烷',
  'BF3': '三氟化硼',
  'CH2O': '甲醛',
  'CH4': '甲烷',
  'CH3F': '氟甲烷',
  'CH2F2': '二氟甲烷',
  'CHF3': '三氟甲烷',
  'CF4': '四氟甲烷',
  'CHCl3': '氯仿',
};

const _geometries = {
  'H2': 'linear',
  'N2': 'linear',
  'O2': 'linear',
  'F2': 'linear',
  'HF': 'linear',
  'H2O': 'bent',
  'CO2': 'linear',
  'HCN': 'linear',
  'O3': 'bent',
  'NH3': 'trigonalPyramidal',
  'BH3': 'trigonalPlanar',
  'BF3': 'trigonalPlanar',
  'CH2O': 'trigonalPlanar',
  'CH4': 'tetrahedral',
  'CH3F': 'tetrahedral',
  'CH2F2': 'tetrahedral',
  'CHF3': 'tetrahedral',
  'CF4': 'tetrahedral',
  'CHCl3': 'tetrahedral',
};

/// Loads original `all-molecules.json` (atoms/bonds/dipoles + surface mesh).
class RealMoleculeCatalog {
  RealMoleculeCatalog._(this.molecules);

  final List<RealMoleculeDef> molecules;

  static Future<RealMoleculeCatalog> load() async {
    final raw = await rootBundle.loadString(MpAssets.allMoleculesJson);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final simplified = _simplifiedCharges();
    final list = <RealMoleculeDef>[];
    for (final sym in _moleculeOrder) {
      final entry = map[sym] as Map<String, dynamic>;
      list.add(_parseMolecule(sym, entry, simplified[sym] ?? const {}));
    }
    return RealMoleculeCatalog._(list);
  }

  static RealMoleculeDef _parseMolecule(
    String sym,
    Map<String, dynamic> entry,
    Map<String, double> charges,
  ) {
    final atomsJson = entry['atoms'] as List<dynamic>;
    final bondsJson = entry['bonds'] as List<dynamic>;
    final dipolesJson = entry['bondDipoles'] as List<dynamic>? ?? [];
    final hirshfeldJson = entry['hirshfeld'] as List<dynamic>? ?? [];

    final ox = _originOffset(atomsJson, bondsJson);

    final atoms = <RealAtomData>[];
    for (var i = 0; i < atomsJson.length; i++) {
      final m = atomsJson[i] as Map<String, dynamic>;
      final symbol = m['symbol'] as String;
      final bondCount = bondsJson.where((b) {
        final bm = b as Map<String, dynamic>;
        return bm['indexA'] == i || bm['indexB'] == i;
      }).length;
      var q = charges[symbol];
      q ??= charges['$symbol$bondCount'];
      q ??= 0.0;
      final h = i < hirshfeldJson.length
          ? (hirshfeldJson[i] as num).toDouble()
          : 0.0;
      atoms.add(RealAtomData(
        symbol: symbol,
        x: (m['x'] as num).toDouble() - ox[0],
        y: (m['y'] as num).toDouble() - ox[1],
        z: (m['z'] as num).toDouble() - ox[2],
        simplifiedPartialCharge: q,
        hirshfeldPartialCharge: h,
      ));
    }

    final dipoleByPair = <String, Map<String, dynamic>>{};
    for (final d in dipolesJson) {
      final m = d as Map<String, dynamic>;
      dipoleByPair['${m['indexA']}_${m['indexB']}'] = m;
    }

    final bonds = <RealBondData>[];
    for (final b in bondsJson) {
      final m = b as Map<String, dynamic>;
      final ia = m['indexA'] as int;
      final ib = m['indexB'] as int;
      final d = dipoleByPair['${ia}_$ib'] ?? dipoleByPair['${ib}_$ia'];
      bonds.add(RealBondData(
        indexA: ia,
        indexB: ib,
        bondType: m['bondType'] as num,
        dipoleX: d == null ? 0 : (d['x'] as num).toDouble(),
        dipoleY: d == null ? 0 : (d['y'] as num).toDouble(),
        dipoleZ: d == null ? 0 : (d['z'] as num).toDouble(),
        dipoleMagnitude: d == null ? 0 : (d['magnitude'] as num).toDouble(),
      ));
    }

    final md = (entry['molecularDipole'] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();

    RealMoleculeMesh? mesh;
    final vp = entry['vertexPositions'] as List<dynamic>?;
    if (vp != null && vp.isNotEmpty) {
      final vn = entry['vertexNormals'] as List<dynamic>;
      final esp = entry['vertexElectrostaticPotentialValues'] as List<dynamic>;
      final dens = entry['vertexElectronDensityValues'] as List<dynamic>;
      final faces = entry['faceIndices'] as List<dynamic>;

      final positions = <double>[];
      final normals = <double>[];
      for (var i = 0; i < vp.length; i++) {
        final p = vp[i] as List<dynamic>;
        final n = vn[i] as List<dynamic>;
        positions.addAll([
          (p[0] as num).toDouble() - ox[0],
          (p[1] as num).toDouble() - ox[1],
          (p[2] as num).toDouble() - ox[2],
        ]);
        normals.addAll([
          (n[0] as num).toDouble(),
          (n[1] as num).toDouble(),
          (n[2] as num).toDouble(),
        ]);
      }
      mesh = RealMoleculeMesh(
        positions: Float64ListView(positions),
        normals: Float64ListView(normals),
        espValues: esp.map((e) => (e as num).toDouble()).toList(),
        densityValues: dens.map((e) => (e as num).toDouble()).toList(),
        faceIndices: faces
            .map((f) => (f as List<dynamic>).map((e) => e as int).toList())
            .toList(),
      );
    }

    return RealMoleculeDef(
      symbol: sym,
      name: _moleculeNames[sym] ?? sym,
      geometry: _geometries[sym] ?? 'unknown',
      atoms: atoms,
      bonds: bonds,
      molecularDipole: md,
      mesh: mesh,
    );
  }

  /// Port of `RealMolecule.computeOriginOffset`.
  static List<double> _originOffset(
    List<dynamic> atomsJson,
    List<dynamic> bondsJson,
  ) {
    if (atomsJson.length == 2) {
      final a0 = atomsJson[0] as Map<String, dynamic>;
      final a1 = atomsJson[1] as Map<String, dynamic>;
      if (a0['symbol'] == a1['symbol']) {
        return [
          ((a0['x'] as num) + (a1['x'] as num)) / 2,
          ((a0['y'] as num) + (a1['y'] as num)) / 2,
          ((a0['z'] as num) + (a1['z'] as num)) / 2,
        ];
      }
      // HF: center on F
      final f = a0['symbol'] == 'F' ? a0 : a1;
      return [
        (f['x'] as num).toDouble(),
        (f['y'] as num).toDouble(),
        (f['z'] as num).toDouble(),
      ];
    }
    var bestBondCount = -1;
    var bestIndex = 0;
    for (var i = 0; i < atomsJson.length; i++) {
      final count = bondsJson.where((b) {
        final bm = b as Map<String, dynamic>;
        return bm['indexA'] == i || bm['indexB'] == i;
      }).length;
      if (count > bestBondCount) {
        bestBondCount = count;
        bestIndex = i;
      }
    }
    final c = atomsJson[bestIndex] as Map<String, dynamic>;
    return [
      (c['x'] as num).toDouble(),
      (c['y'] as num).toDouble(),
      (c['z'] as num).toDouble(),
    ];
  }

  static Map<String, Map<String, double>> _simplifiedCharges() {
    return {
      'BF3': {'B': 0.842505, 'F': -0.280358},
      'BH3': {'B': 0.301318, 'H': -0.100417},
      'CF4': {'C': 0.423049, 'F': -0.105762},
      'CH2F2': {'C': 0.100550, 'F': -0.159942, 'H': 0.109667},
      'CH2O': {'C': 0.270184, 'H': 0.038366, 'O': -0.346916},
      'CH3F': {'C': -0.230517, 'F': -0.166365, 'H': 0.132281},
      'CH4': {'C': -0.802069, 'H': 0.200517},
      'CHCl3': {'C': -0.025406, 'Cl': -0.052227, 'H': 0.182373},
      'CHF3': {'C': 0.282658, 'F': -0.135350, 'H': 0.123152},
      'CO2': {'C': 0.685248, 'O': -0.342624},
      'F2': {'F': 0},
      'H2': {'H': 0},
      'H2O': {'H': 0.376285, 'O': -0.752569},
      'HCN': {'C': 0.047988, 'N': -0.282540, 'H': 0.234552},
      'HF': {'F': -0.430703, 'H': 0.430703},
      'N2': {'N': 0},
      'NH3': {'N': -0.777549, 'H': 0.259183},
      'O2': {'O': 0},
      'O3': {'O2': 0.242265, 'O1': -0.121133},
    };
  }
}

/// Quaternion as (x,y,z,w).
class MpQuaternion {
  const MpQuaternion(this.x, this.y, this.z, this.w);
  final double x, y, z, w;
  static const identity = MpQuaternion(0, 0, 0, 1);

  MpQuaternion multiply(MpQuaternion o) {
    return MpQuaternion(
      w * o.x + x * o.w + y * o.z - z * o.y,
      w * o.y - x * o.z + y * o.w + z * o.x,
      w * o.z + x * o.y - y * o.x + z * o.w,
      w * o.w - x * o.x - y * o.y - z * o.z,
    );
  }

  List<double> rotate(double px, double py, double pz) {
    final qx = x, qy = y, qz = z, qw = w;
    final ix = qw * px + qy * pz - qz * py;
    final iy = qw * py + qz * px - qx * pz;
    final iz = qw * pz + qx * py - qy * px;
    final iw = -qx * px - qy * py - qz * pz;
    return [
      ix * qw + iw * -qx + iy * -qz - iz * -qy,
      iy * qw + iw * -qy + iz * -qx - ix * -qz,
      iz * qw + iw * -qz + ix * -qy - iy * -qx,
    ];
  }

  /// Rotate by conjugate (inverse for unit quaternion).
  List<double> inverseRotate(double px, double py, double pz) {
    return MpQuaternion(-x, -y, -z, w).rotate(px, py, pz);
  }

  static MpQuaternion fromAxisAngle(
    double ax,
    double ay,
    double az,
    double angle,
  ) {
    final half = angle / 2;
    final s = math.sin(half);
    final len = math.sqrt(ax * ax + ay * ay + az * az);
    if (len < 1e-12) return identity;
    return MpQuaternion(
      ax / len * s,
      ay / len * s,
      az / len * s,
      math.cos(half),
    );
  }
}

const _initialRotation = <String, MpQuaternion>{
  'CF4': MpQuaternion(
    -0.3937806654121543,
    -0.17485260291214183,
    -0.9001547262973663,
    0.0639126241591583,
  ),
  'CH2F2': MpQuaternion(
    -0.27136646893101857,
    -0.6903203332285108,
    -0.6223760651398221,
    0.24993221203410235,
  ),
  'CH2O': MpQuaternion(
    0.3666328007228524,
    0.4262567778088401,
    0.5594996323273494,
    0.6089710257735602,
  ),
  'CH3F': MpQuaternion(
    -0.424564362987182,
    -0.5991718998340826,
    0.3800185779324334,
    0.5624268988559403,
  ),
  'CH4': MpQuaternion(
    0.09754516100806414,
    0.09754516100806415,
    -0.009607359798384778,
    0.9903926402016154,
  ),
  'CHCl3': MpQuaternion(
    -0.1748081804583777,
    -0.789947747694425,
    0.5773331843722288,
    -0.11005021662823589,
  ),
  'CHF3': MpQuaternion(
    0.017834718285708984,
    -0.7400716028848267,
    0.6715496673518707,
    0.03157514381184575,
  ),
  'H2O': MpQuaternion(-1, 0, 0, 0),
  'HCN': MpQuaternion(0, -math.sqrt2 / 2, 0, math.sqrt2 / 2),
  'HF': MpQuaternion(0, -math.sqrt2 / 2, 0, math.sqrt2 / 2),
  'NH3': MpQuaternion(
    0.7677141944032492,
    -0.4684697628688284,
    0.01799052832586886,
    0.4368378851243859,
  ),
  'O3': MpQuaternion(
    0.9995276220774126,
    -0.01492863425893462,
    0.010407093463581261,
    0.024766125838878564,
  ),
};

MpQuaternion initialRotationFor(String symbol) =>
    _initialRotation[symbol] ?? MpQuaternion.identity;

class RealMoleculesModel {
  RealMoleculesModel({
    required this.catalog,
    this.preferences,
    RealMoleculesViewProperties? viewProperties,
  })  : viewProperties = viewProperties ?? RealMoleculesViewProperties(),
        molecule = catalog.molecules.firstWhere((m) => m.symbol == 'HF') {
    quaternion = initialRotationFor(molecule.symbol);
  }

  final RealMoleculeCatalog catalog;
  final MpPreferences? preferences;
  final RealMoleculesViewProperties viewProperties;

  late RealMoleculeDef molecule;
  bool isAdvanced = false;
  late MpQuaternion quaternion;

  void selectMolecule(RealMoleculeDef m) {
    molecule = m;
    quaternion = initialRotationFor(m.symbol);
  }

  void reset() {
    molecule = catalog.molecules.firstWhere((m) => m.symbol == 'HF');
    isAdvanced = false;
    quaternion = initialRotationFor(molecule.symbol);
    viewProperties.reset();
  }

  void applyDrag(double dx, double dy) {
    applyArcball(Offset.zero, Offset(dx, dy), Offset.zero);
  }

  static const double viewScale = 90;

  /// Front-most atom under [local], or null if the pointer is on empty space.
  int? hitTestAtom(Offset local, Offset center) {
    var best = -1;
    var bestZ = -1e9;
    var bestD = 1e9;
    for (var i = 0; i < molecule.atoms.length; i++) {
      final atom = molecule.atoms[i];
      final r = quaternion.rotate(atom.x, atom.y, atom.z);
      final p = Offset(
        center.dx + r[0] * viewScale,
        center.dy - r[1] * viewScale,
      );
      final hitR = atomDisplayRadius(atom.symbol) * viewScale * 1.45;
      final d = (local - p).distance;
      if (d > hitR) continue;
      // Prefer the atom facing the camera (larger view-Z), then nearer in 2D.
      if (r[2] > bestZ + 1e-6 || (r[2] - bestZ).abs() < 1e-6 && d < bestD) {
        best = i;
        bestZ = r[2];
        bestD = d;
      }
    }
    return best < 0 ? null : best;
  }

  /// Trackball: the point under the pointer stays under the pointer.
  void applyArcball(Offset from, Offset to, Offset center, {double radius = 220}) {
    final a = _projectOnBall(from - center, radius);
    final b = _projectOnBall(to - center, radius);
    final ax = a[1] * b[2] - a[2] * b[1];
    final ay = a[2] * b[0] - a[0] * b[2];
    final az = a[0] * b[1] - a[1] * b[0];
    final axisLen = math.sqrt(ax * ax + ay * ay + az * az);
    if (axisLen < 1e-9) return;
    final dot = (a[0] * b[0] + a[1] * b[1] + a[2] * b[2]).clamp(-1.0, 1.0);
    final angle = math.acos(dot);
    if (angle.abs() < 1e-9) return;
    quaternion =
        MpQuaternion.fromAxisAngle(ax, ay, az, angle).multiply(quaternion);
  }

  static List<double> _projectOnBall(Offset p, double radius) {
    final x = p.dx / radius;
    final y = -p.dy / radius;
    final d2 = x * x + y * y;
    if (d2 <= 1) {
      return [x, y, math.sqrt(1 - d2)];
    }
    final n = math.sqrt(d2);
    return [x / n, y / n, 0.0];
  }
}

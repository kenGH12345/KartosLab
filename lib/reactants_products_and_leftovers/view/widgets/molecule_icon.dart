import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Nitroglycerin `Element` — covalent radii + CPK colors used by RPL.
class NitroElement {
  const NitroElement(this.symbol, this.covalentRadius, this.color);

  final String symbol;
  final double covalentRadius;
  final Color color;

  static const h = NitroElement('H', 37, Color(0xFFFFFFFF));
  static const c = NitroElement('C', 77, Color(0xFFB2B2B2));
  static const n = NitroElement('N', 75, Color(0xFF0000FF));
  static const o = NitroElement('O', 73, Color(0xFFFF5500));
  static const s = NitroElement('S', 103, Color(0xFFD4B53B));
  static const f = NitroElement('F', 72, Color(0xFFF5FF24));
  static const cl = NitroElement('Cl', 100, Color(0xFF88F215));
  static const p = NitroElement('P', 110, Color(0xFFFF9A00));

  static const pMaxRadius = 110.0;
  static const rateOfChange = 0.75;
  static const modelToViewScale = 0.11;

  double get diameter {
    final adjusted =
        pMaxRadius - rateOfChange * (pMaxRadius - covalentRadius);
    return 2 * modelToViewScale * adjusted;
  }
}

class _AtomLayout {
  const _AtomLayout(this.element, this.center, {this.z = 0});
  final NitroElement element;
  final Offset center;
  final int z;
}

/// All molecules used by Molecules + Game — geometry from nitroglycerin `*Node.ts`.
enum RpalMoleculeId {
  h2,
  o2,
  n2,
  f2,
  cl2,
  c,
  s,
  h2o,
  nh3,
  ch4,
  co2,
  co,
  hf,
  hcl,
  no,
  no2,
  n2o,
  so2,
  so3,
  h2s,
  cs2,
  of2,
  c2h2,
  c2h4,
  c2h6,
  ch2o,
  ch3oh,
  c2h5Oh,
  c2h5Cl,
  p4,
  ph3,
  pf3,
  pcl3,
  pcl5,
}

extension RpalMoleculeIdX on RpalMoleculeId {
  String get iconKey {
    switch (this) {
      case RpalMoleculeId.h2:
        return 'H2';
      case RpalMoleculeId.o2:
        return 'O2';
      case RpalMoleculeId.n2:
        return 'N2';
      case RpalMoleculeId.f2:
        return 'F2';
      case RpalMoleculeId.cl2:
        return 'Cl2';
      case RpalMoleculeId.c:
        return 'C';
      case RpalMoleculeId.s:
        return 'S';
      case RpalMoleculeId.h2o:
        return 'H2O';
      case RpalMoleculeId.nh3:
        return 'NH3';
      case RpalMoleculeId.ch4:
        return 'CH4';
      case RpalMoleculeId.co2:
        return 'CO2';
      case RpalMoleculeId.co:
        return 'CO';
      case RpalMoleculeId.hf:
        return 'HF';
      case RpalMoleculeId.hcl:
        return 'HCl';
      case RpalMoleculeId.no:
        return 'NO';
      case RpalMoleculeId.no2:
        return 'NO2';
      case RpalMoleculeId.n2o:
        return 'N2O';
      case RpalMoleculeId.so2:
        return 'SO2';
      case RpalMoleculeId.so3:
        return 'SO3';
      case RpalMoleculeId.h2s:
        return 'H2S';
      case RpalMoleculeId.cs2:
        return 'CS2';
      case RpalMoleculeId.of2:
        return 'OF2';
      case RpalMoleculeId.c2h2:
        return 'C2H2';
      case RpalMoleculeId.c2h4:
        return 'C2H4';
      case RpalMoleculeId.c2h6:
        return 'C2H6';
      case RpalMoleculeId.ch2o:
        return 'CH2O';
      case RpalMoleculeId.ch3oh:
        return 'CH3OH';
      case RpalMoleculeId.c2h5Oh:
        return 'C2H5OH';
      case RpalMoleculeId.c2h5Cl:
        return 'C2H5Cl';
      case RpalMoleculeId.p4:
        return 'P4';
      case RpalMoleculeId.ph3:
        return 'PH3';
      case RpalMoleculeId.pf3:
        return 'PF3';
      case RpalMoleculeId.pcl3:
        return 'PCl3';
      case RpalMoleculeId.pcl5:
        return 'PCl5';
    }
  }

  static RpalMoleculeId? fromIconId(String? iconId) {
    switch (iconId) {
      case 'H2':
        return RpalMoleculeId.h2;
      case 'O2':
        return RpalMoleculeId.o2;
      case 'N2':
        return RpalMoleculeId.n2;
      case 'F2':
        return RpalMoleculeId.f2;
      case 'Cl2':
        return RpalMoleculeId.cl2;
      case 'C':
        return RpalMoleculeId.c;
      case 'S':
        return RpalMoleculeId.s;
      case 'H2O':
        return RpalMoleculeId.h2o;
      case 'NH3':
        return RpalMoleculeId.nh3;
      case 'CH4':
        return RpalMoleculeId.ch4;
      case 'CO2':
        return RpalMoleculeId.co2;
      case 'CO':
        return RpalMoleculeId.co;
      case 'HF':
        return RpalMoleculeId.hf;
      case 'HCl':
        return RpalMoleculeId.hcl;
      case 'NO':
        return RpalMoleculeId.no;
      case 'NO2':
        return RpalMoleculeId.no2;
      case 'N2O':
        return RpalMoleculeId.n2o;
      case 'SO2':
        return RpalMoleculeId.so2;
      case 'SO3':
        return RpalMoleculeId.so3;
      case 'H2S':
        return RpalMoleculeId.h2s;
      case 'CS2':
        return RpalMoleculeId.cs2;
      case 'OF2':
        return RpalMoleculeId.of2;
      case 'C2H2':
        return RpalMoleculeId.c2h2;
      case 'C2H4':
        return RpalMoleculeId.c2h4;
      case 'C2H6':
        return RpalMoleculeId.c2h6;
      case 'CH2O':
        return RpalMoleculeId.ch2o;
      case 'CH3OH':
        return RpalMoleculeId.ch3oh;
      case 'C2H5OH':
        return RpalMoleculeId.c2h5Oh;
      case 'C2H5Cl':
        return RpalMoleculeId.c2h5Cl;
      case 'P4':
        return RpalMoleculeId.p4;
      case 'PH3':
        return RpalMoleculeId.ph3;
      case 'PF3':
        return RpalMoleculeId.pf3;
      case 'PCl3':
        return RpalMoleculeId.pcl3;
      case 'PCl5':
        return RpalMoleculeId.pcl5;
      default:
        return null;
    }
  }
}

class MoleculeIcon extends StatelessWidget {
  const MoleculeIcon({
    super.key,
    required this.id,
    this.scale = 1.0,
  });

  final RpalMoleculeId id;
  final double scale;

  static Size layoutSize(RpalMoleculeId id) {
    final atoms = _atomsFor(id);
    return _boundsOf(atoms).size;
  }

  @override
  Widget build(BuildContext context) {
    final atoms = _atomsFor(id);
    final bounds = _boundsOf(atoms);
    return CustomPaint(
      size: Size(bounds.width * scale, bounds.height * scale),
      painter: _MoleculePainter(
        atoms: atoms,
        origin: bounds.topLeft,
        scale: scale,
      ),
    );
  }

  static List<_AtomLayout> _atomsFor(RpalMoleculeId id) {
    switch (id) {
      case RpalMoleculeId.h2:
        return _horizontal([NitroElement.h, NitroElement.h]);
      case RpalMoleculeId.o2:
        return _horizontal([NitroElement.o, NitroElement.o]);
      case RpalMoleculeId.n2:
        return _horizontal([NitroElement.n, NitroElement.n]);
      case RpalMoleculeId.f2:
        return _horizontal([NitroElement.f, NitroElement.f]);
      case RpalMoleculeId.cl2:
        return _horizontal([NitroElement.cl, NitroElement.cl]);
      case RpalMoleculeId.c:
        return _horizontal([NitroElement.c]);
      case RpalMoleculeId.s:
        return _horizontal([NitroElement.s]);
      case RpalMoleculeId.co2:
        return _horizontal([NitroElement.o, NitroElement.c, NitroElement.o]);
      case RpalMoleculeId.co:
        return _horizontal([NitroElement.c, NitroElement.o]);
      case RpalMoleculeId.cs2:
        return _horizontal([NitroElement.s, NitroElement.c, NitroElement.s]);
      case RpalMoleculeId.no:
        return _horizontal([NitroElement.n, NitroElement.o]);
      case RpalMoleculeId.n2o:
        return _horizontal([NitroElement.n, NitroElement.n, NitroElement.o]);
      case RpalMoleculeId.c2h2:
        return _horizontal(
          [NitroElement.h, NitroElement.c, NitroElement.c, NitroElement.h],
          overlapPercent: 0.35,
        );
      case RpalMoleculeId.hf:
        return _horizontal(
          [NitroElement.f, NitroElement.h],
          directionRightToLeft: true,
          overlapPercent: 0.5,
        );
      case RpalMoleculeId.hcl:
        return _horizontal(
          [NitroElement.cl, NitroElement.h],
          directionRightToLeft: true,
          overlapPercent: 0.5,
        );
      case RpalMoleculeId.h2o:
        return _h2o();
      case RpalMoleculeId.nh3:
        return _nh3();
      case RpalMoleculeId.ch4:
        return _ch4();
      case RpalMoleculeId.so2:
        return _so2();
      case RpalMoleculeId.so3:
        return _so3();
      case RpalMoleculeId.h2s:
        return _h2s();
      case RpalMoleculeId.no2:
        return _no2();
      case RpalMoleculeId.of2:
        return _of2();
      case RpalMoleculeId.c2h4:
        return _c2h4();
      case RpalMoleculeId.c2h6:
        return _c2h6();
      case RpalMoleculeId.ch2o:
        return _ch2o();
      case RpalMoleculeId.ch3oh:
        return _ch3oh();
      case RpalMoleculeId.c2h5Oh:
        return _c2h5Oh();
      case RpalMoleculeId.c2h5Cl:
        return _c2h5Cl();
      case RpalMoleculeId.p4:
        return _p4();
      case RpalMoleculeId.ph3:
        return _ph3();
      case RpalMoleculeId.pf3:
        return _pf3();
      case RpalMoleculeId.pcl3:
        return _pcl3();
      case RpalMoleculeId.pcl5:
        return _pcl5();
    }
  }

  static List<_AtomLayout> _horizontal(
    List<NitroElement> elements, {
    double overlapPercent = 0.25,
    bool directionRightToLeft = false,
  }) {
    final atoms = <_AtomLayout>[];
    double? prevEdge;
    for (var i = 0; i < elements.length; i++) {
      final e = elements[i];
      final d = e.diameter;
      final r = d / 2;
      late double cx;
      if (prevEdge == null) {
        cx = r;
      } else {
        final overlap = overlapPercent * d;
        if (directionRightToLeft) {
          // Place to the left of previous (right edge of new = left of prev + overlap)
          final right = prevEdge + overlap;
          cx = right - r;
        } else {
          final left = prevEdge - overlap;
          cx = left + r;
        }
      }
      atoms.add(_AtomLayout(e, Offset(cx, r), z: i));
      prevEdge = directionRightToLeft ? (cx - r) : (cx + r);
    }
    // Normalize so leftmost >= 0
    var minX = double.infinity;
    for (final a in atoms) {
      minX = math.min(minX, a.center.dx - a.element.diameter / 2);
    }
    if (minX < 0) {
      return [
        for (var i = 0; i < atoms.length; i++)
          _AtomLayout(
            atoms[i].element,
            Offset(atoms[i].center.dx - minX, atoms[i].center.dy),
            z: atoms[i].z,
          ),
      ];
    }
    return atoms;
  }

  static List<_AtomLayout> _h2o() {
    final o = NitroElement.o;
    final h = NitroElement.h;
    final oD = o.diameter;
    final oCenter = Offset(oD / 2, oD / 2);
    final hY = oCenter.dy + oD / 2 - 0.25 * oD;
    return [
      _AtomLayout(o, oCenter, z: 0),
      _AtomLayout(h, Offset(oCenter.dx - oD / 2, hY), z: 1),
      _AtomLayout(h, Offset(oCenter.dx + oD / 2, hY), z: 2),
    ];
  }

  static List<_AtomLayout> _nh3() {
    final n = NitroElement.n;
    final h = NitroElement.h;
    final nD = n.diameter;
    final nCenter = Offset(nD / 2, nD / 2);
    final sideY = nCenter.dy + nD / 2 - 0.25 * nD;
    return [
      _AtomLayout(h, Offset(nCenter.dx - nD / 2, sideY), z: 0),
      _AtomLayout(h, Offset(nCenter.dx + nD / 2, sideY), z: 1),
      _AtomLayout(n, nCenter, z: 2),
      _AtomLayout(h, Offset(nCenter.dx, nCenter.dy + nD / 2), z: 3),
    ];
  }

  static List<_AtomLayout> _ch4() {
    final c = NitroElement.c;
    final h = NitroElement.h;
    final cD = c.diameter;
    final cCenter = Offset(cD / 2, cD / 2);
    final small = 0.165 * cD;
    final left = cCenter.dx - cD / 2;
    final right = cCenter.dx + cD / 2;
    final top = cCenter.dy - cD / 2;
    final bottom = cCenter.dy + cD / 2;
    return [
      _AtomLayout(h, Offset(right - small, top + small), z: 0),
      _AtomLayout(h, Offset(left + small, bottom - small), z: 1),
      _AtomLayout(c, cCenter, z: 2),
      _AtomLayout(h, Offset(left + small, top + small), z: 3),
      _AtomLayout(h, Offset(right - small, bottom - small), z: 4),
    ];
  }

  /// SO2Node.ts
  static List<_AtomLayout> _so2() {
    final s = NitroElement.s;
    final o = NitroElement.o;
    final sD = s.diameter;
    final c = Offset(sD / 2, sD / 2);
    final oy = c.dy + 0.2 * sD;
    return [
      _AtomLayout(o, Offset(c.dx - sD / 2, oy), z: 0),
      _AtomLayout(s, c, z: 1),
      _AtomLayout(o, Offset(c.dx + sD / 2, oy), z: 2),
    ];
  }

  /// SO3Node.ts
  static List<_AtomLayout> _so3() {
    final s = NitroElement.s;
    final o = NitroElement.o;
    final sD = s.diameter;
    final c = Offset(sD / 2, sD / 2);
    final oy = c.dy + 0.2 * sD;
    return [
      _AtomLayout(
        o,
        Offset(c.dx + 0.08 * sD, c.dy - sD / 2 + 0.08 * sD),
        z: 0,
      ),
      _AtomLayout(o, Offset(c.dx - sD / 2, oy), z: 1),
      _AtomLayout(s, c, z: 2),
      _AtomLayout(o, Offset(c.dx + sD / 2, oy), z: 3),
    ];
  }

  /// H2SNode.ts
  static List<_AtomLayout> _h2s() {
    final s = NitroElement.s;
    final h = NitroElement.h;
    final sD = s.diameter;
    final c = Offset(sD / 2, sD / 2);
    final hy = c.dy + sD / 2 - 0.25 * sD;
    return [
      _AtomLayout(s, c, z: 0),
      _AtomLayout(h, Offset(c.dx - sD / 2, hy), z: 1),
      _AtomLayout(h, Offset(c.dx + sD / 2, hy), z: 2),
    ];
  }

  /// NO2Node.ts
  static List<_AtomLayout> _no2() {
    final n = NitroElement.n;
    final o = NitroElement.o;
    final nD = n.diameter;
    final c = Offset(nD / 2, nD / 2);
    final oy = c.dy + 0.25 * nD;
    return [
      _AtomLayout(o, Offset(c.dx - nD / 2, oy), z: 0),
      _AtomLayout(n, c, z: 1),
      _AtomLayout(o, Offset(c.dx + nD / 2, oy), z: 2),
    ];
  }

  /// OF2Node.ts
  static List<_AtomLayout> _of2() {
    final o = NitroElement.o;
    final f = NitroElement.f;
    final oD = o.diameter;
    final c = Offset(oD / 2, oD / 2);
    final fy = c.dy + 0.25 * oD;
    return [
      _AtomLayout(f, Offset(c.dx - oD / 2, fy), z: 0),
      _AtomLayout(o, c, z: 1),
      _AtomLayout(f, Offset(c.dx + oD / 2, fy), z: 2),
    ];
  }

  /// C2H4Node.ts
  static List<_AtomLayout> _c2h4() {
    final c = NitroElement.c;
    final h = NitroElement.h;
    final cD = c.diameter;
    final left = Offset(cD / 2, cD / 2);
    final right = Offset(left.dx + 0.25 * cD + cD / 2, left.dy);
    // more precisely: left of right = left.centerX + 0.25*width →
    // right.centerX = left.centerX + 0.25*cD + cD/2
    final small = 0.165 * cD;
    return [
      _AtomLayout(h, Offset(right.dx + cD / 2 - small, right.dy - cD / 2 + small),
          z: 0),
      _AtomLayout(
          h, Offset(left.dx - cD / 2 + small, left.dy - cD / 2 + small),
          z: 1),
      _AtomLayout(c, left, z: 2),
      _AtomLayout(c, right, z: 3),
      _AtomLayout(
          h, Offset(left.dx - cD / 2 + small, left.dy + cD / 2 - small),
          z: 4),
      _AtomLayout(
          h, Offset(right.dx + cD / 2 - small, right.dy + cD / 2 - small),
          z: 5),
    ];
  }

  /// C2H6Node.ts
  static List<_AtomLayout> _c2h6() {
    final c = NitroElement.c;
    final h = NitroElement.h;
    final cD = c.diameter;
    final left = Offset(cD / 2, cD / 2);
    final right = Offset(left.dx + cD / 2 + 0.25 * cD, left.dy);
    return [
      _AtomLayout(h, Offset(right.dx, right.dy + cD / 2), z: 0),
      _AtomLayout(h, Offset(right.dx, right.dy - cD / 2), z: 1),
      _AtomLayout(c, right, z: 2),
      _AtomLayout(h, Offset(right.dx + cD / 2, right.dy), z: 3),
      _AtomLayout(h, Offset(left.dx - cD / 2, left.dy), z: 4),
      _AtomLayout(c, left, z: 5),
      _AtomLayout(h, Offset(left.dx, left.dy + cD / 2), z: 6),
      _AtomLayout(h, Offset(left.dx, left.dy - cD / 2), z: 7),
    ];
  }

  /// CH2ONode.ts
  static List<_AtomLayout> _ch2o() {
    final c = NitroElement.c;
    final o = NitroElement.o;
    final h = NitroElement.h;
    final cD = c.diameter;
    final left = Offset(cD / 2, cD / 2);
    final small = 0.165 * cD;
    final right = Offset(left.dx + cD / 2 + 0.25 * cD, left.dy);
    return [
      _AtomLayout(
          h, Offset(left.dx - cD / 2 + small, left.dy - cD / 2 + small),
          z: 0),
      _AtomLayout(c, left, z: 1),
      _AtomLayout(o, right, z: 2),
      _AtomLayout(
          h, Offset(left.dx - cD / 2 + small, left.dy + cD / 2 - small),
          z: 3),
    ];
  }

  /// CH3OHNode.ts
  static List<_AtomLayout> _ch3oh() {
    final c = NitroElement.c;
    final o = NitroElement.o;
    final h = NitroElement.h;
    final cD = c.diameter;
    final left = Offset(cD / 2, cD / 2);
    final right = Offset(left.dx + cD / 2 + 0.25 * cD, left.dy);
    return [
      _AtomLayout(h, Offset(left.dx, left.dy + cD / 2), z: 0),
      _AtomLayout(h, Offset(left.dx, left.dy - cD / 2), z: 1),
      _AtomLayout(c, left, z: 2),
      _AtomLayout(h, Offset(left.dx - cD / 2, left.dy), z: 3),
      _AtomLayout(h, Offset(right.dx + o.diameter / 2, right.dy), z: 4),
      _AtomLayout(o, right, z: 5),
    ];
  }

  /// C2H5OHNode.ts
  static List<_AtomLayout> _c2h5Oh() {
    final c = NitroElement.c;
    final o = NitroElement.o;
    final h = NitroElement.h;
    final cD = c.diameter;
    final left = Offset(cD / 2, cD / 2);
    final center = Offset(left.dx + cD / 2 + 0.25 * cD, left.dy);
    final right = Offset(center.dx + cD / 2, center.dy);
    return [
      _AtomLayout(h, Offset(center.dx, center.dy + cD / 2), z: 0),
      _AtomLayout(h, Offset(center.dx, center.dy - cD / 2), z: 1),
      _AtomLayout(c, center, z: 2),
      _AtomLayout(h, Offset(right.dx + o.diameter / 2, right.dy), z: 3),
      _AtomLayout(o, right, z: 4),
      _AtomLayout(h, Offset(left.dx - cD / 2, left.dy), z: 5),
      _AtomLayout(c, left, z: 6),
      _AtomLayout(h, Offset(left.dx, left.dy + cD / 2), z: 7),
      _AtomLayout(h, Offset(left.dx, left.dy - cD / 2), z: 8),
    ];
  }

  /// C2H5ClNode.ts
  static List<_AtomLayout> _c2h5Cl() {
    final c = NitroElement.c;
    final cl = NitroElement.cl;
    final h = NitroElement.h;
    final cD = c.diameter;
    final left = Offset(cD / 2, cD / 2);
    final center = Offset(left.dx + cD / 2 + 0.25 * cD, left.dy);
    final right = Offset(center.dx + 0.11 * cD + cl.diameter / 2, center.dy);
    return [
      _AtomLayout(h, Offset(center.dx, center.dy + cD / 2), z: 0),
      _AtomLayout(h, Offset(center.dx, center.dy - cD / 2), z: 1),
      _AtomLayout(c, center, z: 2),
      _AtomLayout(cl, right, z: 3),
      _AtomLayout(h, Offset(left.dx - cD / 2, left.dy), z: 4),
      _AtomLayout(c, left, z: 5),
      _AtomLayout(h, Offset(left.dx, left.dy + cD / 2), z: 6),
      _AtomLayout(h, Offset(left.dx, left.dy - cD / 2), z: 7),
    ];
  }

  /// P4Node.ts
  static List<_AtomLayout> _p4() {
    final p = NitroElement.p;
    final d = p.diameter;
    final top = Offset(d / 2, d / 2);
    return [
      _AtomLayout(
        p,
        Offset(top.dx - d / 2, top.dy + 0.2 * d),
        z: 0,
      ),
      _AtomLayout(p, Offset(top.dx + d / 2, top.dy + d / 2), z: 1),
      _AtomLayout(
        p,
        Offset(top.dx - d / 2 + 0.3 * d, top.dy + d / 2 + 0.2 * d),
        z: 2,
      ),
      _AtomLayout(p, top, z: 3),
    ];
  }

  /// PH3Node.ts
  static List<_AtomLayout> _ph3() {
    final p = NitroElement.p;
    final h = NitroElement.h;
    final d = p.diameter;
    final c = Offset(d / 2, d / 2);
    final hy = c.dy + d / 2 - 0.25 * d;
    return [
      _AtomLayout(h, Offset(c.dx - d / 2, hy), z: 0),
      _AtomLayout(h, Offset(c.dx + d / 2, hy), z: 1),
      _AtomLayout(p, c, z: 2),
      _AtomLayout(h, Offset(c.dx, c.dy + d / 2), z: 3),
    ];
  }

  /// PF3Node.ts
  static List<_AtomLayout> _pf3() {
    final p = NitroElement.p;
    final f = NitroElement.f;
    final d = p.diameter;
    final c = Offset(d / 2, d / 2);
    final fy = c.dy + d / 2 - 0.25 * d;
    return [
      _AtomLayout(f, Offset(c.dx - d / 2, fy), z: 0),
      _AtomLayout(f, Offset(c.dx + d / 2, fy), z: 1),
      _AtomLayout(p, c, z: 2),
      _AtomLayout(f, Offset(c.dx, c.dy + d / 2), z: 3),
    ];
  }

  /// PCl3Node.ts
  static List<_AtomLayout> _pcl3() {
    final p = NitroElement.p;
    final cl = NitroElement.cl;
    final d = p.diameter;
    final c = Offset(d / 2, d / 2);
    final cy = c.dy + d / 2 - 0.25 * d;
    return [
      _AtomLayout(cl, Offset(c.dx - d / 2, cy), z: 0),
      _AtomLayout(cl, Offset(c.dx + d / 2, cy), z: 1),
      _AtomLayout(p, c, z: 2),
      _AtomLayout(cl, Offset(c.dx, c.dy + d / 2), z: 3),
    ];
  }

  /// PCl5Node.ts
  static List<_AtomLayout> _pcl5() {
    final p = NitroElement.p;
    final cl = NitroElement.cl;
    final d = p.diameter;
    final c = Offset(d / 2, d / 2);
    return [
      _AtomLayout(cl, Offset(c.dx + d / 2, c.dy), z: 0),
      _AtomLayout(cl, Offset(c.dx, c.dy + d / 2), z: 1),
      _AtomLayout(
        cl,
        Offset(c.dx - d / 2 + 0.25 * d, c.dy - d / 2 + 0.25 * d),
        z: 2,
      ),
      _AtomLayout(p, c, z: 3),
      _AtomLayout(cl, Offset(c.dx, c.dy - d / 2), z: 4),
      _AtomLayout(
        cl,
        Offset(c.dx - d / 2 + 0.1 * d, c.dy + d / 2 - 0.1 * d),
        z: 5,
      ),
    ];
  }

  static Rect _boundsOf(List<_AtomLayout> atoms) {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    for (final a in atoms) {
      final r = a.element.diameter / 2;
      minX = math.min(minX, a.center.dx - r);
      minY = math.min(minY, a.center.dy - r);
      maxX = math.max(maxX, a.center.dx + r);
      maxY = math.max(maxY, a.center.dy + r);
    }
    const pad = 1.0;
    return Rect.fromLTRB(minX - pad, minY - pad, maxX + pad, maxY + pad);
  }
}

class _MoleculePainter extends CustomPainter {
  _MoleculePainter({
    required this.atoms,
    required this.origin,
    required this.scale,
  });

  final List<_AtomLayout> atoms;
  final Offset origin;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final ordered = [...atoms]..sort((a, b) => a.z.compareTo(b.z));
    for (final atom in ordered) {
      final center = Offset(
        (atom.center.dx - origin.dx) * scale,
        (atom.center.dy - origin.dy) * scale,
      );
      final radius = (atom.element.diameter / 2) * scale;
      _paintShadedSphere(canvas, center, radius, atom.element.color);
    }
  }

  void _paintShadedSphere(
    Canvas canvas,
    Offset center,
    double radius,
    Color main,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final highlight = Offset(
      center.dx - radius * 0.35,
      center.dy - radius * 0.35,
    );
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          ((highlight.dx - center.dx) / radius).clamp(-1.0, 1.0),
          ((highlight.dy - center.dy) / radius).clamp(-1.0, 1.0),
        ),
        colors: [
          Color.lerp(main, Colors.white, 0.55)!,
          main,
          Color.lerp(main, Colors.black, 0.35)!,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * scale.clamp(0.5, 2)
        ..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _MoleculePainter oldDelegate) =>
      oldDelegate.scale != scale || oldDelegate.atoms != atoms;
}

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/bce_element.dart';
import '../model/bce_molecule.dart';

/// Nitroglycerin-style molecule node for BCE particles / scales / bars.
///
/// Geometry adapted from nitroglycerin `*Node.ts` layouts (same approach as
/// KartosLab RPL `MoleculeIcon`) using [BceElement] colors from SHA ca115ad.
class BceMoleculeNode extends StatelessWidget {
  const BceMoleculeNode({
    super.key,
    required this.molecule,
    this.scale = 0.74,
  });

  final BceMolecule molecule;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final atoms = layoutsFor(molecule);
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

  static Size layoutSize(BceMolecule molecule, {double scale = 0.74}) {
    final bounds = _boundsOf(layoutsFor(molecule));
    return Size(bounds.width * scale, bounds.height * scale);
  }

  /// Atom layouts in model units (covalent-radius diameter space).
  static List<BceAtomLayout> layoutsFor(BceMolecule molecule) {
    switch (molecule.id) {
      case 'H2':
        return _horizontal([BceElement.h, BceElement.h]);
      case 'N2':
        return _horizontal([BceElement.n, BceElement.n]);
      case 'O2':
        return _horizontal([BceElement.o, BceElement.o]);
      case 'Cl2':
        return _horizontal([BceElement.cl, BceElement.cl]);
      case 'F2':
        return _horizontal([BceElement.f, BceElement.f]);
      case 'CO':
        return _horizontal([BceElement.c, BceElement.o]);
      case 'NO':
        return _horizontal([BceElement.n, BceElement.o]);
      case 'CO2':
        return _horizontal([BceElement.o, BceElement.c, BceElement.o]);
      case 'CS2':
        return _horizontal([BceElement.s, BceElement.c, BceElement.s]);
      case 'N2O':
        return _horizontal([BceElement.n, BceElement.n, BceElement.o]);
      case 'NO2':
        return _bent(BceElement.n, BceElement.o, BceElement.o, 134.0);
      case 'OF2':
        return _bent(BceElement.o, BceElement.f, BceElement.f, 103.0);
      case 'H2S':
        return _bent(BceElement.s, BceElement.h, BceElement.h, 92.0);
      case 'NH3':
        return _nh3();
      case 'H2O':
        return _h2o();
      case 'H2O2':
        return _h2o2();
      case 'CH4':
        return _ch4();
      case 'C':
        return [BceAtomLayout(BceElement.c, Offset(
          BceAtomLayout(BceElement.c, Offset.zero).diameter / 2,
          BceAtomLayout(BceElement.c, Offset.zero).diameter / 2,
        ))];
      case 'P':
        return [BceAtomLayout(BceElement.p, Offset(
          BceAtomLayout(BceElement.p, Offset.zero).diameter / 2,
          BceAtomLayout(BceElement.p, Offset.zero).diameter / 2,
        ))];
      case 'S':
        return [BceAtomLayout(BceElement.s, Offset(
          BceAtomLayout(BceElement.s, Offset.zero).diameter / 2,
          BceAtomLayout(BceElement.s, Offset.zero).diameter / 2,
        ))];
      case 'HF':
        return _horizontal([BceElement.h, BceElement.f]);
      case 'HCl':
        return _horizontal([BceElement.h, BceElement.cl]);
      case 'C2H2':
        return _c2h2();
      case 'C2H4':
        return _c2hx(4);
      case 'C2H6':
        return _c2hx(6);
      case 'CH3OH':
        return _ch3oh();
      case 'C2H5OH':
        return _c2h5oh();
      case 'N2O5':
        return _n2o5();
      case 'P2O5':
        return _p2o5();
      case 'PCl3':
        return _pcl3();
      case 'PCl5':
        return _pcl5();
      case 'PF3':
        return _pcl3(center: BceElement.p, ligand: BceElement.f);
      case 'PH3':
        return _nh3Like(BceElement.p, BceElement.h);
      case 'SO2':
        return _bent(BceElement.s, BceElement.o, BceElement.o, 119.0);
      case 'SO3':
        return _trigonal(BceElement.s, BceElement.o);
      case 'CH2O':
        return _ch2o();
      case 'P4':
        return _p4();
      default:
        return _horizontal(
          molecule.atoms.map((a) => a.element).toList(),
        );
    }
  }
}

class BceAtomLayout {
  const BceAtomLayout(this.element, this.center);
  final BceElement element;
  final Offset center;

  double get diameter {
    // nitroglycerin AtomNode.scaleRadius — same as RPL MoleculeIcon.
    const pMax = 110.0;
    const rate = 0.75;
    const modelToView = 0.11;
    final adjusted = pMax - rate * (pMax - element.covalentRadius);
    return 2 * modelToView * adjusted;
  }
}

Rect _boundsOf(List<BceAtomLayout> atoms) {
  if (atoms.isEmpty) return Rect.zero;
  var minX = double.infinity;
  var minY = double.infinity;
  var maxX = -double.infinity;
  var maxY = -double.infinity;
  for (final a in atoms) {
    final r = a.diameter / 2;
    minX = math.min(minX, a.center.dx - r);
    minY = math.min(minY, a.center.dy - r);
    maxX = math.max(maxX, a.center.dx + r);
    maxY = math.max(maxY, a.center.dy + r);
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

List<BceAtomLayout> _horizontal(List<BceElement> elements, {double overlap = 0.25}) {
  final layouts = <BceAtomLayout>[];
  var x = 0.0;
  for (var i = 0; i < elements.length; i++) {
    final e = elements[i];
    final d = BceAtomLayout(e, Offset.zero).diameter;
    if (i == 0) {
      layouts.add(BceAtomLayout(e, Offset(d / 2, d / 2)));
      x = d;
    } else {
      final prev = layouts.last;
      final step = (prev.diameter + d) / 2 * (1 - overlap);
      x = prev.center.dx + step;
      layouts.add(BceAtomLayout(e, Offset(x, math.max(prev.center.dy, d / 2))));
    }
  }
  return layouts;
}

List<BceAtomLayout> _h2o() {
  // nitroglycerin H2ONode: O center; H at left/right of O, y = O.bottom - 0.25*O.height
  final o = BceElement.o;
  final h = BceElement.h;
  final od = BceAtomLayout(o, Offset.zero).diameter;
  final ox = od;
  final oy = od;
  final oLeft = ox - od / 2;
  final oRight = ox + od / 2;
  final oBottom = oy + od / 2;
  final hy = oBottom - 0.25 * od;
  return [
    BceAtomLayout(o, Offset(ox, oy)),
    BceAtomLayout(h, Offset(oLeft, hy)),
    BceAtomLayout(h, Offset(oRight, hy)),
  ];
}

List<BceAtomLayout> _nh3() {
  // nitroglycerin NH3Node: N big; H left/right at N.bottom-0.25h; H bottom at N.centerX/bottom
  final n = BceElement.n;
  final h = BceElement.h;
  final nd = BceAtomLayout(n, Offset.zero).diameter;
  final nx = nd * 1.1;
  final ny = nd * 1.0;
  final nLeft = nx - nd / 2;
  final nRight = nx + nd / 2;
  final nBottom = ny + nd / 2;
  final sideY = nBottom - 0.25 * nd;
  return [
    BceAtomLayout(h, Offset(nLeft, sideY)),
    BceAtomLayout(h, Offset(nRight, sideY)),
    BceAtomLayout(n, Offset(nx, ny)),
    BceAtomLayout(h, Offset(nx, nBottom)),
  ];
}

List<BceAtomLayout> _ch4() {
  final c = BceElement.c;
  final h = BceElement.h;
  final cd = BceAtomLayout(c, Offset.zero).diameter;
  final hd = BceAtomLayout(h, Offset.zero).diameter;
  final cx = cd * 1.3;
  final cy = cd * 1.3;
  final dist = (cd + hd) / 2 * 0.72;
  return [
    BceAtomLayout(c, Offset(cx, cy)),
    BceAtomLayout(h, Offset(cx, cy - dist)),
    BceAtomLayout(h, Offset(cx, cy + dist)),
    BceAtomLayout(h, Offset(cx - dist, cy)),
    BceAtomLayout(h, Offset(cx + dist, cy)),
  ];
}

List<BceAtomLayout> _bent(
  BceElement center,
  BceElement a,
  BceElement b,
  double angleDeg,
) {
  final cd = BceAtomLayout(center, Offset.zero).diameter;
  final ad = BceAtomLayout(a, Offset.zero).diameter;
  final bd = BceAtomLayout(b, Offset.zero).diameter;
  final cx = cd * 1.2;
  final cy = cd * 1.1;
  final angle = angleDeg * math.pi / 180;
  final distA = (cd + ad) / 2 * 0.72;
  final distB = (cd + bd) / 2 * 0.72;
  return [
    BceAtomLayout(center, Offset(cx, cy)),
    BceAtomLayout(
      a,
      Offset(
        cx - distA * math.sin(angle / 2),
        cy + distA * math.cos(angle / 2),
      ),
    ),
    BceAtomLayout(
      b,
      Offset(
        cx + distB * math.sin(angle / 2),
        cy + distB * math.cos(angle / 2),
      ),
    ),
  ];
}

List<BceAtomLayout> _h2o2() {
  // HO–OH zig-zag
  final o = BceElement.o;
  final h = BceElement.h;
  final od = BceAtomLayout(o, Offset.zero).diameter;
  final hd = BceAtomLayout(h, Offset.zero).diameter;
  final oDist = od * 0.7;
  final hDist = (od + hd) / 2 * 0.7;
  final o1 = Offset(od, od * 1.2);
  final o2 = Offset(od + oDist, od * 0.9);
  return [
    BceAtomLayout(o, o1),
    BceAtomLayout(o, o2),
    BceAtomLayout(h, Offset(o1.dx - hDist * 0.7, o1.dy + hDist * 0.5)),
    BceAtomLayout(h, Offset(o2.dx + hDist * 0.7, o2.dy - hDist * 0.5)),
  ];
}

List<BceAtomLayout> _c2h2() {
  final c = BceElement.c;
  final h = BceElement.h;
  final cd = BceAtomLayout(c, Offset.zero).diameter;
  final hd = BceAtomLayout(h, Offset.zero).diameter;
  final cDist = cd * 0.65;
  final hDist = (cd + hd) / 2 * 0.7;
  final c1 = Offset(cd + hd, cd);
  final c2 = Offset(c1.dx + cDist, cd);
  return [
    BceAtomLayout(c, c1),
    BceAtomLayout(c, c2),
    BceAtomLayout(h, Offset(c1.dx - hDist, c1.dy)),
    BceAtomLayout(h, Offset(c2.dx + hDist, c2.dy)),
  ];
}

List<BceAtomLayout> _c2hx(int hCount) {
  final c = BceElement.c;
  final h = BceElement.h;
  final cd = BceAtomLayout(c, Offset.zero).diameter;
  final hd = BceAtomLayout(h, Offset.zero).diameter;
  final cDist = cd * 0.7;
  final hDist = (cd + hd) / 2 * 0.65;
  final c1 = Offset(cd * 1.4, cd * 1.3);
  final c2 = Offset(c1.dx + cDist, c1.dy);
  final out = <BceAtomLayout>[
    BceAtomLayout(c, c1),
    BceAtomLayout(c, c2),
  ];
  final perCarbon = hCount ~/ 2;
  for (var i = 0; i < perCarbon; i++) {
    final a = -math.pi / 2 + i * (math.pi / (perCarbon + 0.5));
    out.add(BceAtomLayout(
      h,
      Offset(c1.dx + hDist * math.cos(a + math.pi), c1.dy + hDist * math.sin(a + math.pi)),
    ));
    out.add(BceAtomLayout(
      h,
      Offset(c2.dx + hDist * math.cos(a), c2.dy + hDist * math.sin(a)),
    ));
  }
  return out;
}

List<BceAtomLayout> _ch3oh() {
  final c = BceElement.c;
  final o = BceElement.o;
  final h = BceElement.h;
  final cd = BceAtomLayout(c, Offset.zero).diameter;
  final od = BceAtomLayout(o, Offset.zero).diameter;
  final hd = BceAtomLayout(h, Offset.zero).diameter;
  final cx = cd * 1.3;
  final cy = cd * 1.3;
  final co = (cd + od) / 2 * 0.72;
  final ch = (cd + hd) / 2 * 0.65;
  final oh = (od + hd) / 2 * 0.65;
  final oPos = Offset(cx + co, cy);
  return [
    BceAtomLayout(c, Offset(cx, cy)),
    BceAtomLayout(o, oPos),
    BceAtomLayout(h, Offset(cx - ch, cy)),
    BceAtomLayout(h, Offset(cx, cy - ch)),
    BceAtomLayout(h, Offset(cx, cy + ch)),
    BceAtomLayout(h, Offset(oPos.dx + oh, oPos.dy)),
  ];
}

List<BceAtomLayout> _c2h5oh() {
  final base = _c2hx(5);
  // Replace last H near second C with O–H roughly
  final o = BceElement.o;
  final h = BceElement.h;
  final od = BceAtomLayout(o, Offset.zero).diameter;
  final hd = BceAtomLayout(h, Offset.zero).diameter;
  final c2 = base[1].center;
  final oPos = Offset(c2.dx + od * 0.55, c2.dy - od * 0.2);
  return [
    ...base.take(2),
    ...base.skip(2).take(5),
    BceAtomLayout(o, oPos),
    BceAtomLayout(h, Offset(oPos.dx + (od + hd) / 2 * 0.6, oPos.dy)),
  ];
}

List<BceAtomLayout> _n2o5() {
  // N–N with oxygens around — compact nitroglycerin-like cluster
  final n = BceElement.n;
  final o = BceElement.o;
  final nd = BceAtomLayout(n, Offset.zero).diameter;
  final od = BceAtomLayout(o, Offset.zero).diameter;
  final n1 = Offset(nd * 1.2, nd * 1.4);
  final n2 = Offset(n1.dx + nd * 0.7, n1.dy);
  final dist = (nd + od) / 2 * 0.7;
  return [
    BceAtomLayout(n, n1),
    BceAtomLayout(n, n2),
    BceAtomLayout(o, Offset(n1.dx - dist, n1.dy)),
    BceAtomLayout(o, Offset(n1.dx, n1.dy - dist)),
    BceAtomLayout(o, Offset((n1.dx + n2.dx) / 2, n1.dy + dist)),
    BceAtomLayout(o, Offset(n2.dx + dist, n2.dy)),
    BceAtomLayout(o, Offset(n2.dx, n2.dy - dist)),
  ];
}

List<BceAtomLayout> _p2o5() {
  final p = BceElement.p;
  final o = BceElement.o;
  final pd = BceAtomLayout(p, Offset.zero).diameter;
  final od = BceAtomLayout(o, Offset.zero).diameter;
  final p1 = Offset(pd * 1.2, pd * 1.4);
  final p2 = Offset(p1.dx + pd * 0.75, p1.dy);
  final dist = (pd + od) / 2 * 0.7;
  return [
    BceAtomLayout(p, p1),
    BceAtomLayout(p, p2),
    BceAtomLayout(o, Offset(p1.dx - dist, p1.dy)),
    BceAtomLayout(o, Offset(p1.dx, p1.dy - dist)),
    BceAtomLayout(o, Offset((p1.dx + p2.dx) / 2, p1.dy + dist)),
    BceAtomLayout(o, Offset(p2.dx + dist, p2.dy)),
    BceAtomLayout(o, Offset(p2.dx, p2.dy - dist)),
  ];
}

List<BceAtomLayout> _pcl3({
  BceElement center = BceElement.p,
  BceElement ligand = BceElement.cl,
}) {
  final cd = BceAtomLayout(center, Offset.zero).diameter;
  final ld = BceAtomLayout(ligand, Offset.zero).diameter;
  final cx = cd * 1.3;
  final cy = cd * 1.3;
  final dist = (cd + ld) / 2 * 0.72;
  return [
    BceAtomLayout(center, Offset(cx, cy)),
    for (var i = 0; i < 3; i++)
      BceAtomLayout(
        ligand,
        Offset(
          cx + dist * math.cos(i * 2 * math.pi / 3 - math.pi / 2),
          cy + dist * math.sin(i * 2 * math.pi / 3 - math.pi / 2),
        ),
      ),
  ];
}

List<BceAtomLayout> _pcl5() {
  final p = BceElement.p;
  final cl = BceElement.cl;
  final pd = BceAtomLayout(p, Offset.zero).diameter;
  final cld = BceAtomLayout(cl, Offset.zero).diameter;
  final cx = pd * 1.5;
  final cy = pd * 1.5;
  final dist = (pd + cld) / 2 * 0.7;
  return [
    BceAtomLayout(p, Offset(cx, cy)),
    for (var i = 0; i < 5; i++)
      BceAtomLayout(
        cl,
        Offset(
          cx + dist * math.cos(i * 2 * math.pi / 5 - math.pi / 2),
          cy + dist * math.sin(i * 2 * math.pi / 5 - math.pi / 2),
        ),
      ),
  ];
}

List<BceAtomLayout> _nh3Like(BceElement center, BceElement ligand) {
  final cd = BceAtomLayout(center, Offset.zero).diameter;
  final ld = BceAtomLayout(ligand, Offset.zero).diameter;
  final cx = cd * 1.2;
  final cy = cd * 1.1;
  final dist = (cd + ld) / 2 * 0.7;
  return [
    BceAtomLayout(center, Offset(cx, cy)),
    BceAtomLayout(ligand, Offset(cx, cy - dist)),
    BceAtomLayout(ligand, Offset(cx - dist * 0.9, cy + dist * 0.5)),
    BceAtomLayout(ligand, Offset(cx + dist * 0.9, cy + dist * 0.5)),
  ];
}

List<BceAtomLayout> _trigonal(BceElement center, BceElement ligand) {
  final cd = BceAtomLayout(center, Offset.zero).diameter;
  final ld = BceAtomLayout(ligand, Offset.zero).diameter;
  final cx = cd * 1.3;
  final cy = cd * 1.3;
  final dist = (cd + ld) / 2 * 0.72;
  return [
    BceAtomLayout(center, Offset(cx, cy)),
    for (var i = 0; i < 3; i++)
      BceAtomLayout(
        ligand,
        Offset(
          cx + dist * math.cos(i * 2 * math.pi / 3 - math.pi / 2),
          cy + dist * math.sin(i * 2 * math.pi / 3 - math.pi / 2),
        ),
      ),
  ];
}

List<BceAtomLayout> _ch2o() {
  final c = BceElement.c;
  final o = BceElement.o;
  final h = BceElement.h;
  final cd = BceAtomLayout(c, Offset.zero).diameter;
  final od = BceAtomLayout(o, Offset.zero).diameter;
  final hd = BceAtomLayout(h, Offset.zero).diameter;
  final cx = cd * 1.2;
  final cy = cd * 1.2;
  return [
    BceAtomLayout(c, Offset(cx, cy)),
    BceAtomLayout(o, Offset(cx + (cd + od) / 2 * 0.75, cy)),
    BceAtomLayout(h, Offset(cx - (cd + hd) / 2 * 0.6, cy - (cd + hd) / 2 * 0.5)),
    BceAtomLayout(h, Offset(cx - (cd + hd) / 2 * 0.6, cy + (cd + hd) / 2 * 0.5)),
  ];
}

List<BceAtomLayout> _p4() {
  final p = BceElement.p;
  final pd = BceAtomLayout(p, Offset.zero).diameter;
  final dist = pd * 0.65;
  final c = Offset(pd * 1.5, pd * 1.5);
  return [
    BceAtomLayout(p, Offset(c.dx, c.dy - dist)),
    BceAtomLayout(p, Offset(c.dx - dist * 0.9, c.dy + dist * 0.5)),
    BceAtomLayout(p, Offset(c.dx + dist * 0.9, c.dy + dist * 0.5)),
    BceAtomLayout(p, Offset(c.dx, c.dy + dist * 0.15)),
  ];
}

class _MoleculePainter extends CustomPainter {
  _MoleculePainter({
    required this.atoms,
    required this.origin,
    required this.scale,
  });

  final List<BceAtomLayout> atoms;
  final Offset origin;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale);
    canvas.translate(-origin.dx, -origin.dy);
    final ordered = [...atoms]..sort((a, b) => b.diameter.compareTo(a.diameter));
    for (final a in ordered) {
      _paintAtom(canvas, a);
    }
    canvas.restore();
  }

  void _paintAtom(Canvas canvas, BceAtomLayout a) {
    final r = a.diameter / 2;
    final c = a.center;
    final base = Color(a.element.colorArgb);
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(c.dx - r * 0.35, c.dy - r * 0.35),
        r * 1.2,
        [
          Color.lerp(base, Colors.white, 0.55)!,
          base,
          Color.lerp(base, Colors.black, 0.25)!,
        ],
        const [0.0, 0.45, 1.0],
      );
    canvas.drawCircle(c, r, paint);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _MoleculePainter oldDelegate) =>
      oldDelegate.atoms != atoms || oldDelegate.scale != scale;
}

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/bond.dart';
import '../model/geometry.dart';
import '../model/molecule.dart';
import '../model/molecule_shapes_model.dart';
import '../model/pair_group.dart';
import '../model/vec3.dart';
import 'element_colors.dart';
import 'lone_pair_geometry_data.dart';
import 'molecule_camera.dart';
import 'molecule_shapes_colors.dart';

enum _DrawableKind { bond, lonePair, atom, angle }

class _Drawable {
  _Drawable({
    required this.depth,
    required this.kind,
    required this.paint,
  });

  final double depth;
  final _DrawableKind kind;
  final void Function(Canvas canvas) paint;
}

/// Renders the model-screen molecule with perspective projection and depth sort.
class MoleculePainter extends CustomPainter {
  MoleculePainter({
    required this.model,
    required this.camera,
    this.layoutOrigin = Offset.zero,
  });

  final MoleculeShapesModel model;
  final MoleculeCamera camera;
  final Offset layoutOrigin;

  static const atomRadius = 2.0;
  static const bondRadius = 0.5;
  static const bondAngleRadius = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = MoleculeShapesColors.background);
    final molecule = model.molecule;
    final center = molecule.centralAtom;
    if (center == null) {
      return;
    }

    final drawables = <_Drawable>[];
    final quat = model.quaternion;

    void addAtom(PairGroup group, Color color) {
      final world = quat.rotate(group.position);
      final screen = camera.project(world, size);
      final scale = camera.scaleAt(world, size);
      final r = atomRadius * scale;
      drawables.add(
        _Drawable(
          depth: camera.depth(world),
          kind: _DrawableKind.atom,
          paint: (c) {
            final shade = _sphereShader(screen, r, color);
            c.drawCircle(screen, r, Paint()..shader = shade);
            c.drawCircle(
              screen,
              r,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1
                ..color = Colors.black.withValues(alpha: 0.35),
            );
            if (group.element != null && group.element!.isNotEmpty) {
              final tp = TextPainter(
                text: TextSpan(
                  text: group.element,
                  style: TextStyle(
                    color: _labelColorFor(color),
                    fontSize: math.max(10, r * 0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();
              tp.paint(c, screen.translate(-tp.width / 2, -tp.height / 2));
            }
          },
        ),
      );
    }

    Color colorFor(PairGroup group, {required bool central}) {
      if (group.element != null) {
        return elementColor(group.element);
      }
      return central ? MoleculeShapesColors.centralAtom : MoleculeShapesColors.atom;
    }

    addAtom(center, colorFor(center, central: true));

    for (final atom in molecule.radialAtoms) {
      addAtom(atom, colorFor(atom, central: false));
    }

    for (final bond in molecule.bondsAround(center)) {
      final other = bond.other(center);
      if (other.isLonePair) {
        continue;
      }
      _addBondDrawables(drawables, size, quat, center, other, bond);
    }

    if (model.showLonePairs) {
      for (final lone in molecule.radialLonePairs) {
        _addLonePairDrawables(drawables, size, quat, center, lone);
      }
    }
    if (model.showOuterLonePairs) {
      for (final lone in molecule.distantLonePairs) {
        final parent = molecule.parentBond(lone)?.other(lone);
        if (parent != null) {
          _addLonePairDrawables(drawables, size, quat, parent, lone);
        }
      }
    }

    if (model.showBondAngles) {
      _addAngleDrawables(drawables, size, quat, molecule);
    }

    drawables.sort((a, b) => b.depth.compareTo(a.depth)); // far first
    for (final d in drawables) {
      d.paint(canvas);
    }
  }

  void _addBondDrawables(
    List<_Drawable> drawables,
    Size size,
    Quat quat,
    PairGroup a,
    PairGroup b,
    Bond bond,
  ) {
    final start = quat.rotate(a.position);
    final end = quat.rotate(b.position);
    final mid = start.plus(end).times(0.5);
    final toward = end.minus(start);
    final length = toward.magnitude;
    if (length < 1e-6) {
      return;
    }
    final towardN = toward.normalized();
    final cameraPos = camera.position;
    var perpendicular = towardN.cross(mid.minus(cameraPos).normalized());
    if (perpendicular.magnitude < 1e-6) {
      perpendicular = towardN.cross(const Vec3(0, 1, 0));
    }
    if (perpendicular.magnitude < 1e-6) {
      perpendicular = towardN.cross(const Vec3(1, 0, 0));
    }
    perpendicular = perpendicular.normalized();
    final separation = bondRadius * (12 / 5);
    final offsets = <Vec3>[];
    switch (bond.order) {
      case 1:
        offsets.add(Vec3.zero);
      case 2:
        offsets
          ..add(perpendicular.times(separation / 2))
          ..add(perpendicular.times(-separation / 2));
      case 3:
        offsets
          ..add(Vec3.zero)
          ..add(perpendicular.times(separation))
          ..add(perpendicular.times(-separation));
      default:
        return;
    }

    for (final offset in offsets) {
      final s = start.plus(offset);
      final e = end.plus(offset);
      final mid = s.plus(e).times(0.5);
      final depth = camera.depth(mid);
      // BondView: two half-cylinders share MoleculeShapesColors.bondProperty
      // (not adjacent-atom CPK). Draw as two segments with the same color.
      drawables.add(
        _Drawable(
          depth: depth,
          kind: _DrawableKind.bond,
          paint: (c) {
            final p0 = camera.project(s, size);
            final p1 = camera.project(mid, size);
            final p2 = camera.project(e, size);
            final scale = camera.scaleAt(mid, size);
            final stroke = math.max(2.0, bondRadius * 2.2 * scale);
            final paint = Paint()
              ..shader = ui.Gradient.linear(
                Offset(p0.dx, p0.dy - stroke),
                Offset(p0.dx, p0.dy + stroke),
                const [
                  Color(0xFFFFFFFF),
                  Color(0xFFE8E8E8),
                  Color(0xFF9A9A9A),
                ],
                const [0.0, 0.4, 1.0],
              )
              ..strokeWidth = stroke
              ..strokeCap = StrokeCap.round;
            c.drawLine(p0, p1, paint);
            c.drawLine(p1, p2, paint);
          },
        ),
      );
    }
  }

  void _addLonePairDrawables(
    List<_Drawable> drawables,
    Size size,
    Quat quat,
    PairGroup parent,
    PairGroup lone,
  ) {
    final parentWorld = quat.rotate(parent.position);
    final loneWorld = quat.rotate(lone.position);
    final offset = loneWorld.minus(parentWorld);
    final orientation = offset.magnitude > 0 ? offset.normalized() : Vec3.xUnit;
    // LonePairView: shell rooted at parent, +Y → orientation, shellScale 2.5.
    const shellScale = 2.5;
    final align = Quat.rotateAToB(const Vec3(0, 1, 0), orientation);

    final verts = LonePairGeometryData.vertices;
    final tris = LonePairGeometryData.triangles;
    final worldVerts = <Vec3>[];
    for (var i = 0; i < verts.length; i += 3) {
      final local = Vec3(verts[i], verts[i + 1], verts[i + 2]).times(shellScale);
      worldVerts.add(parentWorld.plus(align.rotate(local)));
    }

    for (var t = 0; t < tris.length; t += 3) {
      final a = worldVerts[tris[t]];
      final b = worldVerts[tris[t + 1]];
      final c = worldVerts[tris[t + 2]];
      final centroid = a.plus(b).plus(c).times(1 / 3);
      // Back-face cull in camera space roughly.
      final normal = b.minus(a).cross(c.minus(a));
      final toCam = camera.position.minus(centroid);
      if (normal.dot(toCam) <= 0) {
        continue;
      }
      drawables.add(
        _Drawable(
          depth: camera.depth(centroid),
          kind: _DrawableKind.lonePair,
          paint: (canvas) {
            final pa = camera.project(a, size);
            final pb = camera.project(b, size);
            final pc = camera.project(c, size);
            final path = Path()
              ..moveTo(pa.dx, pa.dy)
              ..lineTo(pb.dx, pb.dy)
              ..lineTo(pc.dx, pc.dy)
              ..close();
            // Soft Lambert-ish shade from camera-facing normal.
            final n = normal.normalized();
            final light = toCam.normalized();
            final shade = (0.35 + 0.65 * n.dot(light).clamp(0.0, 1.0));
            final base = MoleculeShapesColors.lonePairShell;
            canvas.drawPath(
              path,
              Paint()
                ..color = base.withValues(alpha: (base.a * shade).clamp(0.15, 0.85))
                ..style = PaintingStyle.fill
                ..isAntiAlias = true,
            );
          },
        ),
      );
    }

    // Electrons at local (±0.75, 5, 0) after Y→orientation, as LonePairView.
    final e1Local = align.rotate(const Vec3(0.75, 5, 0));
    final e2Local = align.rotate(const Vec3(-0.75, 5, 0));
    final e1 = parentWorld.plus(e1Local);
    final e2 = parentWorld.plus(e2Local);
    for (final e in [e1, e2]) {
      drawables.add(
        _Drawable(
          depth: camera.depth(e),
          kind: _DrawableKind.lonePair,
          paint: (c) {
            final er = math.max(2.0, 0.25 * camera.scaleAt(e, size));
            c.drawCircle(
              camera.project(e, size),
              er,
              Paint()..color = MoleculeShapesColors.lonePairElectron,
            );
          },
        ),
      );
    }
  }

  void _addAngleDrawables(
    List<_Drawable> drawables,
    Size size,
    Quat quat,
    Molecule molecule,
  ) {
    final atoms = molecule.radialAtoms;
    final bondQuantity = atoms.length;
    // Camera orientation in molecule local frame.
    final inv = Quat(-quat.x, -quat.y, -quat.z, quat.w);
    final localCamOrientation = inv.rotate(camera.position).normalized().negated();

    for (var i = 0; i < atoms.length; i++) {
      for (var j = i + 1; j < atoms.length; j++) {
        final a = atoms[i];
        final b = atoms[j];
        final aDir = a.orientation;
        final bDir = b.orientation;
        final brightness =
            _angleBrightness(aDir, bDir, localCamOrientation, bondQuantity);
        if (brightness <= 0) {
          continue;
        }
        final angle = angleDegreesBetween(aDir, bDir);
        final midpointUnit = aDir.plus(bDir).magnitude > 1e-6
            ? aDir.plus(bDir).normalized()
            : aDir.cross(const Vec3(0, 0, 1)).normalized();
        final midLocal = midpointUnit.times(bondAngleRadius);
        final midWorld = quat.rotate(midLocal);
        final centerWorld = quat.rotate(Vec3.zero);
        drawables.add(
          _Drawable(
            depth: camera.depth(midWorld),
            kind: _DrawableKind.angle,
            paint: (c) {
              final center = camera.project(centerWorld, size);
              final mid = camera.project(midWorld, size);
              final aScreen =
                  camera.project(quat.rotate(aDir.times(bondAngleRadius)), size);
              final bScreen =
                  camera.project(quat.rotate(bDir.times(bondAngleRadius)), size);
              final path = Path()
                ..moveTo(aScreen.dx, aScreen.dy)
                ..quadraticBezierTo(mid.dx, mid.dy, bScreen.dx, bScreen.dy);
              c.drawPath(
                path,
                Paint()
                  ..color =
                      MoleculeShapesColors.bondAngleArc.withValues(alpha: brightness)
                  ..strokeWidth = 2
                  ..style = PaintingStyle.stroke,
              );
              final label = formatBondAngleDegrees(angle);
              final tp = TextPainter(
                text: TextSpan(
                  text: label,
                  style: TextStyle(
                    color: MoleculeShapesColors.bondAngleReadout
                        .withValues(alpha: brightness),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();
              tp.paint(
                c,
                Offset(
                  (center.dx + mid.dx) / 2 - tp.width / 2,
                  (center.dy + mid.dy) / 2 - tp.height / 2,
                ),
              );
            },
          ),
        );
      }
    }
  }

  static double _angleBrightness(
    Vec3 aDir,
    Vec3 bDir,
    Vec3 localCameraOrientation,
    int bondQuantity,
  ) {
    if (bondQuantity <= 2) {
      return 1;
    }
    final brightness = aDir.cross(bDir).dot(localCameraOrientation).abs();
    const low = [0.0, 0.0, 0.0, 0.1, 0.35, 0.45, 0.5];
    const high = [0.0, 0.0, 0.0, 0.5, 0.55, 0.65, 0.75];
    final idx = bondQuantity.clamp(0, 6);
    final lowT = low[idx];
    final highT = high[idx];
    return ((brightness / (highT - lowT)) - lowT / (highT - lowT)).clamp(0.0, 1.0);
  }

  static Color _labelColorFor(Color background) {
    final luminance =
        (0.299 * background.r + 0.587 * background.g + 0.114 * background.b);
    return luminance > 0.6 ? Colors.black : Colors.white;
  }

  static ui.Gradient _sphereShader(Offset center, double r, Color color) {
    final highlight = Color.lerp(color, Colors.white, 0.55)!;
    final mid = Color.lerp(color, Colors.white, 0.08)!;
    final shade = Color.lerp(color, Colors.black, 0.42)!;
    return ui.Gradient.radial(
      center.translate(-r * 0.38, -r * 0.42),
      r * 1.25,
      [highlight, mid, color, shade],
      const [0.0, 0.28, 0.62, 1.0],
    );
  }

  @override
  bool shouldRepaint(covariant MoleculePainter oldDelegate) => true;
}

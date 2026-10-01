import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/vec3.dart';
import 'lone_pair_geometry_data.dart';
import 'molecule_shapes_colors.dart';

/// Bonding / Lone Pair row preview matching `BondGroupNode.getBondDataURL`.
///
/// Source hides the central atom and renders an orthographic snapshot of the
/// peripheral atom + bond(s), or the lone-pair balloon. No text labels.
class BondThumbnailPainter extends CustomPainter {
  BondThumbnailPainter({required this.order});

  final int order;

  @override
  void paint(Canvas canvas, Size size) {
    // Transparent — panel fill shows through (BondGroupNode uses clearColor bg
    // but the chrome image is the molecule only, centered in the hit overlay).
    if (order == 0) {
      _paintLonePair(canvas, size);
    } else {
      _paintBond(canvas, size);
    }
  }

  void _paintBond(Canvas canvas, Size size) {
    // Layout tuned to BondGroupNode ortho framing: bond along +X, atom on right.
    final cy = size.height * 0.5;
    final atomR = size.height * 0.38;
    final right = size.width - atomR - 4;
    final left = size.width * 0.08;
    final midX = (left + right) * 0.55;
    final stroke = math.max(3.0, size.height * 0.12);
    final gap = order == 1 ? 0.0 : stroke * 1.15;

    for (var i = 0; i < order; i++) {
      final dy = (i - (order - 1) / 2) * gap;
      final y0 = cy + dy;
      final p0 = Offset(left, y0);
      final p1 = Offset(right - atomR * 0.55, y0);
      // Shaded cylinder strip (bondProperty white with lighting).
      final paint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(midX, y0 - stroke),
          Offset(midX, y0 + stroke),
          [
            const Color(0xFFFFFFFF),
            MoleculeShapesColors.bond,
            const Color(0xFF888888),
          ],
          const [0.0, 0.45, 1.0],
        )
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(p0, p1, paint);
    }

    _drawSphere(
      canvas,
      Offset(right, cy),
      atomR,
      MoleculeShapesColors.atom,
    );
  }

  void _paintLonePair(Canvas canvas, Size size) {
    // Balloon along +X in the thumbnail (source orients Y up in 3D, camera
    // looks down Z — balloon appears as a teardrop pointing right).
    final scale = size.height * 0.42;
    final origin = Offset(size.width * 0.12, size.height * 0.55);
    // Map local balloon (Y-up axis) to screen: local Y → screen +X, local X → -Y.
    Offset project(Vec3 v) {
      return Offset(
        origin.dx + v.y * scale,
        origin.dy - v.x * scale,
      );
    }

    final verts = LonePairGeometryData.vertices;
    final tris = LonePairGeometryData.triangles;
    final projected = <Offset>[];
    for (var i = 0; i < verts.length; i += 3) {
      projected.add(project(Vec3(verts[i], verts[i + 1], verts[i + 2])));
    }

    final fill = Paint()
      ..color = MoleculeShapesColors.lonePairShell
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    for (var t = 0; t < tris.length; t += 3) {
      final a = projected[tris[t]];
      final b = projected[tris[t + 1]];
      final c = projected[tris[t + 2]];
      // Simple 2D facing: keep upward-ish triangles.
      final cross = (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);
      if (cross <= 0) {
        continue;
      }
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(c.dx, c.dy)
          ..close(),
        fill,
      );
    }

    // Electrons at local (±0.75, 5) → after same projection.
    final e1 = project(const Vec3(0.75, 5, 0));
    final e2 = project(const Vec3(-0.75, 5, 0));
    final er = math.max(2.5, size.height * 0.06);
    final ep = Paint()..color = MoleculeShapesColors.lonePairElectron;
    canvas.drawCircle(e1, er, ep);
    canvas.drawCircle(e2, er, ep);
  }

  void _drawSphere(Canvas canvas, Offset center, double r, Color color) {
    final highlight = Color.lerp(color, Colors.white, 0.5)!;
    final shade = Color.lerp(color, Colors.black, 0.35)!;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          center.translate(-r * 0.35, -r * 0.35),
          r * 1.15,
          [highlight, color, shade],
          const [0.0, 0.5, 1.0],
        ),
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withValues(alpha: 0.3),
    );
  }

  @override
  bool shouldRepaint(covariant BondThumbnailPainter oldDelegate) =>
      oldDelegate.order != order;
}

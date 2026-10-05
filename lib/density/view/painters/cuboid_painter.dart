import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/density_texture_cache.dart';
import '../../density_colors.dart';
import '../../render/density_mvt.dart';
import '../../render/density_render_data.dart';
import '../../solver/density_relation.dart';

class CuboidPainter extends CustomPainter {
  CuboidPainter(this.data);

  final DensityRenderData data;

  /// Screen depth as a fraction of cube side; matches PhET isometric cuboids.
  static const double _iso = 0.42;

  @override
  void paint(Canvas canvas, Size size) {
    final mvt = data.mvt;
    // Lower (world y) first so a stacked cube is not painted over by its support.
    final ordered = [...data.cubes]..sort((a, b) {
        final dy = a.center.y.compareTo(b.center.y);
        if (dy != 0) return dy;
        return a.center.x.compareTo(b.center.x);
      });
    for (final cube in ordered) {
      _paintCube(canvas, mvt, cube);
    }
  }

  void _paintCube(Canvas canvas, DensityMvt mvt, DensityCubeView cube) {
    final side = DensityRelation.cubeSideLength(cube.volume);
    final front = mvt.cubeFrontRect(cube.center, cube.volume);
    final depth = mvt.toScreenDelta(side) * _iso;
    final color = cube.color;
    // Wider right face, shorter top — PhET camera is slightly above-right.
    final depthOffset = Offset(depth * 0.72, -depth * 0.42);

    final fr = front.bottomRight;
    final fl = front.bottomLeft;
    final tl = front.topLeft;
    final tr = front.topRight;
    final trd = tr + depthOffset;
    final tld = tl + depthOffset;
    final frd = fr + depthOffset;

    final texture = DensityTextureCache.imageForBlock(
      materialId: cube.materialId,
      colorArgb: cube.colorArgb,
    );

    // Back-to-front: right, top, front.
    _paintFace(
      canvas,
      [tr, trd, frd, fr],
      texture,
      _shade(color, -0.28),
      lit: 0.72,
    );
    _paintFace(
      canvas,
      [tl, tr, trd, tld],
      texture,
      _shade(color, 0.16),
      lit: 1.0,
    );
    _paintFace(
      canvas,
      [tl, tr, fr, fl],
      texture,
      color,
      lit: 0.88,
    );

    final outline = Path()
      ..moveTo(fl.dx, fl.dy)
      ..lineTo(tl.dx, tl.dy)
      ..lineTo(tld.dx, tld.dy)
      ..lineTo(trd.dx, trd.dy)
      ..lineTo(frd.dx, frd.dy)
      ..lineTo(fr.dx, fr.dy)
      ..close()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(fr.dx, fr.dy)
      ..moveTo(tr.dx, tr.dy)
      ..lineTo(trd.dx, trd.dy);
    canvas.drawPath(
      outline,
      Paint()
        ..color = cube.grabbed ? const Color(0xFF111827) : const Color(0x89000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cube.grabbed ? 2.5 : 1.2
        ..strokeJoin = StrokeJoin.round,
    );

    _paintTag(canvas, front, cube.tag);
    if (cube.showMassLabel) {
      _paintMass(canvas, front, cube.massKg);
    }
  }

  void _paintFace(
    Canvas canvas,
    List<Offset> quad,
    ui.Image? texture,
    Color solid, {
    required double lit,
  }) {
    if (texture == null) {
      final path = Path()
        ..moveTo(quad[0].dx, quad[0].dy)
        ..lineTo(quad[1].dx, quad[1].dy)
        ..lineTo(quad[2].dx, quad[2].dy)
        ..lineTo(quad[3].dx, quad[3].dy)
        ..close();
      canvas.drawPath(path, Paint()..color = solid);
      return;
    }
    final tw = texture.width.toDouble();
    final th = texture.height.toDouble();
    final positions = Float32List.fromList([
      quad[0].dx, quad[0].dy,
      quad[1].dx, quad[1].dy,
      quad[2].dx, quad[2].dy,
      quad[0].dx, quad[0].dy,
      quad[2].dx, quad[2].dy,
      quad[3].dx, quad[3].dy,
    ]);
    final uvs = Float32List.fromList([
      0, 0, tw, 0, tw, th,
      0, 0, tw, th, 0, th,
    ]);
    final b = (lit * 255).round().clamp(40, 255);
    final c = Color.fromARGB(255, b, b, b).toARGB32();
    final colors = Int32List.fromList([c, c, c, c, c, c]);
    canvas.drawVertices(
      ui.Vertices.raw(
        ui.VertexMode.triangles,
        positions,
        textureCoordinates: uvs,
        colors: colors,
      ),
      BlendMode.modulate,
      Paint()
        ..shader = ImageShader(
          texture,
          TileMode.repeated,
          TileMode.repeated,
          Matrix4.identity().storage,
        )
        ..isAntiAlias = true,
    );
  }

  void _paintTag(Canvas canvas, Rect front, String tag) {
    final tp = TextPainter(
      text: TextSpan(
        text: tag,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    const pad = Offset(4, 3);
    final origin = front.topLeft + const Offset(4, 4);
    final bg = Rect.fromLTWH(
      origin.dx,
      origin.dy,
      tp.width + pad.dx * 2,
      tp.height + pad.dy * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bg, const Radius.circular(3)),
      Paint()..color = const Color(0xCC111827),
    );
    tp.paint(canvas, origin + pad);
  }

  void _paintMass(Canvas canvas, Rect front, double massKg) {
    final label = '${massKg.toStringAsFixed(2)} kg';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final origin = Offset(
      front.center.dx - tp.width / 2,
      front.bottom + 4,
    );
    final bg = Rect.fromLTWH(
      origin.dx - 4,
      origin.dy - 2,
      tp.width + 8,
      tp.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bg, const Radius.circular(3)),
      Paint()..color = Color(DensityColors.massLabelBackground),
    );
    tp.paint(canvas, origin);
  }

  Color _shade(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(CuboidPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.data.cubes.length != data.cubes.length;
}

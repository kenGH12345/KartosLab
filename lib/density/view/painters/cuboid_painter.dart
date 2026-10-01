import 'package:flutter/material.dart';

import '../../data/density_texture_cache.dart';
import '../../density_colors.dart';
import '../../render/density_mvt.dart';
import '../../render/density_render_data.dart';
import '../../solver/density_relation.dart';

class CuboidPainter extends CustomPainter {
  CuboidPainter(this.data);

  final DensityRenderData data;

  static const double _iso = 0.28;

  @override
  void paint(Canvas canvas, Size size) {
    final mvt = data.mvt;
    final ordered = [...data.cubes]
      ..sort((a, b) => b.center.y.compareTo(a.center.y));
    for (final cube in ordered) {
      _paintCube(canvas, mvt, cube);
    }
  }

  void _paintCube(Canvas canvas, DensityMvt mvt, DensityCubeView cube) {
    final side = DensityRelation.cubeSideLength(cube.volume);
    final front = mvt.cubeFrontRect(cube.center, cube.volume);
    final depth = mvt.toScreenDelta(side) * _iso;
    final color = cube.color;
    final top = _shade(color, 0.18);
    final sideColor = _shade(color, -0.22);

    final fr = front.bottomRight;
    final tl = front.topLeft;
    final tr = front.topRight;
    final depthOffset = Offset(-depth * 0.55, -depth * 0.85);

    final sidePath = Path()
      ..moveTo(fr.dx, fr.dy)
      ..lineTo((fr + depthOffset).dx, (fr + depthOffset).dy)
      ..lineTo((tr + depthOffset).dx, (tr + depthOffset).dy)
      ..lineTo(tr.dx, tr.dy)
      ..close();
    canvas.drawPath(sidePath, Paint()..color = sideColor);

    final topPath = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo((tr + depthOffset).dx, (tr + depthOffset).dy)
      ..lineTo((tl + depthOffset).dx, (tl + depthOffset).dy)
      ..close();
    canvas.drawPath(topPath, Paint()..color = top);

    _paintFrontFace(canvas, front, cube, color);
    canvas.drawRect(
      front,
      Paint()
        ..color = cube.grabbed ? const Color(0xFF111827) : const Color(0x89000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cube.grabbed ? 2.5 : 1.2,
    );

    _paintTag(canvas, front, cube.tag);
    if (cube.showMassLabel) {
      _paintMass(canvas, front, cube.massKg);
    }
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

  void _paintFrontFace(
    Canvas canvas,
    Rect front,
    DensityCubeView cube,
    Color fallback,
  ) {
    final texture = DensityTextureCache.imageForBlock(
      materialId: cube.materialId,
      colorArgb: cube.colorArgb,
    );
    if (texture != null) {
      paintImage(
        canvas: canvas,
        rect: front,
        image: texture,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      );
    } else {
      canvas.drawRect(front, Paint()..color = fallback);
    }
  }

  Color _shade(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(CuboidPainter oldDelegate) => oldDelegate.data != data;
}

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../transform/bvec3.dart';
import '../transform/buoyancy_three_transform.dart';
import 'composed_scene.dart';

/// Painter's-algorithm mesh renderer. Does not run physics.
///
/// Ground / pool / sky colors + extents match
/// `GroundFrontMesh` / `GroundTopMesh` / `PoolMesh` +
/// `DensityBuoyancyCommonColors` / `DensityBuoyancyModel` bounds.
class BuoyancyScenePainter extends CustomPainter {
  BuoyancyScenePainter({
    required this.scene,
    required this.transform,
    this.textures = const {},
  });

  final ComposedScene scene;
  final BuoyancyThreeTransform transform;
  final Map<String, ui.Image> textures;

  static const _sun = BVec3(-0.7, 1.5, 0.8);
  static const _ambient = 0.2;

  // DensityBuoyancyCommonColors
  static const _skyTop = Color.fromARGB(255, 19, 165, 224);
  static const _skyBottom = Color.fromARGB(255, 255, 255, 255);
  static const _ground = Color.fromARGB(255, 161, 101, 47);
  static const _grassClose = Color.fromARGB(255, 107, 165, 75);
  static const _grassFar = Color.fromARGB(255, 230, 230, 80);
  static const _poolSurface = Color.fromARGB(255, 183, 159, 159);
  static const _water = Color.fromARGB(102, 0, 128, 255); // a=0.4

  // DensityBuoyancyModel groundBounds / poolBounds
  static const _gMinX = -10.0;
  static const _gMaxX = 10.0;
  static const _gMinY = -10.0;
  static const _gMaxY = 0.0;
  static const _gMinZ = -2.0;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawGroundAndPool(canvas, size);
    _drawFluidVolume(canvas);

    final tris = <_Tri>[];
    for (final inst in scene.meshes) {
      _collect(inst, tris);
    }
    tris.sort((a, b) => b.depth.compareTo(a.depth));
    for (final t in tris) {
      if (t.image != null && t.uvs != null) {
        _drawTexturedTri(canvas, t);
      } else {
        canvas.drawPath(t.path, t.paint);
      }
    }

    _drawCabinFluid(canvas);
    _drawScales(canvas);
    _drawArrows(canvas);
    _drawMassOverlays(canvas);
    _drawFluidVolumeReadout(canvas);
  }

  void _drawSky(Canvas canvas, Size size) {
    final sky = Rect.fromLTWH(0, 0, size.width, size.height);
    // Horizon ≈ ground top front projected Y; fall back to mid-canvas.
    final horizon = transform.modelToView(
      BVec3(0, _gMaxY, scene.pool.depth / 2),
    );
    final horizonT = (horizon.dy / size.height).clamp(0.35, 0.65);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment(0, horizonT * 2 - 1),
          colors: const [_skyTop, _skyBottom],
        ).createShader(sky),
    );
  }

  void _drawGroundAndPool(Canvas canvas, Size size) {
    final p = scene.pool;
    final zFront = p.depth / 2;
    final zBack = -p.depth / 2;

    Offset v(BVec3 w) => transform.modelToView(w);

    void quad(BVec3 a, BVec3 b, BVec3 c, BVec3 d, Color color) {
      final pa = v(a), pb = v(b), pc = v(c), pd = v(d);
      canvas.drawPath(
        Path()
          ..moveTo(pa.dx, pa.dy)
          ..lineTo(pb.dx, pb.dy)
          ..lineTo(pc.dx, pc.dy)
          ..lineTo(pd.dx, pd.dy)
          ..close(),
        Paint()..color = color,
      );
    }

    // Horizon / grass line across full viewport (PhET fills display edges).
    final leftGrass = v(BVec3(_gMinX, _gMaxY, zFront));
    final rightGrass = v(BVec3(_gMaxX, _gMaxY, zFront));
    final grassY = math.min(leftGrass.dy, rightGrass.dy);

    // Pool mouth in view (cutout in the dirt face).
    final mouthTL = v(BVec3(p.minX, _gMaxY, zFront));
    final mouthTR = v(BVec3(p.maxX, _gMaxY, zFront));
    final mouthBL = v(BVec3(p.minX, p.minY, zFront));
    final mouthBR = v(BVec3(p.maxX, p.minY, zFront));

    // Dirt below grass, with pool mouth punched out (GroundFrontMesh gap).
    final dirt = Path()
      ..moveTo(0, grassY)
      ..lineTo(size.width, grassY)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final mouth = Path()
      ..moveTo(mouthTL.dx, mouthTL.dy)
      ..lineTo(mouthTR.dx, mouthTR.dy)
      ..lineTo(mouthBR.dx, mouthBR.dy)
      ..lineTo(mouthBL.dx, mouthBL.dy)
      ..close();
    canvas.drawPath(
      Path.combine(PathOperation.difference, dirt, mouth),
      Paint()..color = _ground,
    );

    // —— GroundFrontMesh (brown dirt at z = ground.maxZ) ——
    quad(
      BVec3(_gMinX, _gMinY, zFront),
      BVec3(p.minX, _gMinY, zFront),
      BVec3(p.minX, _gMaxY, zFront),
      BVec3(_gMinX, _gMaxY, zFront),
      _ground,
    );
    quad(
      BVec3(p.maxX, _gMinY, zFront),
      BVec3(_gMaxX, _gMinY, zFront),
      BVec3(_gMaxX, _gMaxY, zFront),
      BVec3(p.maxX, _gMaxY, zFront),
      _ground,
    );
    quad(
      BVec3(p.minX, _gMinY, zFront),
      BVec3(p.maxX, _gMinY, zFront),
      BVec3(p.maxX, p.minY, zFront),
      BVec3(p.minX, p.minY, zFront),
      _ground,
    );

    // —— GroundTopMesh (grass at y = 0) ——
    quad(
      BVec3(_gMinX, _gMaxY, zBack),
      BVec3(p.minX, _gMaxY, zBack),
      BVec3(p.minX, _gMaxY, zFront),
      BVec3(_gMinX, _gMaxY, zFront),
      _grassClose,
    );
    quad(
      BVec3(p.maxX, _gMaxY, zBack),
      BVec3(_gMaxX, _gMaxY, zBack),
      BVec3(_gMaxX, _gMaxY, zFront),
      BVec3(p.maxX, _gMaxY, zFront),
      _grassClose,
    );
    final backFar = [
      v(BVec3(_gMinX, _gMaxY, _gMinZ)),
      v(BVec3(_gMaxX, _gMaxY, _gMinZ)),
      v(BVec3(_gMaxX, _gMaxY, zBack)),
      v(BVec3(_gMinX, _gMaxY, zBack)),
    ];
    canvas.drawPath(
      Path()
        ..moveTo(backFar[0].dx, backFar[0].dy)
        ..lineTo(backFar[1].dx, backFar[1].dy)
        ..lineTo(backFar[2].dx, backFar[2].dy)
        ..lineTo(backFar[3].dx, backFar[3].dy)
        ..close(),
      Paint()
        ..shader = ui.Gradient.linear(
          backFar[0],
          Offset(
            (backFar[2].dx + backFar[3].dx) / 2,
            (backFar[2].dy + backFar[3].dy) / 2,
          ),
          [_grassFar, _grassClose],
        ),
    );

    // Full-width thin grass ribbon left/right of pool mouth only
    // (do not paint over shore blocks sitting on the grass).
    if (mouthTL.dx > 0) {
      canvas.drawRect(
        Rect.fromLTRB(0, grassY - 3, mouthTL.dx, grassY + 5),
        Paint()..color = _grassClose,
      );
    }
    if (mouthTR.dx < size.width) {
      canvas.drawRect(
        Rect.fromLTRB(mouthTR.dx, grassY - 3, size.width, grassY + 5),
        Paint()..color = _grassClose,
      );
    }

    // —— PoolMesh interior ——
    quad(
      BVec3(p.minX, p.minY, zBack),
      BVec3(p.maxX, p.minY, zBack),
      BVec3(p.maxX, p.minY, zFront),
      BVec3(p.minX, p.minY, zFront),
      _shade(_poolSurface, 0.75),
    );
    quad(
      BVec3(p.minX, p.minY, zBack),
      BVec3(p.maxX, p.minY, zBack),
      BVec3(p.maxX, p.maxY, zBack),
      BVec3(p.minX, p.maxY, zBack),
      _shade(_poolSurface, 0.9),
    );
    quad(
      BVec3(p.minX, p.minY, zBack),
      BVec3(p.minX, p.minY, zFront),
      BVec3(p.minX, p.maxY, zFront),
      BVec3(p.minX, p.maxY, zBack),
      _shade(_poolSurface, 0.65),
    );
    quad(
      BVec3(p.maxX, p.minY, zFront),
      BVec3(p.maxX, p.minY, zBack),
      BVec3(p.maxX, p.maxY, zBack),
      BVec3(p.maxX, p.maxY, zFront),
      _shade(_poolSurface, 0.65),
    );
  }

  Color _shade(Color c, double factor) => Color.fromARGB(
        (c.a * 255.0).round().clamp(0, 255),
        (c.r * 255.0 * factor).round().clamp(0, 255),
        (c.g * 255.0 * factor).round().clamp(0, 255),
        (c.b * 255.0 * factor).round().clamp(0, 255),
      );

  void _drawFluidVolume(Canvas canvas) {
    final p = scene.pool;
    final y = scene.fluidY;
    if (y <= p.minY + 1e-9) {
      return;
    }
    final zFront = p.depth / 2;
    final zBack = -p.depth / 2;
    Offset v(BVec3 w) => transform.modelToView(w);

    void quad(BVec3 a, BVec3 b, BVec3 c, BVec3 d) {
      final pa = v(a), pb = v(b), pc = v(c), pd = v(d);
      canvas.drawPath(
        Path()
          ..moveTo(pa.dx, pa.dy)
          ..lineTo(pb.dx, pb.dy)
          ..lineTo(pc.dx, pc.dy)
          ..lineTo(pd.dx, pd.dy)
          ..close(),
        Paint()..color = _water,
      );
    }

    // Front face of fluid column (FluidMesh-style)
    quad(
      BVec3(p.minX, p.minY, zFront),
      BVec3(p.maxX, p.minY, zFront),
      BVec3(p.maxX, y, zFront),
      BVec3(p.minX, y, zFront),
    );
    // Top surface
    quad(
      BVec3(p.minX, y, zBack),
      BVec3(p.maxX, y, zBack),
      BVec3(p.maxX, y, zFront),
      BVec3(p.minX, y, zFront),
    );
  }

  void _drawCabinFluid(Canvas canvas) {
    final y = scene.cabinFluidY;
    final minX = scene.cabinFluidMinX;
    final maxX = scene.cabinFluidMaxX;
    if (y == null || minX == null || maxX == null) {
      return;
    }
    final z = scene.pool.depth / 2;
    final pts = [
      transform.modelToView(BVec3(minX, y, -z)),
      transform.modelToView(BVec3(maxX, y, -z)),
      transform.modelToView(BVec3(maxX, y, z)),
      transform.modelToView(BVec3(minX, y, z)),
    ];
    canvas.drawPath(
      Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..lineTo(pts[3].dx, pts[3].dy)
        ..close(),
      Paint()..color = _water,
    );
  }

  void _drawScales(Canvas canvas) {
    // Source ScaleView: cuboid base + top cylinder (Figure 4).
    const w = 0.15;
    const h = 0.06;
    const d = 0.2;
    const baseH = 0.05;
    const metal = Color(0xFFC5C8CC);
    const metalDark = Color(0xFF8A9096);

    for (final s in scene.scales) {
      final o = s.origin;
      final y0 = o.y - h / 2;
      final yBaseTop = y0 + baseH;
      final yTop = y0 + h;

      Offset vv(double x, double y, double z) =>
          transform.modelToView(BVec3(o.x + x, y, o.z + z));

      void quad(List<Offset> pts, Color color) {
        canvas.drawPath(
          Path()
            ..moveTo(pts[0].dx, pts[0].dy)
            ..lineTo(pts[1].dx, pts[1].dy)
            ..lineTo(pts[2].dx, pts[2].dy)
            ..lineTo(pts[3].dx, pts[3].dy)
            ..close(),
          Paint()..color = color,
        );
      }

      final hx = w / 2;
      final hz = d / 2;
      quad([vv(-hx, y0, -hz), vv(hx, y0, -hz), vv(hx, yBaseTop, -hz), vv(-hx, yBaseTop, -hz)], metalDark);
      quad([vv(-hx, y0, -hz), vv(-hx, y0, hz), vv(-hx, yBaseTop, hz), vv(-hx, yBaseTop, -hz)], _shade(metal, 0.85));
      quad([vv(hx, y0, hz), vv(hx, y0, -hz), vv(hx, yBaseTop, -hz), vv(hx, yBaseTop, hz)], _shade(metal, 0.75));
      quad([vv(-hx, y0, hz), vv(hx, y0, hz), vv(hx, yBaseTop, hz), vv(-hx, yBaseTop, hz)], metal);
      quad([vv(-hx, yBaseTop, -hz), vv(hx, yBaseTop, -hz), vv(hx, yBaseTop, hz), vv(-hx, yBaseTop, hz)], _shade(metal, 1.05));

      final disc = Path();
      const n = 24;
      for (var i = 0; i <= n; i++) {
        final t = i / n * math.pi * 2;
        final p = vv((w / 2) * math.cos(t), yTop, (w / 2) * math.sin(t));
        if (i == 0) {
          disc.moveTo(p.dx, p.dy);
        } else {
          disc.lineTo(p.dx, p.dy);
        }
      }
      disc.close();
      canvas.drawPath(disc, Paint()..color = const Color(0xFFD8DCE0));
      canvas.drawPath(
        disc,
        Paint()
          ..color = const Color(0xFF666666)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Front face LED readout (ScaleView display strip).
      final frontCenter = vv(0, y0 + baseH * 0.42, hz);
      final tp = TextPainter(
        text: TextSpan(
          text: s.readout,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            fontFamily: 'RobotoMono',
            fontFamilyFallback: ['Consolas', 'monospace'],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final padX = 5.0;
      final padY = 2.0;
      final led = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: frontCenter,
          width: tp.width + padX * 2,
          height: tp.height + padY * 2,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(led, Paint()..color = const Color(0xFFE8F0D8));
      canvas.drawRRect(
        led,
        Paint()
          ..color = const Color(0xFF555555)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
      tp.paint(
        canvas,
        Offset(frontCenter.dx - tp.width / 2, frontCenter.dy - tp.height / 2),
      );
    }
  }

  void _drawArrows(Canvas canvas) {
    for (final a in scene.forceArrows) {
      if (a.tipYDesign.abs() < 1e-6) {
        continue;
      }
      final o = transform.modelToView(a.origin);
      final tip = Offset(o.dx, o.dy + a.tipYDesign * transform.frame.scale);
      canvas.drawLine(
        o,
        tip,
        Paint()
          ..color = a.color
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      // Arrow head
      final dir = tip - o;
      final len = dir.distance;
      if (len > 1) {
        final u = dir / len;
        final n = Offset(-u.dy, u.dx);
        final p1 = tip - u * 10 + n * 5;
        final p2 = tip - u * 10 - n * 5;
        canvas.drawPath(
          Path()
            ..moveTo(tip.dx, tip.dy)
            ..lineTo(p1.dx, p1.dy)
            ..lineTo(p2.dx, p2.dy)
            ..close(),
          Paint()..color = a.color,
        );
      }
      final label = a.label;
      if (label != null) {
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
              backgroundColor: Color(0xCCFFFFFF),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset((o.dx + tip.dx) / 2 + 6, (o.dy + tip.dy) / 2));
      }
    }
  }

  void _drawMassOverlays(Canvas canvas) {
    for (final inst in scene.meshes) {
      final top = transform.modelToView(
        BVec3(inst.origin.x, inst.origin.y + 0.02 * inst.scale, inst.origin.z),
      );
      final tag = inst.tagLabel;
      if (tag != null) {
        final bg = inst.tagColor ?? const Color(0xFF2F59A6);
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
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(top.dx - tp.width / 2 - 4, top.dy - tp.height - 18,
              tp.width + 8, tp.height + 4),
          const Radius.circular(3),
        );
        canvas.drawRRect(r, Paint()..color = bg);
        tp.paint(canvas, Offset(top.dx - tp.width / 2, top.dy - tp.height - 16));
      }
      final mass = inst.massLabel;
      if (mass != null) {
        final bottom = transform.modelToView(
          BVec3(inst.origin.x, inst.origin.y - 0.06 * inst.scale, inst.origin.z),
        );
        final tp = TextPainter(
          text: TextSpan(
            text: mass,
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final pad = Rect.fromLTWH(
          bottom.dx - tp.width / 2 - 5,
          bottom.dy + 8,
          tp.width + 10,
          tp.height + 4,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(pad, const Radius.circular(3)),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(pad, const Radius.circular(3)),
          Paint()
            ..color = Colors.black54
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        tp.paint(canvas, Offset(pad.left + 5, pad.top + 2));
      }
      if (scene.showDepthLines) {
        final hy = transform.modelToView(
          BVec3(inst.origin.x, inst.origin.y, inst.origin.z),
        );
        canvas.drawLine(
          Offset(hy.dx - 30, hy.dy),
          Offset(hy.dx + 30, hy.dy),
          Paint()
            ..color = const Color(0xAAFFFFFF)
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  void _drawFluidVolumeReadout(Canvas canvas) {
    // Overlay widget also draws liters; keep painter marker as red notch only.
    final p = scene.pool;
    final y = scene.fluidY;
    final left = transform.modelToView(BVec3(p.minX, y, p.depth / 2));
    final path = Path()
      ..moveTo(left.dx - 2, left.dy)
      ..lineTo(left.dx - 14, left.dy - 7)
      ..lineTo(left.dx - 14, left.dy + 7)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.red);
  }

  void _collect(SceneMeshInstance inst, List<_Tri> out) {
    final mesh = inst.mesh;
    final o = inst.origin;
    final s = inst.scale;
    final image = textures[inst.textureAsset];
    final bounds = mesh.bounds();
    final w = (bounds.maxX - bounds.minX).abs().clamp(1e-6, double.infinity);
    final h = (bounds.maxY - bounds.minY).abs().clamp(1e-6, double.infinity);
    final d = (bounds.maxZ - bounds.minZ).abs().clamp(1e-6, double.infinity);

    for (var t = 0; t < mesh.triangleCount; t++) {
      final i0 = mesh.indices[t * 3];
      final i1 = mesh.indices[t * 3 + 1];
      final i2 = mesh.indices[t * 3 + 2];
      BVec3 vtx(int i) => BVec3(
            o.x + mesh.positions[i * 3] * s,
            o.y + mesh.positions[i * 3 + 1] * s,
            o.z + mesh.positions[i * 3 + 2] * s,
          );
      final a = vtx(i0);
      final b = vtx(i1);
      final c = vtx(i2);
      final e1 = b - a;
      final e2 = c - a;
      var n = e1.cross(e2);
      if (n.length == 0) {
        continue;
      }
      n = n.normalized();
      // Two-sided Lambert: dense bottle/boat meshes have mixed winding; abs()
      // keeps the silhouette lit instead of near-black.
      final ndl = n.dot(_sun.normalized()).abs();
      final lit = (_ambient + ndl * 0.8).clamp(0.35, 1.0);
      final col = Color.fromARGB(
        (inst.opacity * 255).round().clamp(0, 255),
        (inst.color.r * 255.0 * lit).round().clamp(0, 255),
        (inst.color.g * 255.0 * lit).round().clamp(0, 255),
        (inst.color.b * 255.0 * lit).round().clamp(0, 255),
      );
      final pa = transform.modelToView(a);
      final pb = transform.modelToView(b);
      final pc = transform.modelToView(c);
      final depth = (transform.worldToCamera(a).z +
              transform.worldToCamera(b).z +
              transform.worldToCamera(c).z) /
          3;

      List<Offset>? uvs;
      if (image != null) {
        Offset uvFor(BVec3 local) {
          // Local coords before origin (mesh space * scale).
          final lx = (local.x - o.x) / s;
          final ly = (local.y - o.y) / s;
          final lz = (local.z - o.z) / s;
          final an = n;
          if (an.y.abs() >= an.x.abs() && an.y.abs() >= an.z.abs()) {
            return Offset((lx - bounds.minX) / w, (lz - bounds.minZ) / d);
          }
          if (an.x.abs() >= an.z.abs()) {
            return Offset((lz - bounds.minZ) / d, 1 - (ly - bounds.minY) / h);
          }
          return Offset((lx - bounds.minX) / w, 1 - (ly - bounds.minY) / h);
        }

        final la = BVec3(
          mesh.positions[i0 * 3] * s + o.x,
          mesh.positions[i0 * 3 + 1] * s + o.y,
          mesh.positions[i0 * 3 + 2] * s + o.z,
        );
        final lb = BVec3(
          mesh.positions[i1 * 3] * s + o.x,
          mesh.positions[i1 * 3 + 1] * s + o.y,
          mesh.positions[i1 * 3 + 2] * s + o.z,
        );
        final lc = BVec3(
          mesh.positions[i2 * 3] * s + o.x,
          mesh.positions[i2 * 3 + 1] * s + o.y,
          mesh.positions[i2 * 3 + 2] * s + o.z,
        );
        uvs = [uvFor(la), uvFor(lb), uvFor(lc)];
      }

      out.add(
        _Tri(
          Path()
            ..moveTo(pa.dx, pa.dy)
            ..lineTo(pb.dx, pb.dy)
            ..lineTo(pc.dx, pc.dy)
            ..close(),
          Paint()..color = col,
          depth,
          image: image,
          screen: [pa, pb, pc],
          uvs: uvs,
          lit: lit,
        ),
      );
    }
  }

  void _drawTexturedTri(Canvas canvas, _Tri t) {
    final image = t.image!;
    final screen = t.screen!;
    final uvs = t.uvs!;
    final tw = image.width.toDouble();
    final th = image.height.toDouble();
    final positions = Float32List(6);
    final texCoords = Float32List(6);
    final colors = Int32List(3);
    final litByte = (t.lit * 255).round().clamp(40, 255);
    final modulate = Color.fromARGB(255, litByte, litByte, litByte);
    for (var i = 0; i < 3; i++) {
      positions[i * 2] = screen[i].dx;
      positions[i * 2 + 1] = screen[i].dy;
      texCoords[i * 2] = uvs[i].dx * tw;
      texCoords[i * 2 + 1] = uvs[i].dy * th;
      colors[i] = modulate.toARGB32();
    }
    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: texCoords,
      colors: colors,
    );
    canvas.drawVertices(
      vertices,
      BlendMode.modulate,
      Paint()
        ..shader = ImageShader(
          image,
          TileMode.repeated,
          TileMode.repeated,
          Matrix4.identity().storage,
        ),
    );
  }

  @override
  bool shouldRepaint(covariant BuoyancyScenePainter oldDelegate) => true;
}

class _Tri {
  _Tri(
    this.path,
    this.paint,
    this.depth, {
    this.image,
    this.screen,
    this.uvs,
    this.lit = 1,
  });
  final Path path;
  final Paint paint;
  final double depth;
  final ui.Image? image;
  final List<Offset>? screen;
  final List<Offset>? uvs;
  final double lit;
}

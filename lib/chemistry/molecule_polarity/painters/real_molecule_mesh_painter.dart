import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/mp_preferences.dart';
import '../model/real_molecules/real_molecule_surface_colors.dart';
import '../model/real_molecules/real_molecules_model.dart';

/// Canvas projection of PhET `SurfaceMesh.ts` (FrontSide, dual pass, no Three.js).
///
/// Transform comes only from [RealMoleculesModel.quaternion] — mesh has no own
/// rotation/scale/position state.
abstract final class RealMoleculeMeshPainter {
  static const double modelScale = 90;

  /// `REAL_MOLECULES_CAMERA_POSITION`
  static const List<double> camera = [0.0, 1.5, 15.0];

  static void paintBackground({
    required Canvas canvas,
    required RealMoleculesModel model,
    required Offset center,
  }) {
    _paintPass(
      canvas: canvas,
      model: model,
      center: center,
      opaqueBlend: true,
      alpha: RealMoleculeSurfaceColors.surfaceBackAlpha,
    );
  }

  static void paintForeground({
    required Canvas canvas,
    required RealMoleculesModel model,
    required Offset center,
  }) {
    _paintPass(
      canvas: canvas,
      model: model,
      center: center,
      opaqueBlend: false,
      alpha: RealMoleculeSurfaceColors.surfaceFrontAlpha,
    );
  }

  static void _paintPass({
    required Canvas canvas,
    required RealMoleculesModel model,
    required Offset center,
    required bool opaqueBlend,
    required double alpha,
  }) {
    final surface = model.viewProperties.surfaceType;
    if (surface == SurfaceType.none) return;

    final mesh = model.molecule.mesh;
    if (mesh == null || mesh.faceIndices.isEmpty) return;

    final q = model.quaternion;
    final colors = _vertexColors(model, surface);
    final n = mesh.vertexCount;

    final px = List<double>.filled(n, 0);
    final py = List<double>.filled(n, 0);
    final pz = List<double>.filled(n, 0);
    final nx = List<double>.filled(n, 0);
    final ny = List<double>.filled(n, 0);
    final nz = List<double>.filled(n, 0);

    for (var i = 0; i < n; i++) {
      final r = q.rotate(
        mesh.positions[i * 3],
        mesh.positions[i * 3 + 1],
        mesh.positions[i * 3 + 2],
      );
      px[i] = center.dx + r[0] * modelScale;
      py[i] = center.dy - r[1] * modelScale;
      pz[i] = r[2];
      final rn = q.rotate(
        mesh.normals[i * 3],
        mesh.normals[i * 3 + 1],
        mesh.normals[i * 3 + 2],
      );
      nx[i] = rn[0];
      ny[i] = rn[1];
      nz[i] = rn[2];
    }

    final faces = <_Face>[];
    for (final tri in mesh.faceIndices) {
      final i0 = tri[0], i1 = tri[1], i2 = tri[2];
      final mid = q.rotate(
        (mesh.positions[i0 * 3] +
                mesh.positions[i1 * 3] +
                mesh.positions[i2 * 3]) /
            3,
        (mesh.positions[i0 * 3 + 1] +
                mesh.positions[i1 * 3 + 1] +
                mesh.positions[i2 * 3 + 1]) /
            3,
        (mesh.positions[i0 * 3 + 2] +
                mesh.positions[i1 * 3 + 2] +
                mesh.positions[i2 * 3 + 2]) /
            3,
      );
      final fnx = (nx[i0] + nx[i1] + nx[i2]) / 3;
      final fny = (ny[i0] + ny[i1] + ny[i2]) / 3;
      final fnz = (nz[i0] + nz[i1] + nz[i2]) / 3;
      final vx = camera[0] - mid[0];
      final vy = camera[1] - mid[1];
      final vz = camera[2] - mid[2];
      if (fnx * vx + fny * vy + fnz * vz <= 0) continue;
      faces.add(_Face(
        i0: i0,
        i1: i1,
        i2: i2,
        depth: (pz[i0] + pz[i1] + pz[i2]) / 3,
        // Keep normal for slight silhouette darkening (MeshBasic has no Lambert;
        // grazing angles still look flatter without subdivision).
        ndotv: (() {
          final len = math.sqrt(vx * vx + vy * vy + vz * vz);
          if (len < 1e-9) return 1.0;
          return ((fnx * vx + fny * vy + fnz * vz) / len).clamp(0.0, 1.0);
        })(),
      ));
    }
    faces.sort((a, b) => a.depth.compareTo(b.depth));

    final paint = Paint()..style = PaintingStyle.fill;
    for (final f in faces) {
      final c0 = colors[f.i0];
      final c1 = colors[f.i1];
      final c2 = colors[f.i2];
      final ar = (c0.r + c1.r + c2.r) / 3;
      final ag = (c0.g + c1.g + c2.g) / 3;
      final ab = (c0.b + c1.b + c2.b) / 3;
      // Soft Fresnel-like rim darkening to reduce flat triangle look.
      final shade = 0.72 + 0.28 * f.ndotv;
      final avg = Color.fromRGBO(
        (ar * 255 * shade).round().clamp(0, 255),
        (ag * 255 * shade).round().clamp(0, 255),
        (ab * 255 * shade).round().clamp(0, 255),
        1,
      );
      if (opaqueBlend) {
        paint.color =
            RealMoleculeSurfaceColors.blendOverBackground(avg, alpha);
      } else {
        paint.color = avg.withValues(alpha: alpha);
      }
      canvas.drawPath(
        Path()
          ..moveTo(px[f.i0], py[f.i0])
          ..lineTo(px[f.i1], py[f.i1])
          ..lineTo(px[f.i2], py[f.i2])
          ..close(),
        paint,
      );
    }
  }

  static final Map<String, List<Color>> _colorCache = {};

  static List<Color> _vertexColors(
    RealMoleculesModel model,
    SurfaceType surface,
  ) {
    final mol = model.molecule;
    final mode = model.preferences?.surfaceColor ?? SurfaceColor.blueWhiteRed;
    final mesh = mol.mesh!;
    final key =
        '${mol.symbol}|$surface|${model.isAdvanced}|${mode.name}|${mesh.vertexCount}';
    final cached = _colorCache[key];
    if (cached != null) return cached;

    final out = List<Color>.generate(mesh.vertexCount, (i) {
      final value = mol.sampleSurfaceValue(
        surface,
        isAdvanced: model.isAdvanced,
        vertexIndex: i,
        x: mesh.positions[i * 3],
        y: mesh.positions[i * 3 + 1],
        z: mesh.positions[i * 3 + 2],
      );
      if (surface == SurfaceType.electrostaticPotential) {
        return RealMoleculeSurfaceColors.colorizeEsp(value, mode);
      }
      return model.isAdvanced
          ? RealMoleculeSurfaceColors.colorizeRealElectronDensity(value)
          : RealMoleculeSurfaceColors.colorizeJavaElectronDensity(value);
    });
    if (_colorCache.length > 48) _colorCache.clear();
    _colorCache[key] = out;
    return out;
  }
}

class _Face {
  _Face({
    required this.i0,
    required this.i1,
    required this.i2,
    required this.depth,
    required this.ndotv,
  });
  final int i0, i1, i2;
  final double depth;
  final double ndotv;
}

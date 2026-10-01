import 'dart:math' as math;

import '../../domain/shape/shape_geometry.dart';
import 'boat_source_mesh.dart';
import 'bottle_source_mesh.dart';
import 'duck_source_mesh.dart';
import 'triangle_mesh.dart';

/// Cached static visual meshes. Do not cache pose / waterline.
class ProceduralMeshes {
  ProceduralMeshes._();

  static final Map<String, TriangleMesh> _cache = {};

  static TriangleMesh cube(double w, double h, double d) {
    final key = 'cube:$w:$h:$d';
    return _cache.putIfAbsent(key, () {
      final hx = w / 2, hy = h / 2, hz = d / 2;
      final p = <double>[
        -hx, -hy, -hz, hx, -hy, -hz, hx, hy, -hz, -hx, hy, -hz,
        -hx, -hy, hz, hx, -hy, hz, hx, hy, hz, -hx, hy, hz,
      ];
      const i = <int>[
        0, 1, 2, 0, 2, 3,
        4, 6, 5, 4, 7, 6,
        0, 4, 5, 0, 5, 1,
        3, 2, 6, 3, 6, 7,
        0, 3, 7, 0, 7, 4,
        1, 5, 6, 1, 6, 2,
      ];
      return TriangleMesh(positions: p, indices: i);
    });
  }

  static TriangleMesh ellipsoid(double w, double h, double d) {
    final key = 'ell:$w:$h:$d';
    return _cache.putIfAbsent(key, () {
      const stacks = 8, slices = 12;
      final pos = <double>[];
      final idx = <int>[];
      for (var i = 0; i <= stacks; i++) {
        final v = i / stacks;
        final phi = v * math.pi;
        for (var j = 0; j <= slices; j++) {
          final u = j / slices;
          final theta = u * math.pi * 2;
          pos.addAll([
            (w / 2) * math.sin(phi) * math.cos(theta),
            (h / 2) * math.cos(phi),
            (d / 2) * math.sin(phi) * math.sin(theta),
          ]);
        }
      }
      for (var i = 0; i < stacks; i++) {
        for (var j = 0; j < slices; j++) {
          final a = i * (slices + 1) + j;
          final b = a + slices + 1;
          idx.addAll([a, b, a + 1, a + 1, b, b + 1]);
        }
      }
      return TriangleMesh(positions: pos, indices: idx);
    });
  }

  static TriangleMesh verticalCylinder(double r, double h) {
    final key = 'vc:$r:$h';
    return _cache.putIfAbsent(key, () => _lathe(r, -h / 2, h / 2, key));
  }

  static TriangleMesh horizontalCylinder(double r, double length) {
    final key = 'hc:$r:$length';
    return _cache.putIfAbsent(key, () {
      final core = verticalCylinder(r, length);
      // Rotate so axis is X: (x,y,z) <- (y, z, x) wait: vertical y-up → x-axis
      final p = <double>[];
      for (var i = 0; i < core.positions.length; i += 3) {
        final x = core.positions[i];
        final y = core.positions[i + 1];
        final z = core.positions[i + 2];
        p.addAll([y, z, x]);
      }
      return TriangleMesh(positions: p, indices: core.indices);
    });
  }

  static TriangleMesh cone(double r, double h, {required bool vertexUp}) {
    final key = 'cone:$r:$h:$vertexUp';
    return _cache.putIfAbsent(key, () {
      const n = 16;
      final pos = <double>[0, vertexUp ? h / 2 : -h / 2, 0];
      final idx = <int>[];
      final yBase = vertexUp ? -h / 2 : h / 2;
      for (var i = 0; i <= n; i++) {
        final t = i / n * math.pi * 2;
        pos.addAll([r * math.cos(t), yBase, r * math.sin(t)]);
      }
      for (var i = 0; i < n; i++) {
        idx.addAll([0, i + 1, i + 2]);
      }
      return TriangleMesh(positions: pos, indices: idx);
    });
  }

  static TriangleMesh _lathe(double r, double y0, double y1, String key) {
    const n = 16;
    final pos = <double>[];
    final idx = <int>[];
    for (var i = 0; i <= n; i++) {
      final t = i / n * math.pi * 2;
      final x = r * math.cos(t);
      final z = r * math.sin(t);
      pos.addAll([x, y0, z, x, y1, z]);
    }
    for (var i = 0; i < n; i++) {
      final a = i * 2;
      idx.addAll([a, a + 1, a + 2, a + 1, a + 3, a + 2]);
    }
    return TriangleMesh(positions: pos, indices: idx);
  }

  static TriangleMesh duckVisual(ShapeGeometry g) {
    final key = 'duck:${g.width}:${g.height}:${g.depth}';
    return _cache.putIfAbsent(key, () {
      final src = TriangleMesh(
        positions: DuckSourceMesh.positions,
        indices: DuckSourceMesh.indices,
      );
      final b = src.bounds();
      final sw = g.width / math.max(1e-9, b.maxX - b.minX);
      final sh = g.height / math.max(1e-9, b.maxY - b.minY);
      final sd = g.depth / math.max(1e-9, b.maxZ - b.minZ);
      final cx = (b.minX + b.maxX) / 2;
      final cy = (b.minY + b.maxY) / 2;
      final cz = (b.minZ + b.maxZ) / 2;
      final p = <double>[];
      for (var i = 0; i < src.positions.length; i += 3) {
        p.addAll([
          (src.positions[i] - cx) * sw,
          (src.positions[i + 1] - cy) * sh,
          (src.positions[i + 2] - cz) * sd,
        ]);
      }
      return TriangleMesh(positions: p, indices: src.indices);
    });
  }

  static TriangleMesh boatOneLiter() => _cache.putIfAbsent(
        'boat1L',
        () => TriangleMesh(
          positions: BoatSourceMesh.positions,
          indices: BoatSourceMesh.indices,
        ),
      );

  static TriangleMesh bottleTenLiter() => _cache.putIfAbsent(
        'bottle10L',
        () => TriangleMesh(
          positions: BottleSourceMesh.positions,
          indices: BottleSourceMesh.indices,
        ),
      );

  /// Source lathe is along +X with cap/neck at −X (Bottle.ts diagram).
  /// Bottle floats on its side — do **not** rotate upright. Uniform-scale so
  /// mesh Y extent (= diameter) matches [g.height] (physics bottleHeight).
  static TriangleMesh bottleVisual(ShapeGeometry g) {
    final key = 'bottleVizH:${g.height}';
    return _cache.putIfAbsent(key, () {
      return _centerUniformScale(bottleTenLiter(), g.height);
    });
  }

  /// ONE_LITER hull scaled to [g.height] (Applications `stepMultiplier` baked
  /// into geometry.height). Instance scale should stay 1.
  static TriangleMesh boatVisual(ShapeGeometry g) {
    final key = 'boatViz:${g.height}';
    return _cache.putIfAbsent(key, () {
      return _centerUniformScale(boatOneLiter(), g.height);
    });
  }

  static TriangleMesh _centerUniformScale(TriangleMesh src, double targetHeight) {
    final b = src.bounds();
    final hy = (b.maxY - b.minY).abs().clamp(1e-9, double.infinity);
    final s = targetHeight / hy;
    final cx = (b.minX + b.maxX) / 2;
    final cy = (b.minY + b.maxY) / 2;
    final cz = (b.minZ + b.maxZ) / 2;
    final p = <double>[];
    for (var i = 0; i < src.positions.length; i += 3) {
      p.addAll([
        (src.positions[i] - cx) * s,
        (src.positions[i + 1] - cy) * s,
        (src.positions[i + 2] - cz) * s,
      ]);
    }
    return TriangleMesh(positions: p, indices: src.indices);
  }

  static TriangleMesh forGeometry(ShapeGeometry g) {
    switch (g.kind) {
      case MassShapeKind.block:
        return cube(g.width, g.height, g.depth);
      case MassShapeKind.ellipsoid:
        return ellipsoid(g.width, g.height, g.depth);
      case MassShapeKind.duck:
        return duckVisual(g);
      case MassShapeKind.verticalCylinder:
        return verticalCylinder(g.radius, g.height);
      case MassShapeKind.horizontalCylinder:
        return horizontalCylinder(g.radius, g.length);
      case MassShapeKind.cone:
        return cone(g.radius, g.height, vertexUp: true);
      case MassShapeKind.invertedCone:
        return cone(g.radius, g.height, vertexUp: false);
      case MassShapeKind.boat:
        return boatVisual(g);
      case MassShapeKind.bottle:
        return bottleVisual(g);
    }
  }
}

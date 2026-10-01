import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/density/model/density_block.dart';
import 'package:kratos/density/model/density_material.dart';
import 'package:kratos/density/model/density_vec.dart';
import 'package:kratos/density/render/density_mvt.dart';
import 'package:kratos/density/solver/buoyancy_world.dart';
import 'package:kratos/density/solver/density_relation.dart';

/// Loop 10: Y-axis stability while dragging (constant pointer Y, moving X).
void main() {
  const volume = 0.005;
  const dt = 1 / 60;
  const frames = 90;

  double half([double v = volume]) => DensityRelation.cubeSideLength(v) / 2;

  DensityBlock cube({
    required String id,
    required String tag,
    required double x,
    required double y,
    DensityMaterialId material = DensityMaterialId.wood,
  }) {
    return DensityRelation.createWithVolume(
      id: id,
      tag: tag,
      materialId: material,
      volume: volume,
    ).copyWith(
      position: DensityVec(x, y),
      velocity: DensityVec.zero,
    );
  }

  (DensityBlock top, DensityBlock bottom) stackedOnGround({double x = 0}) {
    final h = half();
    final bottom = cube(id: 'bottom', tag: 'B', x: x, y: h);
    final top = cube(id: 'top', tag: 'A', x: x, y: bottom.position.y + h * 2);
    return (top, bottom);
  }

  /// Blocks submerged in pool (wood floats near surface region).
  (DensityBlock top, DensityBlock bottom) stackedInPool({double x = 0}) {
    final h = half();
    final floor = DensityMvt.poolMinY + h;
    final bottom = cube(
      id: 'bottom',
      tag: 'B',
      x: x,
      y: floor,
      material: DensityMaterialId.aluminum,
    );
    final top = cube(id: 'top', tag: 'A', x: x, y: bottom.position.y + h * 2);
    return (top, bottom);
  }

  int yDirectionChanges(List<double> ys) {
    var changes = 0;
    for (var i = 2; i < ys.length; i++) {
      final d0 = ys[i - 1] - ys[i - 2];
      final d1 = ys[i] - ys[i - 1];
      if (d0.abs() > 1e-4 && d1.abs() > 1e-4 && d0.sign != d1.sign) changes++;
    }
    return changes;
  }

  double yVariance(List<double> ys) {
    if (ys.isEmpty) return 0;
    final mean = ys.reduce((a, b) => a + b) / ys.length;
    return ys.map((y) => (y - mean) * (y - mean)).reduce((a, b) => a + b) /
        ys.length;
  }

  List<double> traceY({
    required List<DensityBlock> blocks,
    required String grabbedId,
    required double pointerY,
    required double pointerXEnd,
    int frameCount = frames,
  }) {
    final ys = <double>[];
    var next = blocks;
    final startX = blocks.firstWhere((b) => b.id == grabbedId).position.x;
    for (var i = 0; i < frameCount; i++) {
      final t = (i + 1) / frameCount;
      final px = startX + (pointerXEnd - startX) * t;
      next = BuoyancyWorld.step(
        blocks: next,
        dt: dt,
        grabbedId: grabbedId,
        pointerWorld: DensityVec(px, pointerY),
      ).blocks;
      ys.add(next.firstWhere((b) => b.id == grabbedId).position.y);
    }
    return ys;
  }

  group('Y oscillation while horizontal drag', () {
    test('air stacked: constant pointerY, drag left — low Y variance', () {
      final (top, bottom) = stackedOnGround();
      final pointerY = top.position.y;
      final ys = traceY(
        blocks: [top, bottom],
        grabbedId: top.id,
        pointerY: pointerY,
        pointerXEnd: top.position.x - 0.25,
      );
      expect(yVariance(ys), lessThan(1e-4));
      expect(yDirectionChanges(ys), lessThan(3));
      expect((ys.last - pointerY).abs(), lessThan(0.015));
    });

    test('air stacked: constant pointerY, drag right — low Y variance', () {
      final (top, bottom) = stackedOnGround();
      final pointerY = top.position.y;
      final ys = traceY(
        blocks: [top, bottom],
        grabbedId: top.id,
        pointerY: pointerY,
        pointerXEnd: top.position.x + 0.25,
      );
      expect(yVariance(ys), lessThan(1e-4));
      expect(yDirectionChanges(ys), lessThan(3));
    });

    test('water stacked: constant pointerY, drag left — low Y variance', () {
      final (top, bottom) = stackedInPool();
      final pointerY = top.position.y;
      final ys = traceY(
        blocks: [top, bottom],
        grabbedId: top.id,
        pointerY: pointerY,
        pointerXEnd: top.position.x - 0.2,
      );
      expect(yVariance(ys), lessThan(2e-4));
      expect(yDirectionChanges(ys), lessThan(4));
    });

    test('water single block: horizontal drag — stable Y', () {
      final h = half();
      final block = cube(
        id: 'solo',
        tag: 'A',
        x: 0,
        y: DensityMvt.poolMinY + h * 3,
        material: DensityMaterialId.wood,
      );
      final pointerY = block.position.y;
      final ys = traceY(
        blocks: [block],
        grabbedId: block.id,
        pointerY: pointerY,
        pointerXEnd: block.position.x + 0.2,
      );
      expect(yVariance(ys), lessThan(2e-4));
      expect(yDirectionChanges(ys), lessThan(4));
    });

    test('air single block: horizontal drag — stable Y', () {
      final block = cube(id: 'solo', tag: 'A', x: 0.3, y: 0.5);
      final pointerY = block.position.y;
      final ys = traceY(
        blocks: [block],
        grabbedId: block.id,
        pointerY: pointerY,
        pointerXEnd: block.position.x - 0.2,
      );
      expect(yVariance(ys), lessThan(1e-4));
      expect(yDirectionChanges(ys), lessThan(3));
    });

    test('max Y deviation bounded over 60 frames', () {
      final (top, bottom) = stackedOnGround();
      final pointerY = top.position.y;
      final ys = traceY(
        blocks: [top, bottom],
        grabbedId: top.id,
        pointerY: pointerY,
        pointerXEnd: top.position.x - 0.25,
        frameCount: 60,
      );
      final maxDev = ys.map((y) => (y - pointerY).abs()).reduce(math.max);
      expect(maxDev, lessThan(0.02));
    });

    test('resting stack without grab — no Y oscillation after settle', () {
      final (top, bottom) = stackedOnGround();
      var blocks = [top, bottom];
      final ys = <double>[];
      for (var i = 0; i < 240; i++) {
        blocks = BuoyancyWorld.step(blocks: blocks, dt: dt).blocks;
        ys.add(blocks.firstWhere((b) => b.id == top.id).position.y);
      }
      final tail = ys.sublist(120);
      expect(yVariance(tail), lessThan(1e-6));
      expect(yDirectionChanges(tail), lessThan(2));
    });
  });
}

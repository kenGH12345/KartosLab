import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/density/model/density_block.dart';
import 'package:kratos/density/model/density_material.dart';
import 'package:kratos/density/model/density_vec.dart';
import 'package:kratos/density/solver/buoyancy_world.dart';
import 'package:kratos/density/solver/density_relation.dart';

/// Loop 9: stacked-block drag must not lock against pointer spring.
void main() {
  const volume = 0.005;
  const dt = 1 / 60;

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

  /// A resting on B, same x.
  (DensityBlock top, DensityBlock bottom) stackedPair({
    double x = 0,
    double floorY = 0,
    String topId = 'top',
    String bottomId = 'bottom',
  }) {
    final h = half();
    final bottom = cube(id: bottomId, tag: 'B', x: x, y: floorY + h);
    final top = cube(id: topId, tag: 'A', x: x, y: bottom.position.y + h * 2);
    return (top, bottom);
  }

  List<DensityBlock> stepDrag({
    required List<DensityBlock> blocks,
    required String grabbedId,
    required DensityVec pointer,
    int frames = 90,
  }) {
    var next = blocks;
    for (var i = 0; i < frames; i++) {
      next = BuoyancyWorld.step(
        blocks: next,
        dt: dt,
        grabbedId: grabbedId,
        pointerWorld: pointer,
      ).blocks;
    }
    return next;
  }

  group('stacked drag regression', () {
    test('case 1: grab top block, drag left — top.x changes', () {
      final (top, bottom) = stackedPair();
      final startX = top.position.x;
      final result = stepDrag(
        blocks: [top, bottom],
        grabbedId: top.id,
        pointer: DensityVec(startX - 0.25, top.position.y),
      );
      final moved = result.firstWhere((b) => b.id == top.id);
      expect(moved.position.x, lessThan(startX - 0.05));
    });

    test('case 2: grab top block, drag right — top.x changes', () {
      final (top, bottom) = stackedPair();
      final startX = top.position.x;
      final result = stepDrag(
        blocks: [top, bottom],
        grabbedId: top.id,
        pointer: DensityVec(startX + 0.25, top.position.y),
      );
      final moved = result.firstWhere((b) => b.id == top.id);
      expect(moved.position.x, greaterThan(startX + 0.05));
    });

    test('case 3: grab top block, drag up — top can leave bottom', () {
      final (top, bottom) = stackedPair();
      final startY = top.position.y;
      final result = stepDrag(
        blocks: [top, bottom],
        grabbedId: top.id,
        pointer: DensityVec(top.position.x, startY + 0.35),
      );
      final moved = result.firstWhere((b) => b.id == top.id);
      expect(moved.position.y, greaterThan(startY + 0.08));
    });

    test('case 4: lateral drag off stack — top not locked to bottom x', () {
      final (top, bottom) = stackedPair();
      final result = stepDrag(
        blocks: [top, bottom],
        grabbedId: top.id,
        pointer: DensityVec(top.position.x - 0.3, top.position.y + 0.05),
      );
      final movedTop = result.firstWhere((b) => b.id == top.id);
      final stillBottom = result.firstWhere((b) => b.id == bottom.id);
      expect(
        (movedTop.position.x - stillBottom.position.x).abs(),
        greaterThan(0.06),
      );
    });

    test('case 5: no grab — stacked pair does not drift sideways', () {
      final (top, bottom) = stackedPair();
      var blocks = [top, bottom];
      for (var i = 0; i < 60; i++) {
        blocks = BuoyancyWorld.step(blocks: blocks, dt: dt).blocks;
      }
      final finalTop = blocks.firstWhere((b) => b.id == top.id);
      final finalBottom = blocks.firstWhere((b) => b.id == bottom.id);
      expect(finalTop.position.x, closeTo(top.position.x, 0.02));
      expect(finalBottom.position.x, closeTo(bottom.position.x, 0.02));
    });

    test('three-block stack: grab top, drag left/right/up', () {
      final h = half();
      final c = cube(id: 'c', tag: 'C', x: 0, y: h);
      final b = cube(id: 'b', tag: 'B', x: 0, y: c.position.y + h * 2);
      final a = cube(id: 'a', tag: 'A', x: 0, y: b.position.y + h * 2);
      final stack = [a, b, c];

      final left = stepDrag(
        blocks: stack,
        grabbedId: a.id,
        pointer: DensityVec(a.position.x - 0.3, a.position.y),
        frames: 60,
      );
      expect(
        left.firstWhere((x) => x.id == a.id).position.x,
        lessThan(a.position.x - 0.05),
      );

      final (a2, b2, c2) = (
        a.copyWith(position: a.position, velocity: DensityVec.zero),
        b.copyWith(position: b.position, velocity: DensityVec.zero),
        c.copyWith(position: c.position, velocity: DensityVec.zero),
      );
      final right = stepDrag(
        blocks: [a2, b2, c2],
        grabbedId: a2.id,
        pointer: DensityVec(a2.position.x + 0.3, a2.position.y),
        frames: 60,
      );
      expect(
        right.firstWhere((x) => x.id == a2.id).position.x,
        greaterThan(a2.position.x + 0.05),
      );

      final (a3, b3, c3) = (
        a.copyWith(position: a.position, velocity: DensityVec.zero),
        b.copyWith(position: b.position, velocity: DensityVec.zero),
        c.copyWith(position: c.position, velocity: DensityVec.zero),
      );
      final up = stepDrag(
        blocks: [a3, b3, c3],
        grabbedId: a3.id,
        pointer: DensityVec(a3.position.x, a3.position.y + 0.4),
        frames: 60,
      );
      expect(
        up.firstWhere((x) => x.id == a3.id).position.y,
        greaterThan(a3.position.y + 0.08),
      );
    });

    test('ungrabbed separation direction moves away from grabbed block', () {
      final grabbed = cube(id: 'g', tag: 'G', x: 0, y: 0.2);
      final other = cube(id: 'o', tag: 'O', x: 0, y: 0);
      // Penetrate in both axes so AABB overlap triggers separation.
      final penetrated = other.copyWith(
        position: other.position.copyWith(x: 0.02, y: 0.02),
      );
      final beforeY = penetrated.position.y;
      final result = BuoyancyWorld.step(
        blocks: [grabbed, penetrated],
        dt: dt,
        grabbedId: grabbed.id,
        pointerWorld: grabbed.position,
      ).blocks;
      final movedOther = result.firstWhere((b) => b.id == other.id);
      expect(movedOther.position.y, lessThan(beforeY));
    });

    int directionChanges(List<double> values) {
      var changes = 0;
      for (var i = 2; i < values.length; i++) {
        final d0 = values[i - 1] - values[i - 2];
        final d1 = values[i] - values[i - 1];
        if (d0.abs() > 1e-4 && d1.abs() > 1e-4 && d0.sign != d1.sign) {
          changes++;
        }
      }
      return changes;
    }

    List<double> traceX({
      required List<DensityBlock> blocks,
      required String grabbedId,
      required DensityVec pointer,
      int frames = 90,
    }) {
      final xs = <double>[];
      var next = blocks;
      for (var i = 0; i < frames; i++) {
        next = BuoyancyWorld.step(
          blocks: next,
          dt: dt,
          grabbedId: grabbedId,
          pointerWorld: pointer,
        ).blocks;
        xs.add(next.firstWhere((b) => b.id == grabbedId).position.x);
      }
      return xs;
    }

    test('oscillation: horizontal drag left — no ping-pong in x', () {
      final (top, bottom) = stackedPair();
      final xs = traceX(
        blocks: [top, bottom],
        grabbedId: top.id,
        pointer: DensityVec(top.position.x - 0.25, top.position.y),
      );
      expect(directionChanges(xs), lessThan(4));
      expect(xs.last, lessThan(xs.first - 0.05));
    });

    test('oscillation: horizontal drag right — no ping-pong in x', () {
      final (top, bottom) = stackedPair();
      final xs = traceX(
        blocks: [top, bottom],
        grabbedId: top.id,
        pointer: DensityVec(top.position.x + 0.25, top.position.y),
      );
      expect(directionChanges(xs), lessThan(4));
      expect(xs.last, greaterThan(xs.first + 0.05));
    });

    test('oscillation: vertical drag — y trajectory mostly monotonic up', () {
      final (top, bottom) = stackedPair();
      final ys = <double>[];
      var blocks = [top, bottom];
      final pointer = DensityVec(top.position.x, top.position.y + 0.35);
      for (var i = 0; i < 90; i++) {
        blocks = BuoyancyWorld.step(
          blocks: blocks,
          dt: dt,
          grabbedId: top.id,
          pointerWorld: pointer,
        ).blocks;
        ys.add(blocks.firstWhere((b) => b.id == top.id).position.y);
      }
      expect(directionChanges(ys), lessThan(4));
      expect(ys.last, greaterThan(ys.first + 0.08));
    });

    test('oscillation: partial contact lateral drag — stable x trend', () {
      final (top, bottom) = stackedPair();
      final offsetTop = top.copyWith(
        position: top.position.copyWith(x: top.position.x + 0.04),
      );
      final xs = traceX(
        blocks: [offsetTop, bottom],
        grabbedId: offsetTop.id,
        pointer: DensityVec(offsetTop.position.x - 0.2, offsetTop.position.y),
      );
      expect(directionChanges(xs), lessThan(5));
    });

    test('oscillation: resting stack without grab — no lateral jitter', () {
      final (top, bottom) = stackedPair();
      final xs = <double>[];
      var blocks = [top, bottom];
      for (var i = 0; i < 90; i++) {
        blocks = BuoyancyWorld.step(blocks: blocks, dt: dt).blocks;
        xs.add(blocks.firstWhere((b) => b.id == top.id).position.x);
      }
      expect(directionChanges(xs), lessThan(2));
    });
  });
}

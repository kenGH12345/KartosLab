import 'dart:math' as math;

import '../density_constants.dart';
import '../model/density_block.dart';
import '../model/density_vec.dart';
import '../render/density_mvt.dart';
import 'density_relation.dart';

class WorldStepResult {
  const WorldStepResult({
    required this.blocks,
    required this.fluidSurfaceY,
    required this.scaleKg,
  });

  final List<DensityBlock> blocks;
  final double fluidSurfaceY;
  final double scaleKg;
}

/// Gravity + buoyancy + contact + pointer pin. No rotation.
///
/// Pointer uses spring-damper capped at [pointerBaseForce] (`p2PointerBaseForce` 2500).
class BuoyancyWorld {
  BuoyancyWorld._();

  static const double pointerBaseForce = 2500;
  static const double pointerStiffness = 180;
  static const double pointerDamping = 34;
  static const double startDragOffset = 0.0001;
  static const double viscosity = 8.0;
  static const double slip = 0.01;
  static const double restitution = 0;

  static const double scaleWidth = 0.15;
  static const double scaleHeight = 0.06;
  static const DensityVec scalePosition = DensityVec(-0.75, 0.03);

  static WorldStepResult step({
    required List<DensityBlock> blocks,
    required double dt,
    String? grabbedId,
    DensityVec? pointerWorld,
    bool measureScale = false,
  }) {
    final clampedDt = dt.clamp(1 / 240, 1 / 30).toDouble();
    var fluidY = _fluidSurface(blocks, DensityConstants.desiredStartingPoolVolume);
    for (var i = 0; i < 3; i++) {
      fluidY = _fluidSurface(blocks, DensityConstants.desiredStartingPoolVolume);
    }

    final next = <DensityBlock>[];
    for (final block in blocks) {
      if (!block.visible) {
        next.add(block);
        continue;
      }
      next.add(
        _integrate(
          block: block,
          dt: clampedDt,
          fluidY: fluidY,
          grabbed: block.id == grabbedId,
          pointer: pointerWorld,
        ),
      );
    }

    _resolveBlockCollisions(next, grabbedId);
    _applyBoundaries(next, grabbedId);

    fluidY = _fluidSurface(next, DensityConstants.desiredStartingPoolVolume);
    final scaleKg = measureScale ? _scaleReading(next, grabbedId) : 0.0;
    return WorldStepResult(
      blocks: next,
      fluidSurfaceY: fluidY,
      scaleKg: scaleKg,
    );
  }

  static double submergedVolume(DensityBlock block, double fluidY) {
    final side = DensityRelation.cubeSideLength(block.volume);
    final half = side / 2;
    final bottom = block.position.y - half;
    final top = block.position.y + half;
    if (top <= fluidY) return block.volume;
    if (bottom >= fluidY) return 0;
    return block.volume * ((fluidY - bottom) / side).clamp(0.0, 1.0);
  }

  static double _fluidSurface(List<DensityBlock> blocks, double waterVolume) {
    var displaced = 0.0;
    final trial = fluidSurfaceYFromVolume(waterVolume);
    for (final b in blocks) {
      if (b.visible) displaced += submergedVolume(b, trial);
    }
    return fluidSurfaceYFromVolume(waterVolume + displaced);
  }

  static DensityBlock _integrate({
    required DensityBlock block,
    required double dt,
    required double fluidY,
    required bool grabbed,
    required DensityVec? pointer,
  }) {
    final mass = math.max(DensityRelation.massOf(block), 0.01);
    var vx = block.velocity.x;
    var vy = block.velocity.y;
    var x = block.position.x;
    var y = block.position.y;

    var fx = 0.0;
    var fy = 0.0;

    // User-controlled: pointer spring is primary; gravity/buoyancy fight constant
    // pointerY and produce Y-axis oscillation (Loop 10).
    if (!grabbed) {
      fy = -mass * DensityConstants.gravity;
      final disp = submergedVolume(block, fluidY);
      fy += DensityConstants.waterDensity * disp * DensityConstants.gravity;

      if (disp > 0) {
        vx *= math.exp(-viscosity * dt);
        vy *= math.exp(-viscosity * dt);
      }
    }

    if (grabbed && pointer != null) {
      final dx = pointer.x - x;
      final dy = pointer.y - y;
      var px = pointerStiffness * mass * dx - pointerDamping * mass * vx;
      var py = pointerStiffness * mass * dy - pointerDamping * mass * vy;
      final pm = math.sqrt(px * px + py * py);
      if (pm > pointerBaseForce) {
        final s = pointerBaseForce / pm;
        px *= s;
        py *= s;
      }
      fx += px;
      fy += py;
    }

    vx += fx / mass * dt;
    vy += fy / mass * dt;

    final speed = math.sqrt(vx * vx + vy * vy);
    if (speed > DensityConstants.velocityCap) {
      final s = DensityConstants.velocityCap / speed;
      vx *= s;
      vy *= s;
    }

    x += vx * dt;
    y += vy * dt;

    return block.copyWith(
      position: DensityVec(x, y),
      velocity: DensityVec(vx, vy),
    );
  }

  static void _applyBoundaries(List<DensityBlock> blocks, String? grabbedId) {
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      if (!block.visible) continue;

      final side = DensityRelation.cubeSideLength(block.volume);
      final half = side / 2;
      var x = block.position.x;
      var y = block.position.y;
      var vx = block.velocity.x;
      var vy = block.velocity.y;
      final grabbed = block.id == grabbedId;

      final inPoolX = x > DensityMvt.poolMinX && x < DensityMvt.poolMaxX;
      final floor = inPoolX ? DensityMvt.poolMinY : 0.0;
      if (y - half < floor) {
        y = floor + half;
        if (grabbed) {
          if (vy < 0) vy = 0;
        } else {
          vy = -vy * restitution;
          if (vy.abs() < 0.05) vy = 0;
          vx *= 0.72;
        }
      }

      final bottom = y - half;
      final top = y + half;
      if (bottom < DensityMvt.poolMaxY - slip && top > DensityMvt.poolMinY + slip) {
        final poolMinX = DensityMvt.poolMinX + half;
        final poolMaxX = DensityMvt.poolMaxX - half;
        if (x < poolMinX) {
          x = poolMinX;
          if (vx < 0) vx = 0;
        }
        if (x > poolMaxX) {
          x = poolMaxX;
          if (vx > 0) vx = 0;
        }
      }

      final minX = DensityMvt.barrierMinX + half;
      final maxX = DensityMvt.barrierMaxX - half;
      if (x < minX) {
        x = minX;
        if (vx < 0) vx = 0;
      }
      if (x > maxX) {
        x = maxX;
        if (vx > 0) vx = 0;
      }
      if (top > 4) {
        y = 4 - half;
        if (vy > 0) vy = 0;
      }

      blocks[i] = block.copyWith(
        position: DensityVec(x, y),
        velocity: DensityVec(vx, vy),
      );
    }
  }

  static void _resolveBlockCollisions(List<DensityBlock> blocks, String? grabbedId) {
    final passes = grabbedId == null ? 3 : 1;
    for (var pass = 0; pass < passes; pass++) {
      for (var i = 0; i < blocks.length; i++) {
        for (var j = i + 1; j < blocks.length; j++) {
          var a = blocks[i];
          var b = blocks[j];
          if (!a.visible || !b.visible) continue;

          final sideA = DensityRelation.cubeSideLength(a.volume);
          final sideB = DensityRelation.cubeSideLength(b.volume);
          final halfA = sideA / 2;
          final halfB = sideB / 2;

          final overlapX = math.min(a.position.x + halfA, b.position.x + halfB) -
              math.max(a.position.x - halfA, b.position.x - halfB);
          final overlapY = math.min(a.position.y + halfA, b.position.y + halfB) -
              math.max(a.position.y - halfA, b.position.y - halfB);

          // AABB overlap requires positive extent on both axes. Stacked blocks
          // touching only in Y have overlapY≈0 and must not trigger separation
          // (was pushing the support block sideways every frame → oscillation).
          if (overlapX <= slip || overlapY <= slip) continue;

          final aGrabbed = a.id == grabbedId;
          final bGrabbed = b.id == grabbedId;
          if (aGrabbed && bGrabbed) continue;

          if (aGrabbed || bGrabbed) {
            final grabbed = aGrabbed ? a : b;
            final other = aGrabbed ? b : a;
            final resolved = _separateUngrabbedFromGrabbed(
              grabbed: grabbed,
              other: other,
              overlapX: overlapX,
              overlapY: overlapY,
            );
            if (aGrabbed) {
              a = resolved.$1;
              b = resolved.$2;
            } else {
              a = resolved.$2;
              b = resolved.$1;
            }
          } else if (overlapX > slip && overlapY > slip) {
            if (overlapX < overlapY) {
              final push = math.max(overlapX - slip, 0.0);
              if (push > 0) {
                final sign = a.position.x >= b.position.x ? 1 : -1;
                a = _shiftBlock(a, push / 2 * sign, 0);
                b = _shiftBlock(b, push / 2 * -sign, 0);
                a = _dampVelocity(a, vxFactor: 0.5);
                b = _dampVelocity(b, vxFactor: 0.5);
              }
            } else {
              // Stacked face contact: only lift the upper block; pushing the
              // support block down fights the floor and causes Y oscillation.
              final push = math.max(overlapY - slip, 0.0);
              if (push > 0) {
                if (a.position.y >= b.position.y) {
                  a = _shiftBlockWithAxisDamping(a, 0, push, dampVy: true);
                } else {
                  b = _shiftBlockWithAxisDamping(b, 0, push, dampVy: true);
                }
              }
            }
          }
          blocks[i] = a;
          blocks[j] = b;
        }
      }
    }
  }

  /// Moves [other] away from [grabbed] along the minimum-overlap axis.
  ///
  /// The previous implementation used the same sign as the symmetric split,
  /// which pushed the resting block toward the grabbed block and fought the
  /// pointer spring (stacked drag felt locked).
  static (DensityBlock grabbed, DensityBlock other) _separateUngrabbedFromGrabbed({
    required DensityBlock grabbed,
    required DensityBlock other,
    required double overlapX,
    required double overlapY,
  }) {
    final useX = overlapX <= overlapY;
    if (useX) {
      final away = grabbed.position.x >= other.position.x ? -1.0 : 1.0;
      final push = math.max(overlapX - slip, 0.0);
      if (push <= 0) return (grabbed, other);
      return (
        grabbed,
        _shiftBlockWithAxisDamping(other, push * away, 0, dampVx: true),
      );
    }
    final push = math.max(overlapY - slip, 0.0);
    if (push <= 0) return (grabbed, other);
    // Support below grabbed: lift grabbed instead of pushing floor block down.
    if (other.position.y < grabbed.position.y) {
      return (
        _shiftBlockWithAxisDamping(grabbed, 0, push, dampVy: true),
        other,
      );
    }
    final away = grabbed.position.y >= other.position.y ? -1.0 : 1.0;
    return (
      grabbed,
      _shiftBlockWithAxisDamping(other, 0, push * away, dampVy: true),
    );
  }

  static DensityBlock _shiftBlockWithAxisDamping(
    DensityBlock block,
    double dx,
    double dy, {
    bool dampVx = false,
    bool dampVy = false,
  }) {
    return block.copyWith(
      position: block.position.copyWith(
        x: block.position.x + dx,
        y: block.position.y + dy,
      ),
      velocity: DensityVec(
        dampVx ? 0 : block.velocity.x,
        dampVy ? 0 : block.velocity.y,
      ),
    );
  }

  static DensityBlock _shiftBlock(DensityBlock block, double dx, double dy) {
    return block.copyWith(position: block.position.copyWith(x: block.position.x + dx, y: block.position.y + dy));
  }

  static DensityBlock _dampVelocity(
    DensityBlock block, {
    double vxFactor = 1,
    double vyFactor = 1,
  }) {
    return block.copyWith(
      velocity: DensityVec(
        block.velocity.x * vxFactor,
        block.velocity.y * vyFactor,
      ),
    );
  }

  static double _scaleReading(List<DensityBlock> blocks, String? grabbedId) {
    var total = 0.0;
    final scaleTop = scalePosition.y + scaleHeight / 2;
    for (final b in blocks) {
      if (!b.visible || b.id == grabbedId) continue;
      final side = DensityRelation.cubeSideLength(b.volume);
      final half = side / 2;
      final overlapsX =
          (b.position.x - scalePosition.x).abs() < half + scaleWidth / 2;
      final onTop = (b.position.y - half) <= scaleTop + 0.02 &&
          (b.position.y - half) >= scaleTop - 0.05;
      if (overlapsX && onTop) {
        total += DensityRelation.massOf(b);
      }
    }
    return total;
  }
}

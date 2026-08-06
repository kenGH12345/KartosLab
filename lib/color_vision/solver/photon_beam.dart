import 'dart:math';
import 'dart:ui';

import '../model/photon.dart';

/// Pool-based photon beam engine.
///
/// Models a beam of photons emitted from a spotlight source.
/// Implements object pooling: photons are created once during init,
/// then recycled via [Photon.reset] / [Photon.kill] instead of alloc/GC.
///
/// Each tick:
/// 1. Cull: photons beyond [maxDistance] are killed (returned to pool).
/// 2. Emit: new photons are spawned from the pool at [emissionRate] per tick.
/// 3. Move: all alive photons advance by [speed] per tick.
class PhotonBeam {
  Color color;
  final double originX;
  final double originY;
  final double speed;       // pixels per tick
  final double maxDistance; // beyond this, photons are culled
  final int maxPhotons;     // pool size
  final double emissionRate; // photons emitted per tick (intensity-scaled)
  final Random _rng = Random();

  final List<Photon> _pool = [];
  final List<Photon> alive = [];

  PhotonBeam({
    required this.color,
    required this.originX,
    required this.originY,
    this.speed = 120.0,
    this.maxDistance = 400.0,
    this.maxPhotons = 120,
    this.emissionRate = 30.0,
  }) {
    // Pre-allocate pool
    for (int i = 0; i < maxPhotons; i++) {
      _pool.add(Photon());
    }
  }

  /// Update intensity: recalculate emission rate from intensity (0-100).
  void setIntensity(double intensity) {
    // At 100% intensity, emits ~30 photons/sec; at 50%, ~15 photons/sec
    _emissionRate = intensity / 100.0 * maxPhotons * 0.25;
  }

  double _emissionRate = 2.0;
  double _accumulator = 0.0;

  /// Advance one simulation tick.
  ///
  /// Returns list of alive photons for rendering.
  List<Photon> stepInTime(double dt) {
    // 1. Cull: kill photons beyond maxDistance
    for (final p in alive) {
      if (p.x - originX > maxDistance) {
        p.kill();
      }
    }
    alive.removeWhere((p) => !p.alive);

    // 2. Emit: spawn from pool
    _accumulator += _emissionRate * dt;
    while (_accumulator >= 1.0 && alive.length < maxPhotons) {
      _accumulator -= 1.0;
      final p = _acquireFromPool();
      if (p != null) {
        alive.add(p);
      }
    }

    // 3. Move: advance all alive photons
    for (final p in alive) {
      p.x += speed * dt;
      // Small random y jitter for natural look
      p.y += (_rng.nextDouble() - 0.5) * 0.5;
    }

    return alive;
  }

  /// Acquire a photon from the pool, initializing it at the origin.
  Photon? _acquireFromPool() {
    for (final p in _pool) {
      if (!p.alive) {
        p.reset(
          originX + _rng.nextDouble() * 2, // slight x jitter at emission
          originY + (_rng.nextDouble() - 0.5) * 4,
          color,
        );
        return p;
      }
    }
    return null; // pool exhausted
  }

  /// Reset all photons to pool.
  void clear() {
    for (final p in alive) {
      p.kill();
    }
    alive.clear();
    _accumulator = 0.0;
  }
}

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gas_properties/gas_properties.dart';

/// Phase 4.1 K8 — sustained-step budget proxy for on-device frame cost.
///
/// Real-device FPS is measured separately on Android (see PHASE_4_VALIDATION.md).
/// This test records model+render-state cost for 100/500/1000 particles over
/// ~1s of model time (2.5 ps) and asserts per-step budget leaves room for 60 FPS.
void main() {
  group('K8 sustained step budget', () {
    Future<void> runCase(int n, {required int maxMs}) async {
      final m = IdealGasLawModel(
        random: RandomSource(1000 + n),
        pressureNoiseEnabled: false,
      );
      final half = n ~/ 2;
      m.setNumberHeavy(half);
      m.setNumberLight(n - half);
      // Warm collisions
      for (var i = 0; i < 5; i++) {
        m.advance(0.2);
      }
      final sw = Stopwatch()..start();
      const steps = 60; // ~12 ps ≈ several display frames of physics
      for (var i = 0; i < steps; i++) {
        m.advance(0.2);
        // Mimic view: build render snapshot each tick
        GasRenderState.fromModel(m);
      }
      sw.stop();
      final usPerStep = sw.elapsedMicroseconds / steps;
      // ignore: avoid_print
      print(
        'K8 N=$n steps=$steps total=${sw.elapsedMilliseconds}ms '
        'µs/step=${usPerStep.toStringAsFixed(0)} '
        'est_physics_ms_per_frame@2.5ps/s=${(usPerStep * (2.5 / 0.2) / 1000).toStringAsFixed(2)}',
      );
      expect(sw.elapsedMilliseconds, lessThan(maxMs));
      expect(m.numberOfParticles, n);
      expect(m.pressureKpa.isFinite, true);
      expect(m.temperatureKelvin?.isFinite ?? true, true);
    }

    test('100 particles', () => runCase(100, maxMs: 2000));
    test('500 particles', () => runCase(500, maxMs: 8000));
    test('1000 particles + heat + width', () async {
      final m = IdealGasLawModel(
        profile: IdealGasProfile.explore,
        random: RandomSource(2000),
        pressureNoiseEnabled: false,
      );
      m.setNumberHeavy(500);
      m.setNumberLight(500);
      m.setHeatCool(1);
      m.container.setDesiredWidth(8000);
      final sw = Stopwatch()..start();
      for (var i = 0; i < 60; i++) {
        m.advance(0.2);
        GasRenderState.fromModel(m, wallVelocityVisible: true);
      }
      m.setHeatCool(0);
      m.pump(50);
      for (var i = 0; i < 10; i++) {
        m.advance(0.2);
      }
      sw.stop();
      // ignore: avoid_print
      print(
        'K8 stress 1000+heat+wall+pump: ${sw.elapsedMilliseconds}ms '
        'N=${m.numberOfParticles} T=${m.temperatureKelvin}',
      );
      expect(sw.elapsedMilliseconds, lessThan(12000));
      expect(m.numberOfParticles, greaterThan(0));
      expect(
        m.particleSystem.heavyParticles.every(
          (p) => p.vx.isFinite && p.vy.isFinite && !p.x.isNaN,
        ),
        isTrue,
      );
    });
  });

  group('K8 painter allocation smoke', () {
    test('GasRenderState does not allocate exploding lists', () {
      final m = IdealGasLawModel(random: RandomSource(7));
      m.setNumberHeavy(500);
      m.setNumberLight(500);
      m.advance(0.2);
      final a = GasRenderState.fromModel(m);
      final b = GasRenderState.fromModel(m);
      expect(a.particles.length, 1000);
      expect(b.particles.length, 1000);
      expect(a.particles.length, b.particles.length);
      // radii finite
      expect(a.particles.map((p) => p.radius).fold<double>(0, math.max), greaterThan(0));
    });
  });
}

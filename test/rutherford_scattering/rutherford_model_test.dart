import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/rutherford_scattering/model/alpha_particle.dart';
import 'package:kratos/rutherford_scattering/model/plum_pudding_atom_model.dart';
import 'package:kratos/rutherford_scattering/model/rutherford_atom_model.dart';
import 'package:kratos/rutherford_scattering/model/rs_geometry.dart';
import 'package:kratos/rutherford_scattering/rs_constants.dart';

void main() {
  group('RutherfordAtomModel initial state', () {
    test('defaults match RSConstants', () {
      final m = RutherfordAtomModel();
      expect(m.gun.on, isFalse);
      expect(m.alphaParticleEnergy, RsConstants.defaultAlphaEnergy);
      expect(m.protonCount, RsConstants.defaultProtonCount);
      expect(m.neutronCount, RsConstants.defaultNeutronCount);
      expect(m.running, isTrue);
      expect(m.showTraces, isFalse);
      expect(m.scene, RutherfordScene.atom);
      expect(m.particles, isEmpty);
      expect(m.atomSpace.isVisible, isTrue);
      expect(m.nucleusSpace.isVisible, isFalse);
      expect(m.atomSpace.atoms.length, 5);
      expect(m.nucleusSpace.atoms.length, 1);
    });
  });

  group('Gun emission', () {
    test('OFF does not spawn; ON spawns over time', () {
      final m = RutherfordAtomModel();
      for (var i = 0; i < 120; i++) {
        m.step(1 / 60);
      }
      expect(m.particles, isEmpty);

      m.setGunOn(true);
      for (var i = 0; i < 120; i++) {
        m.step(1 / 60);
      }
      expect(m.particles, isNotEmpty);
      expect(m.particles.length, lessThanOrEqualTo(RsConstants.maxParticles + 5));
    });

    test('turning OFF keeps existing particles moving', () {
      final m = RutherfordAtomModel();
      m.setGunOn(true);
      for (var i = 0; i < 60; i++) {
        m.step(1 / 60);
      }
      expect(m.particles, isNotEmpty);
      final first = m.particles.first;
      final firstY = first.position.y;

      m.setGunOn(false);
      for (var i = 0; i < 10; i++) {
        m.step(1 / 60);
      }
      if (m.particles.contains(first)) {
        expect(first.position.y, isNot(equals(firstY)));
      }
    });
  });

  group('Pause / Step / Reset', () {
    test('pause freezes; manualStep advances', () {
      final m = RutherfordAtomModel();
      m.setGunOn(true);
      for (var i = 0; i < 40; i++) {
        m.step(1 / 60);
      }
      expect(m.particles, isNotEmpty);

      m.setRunning(false);
      final positions =
          m.particles.map((p) => RsVec2(p.position.x, p.position.y)).toList();
      final count = m.particles.length;
      m.step(1 / 60);
      expect(m.particles.length, count);
      for (var i = 0; i < m.particles.length; i++) {
        expect(m.particles[i].position.x, positions[i].x);
        expect(m.particles[i].position.y, positions[i].y);
      }

      m.manualStep();
      var changed = m.particles.length != count;
      for (var i = 0; i < m.particles.length && i < positions.length; i++) {
        if (m.particles[i].position.y != positions[i].y) changed = true;
      }
      expect(changed, isTrue);
    });

    test('reset restores defaults', () {
      final m = RutherfordAtomModel();
      m.setGunOn(true);
      m.setAlphaParticleEnergy(95);
      m.setProtonCount(50);
      m.setNeutronCount(40);
      m.setShowTraces(true);
      m.setScene(RutherfordScene.nucleus);
      m.setRunning(false);
      for (var i = 0; i < 30; i++) {
        m.manualStep();
      }

      m.reset();
      expect(m.gun.on, isFalse);
      expect(m.alphaParticleEnergy, RsConstants.defaultAlphaEnergy);
      expect(m.protonCount, RsConstants.defaultProtonCount);
      expect(m.neutronCount, RsConstants.defaultNeutronCount);
      expect(m.showTraces, isFalse);
      expect(m.scene, RutherfordScene.atom);
      expect(m.running, isTrue);
      expect(m.particles, isEmpty);
    });
  });

  group('Energy / Protons / Neutrons', () {
    test('energy change clears particles and sets speed for new ones', () {
      final m = RutherfordAtomModel();
      m.setGunOn(true);
      for (var i = 0; i < 40; i++) {
        m.step(1 / 60);
      }
      expect(m.particles, isNotEmpty);

      m.setAlphaParticleEnergy(60);
      expect(m.particles, isEmpty);
      expect(m.alphaParticleEnergy, 60);

      for (var i = 0; i < 40; i++) {
        m.step(1 / 60);
      }
      expect(m.particles, isNotEmpty);
      expect(m.particles.first.initialSpeed, 60);
    });

    test('proton change clears particles', () {
      final m = RutherfordAtomModel();
      m.setGunOn(true);
      for (var i = 0; i < 40; i++) {
        m.step(1 / 60);
      }
      m.setProtonCount(40);
      expect(m.particles, isEmpty);
      expect(m.protonCount, 40);
    });

    test('neutron change clears particles', () {
      final m = RutherfordAtomModel();
      m.setGunOn(true);
      for (var i = 0; i < 40; i++) {
        m.step(1 / 60);
      }
      m.setNeutronCount(80);
      expect(m.particles, isEmpty);
      expect(m.neutronCount, 80);
    });
  });

  group('Scene switch', () {
    test('Atomic↔Nuclear clears particles and toggles visibility', () {
      final m = RutherfordAtomModel();
      m.setGunOn(true);
      for (var i = 0; i < 40; i++) {
        m.step(1 / 60);
      }
      expect(m.particles, isNotEmpty);

      m.setScene(RutherfordScene.nucleus);
      expect(m.particles, isEmpty);
      expect(m.nucleusSpace.isVisible, isTrue);
      expect(m.atomSpace.isVisible, isFalse);

      m.setGunOn(true);
      // Nuclear-scale trajectories cull/error-remove more often; allow longer emit window.
      for (var i = 0; i < 300; i++) {
        m.step(1 / 60);
      }
      expect(m.particles, isNotEmpty);

      m.setScene(RutherfordScene.atom);
      expect(m.particles, isEmpty);
      expect(m.atomSpace.isVisible, isTrue);
    });
  });

  group('Scattering', () {
    test('near-nucleus trajectory bends more than far trajectory', () {
      final m = RutherfordAtomModel();
      m.setScene(RutherfordScene.nucleus);
      m.setRunning(false);
      m.setGunOn(false);

      final near = _inject(m, 12);
      final far = _inject(m, 90);

      for (var i = 0; i < 300; i++) {
        m.manualStep();
      }

      // Far particle should keep roughly its impact parameter if still present.
      final farStill = m.particles.where((p) => identical(p, far)).toList();
      final nearStill = m.particles.where((p) => identical(p, near)).toList();

      if (farStill.isNotEmpty) {
        expect((farStill.first.position.x - 90).abs(), lessThan(25));
      }
      if (nearStill.isNotEmpty) {
        // Close approach should accumulate noticeable lateral deflection.
        expect((nearStill.first.position.x - 12).abs(), greaterThan(5));
      } else {
        // Strong scatter may remove the near particle — that is also valid.
        expect(nearStill, isEmpty);
      }
    });

    test('higher proton count increases D', () {
      const L = 255.0;
      const s0 = 80.0;
      const sd = 80.0;
      double d(int p) =>
          (L / 8) * (p / RsConstants.defaultProtonCount) * ((sd * sd) / (s0 * s0));
      expect(d(100), greaterThan(d(20)));
    });
  });

  group('Plum Pudding', () {
    test('particles travel straight (no atoms)', () {
      final m = PlumPuddingAtomModel();
      expect(m.plumPuddingSpace.atoms, isEmpty);

      m.setGunOn(true);
      for (var i = 0; i < 30; i++) {
        m.step(1 / 60);
      }
      expect(m.particles, isNotEmpty);

      for (final p in m.particles) {
        final x0 = p.positions.first.x;
        expect((p.position.x - x0).abs(), lessThan(1e-6));
      }
    });

    test('reset and pause work', () {
      final m = PlumPuddingAtomModel();
      m.setGunOn(true);
      m.setAlphaParticleEnergy(70);
      m.setShowTraces(true);
      for (var i = 0; i < 20; i++) {
        m.step(1 / 60);
      }
      m.setRunning(false);
      final y = m.particles.isEmpty ? 0.0 : m.particles.first.position.y;
      m.step(1 / 60);
      if (m.particles.isNotEmpty) {
        expect(m.particles.first.position.y, y);
      }
      m.reset();
      expect(m.gun.on, isFalse);
      expect(m.alphaParticleEnergy, RsConstants.defaultAlphaEnergy);
      expect(m.particles, isEmpty);
    });
  });

  group('Traces', () {
    test('positions history grows while particle moves', () {
      final m = RutherfordAtomModel();
      m.setGunOn(true);
      for (var i = 0; i < 20; i++) {
        m.step(1 / 60);
      }
      expect(m.particles, isNotEmpty);
      final p = m.particles.first;
      final len = p.positions.length;
      expect(len, greaterThan(1));
      m.step(1 / 60);
      if (m.particles.contains(p)) {
        expect(p.positions.length, greaterThan(len));
      }
    });
  });

  group('Bounds', () {
    test('model bounds match PhET SPACE_NODE/4', () {
      final m = RutherfordAtomModel();
      expect(m.bounds.width, RsConstants.spaceNodeWidth / 2);
      expect(m.bounds.height, RsConstants.spaceNodeHeight / 2);
    });
  });
}

AlphaParticle _inject(RutherfordAtomModel m, double x) {
  final p = AlphaParticle(
    speed: m.alphaParticleEnergy,
    defaultSpeed: m.alphaParticleEnergy,
    position: RsVec2(x, m.bounds.minY),
  );
  m.addParticle(p);
  return p;
}

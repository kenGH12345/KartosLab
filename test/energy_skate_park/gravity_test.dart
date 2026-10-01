import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_skate_park/controller/intro_controller.dart';
import 'package:kratos/energy_skate_park/controller/graphs_controller.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/gravity_magnitude.dart';

void main() {
  group('GravityMagnitude helpers', () {
    test('clamp to [1, 26]', () {
      expect(GravityMagnitude.clamp(0), 1);
      expect(GravityMagnitude.clamp(50), 26);
      expect(GravityMagnitude.clamp(9.8), 9.8);
    });

    test('comboAdapterValue exact presets else Custom(null)', () {
      expect(GravityMagnitude.comboAdapterValue(1.6), EspConstants.moonGravity);
      expect(GravityMagnitude.comboAdapterValue(9.8), EspConstants.earthGravity);
      expect(
          GravityMagnitude.comboAdapterValue(24.8), EspConstants.jupiterGravity);
      expect(GravityMagnitude.comboAdapterValue(10.0), isNull);
      expect(GravityMagnitude.comboAdapterValue(9.7), isNull);
      // Near-earth must NOT snap to Earth (PhysicalComboBox uses ===).
      expect(GravityMagnitude.comboAdapterValue(9.75), isNull);
    });

    test('display precision 1 decimal', () {
      expect(GravityMagnitude.display(9.8), contains('9.8'));
      expect(GravityMagnitude.display(10), contains('10.0'));
    });
  });

  group('Gravity control → physics', () {
    test('default gravity is Earth 9.8', () {
      final c = IntroController();
      expect(c.model.gravityMagnitude, EspConstants.earthGravity);
      expect(c.model.skater.gravity, -EspConstants.earthGravity);
    });

    test('preset moon/jupiter write magnitude and signed gravity', () {
      final c = IntroController();
      c.setGravityMagnitude(EspConstants.moonGravity);
      expect(c.model.gravityMagnitude, 1.6);
      expect(c.model.skater.gravity, closeTo(-1.6, 1e-12));

      c.setGravityMagnitude(EspConstants.jupiterGravity);
      expect(c.model.gravityMagnitude, 24.8);
      expect(c.model.skater.gravity, closeTo(-24.8, 1e-12));
    });

    test('custom gravity is stored and used by skater (not snapped to Earth)', () {
      final c = IntroController();
      c.setGravityMagnitude(12.5);
      expect(c.model.gravityMagnitude, 12.5);
      expect(GravityMagnitude.comboAdapterValue(c.model.gravityMagnitude), isNull);
      expect(c.model.skater.gravity, closeTo(-12.5, 1e-12));
    });

    test('min / max gravity magnitude', () {
      final c = IntroController();
      c.setGravityMagnitude(0.1);
      expect(c.model.gravityMagnitude, EspConstants.gravityMagnitudeMin);
      c.setGravityMagnitude(100);
      expect(c.model.gravityMagnitude, EspConstants.gravityMagnitudeMax);
    });

    test('slider-like change updates PE immediately', () {
      final c = IntroController();
      final track = c.model.getPhysicalTracks().first;
      c.model.skater.track = track;
      c.model.skater.parametricPosition = 0.2;
      c.model.skater.positionX = track.getX(0.2);
      c.model.skater.positionY = track.getY(0.2);
      c.model.skater.velocityX = 0;
      c.model.skater.velocityY = 0;
      c.model.skater.thermalEnergy = 0;
      c.setGravityMagnitude(9.8);
      final peEarth = c.model.skater.potentialEnergy;

      c.setGravityMagnitude(20.0);
      final peCustom = c.model.skater.potentialEnergy;
      // PE = -m * (y - href) * g_signed = m * (y-href) * magnitude
      // Higher magnitude → higher PE for y > href.
      if (c.model.skater.positionY > c.model.skater.referenceHeight) {
        expect(peCustom.abs(), greaterThan(peEarth.abs()));
      }
      expect(c.model.skater.gravity, closeTo(-20.0, 1e-12));
    });

    test('preset → custom → preset', () {
      final c = IntroController();
      c.setGravityMagnitude(EspConstants.earthGravity);
      expect(GravityMagnitude.isEarth(c.model.gravityMagnitude), isTrue);

      c.setGravityMagnitude(15.0);
      expect(GravityMagnitude.isPreset(c.model.gravityMagnitude), isFalse);

      c.setGravityMagnitude(EspConstants.moonGravity);
      expect(GravityMagnitude.isMoon(c.model.gravityMagnitude), isTrue);
    });

    test('reset restores Earth gravity', () {
      final c = IntroController();
      c.setGravityMagnitude(22.0);
      c.reset();
      expect(c.model.gravityMagnitude, EspConstants.earthGravity);
      expect(c.model.skater.gravity, closeTo(-9.8, 1e-12));
    });

    test('custom gravity affects free-fall acceleration via SkaterState', () {
      final c = IntroController();
      c.setGravityMagnitude(5.0);
      final state = c.model.skater.toSkaterState();
      expect(state.gravity, closeTo(-5.0, 1e-12));
    });

    test('custom gravity trajectory diverges from Earth (Graphs)', () {
      final earth = GraphsController();
      final custom = GraphsController();
      for (final c in [earth, custom]) {
        final track = c.model.getPhysicalTracks().first;
        c.model.skater.track = track;
        c.model.skater.parametricPosition = 0.15;
        c.model.skater.parametricSpeed = 0;
        c.model.skater.positionX = track.getX(0.15);
        c.model.skater.positionY = track.getY(0.15);
        c.model.skater.velocityX = 0;
        c.model.skater.velocityY = 0;
        c.model.skater.thermalEnergy = 0;
        c.model.skater.updateEnergy();
        c.model.friction = 0;
        c.model.paused = false;
      }
      earth.setGravityMagnitude(EspConstants.earthGravity);
      custom.setGravityMagnitude(20.0);

      for (var i = 0; i < 90; i++) {
        earth.model.step(EspConstants.dt);
        custom.model.step(EspConstants.dt);
      }

      // Same start; larger |g| → different parametric speed / position.
      final dx = (earth.model.skater.positionX - custom.model.skater.positionX)
          .abs();
      final dy = (earth.model.skater.positionY - custom.model.skater.positionY)
          .abs();
      expect(dx + dy, greaterThan(0.01),
          reason: 'custom g must change trajectory vs Earth');
    });

    test('custom gravity KE+PE+thermal energy bookkeeping', () {
      final c = IntroController();
      c.setGravityMagnitude(14.0);
      final track = c.model.getPhysicalTracks().first;
      c.model.skater.track = track;
      c.model.skater.parametricPosition = 0.25;
      c.model.skater.positionX = track.getX(0.25);
      c.model.skater.positionY = track.getY(0.25);
      c.model.skater.parametricSpeed = 0;
      c.model.skater.velocityX = 0;
      c.model.skater.velocityY = 0;
      c.model.skater.thermalEnergy = 0;
      c.model.friction = 0;
      c.model.skater.updateEnergy();
      c.model.paused = false;

      final e0 = c.model.skater.totalEnergy;
      for (var i = 0; i < 60; i++) {
        c.model.step(EspConstants.dt);
      }
      final s = c.model.skater;
      expect(
        s.kineticEnergy + s.potentialEnergy + s.thermalEnergy,
        closeTo(s.totalEnergy, 1e-6),
      );
      // Frictionless: total near conserved.
      expect((s.totalEnergy - e0).abs(), lessThan(1e-2));
    });
  });
}

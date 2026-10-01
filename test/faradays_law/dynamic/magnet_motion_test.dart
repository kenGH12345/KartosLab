import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';

import 'dynamic_test_helpers.dart';

void main() {
  group('stationary magnet', () {
    test('many steps keep EMF ~0 and voltage settles near 0', () {
      final model = FaradaysLawModel();
      for (var i = 0; i < 120; i++) {
        model.step(1 / 60);
      }
      expect(model.bottomCoil.emf.abs(), lessThan(1e-9));
      expect(model.voltage.abs(), lessThan(1e-3));
      expect(model.bulb.brightness, 0);
    });

    test('stationary does not continuously increase voltage', () {
      final model = FaradaysLawModel();
      model.step(1 / 60);
      final v0 = model.voltage.abs();
      for (var i = 0; i < 60; i++) {
        model.step(1 / 60);
      }
      expect(model.voltage.abs(), lessThanOrEqualTo(v0 + 1e-6));
    });
  });

  group('motion chain', () {
    test('slow trajectory updates B, EMF, signal continuously', () {
      final model = FaradaysLawModel();
      final path = approachCoilTrajectory(steps: 10);
      model.setMagnetPositionForTest(path.first);
      model.bottomCoil.reset();

      var prevB = model.bottomCoil.magneticField;
      var sawEmf = false;
      for (var i = 1; i < path.length; i++) {
        model.setMagnetPositionForTest(path[i]);
        model.step(1 / 60);
        final b = model.bottomCoil.magneticField;
        final deltaB = b - prevB;
        expect(
          model.bottomCoil.emf,
          closeTo(model.bottomCoil.numberOfCoils * deltaB / (1 / 60), 1e-9),
        );
        expect(
          model.voltmeter.signal,
          closeTo(
            FaradaysLawConstants.emfToSignalScale *
                (model.bottomCoil.emf + model.topCoil.emf),
            1e-9,
          ),
        );
        if (model.bottomCoil.emf.abs() > 1e-6) sawEmf = true;
        prevB = b;
      }
      expect(sawEmf, isTrue);
    });

    test('faster motion yields larger |EMF| for same displacement', () {
      double peakEmf(double dt) {
        final model = FaradaysLawModel();
        model.setMagnetPositionForTest(const Offset(600, 310));
        model.bottomCoil.reset();
        model.setMagnetPositionForTest(const Offset(448, 310));
        model.step(dt);
        return model.bottomCoil.emf.abs();
      }

      expect(peakEmf(0.02), greaterThan(peakEmf(0.1)));
    });

    test('toward vs away reverses EMF sign', () {
      final toward = FaradaysLawModel();
      toward.setMagnetPositionForTest(const Offset(600, 310));
      toward.bottomCoil.reset();
      toward.setMagnetPositionForTest(const Offset(448, 310));
      toward.step(0.05);

      final away = FaradaysLawModel();
      away.setMagnetPositionForTest(const Offset(448, 310));
      away.bottomCoil.reset();
      away.setMagnetPositionForTest(const Offset(600, 310));
      away.step(0.05);

      expect(toward.bottomCoil.emf.sign, isNot(away.bottomCoil.emf.sign));
    });

    test('stop after motion: EMF→0 then voltage settles (not permanent peak)',
        () {
      final model = FaradaysLawModel();
      model.setMagnetPositionForTest(const Offset(600, 310));
      model.bottomCoil.reset();
      model.setMagnetPositionForTest(const Offset(448, 310));
      model.step(0.05);
      for (var i = 0; i < 10; i++) {
        model.step(1 / 60);
      }
      final peak = model.voltage.abs();
      expect(peak, greaterThan(0));

      // Stationary: EMF zero each step
      for (var i = 0; i < 180; i++) {
        model.step(1 / 60);
        expect(model.bottomCoil.emf.abs(), lessThan(1e-9));
      }
      expect(model.voltage.abs(), lessThan(peak));
      expect(model.voltage.abs(), lessThan(0.05));
    });

    test('trajectory is deterministic after reset', () {
      List<double> voltages() {
        final model = FaradaysLawModel();
        final path = approachCoilTrajectory(steps: 6);
        runTrajectory(model, path, dt: 1 / 60);
        return [
          model.bottomCoil.magneticField,
          model.bottomCoil.emf,
          model.voltage,
          model.voltmeter.signal,
          model.bulb.haloScale,
        ];
      }

      final a = voltages();
      final b = voltages();
      for (var i = 0; i < a.length; i++) {
        expect(b[i], closeTo(a[i], 1e-12));
      }
    });
  });

  group('frame independence', () {
    test('same end position → same B regardless of step count', () {
      final many = FaradaysLawModel();
      final few = FaradaysLawModel();
      const start = Offset(620, 310);
      const end = Offset(448, 310);

      many.setMagnetPositionForTest(start);
      many.bottomCoil.reset();
      for (var i = 1; i <= 12; i++) {
        final t = i / 12;
        many.setMagnetPositionForTest(
          Offset(start.dx + (end.dx - start.dx) * t, start.dy),
        );
        many.step(1 / 60);
      }

      few.setMagnetPositionForTest(start);
      few.bottomCoil.reset();
      for (var i = 1; i <= 3; i++) {
        final t = i / 3;
        few.setMagnetPositionForTest(
          Offset(start.dx + (end.dx - start.dx) * t, start.dy),
        );
        few.step(1 / 60);
      }

      expect(
        many.bottomCoil.magneticField,
        closeTo(few.bottomCoil.magneticField, 1e-12),
      );
      expect(many.magnet.position, end);
      expect(few.magnet.position, end);
    });
  });

  group('clock / dt', () {
    test('dt <= 0 is no-op', () {
      final model = FaradaysLawModel();
      model.setMagnetPositionForTest(const Offset(600, 310));
      model.bottomCoil.reset();
      model.setMagnetPositionForTest(const Offset(448, 310));
      model.step(0);
      model.step(-1);
      expect(model.bottomCoil.emf, 0);
    });

    test('dt > maxDT clamps to 0.1 for EMF', () {
      final model = FaradaysLawModel();
      model.setMagnetPositionForTest(const Offset(600, 310));
      model.bottomCoil.reset();
      final b0 = model.bottomCoil.magneticField;
      model.setMagnetPositionForTest(const Offset(448, 310));
      model.step(1.0);
      final expected = model.bottomCoil.numberOfCoils *
          (model.bottomCoil.magneticField - b0) /
          FaradaysLawConstants.maxDt;
      expect(model.bottomCoil.emf, closeTo(expected, 1e-9));
    });
  });

  group('polarity dynamics', () {
    test('NS vs SN same trajectory flips EMF sign', () {
      double emf(MagnetOrientation o) {
        final model = FaradaysLawModel();
        model.magnet.orientation = o;
        model.setMagnetPositionForTest(const Offset(600, 310));
        model.bottomCoil.reset();
        model.setMagnetPositionForTest(const Offset(448, 310));
        model.step(0.05);
        return model.bottomCoil.emf;
      }

      expect(emf(MagnetOrientation.sn), closeTo(-emf(MagnetOrientation.ns), 1e-9));
    });

    test('double flip restores trajectory response', () {
      final path = approachCoilTrajectory(steps: 5);
      final baseline = FaradaysLawModel();
      runTrajectory(baseline, path);

      final flipped = FaradaysLawModel();
      flipped.flipPolarity();
      flipped.flipPolarity();
      runTrajectory(flipped, path);

      expect(flipped.magnet.orientation, MagnetOrientation.ns);
      expect(flipped.bottomCoil.emf, closeTo(baseline.bottomCoil.emf, 1e-12));
      expect(flipped.voltage, closeTo(baseline.voltage, 1e-12));
    });
  });
}

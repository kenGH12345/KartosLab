import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/quantum_measurement/bloch_sphere/model/bloch_sphere_model.dart';
import 'package:kratos/quantum_measurement/common/qm_random.dart';

void main() {
  group('Bloch vector / state', () {
    test('pure state |r|=1 for presets', () {
      for (final d in BlochStateDirection.values) {
        if (d == BlochStateDirection.custom) continue;
        final v = BlochVector3.fromAngles(d.polarAngle, d.azimuthalAngle);
        expect(v.magnitude, closeTo(1.0, 1e-12), reason: '$d');
      }
    });

    test('+Z → P(up)=1 in Z basis amplitudes', () {
      final amp = QuantumStateAmplitudes(0, 0);
      expect(amp.pUp, closeTo(1.0, 1e-12));
      expect(amp.pDown, closeTo(0.0, 1e-12));
    });

    test('+X (θ=π/2, φ=0) → P(up)=P(down)=0.5', () {
      final amp = QuantumStateAmplitudes(math.pi / 2, 0);
      expect(amp.pUp, closeTo(0.5, 1e-12));
      expect(amp.pDown, closeTo(0.5, 1e-12));
    });

    test('α² + β² = 1', () {
      final amp = QuantumStateAmplitudes(1.2, 0.7);
      expect(amp.pUp + amp.pDown, closeTo(1.0, 1e-12));
    });
  });

  group('Bloch measurement collapse', () {
    test('measure +Z state along Z always up', () {
      final sphere = ComplexBlochSphere(initialPolar: 0, initialAzimuthal: 0);
      for (var i = 0; i < 20; i++) {
        sphere.setDirection(0, 0);
        expect(sphere.measure(MeasurementAxis.z, SeededQmRandom(i)), isTrue);
        expect(sphere.polarAngle, 0);
      }
    });

    test('Observe updates counts and state → OBSERVED', () {
      final model = BlochSphereModel(random: SeededQmRandom(10));
      model.setSpinState(BlochStateDirection.xPlus);
      model.measurementAxis = MeasurementAxis.z;
      model.initiateObservation();
      expect(model.measurementState, BlochMeasurementState.observed);
      expect(model.upMeasurementCount + model.downMeasurementCount, 1);
    });

    test('Reprepare restores prepared state from preparation sphere', () {
      final model = BlochSphereModel(random: SeededQmRandom(10));
      model.setSpinState(BlochStateDirection.zPlus);
      model.initiateObservation();
      model.reprepare();
      expect(model.measurementState, BlochMeasurementState.prepared);
      expect(model.singleMeasurement.polarAngle, model.preparation.polarAngle);
    });
  });

  group('Magnetic field precession', () {
    test('azimuth advances when rotatingSpeed > 0', () {
      final sphere = ComplexBlochSphere(
        initialPolar: math.pi / 2,
        initialAzimuthal: 0,
      );
      sphere.rotatingSpeed = 1.0;
      sphere.step(0.1);
      expect(sphere.azimuthalAngle, greaterThan(0));
      expect(sphere.vector.magnitude, closeTo(1.0, 1e-12));
    });

    test('B-field Observe uses timing then collapses', () {
      final model = BlochSphereModel(random: SeededQmRandom(3));
      model.magneticFieldEnabled = true;
      model.measurementDelay = 0.01;
      model.initiateObservation();
      expect(model.measurementState, BlochMeasurementState.timingObservation);
      // step enough model time
      for (var i = 0; i < 50; i++) {
        model.step(1.0);
        if (model.measurementState == BlochMeasurementState.observed) break;
      }
      expect(model.measurementState, BlochMeasurementState.observed);
    });
  });

  group('Erase vs Reset', () {
    test('erase clears counts only', () {
      final model = BlochSphereModel(random: SeededQmRandom(4));
      model.setSpinState(BlochStateDirection.zPlus);
      model.initiateObservation();
      expect(model.upMeasurementCount + model.downMeasurementCount, greaterThan(0));
      final axis = model.measurementAxis;
      model.erase();
      expect(model.upMeasurementCount, 0);
      expect(model.downMeasurementCount, 0);
      expect(model.measurementAxis, axis);
    });

    test('reset restores defaults including +X prep', () {
      final model = BlochSphereModel(random: SeededQmRandom(4));
      model.setSpinState(BlochStateDirection.zMinus);
      model.magneticFieldEnabled = true;
      model.reset();
      expect(model.spinState, BlochStateDirection.xPlus);
      expect(model.magneticFieldEnabled, isFalse);
      expect(model.measurementState, BlochMeasurementState.prepared);
    });
  });

  group('Bloch determinism', () {
    test('same seed ⇒ same observe outcomes', () {
      List<bool> run(int seed) {
        final rng = SeededQmRandom(seed);
        final sphere = ComplexBlochSphere(
          initialPolar: math.pi / 2,
          initialAzimuthal: 0,
        );
        return List.generate(30, (_) {
          sphere.setDirection(math.pi / 2, 0);
          return sphere.measure(MeasurementAxis.z, rng);
        });
      }

      expect(run(88), run(88));
      expect(run(88), isNot(run(89)));
    });
  });
}

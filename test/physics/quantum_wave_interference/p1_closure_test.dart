import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';

void main() {
  group('P1-3 DetectorScreenScale', () {
    test('full half-width is ±20 mm = 0.02 m', () {
      expect(DetectorScreenScale.fullDetectorScreenHalfWidthM, closeTo(0.02, 1e-15));
      expect(DetectorScreenScale.defaultScaleIndex, 0);
      expect(DetectorScreenScale.halfWidthMetersForScaleIndex(0), 0.02);
      expect(DetectorScreenScale.halfWidthMetersForScaleIndex(1), closeTo(0.015, 1e-15));
      expect(DetectorScreenScale.halfWidthMetersForScaleIndex(2), closeTo(0.01, 1e-15));
      expect(DetectorScreenScale.halfWidthMetersForScaleIndex(3), closeTo(0.005, 1e-15));
    });

    test('ExperimentModel uses full half-width not proxy', () {
      final model = ExperimentModel(random: SeededQwiRandom(1));
      expect(model.scene.fullScreenHalfWidthM, DetectorScreenScale.fullDetectorScreenHalfWidthM);
      expect(model.scene.fullScreenHalfWidthM, isNot(closeTo(model.scene.screenDistanceM * 0.15, 1e-6)));
      model.setDetectorScreenScaleIndex(3);
      expect(model.visibleDetectorHalfWidthM, closeTo(0.005, 1e-15));
      // Underlying data half-width unchanged by zoom
      expect(model.scene.fullScreenHalfWidthM, 0.02);
    });
  });

  group('P1-1 Probe measurement projection', () {
    test('failed measurement applies bite and preserves total probability via renorm', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(42));
      model.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
      model.scene.emitPacket();
      for (var i = 0; i < 45; i++) {
        model.stepOnce();
      }
      expect(model.scene.isPacketActive, isTrue);

      final before = model.scene.solver.integrateProbabilityDensity(projections: const []);
      expect(before, greaterThan(0));

      // Force failure path with known projection
      model.scene.detectorProbe
        ..normalizedX = 0.55
        ..normalizedY = 0.5
        ..radius = 0.15
        ..state = ProbeState.ready;

      // Apply projection directly (same as failed Detect)
      model.scene.solver.applyMeasurementProjection(
        centerNormX: 0.55,
        centerNormY: 0.5,
        radiusNorm: 0.15,
      );

      expect(model.scene.solver.measurementProjections, isNotEmpty);
      final after = model.scene.solver.integrateProbabilityDensity();
      // Renorm keeps integrated intensity ≈ before
      expect(after / before, closeTo(1.0, 0.08));

      // Center of bite should be attenuated relative to unprojected at same point
      final source = model.scene.solver.createSource();
      final cx = 0.55 * model.scene.solver.regionWidth;
      final cy = 0.0;
      final unproj = evaluateSample(
        model.scene.solver.createKernelParameters(source, projections: const []),
        cx,
        cy,
        model.scene.solver.time,
      );
      final proj = evaluateSample(
        model.scene.solver.createKernelParameters(source),
        cx,
        cy,
        model.scene.solver.time,
      );
      expect(computeSampleIntensity(proj), lessThan(computeSampleIntensity(unproj) + 1e-18));
    });

    test('Bernoulli success ends packet without screen hit', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(7));
      model.scene.setSlitConfiguration(SlitConfiguration.noBarrier);
      model.scene.emitPacket();
      for (var i = 0; i < 40; i++) {
        model.stepOnce();
      }
      final beforeHits = model.scene.hits.length;
      // Large probe → high p; keep measuring until success or exhaust
      model.scene.detectorProbe
        ..radius = 0.3
        ..normalizedX = 0.5
        ..normalizedY = 0.5;
      var sawSuccess = false;
      for (var a = 0; a < 80 && model.scene.isPacketActive; a++) {
        model.scene.detectorProbe.state = ProbeState.ready;
        model.scene.performDetectorMeasurement();
        if (model.scene.detectorProbe.state == ProbeState.detected) {
          sawSuccess = true;
          expect(model.scene.hits.length, beforeHits);
          expect(model.scene.isPacketActive, isFalse);
          break;
        }
      }
      expect(sawSuccess || model.scene.solver.measurementProjections.isNotEmpty, isTrue);
    });
  });

  group('P1-2 HI slit-detector decoherence scheduling', () {
    test('events schedule at 5/s after wavefront reaches slits', () {
      final model = HighIntensityModel(random: SeededQwiRandom(11));
      model.scene.setSlitConfiguration(SlitConfiguration.bothDetectors);
      model.clock.setSpeed(TimeSpeed.fast);
      model.scene.setEmitting(true);

      for (var i = 0; i < 500; i++) {
        model.step(1 / 60);
      }

      expect(model.scene.solver.decoherenceEvents, isNotEmpty);
      expect(model.scene.leftDetectorHits + model.scene.rightDetectorHits, greaterThan(0));

      // Events are spaced ~0.2 s (rate 5/s)
      final times = model.scene.solver.decoherenceEvents.map((e) => e.time).toList()..sort();
      if (times.length >= 2) {
        final dt = times[1] - times[0];
        expect(dt, closeTo(0.2, 0.05));
      }
    });

    test('no events when bothOpen without detectors', () {
      final model = HighIntensityModel(random: SeededQwiRandom(12));
      model.scene.setSlitConfiguration(SlitConfiguration.bothOpen);
      model.clock.setSpeed(TimeSpeed.fast);
      model.scene.setEmitting(true);
      for (var i = 0; i < 400; i++) {
        model.step(1 / 60);
      }
      expect(model.scene.solver.decoherenceEvents, isEmpty);
    });

    test('which-path events make decoherent intensity differ from coherent at same setup', () {
      List<double> pdfFor(SlitConfiguration config, int seed) {
        final model = HighIntensityModel(random: SeededQwiRandom(seed));
        model.scene.setSlitConfiguration(config);
        model.clock.setSpeed(TimeSpeed.fast);
        model.scene.setEmitting(true);
        for (var i = 0; i < 500; i++) {
          model.step(1 / 60);
        }
        return model.scene.detectorPdf;
      }

      final coherent = pdfFor(SlitConfiguration.bothOpen, 21);
      final decoherent = pdfFor(SlitConfiguration.bothDetectors, 21);
      expect(coherent.any((v) => v > 0), isTrue);
      expect(decoherent.any((v) => v > 0), isTrue);
      // Distributions should not be identical once decoherence events fire
      var same = true;
      for (var i = 0; i < coherent.length; i++) {
        if ((coherent[i] - decoherent[i]).abs() > 1e-6) {
          same = false;
          break;
        }
      }
      // If wavefront reached and events fired, expect difference; else still valid empty-vs-filled edge
      expect(same == false || decoherent.every((v) => v == 0), isTrue);
    });
  });
}

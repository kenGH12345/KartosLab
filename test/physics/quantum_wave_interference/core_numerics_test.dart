import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';

void main() {
  group('Complex', () {
    test('arithmetic and polar', () {
      final a = Complex(3, 4);
      expect(a.magnitudeSquared, 25);
      expect(a.magnitude, 5);
      final b = Complex.polar(2, math.pi / 2);
      expect(b.real, closeTo(0, 1e-12));
      expect(b.imaginary, closeTo(2, 1e-12));
      expect((a + b).real, closeTo(3, 1e-12));
      expect((a * Complex(1, 0)).real, 3);
      expect(a.conjugate.imaginary, -4);
    });
  });

  group('Units', () {
    test('conversions', () {
      expect(QwiUnits.nmToM(650), closeTo(6.5e-7, 1e-18));
      expect(QwiUnits.mmToM(0.25), closeTo(2.5e-4, 1e-18));
      expect(QwiUnits.umToMm(2), closeTo(0.002, 1e-18));
      expect(QwiUnits.nmToMm(2), closeTo(2e-6, 1e-18));
    });
  });

  group('Particle / matter wavelength', () {
    test('masses from source', () {
      expect(QwiConstants.particleMassKg(SourceType.photons), 0);
      expect(QwiConstants.particleMassKg(SourceType.electrons), 9.109e-31);
      expect(QwiConstants.particleMassKg(SourceType.neutrons), 1.675e-27);
      expect(QwiConstants.particleMassKg(SourceType.heliumAtoms), 6.646e-27);
    });

    test('de Broglie for electron default speed', () {
      final props = MatterWaveProperties(sourceType: SourceType.electrons, speedMps: 1.1e6);
      final expected = QwiConstants.planckConstant / (9.109e-31 * 1.1e6);
      expect(props.wavelengthM, closeTo(expected, expected * 1e-12));
    });

    test('photons use nm path not de Broglie', () {
      expect(
        effectiveWavelengthM(
          sourceType: SourceType.photons,
          photonWavelengthNm: 650,
          particleSpeedMps: 0,
        ),
        closeTo(QwiUnits.nmToM(650), 1e-20),
      );
    });
  });

  group('sinc / Fraunhofer', () {
    test('sincSquared limits', () {
      expect(FraunhoferSolver.sincSquared(0), 1);
      expect(FraunhoferSolver.sincSquared(math.pi), closeTo(0, 1e-12));
      expect(FraunhoferSolver.sincSquared(-math.pi / 2), closeTo(FraunhoferSolver.sincSquared(math.pi / 2), 1e-12));
    });

    test('double slit center bright, which-path removes fringes', () {
      const opts = FraunhoferOptions(
        positionOnScreenM: 0,
        effectiveWavelengthM: 650e-9,
        screenDistanceM: 0.6,
        slitWidthM: 0.02e-3,
        slitSeparationM: 0.25e-3,
        slitSetting: SlitConfiguration.bothOpen,
      );
      final both = FraunhoferSolver.getExactDetectorIntensity(opts);
      final decohered = FraunhoferSolver.getExactDetectorIntensity(
        FraunhoferOptions(
          positionOnScreenM: 0,
          effectiveWavelengthM: opts.effectiveWavelengthM,
          screenDistanceM: opts.screenDistanceM,
          slitWidthM: opts.slitWidthM,
          slitSeparationM: opts.slitSeparationM,
          slitSetting: SlitConfiguration.bothDetectors,
        ),
      );
      expect(both, closeTo(1, 1e-9));
      expect(decohered, closeTo(1, 1e-9)); // envelope peak also 1 at center

      // Off-center: interference modulates
      final y = 0.0002;
      final iBoth = FraunhoferSolver.getExactDetectorIntensity(
        FraunhoferOptions(
          positionOnScreenM: y,
          effectiveWavelengthM: opts.effectiveWavelengthM,
          screenDistanceM: opts.screenDistanceM,
          slitWidthM: opts.slitWidthM,
          slitSeparationM: opts.slitSeparationM,
          slitSetting: SlitConfiguration.bothOpen,
        ),
      );
      final iDec = FraunhoferSolver.getExactDetectorIntensity(
        FraunhoferOptions(
          positionOnScreenM: y,
          effectiveWavelengthM: opts.effectiveWavelengthM,
          screenDistanceM: opts.screenDistanceM,
          slitWidthM: opts.slitWidthM,
          slitSeparationM: opts.slitSeparationM,
          slitSetting: SlitConfiguration.bothDetectors,
        ),
      );
      expect(iBoth == iDec, isFalse);
    });

    test('symmetry P(-y) ≈ P(y) for bothOpen', () {
      double at(double y) => FraunhoferSolver.getExactDetectorIntensity(
            FraunhoferOptions(
              positionOnScreenM: y,
              effectiveWavelengthM: 650e-9,
              screenDistanceM: 0.6,
              slitWidthM: 0.02e-3,
              slitSeparationM: 0.25e-3,
              slitSetting: SlitConfiguration.bothOpen,
            ),
          );
      expect(at(0.0001), closeTo(at(-0.0001), 1e-15));
    });

    test('wavelength and slit separation change pattern', () {
      double at({required double lambda, required double d, required double y}) =>
          FraunhoferSolver.getExactDetectorIntensity(
            FraunhoferOptions(
              positionOnScreenM: y,
              effectiveWavelengthM: lambda,
              screenDistanceM: 0.6,
              slitWidthM: 0.02e-3,
              slitSeparationM: d,
              slitSetting: SlitConfiguration.bothOpen,
            ),
          );
      expect(at(lambda: 400e-9, d: 0.25e-3, y: 0.0003) == at(lambda: 700e-9, d: 0.25e-3, y: 0.0003), isFalse);
      expect(at(lambda: 650e-9, d: 0.05e-3, y: 0.0003) == at(lambda: 650e-9, d: 0.5e-3, y: 0.0003), isFalse);
    });

    test('screen distance changes intensity off-axis', () {
      double at(double L) => FraunhoferSolver.getExactDetectorIntensity(
            FraunhoferOptions(
              positionOnScreenM: 0.0004,
              effectiveWavelengthM: 650e-9,
              screenDistanceM: L,
              slitWidthM: 0.02e-3,
              slitSeparationM: 0.25e-3,
              slitSetting: SlitConfiguration.bothOpen,
            ),
          );
      expect(at(0.4) == at(0.8), isFalse);
    });

    test('single slit scale 0.5 at open-slit center', () {
      // leftCovered → open slit offset = +d/2
      const d = 0.25e-3;
      final open = FraunhoferSolver.getExactDetectorIntensity(
        const FraunhoferOptions(
          positionOnScreenM: d / 2,
          effectiveWavelengthM: 650e-9,
          screenDistanceM: 0.6,
          slitWidthM: 0.02e-3,
          slitSeparationM: d,
          slitSetting: SlitConfiguration.leftCovered,
        ),
      );
      expect(open, closeTo(0.5, 1e-9));
    });

    test('noBarrier returns 1', () {
      expect(
        FraunhoferSolver.getExactDetectorIntensity(
          const FraunhoferOptions(
            positionOnScreenM: 0.1,
            effectiveWavelengthM: 650e-9,
            screenDistanceM: 0.6,
            slitWidthM: 0.02e-3,
            slitSeparationM: 0.25e-3,
            slitSetting: SlitConfiguration.noBarrier,
          ),
        ),
        1,
      );
    });
  });

  group('Coherence groups', () {
    test('same group interferes; different groups add intensities', () {
      final a = FieldComponent(
        source: FieldComponentSource.topSlit,
        coherenceGroup: 'g',
        value: Complex(1, 0),
      );
      final b = FieldComponent(
        source: FieldComponentSource.bottomSlit,
        coherenceGroup: 'g',
        value: Complex(1, 0),
      );
      final coherent = computeSampleIntensity(FieldValueSample([a, b]));
      expect(coherent, 4);

      final c = FieldComponent(
        source: FieldComponentSource.bottomSlit,
        coherenceGroup: 'other',
        value: Complex(1, 0),
      );
      final decoherent = computeSampleIntensity(FieldValueSample([a, c]));
      expect(decoherent, 2);
    });
  });

  group('inverseStandardNormalCdf', () {
    test('median and round-trip-ish midpoints', () {
      expect(inverseStandardNormalCdf(0.5), closeTo(0, 1e-6));
      expect(inverseStandardNormalCdf(0.001), lessThan(-2));
      expect(inverseStandardNormalCdf(0.99), greaterThan(2));
      // Clamped finite at edges
      expect(inverseStandardNormalCdf(0).isFinite, isTrue);
      expect(inverseStandardNormalCdf(1).isFinite, isTrue);
    });
  });

  group('Gaussian packet state', () {
    test('center and sigma evolve', () {
      const source = GaussianPacketSource(
        isActive: true,
        waveNumber: 10,
        speed: 2,
        initialCenterX: -0.3,
        centerY: 0,
        sigmaX0: 0.15,
        sigmaY0: 0.15,
        longitudinalSpreadTime: 3.75,
        transverseSpreadTime: 2.25,
      );
      final t0 = getGaussianPacketState(source, 0);
      final t1 = getGaussianPacketState(source, 1.5);
      expect(t0.centerX, closeTo(-0.3, 1e-12));
      expect(t1.centerX, closeTo(-0.3 + 3.0, 1e-12));
      expect(t1.sigmaX, greaterThan(t0.sigmaX));
    });
  });

  group('WaveKernel / Fresnel', () {
    test('noBarrier plane wave reaches downstream', () {
      final params = WaveParameters(
        source: const PlaneWaveSource(waveNumber: 20, speed: 1, startTime: 0),
        barrier: const NoBarrier(),
      );
      final sample = evaluateSample(params, 0.5, 0, 1.0);
      expect(sample, isA<FieldValueSample>());
      expect(computeSampleIntensity(sample), greaterThan(0));
    });

    test('double slit both open produces two components', () {
      final params = WaveParameters(
        source: const PlaneWaveSource(waveNumber: 40, speed: 1, startTime: 0),
        barrier: DoubleSlitBarrier(
          barrierX: 0.4,
          slits: const [
            WaveSlit(
              source: FieldComponentSource.topSlit,
              centerY: 0.1,
              width: 0.05,
              isOpen: true,
              coherenceGroup: 'both',
            ),
            WaveSlit(
              source: FieldComponentSource.bottomSlit,
              centerY: -0.1,
              width: 0.05,
              isOpen: true,
              coherenceGroup: 'both',
            ),
          ],
        ),
      );
      final sample = evaluateSample(params, 0.9, 0, 2.0);
      expect(sample, isA<FieldValueSample>());
      final field = sample as FieldValueSample;
      expect(field.components.length, 2);
      expect(computeSampleIntensity(sample), greaterThanOrEqualTo(0));
    });

    test('single slit open → one component', () {
      final params = WaveParameters(
        source: const PlaneWaveSource(waveNumber: 40, speed: 1, startTime: 0),
        barrier: DoubleSlitBarrier(
          barrierX: 0.4,
          slits: const [
            WaveSlit(
              source: FieldComponentSource.topSlit,
              centerY: 0.1,
              width: 0.05,
              isOpen: true,
              coherenceGroup: 'topSlit',
            ),
            WaveSlit(
              source: FieldComponentSource.bottomSlit,
              centerY: -0.1,
              width: 0.05,
              isOpen: false,
              coherenceGroup: 'bottomSlit',
            ),
          ],
        ),
      );
      final sample = evaluateSample(params, 0.9, 0.1, 2.0);
      expect(sample, isA<FieldValueSample>());
      expect((sample as FieldValueSample).components.length, 1);
    });

    test('which-path decoherence attenuates unselected slit', () {
      final barrier = DoubleSlitBarrier(
        barrierX: 0.4,
        slits: const [
          WaveSlit(
            source: FieldComponentSource.topSlit,
            centerY: 0.1,
            width: 0.05,
            isOpen: true,
            coherenceGroup: 'topSlit',
          ),
          WaveSlit(
            source: FieldComponentSource.bottomSlit,
            centerY: -0.1,
            width: 0.05,
            isOpen: true,
            coherenceGroup: 'bottomSlit',
          ),
        ],
      );
      final params = WaveParameters(
        source: const GaussianPacketSource(
          isActive: true,
          waveNumber: 30,
          speed: 1,
          initialCenterX: -0.2,
          centerY: 0,
          sigmaX0: 0.15,
          sigmaY0: 0.15,
          longitudinalSpreadTime: 3,
          transverseSpreadTime: 2,
        ),
        barrier: barrier,
        decoherenceEvents: const [
          DecoherenceEvent(time: 0.5, selectedSlit: FieldComponentSource.topSlit),
        ],
      );
      final sample = evaluateSample(params, 0.9, 0, 1.5);
      if (sample is FieldValueSample && sample.components.length == 2) {
        final top = sample.components.firstWhere((c) => c.source == FieldComponentSource.topSlit);
        final bottom = sample.components.firstWhere((c) => c.source == FieldComponentSource.bottomSlit);
        expect(top.value.magnitudeSquared, greaterThanOrEqualTo(bottom.value.magnitudeSquared));
      }
    });
  });

  group('SimulationClock / TimeSpeed', () {
    test('Experiment factors', () {
      final clock = SimulationClock(speedFactors: TimeSpeedFactors.experiment);
      clock.setSpeed(TimeSpeed.slow);
      expect(clock.advance(1), closeTo(0.25, 1e-12));
      clock.setSpeed(TimeSpeed.fast);
      expect(clock.advance(1), closeTo(4, 1e-12));
    });

    test('HI / SP factors differ', () {
      expect(TimeSpeedFactors.highIntensity.factor(TimeSpeed.normal), 0.35);
      expect(TimeSpeedFactors.singleParticles.factor(TimeSpeed.fast), 16);
      expect(TimeSpeedFactors.highIntensity.factor(TimeSpeed.slow), 0.15);
    });

    test('stepOnce ignores TimeSpeed', () {
      final clock = SimulationClock(speedFactors: TimeSpeedFactors.singleParticles);
      clock.setSpeed(TimeSpeed.fast);
      final dtSlow = clock.stepOnce();
      clock.setSpeed(TimeSpeed.slow);
      final dtFastSetting = clock.stepOnce();
      expect(dtSlow, QwiConstants.nominalDt);
      expect(dtFastSetting, QwiConstants.nominalDt);
    });

    test('pause stops advancement', () {
      final clock = SimulationClock(speedFactors: TimeSpeedFactors.experiment);
      clock.pause();
      expect(clock.advance(1), 0);
      expect(clock.time, 0);
    });
  });

  group('Hit sampling + RNG determinism', () {
    test('seeded experiment hits reproducible', () {
      List<DetectorHit> run(int seed) {
        final rng = SeededQwiRandom(seed);
        final sampler = ExperimentHitSampler(random: rng);
        return List.generate(
          20,
          (_) => sampler.sampleHit(
            fullScreenHalfWidthM: 0.1,
            intensityOptions: (x) => FraunhoferOptions(
              positionOnScreenM: x,
              effectiveWavelengthM: 650e-9,
              screenDistanceM: 0.6,
              slitWidthM: 0.02e-3,
              slitSeparationM: 0.25e-3,
              slitSetting: SlitConfiguration.bothOpen,
            ),
          ),
        );
      }

      final a = run(12345);
      final b = run(12345);
      final c = run(12346);
      expect(a.map((h) => h.x).toList(), b.map((h) => h.x).toList());
      expect(a.map((h) => h.y).toList(), b.map((h) => h.y).toList());
      expect(a.first.domain, DetectorHitDomain.experiment);
      expect(a.any((h) => h.y < 0), isTrue); // [-1,1]
      expect(a.map((h) => h.x).toList() == c.map((h) => h.x).toList(), isFalse);
    });

    test('wave region hit y in [0,1]', () {
      final sampler = WaveRegionHitSampler(random: SeededQwiRandom(7));
      final hit = sampler.sampleHit(List<double>.filled(50, 1));
      expect(hit.domain, DetectorHitDomain.waveRegion);
      expect(hit.y, inInclusiveRange(0, 1));
      expect(hit.x, inInclusiveRange(-1, 1));
    });
  });

  group('Histogram 100 bins', () {
    test('bin count', () {
      final hits = [
        for (var i = 0; i < 50; i++) DetectorHit(x: i / 25 - 1, y: 0, domain: DetectorHitDomain.experiment),
      ];
      final hist = HitsHistogramData.fromHits(hits);
      expect(hist.binCount, 100);
      expect(hist.bins.reduce((a, b) => a + b), 50);
    });
  });

  group('Snapshots', () {
    test('max 4 then no-op', () {
      final store = SnapshotStore();
      QwiSnapshot snap(int i) => QwiSnapshot(
            snapshotNumber: i,
            hits: const [],
            detectionMode: DetectorMode.hits,
            sourceType: SourceType.photons,
            wavelengthNm: 650,
            slitSeparationMm: 0.25,
            screenDistanceM: 0.6,
            screenHalfWidthM: 0.1,
            effectiveWavelengthM: 650e-9,
            slitSetting: SlitConfiguration.bothOpen,
            envelopeCategory: 'brightestAtCenter',
            isEmitting: false,
            brightness: 50,
            intensity: 0.5,
            slitWidthMm: 0.02,
            intensityDistribution: const [],
          );
      expect(store.tryAdd(snap(1)), isTrue);
      expect(store.tryAdd(snap(2)), isTrue);
      expect(store.tryAdd(snap(3)), isTrue);
      expect(store.tryAdd(snap(4)), isTrue);
      expect(store.tryAdd(snap(5)), isFalse);
      expect(store.length, 4);
      store.deleteAt(1);
      expect(store.length, 3);
      expect(store.snapshots[0].snapshotNumber, 1);
      expect(store.snapshots[1].snapshotNumber, 2);
    });
  });
}

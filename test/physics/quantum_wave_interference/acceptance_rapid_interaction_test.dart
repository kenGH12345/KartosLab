import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';

void main() {
  group('Rapid interaction / edge acceptance', () {
    test('Pause Resume Speed Step Reset burst on SP', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(401));
      model.scene.setAutoRepeat(true);
      model.clock.setSpeed(TimeSpeed.normal);
      for (var i = 0; i < 50; i++) {
        model.step(1 / 60);
      }
      model.clock.isPlaying = false;
      model.clock.isPlaying = true;
      model.clock.isPlaying = false;
      model.clock.isPlaying = true;
      model.clock.setSpeed(TimeSpeed.fast);
      model.clock.isPlaying = false;
      model.stepOnce();
      model.stepOnce();
      model.reset();
      expect(model.scene.isPacketActive, isFalse);
      expect(model.scene.hits.length, 0);
      expect(model.clock.speed, TimeSpeed.normal);
      expect(model.clock.isPlaying, isTrue);
    });

    test('HI rapid pause/resume/speed does not desync emitting flag', () {
      final model = HighIntensityModel(random: SeededQwiRandom(402));
      model.scene.setEmitting(true);
      for (var k = 0; k < 30; k++) {
        model.clock.isPlaying = k.isEven;
        model.clock.setSpeed(k % 3 == 0
            ? TimeSpeed.slow
            : k % 3 == 1
                ? TimeSpeed.normal
                : TimeSpeed.fast);
        model.step(1 / 60);
        if (k % 5 == 0) {
          model.stepOnce();
        }
      }
      expect(model.scene.isEmitting, isTrue);
      model.reset();
      expect(model.scene.isEmitting, isFalse);
    });

    test('edge parameter clamps do not produce NaN intensities', () {
      final model = ExperimentModel(random: SeededQwiRandom(403));
      model.scene.wavelengthNm = QwiConstants.photonWavelengthPropertyMinNm;
      model.scene.onPhysicsParameterChanged();
      var i = model.scene.intensityAtPhysicalX(0);
      expect(i.isFinite, isTrue);
      expect(i, greaterThanOrEqualTo(0));

      model.scene.wavelengthNm = QwiConstants.photonWavelengthPropertyMaxNm;
      model.scene.onPhysicsParameterChanged();
      i = model.scene.intensityAtPhysicalX(0);
      expect(i.isFinite, isTrue);

      model.scene.slitSeparationMm = model.scene.defaults.slitSeparationMinMm;
      model.scene.onPhysicsParameterChanged();
      i = model.scene.intensityAtPhysicalX(0.001);
      expect(i.isFinite, isTrue);

      model.scene.slitSeparationMm = model.scene.defaults.slitSeparationMaxMm;
      model.scene.screenDistanceM = 0.2;
      model.scene.onPhysicsParameterChanged();
      i = model.scene.intensityAtPhysicalX(0.01);
      expect(i.isFinite, isTrue);
      expect(i.isNaN, isFalse);
    });

    test('SP zoom extremes leave physics unchanged', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(404));
      model.scene.emitPacket();
      final l = model.scene.effectiveWavelengthM;
      final sep = model.scene.slitSeparationMm;
      final t = model.scene.solver.time;
      model.graphZoom.setLevel(1);
      model.graphZoom.setLevel(6);
      model.graphZoom.setLevel(1);
      expect(model.scene.effectiveWavelengthM, l);
      expect(model.scene.slitSeparationMm, sep);
      expect(model.scene.solver.time, t);
    });

    test('snapshot delete then add maintains max 4 and renumber', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(405));
      for (var i = 0; i < 4; i++) {
        expect(model.scene.takeSnapshot(), isTrue);
      }
      expect(model.scene.takeSnapshot(), isFalse);
      model.scene.snapshots.deleteAt(1);
      expect(model.scene.snapshots.length, 3);
      expect(model.scene.takeSnapshot(), isTrue);
      expect(model.scene.snapshots.length, 4);
      expect(model.scene.takeSnapshot(), isFalse);
    });

    test('Reset during active packet ×5 leaves stable idle', () {
      final model = SingleParticlesModel(random: SeededQwiRandom(406));
      for (var r = 0; r < 5; r++) {
        model.scene.setAutoRepeat(true);
        model.clock.setSpeed(TimeSpeed.fast);
        for (var i = 0; i < 80; i++) {
          model.step(1 / 60);
        }
        model.reset();
        expect(model.scene.isPacketActive, isFalse);
        expect(model.scene.autoRepeat, isFalse);
        expect(model.scene.hits.length, 0);
        expect(model.scene.solver.measurementProjections, isEmpty);
        expect(model.scene.solver.decoherenceEvents, isEmpty);
      }
    });
  });
}

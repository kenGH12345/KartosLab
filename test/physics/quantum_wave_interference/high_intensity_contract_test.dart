import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';
import 'package:kratos/physics/quantum_wave_interference/render_data/high_intensity/wave_field_render_data.dart';
import 'package:kratos/physics/quantum_wave_interference/view/common/qwi_layout.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_controller.dart';

void main() {
  group('HI numerical ↔ view contracts', () {
    test('layout is 768×504; wave sample grid is 120² not display size', () {
      expect(QwiLayout.designWidth, 768);
      expect(QwiLayout.designHeight, 504);
      expect(QwiLayout.waveRegionWidth, 360);
      expect(QwiLayout.waveRegionHeight, 330);
      final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(1)));
      expect(c.scene.solver.gridWidth, 120);
      expect(c.scene.solver.gridHeight, 120);
      expect(c.scene.solver.gridWidth == QwiLayout.waveRegionWidth, isFalse);
    });

    test('WaveKernel sample → WaveFieldRenderData (not Fraunhofer)', () {
      final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(2)));
      c.setEmitting(true);
      for (var i = 0; i < 40; i++) {
        c.stepOnce();
      }
      c.resampleWave();
      final data = c.waveField;
      expect(data.gridWidth, 120);
      expect(data.rgba.length, 120 * 120 * 4);
      expect(data.isEmitting, isTrue);
      // Some non-black pixels when emitting
      var lit = 0;
      for (var i = 0; i < data.rgba.length; i += 4) {
        if (data.rgba[i] + data.rgba[i + 1] + data.rgba[i + 2] > 0) {
          lit++;
        }
      }
      expect(lit, greaterThan(100));
    });

    test('PDF → detector; brightness does not change PDF', () {
      final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(3)));
      c.setEmitting(true);
      for (var i = 0; i < 90; i++) {
        c.stepOnce();
      }
      final pdf0 = List<double>.from(c.scene.detectorPdf);
      c.setScreenBrightness(100);
      final pdf1 = c.scene.detectorPdf;
      expect(pdf0.length, pdf1.length);
      for (var i = 0; i < pdf0.length; i++) {
        expect(pdf1[i], closeTo(pdf0[i], 1e-12));
      }
      final det = HiDetectorRenderData.fromScene(c.scene);
      expect(det.pdf, isNotEmpty);
      expect(det.formationFactor, greaterThan(0));
    });

    test('hit y ∈ [0,1] waveRegion domain', () {
      final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(4)));
      c.setDetectionMode(DetectorMode.hits);
      c.setEmitting(true);
      for (var i = 0; i < 180; i++) {
        c.stepOnce();
      }
      expect(c.scene.hits.length, greaterThan(0));
      for (final h in c.scene.hits.hits) {
        expect(h.domain, DetectorHitDomain.waveRegion);
        expect(h.y, inInclusiveRange(0.0, 1.0));
      }
    });

    test('seeded hits deterministic', () {
      List<double> run(int seed) {
        final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(seed)));
        c.setDetectionMode(DetectorMode.hits);
        c.setEmitting(true);
        for (var i = 0; i < 180; i++) {
          c.stepOnce();
        }
        return c.scene.hits.hits.map((h) => h.x).toList();
      }

      expect(run(99), run(99));
      expect(run(99) == run(100), isFalse);
    });

    test('wave modes produce different rasters', () {
      final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(5)));
      c.setEmitting(true);
      for (var i = 0; i < 50; i++) {
        c.stepOnce();
      }
      c.setWaveDisplayMode(WaveDisplayMode.electricField);
      c.resampleWave();
      final a = List<int>.from(c.waveField.rgba);
      c.setWaveDisplayMode(WaveDisplayMode.amplitude);
      c.resampleWave();
      final b = c.waveField.rgba;
      var diff = 0;
      for (var i = 0; i < a.length; i++) {
        diff += (a[i] - b[i]).abs();
      }
      expect(diff, greaterThan(0));
    });

    test('zoom does not change PDF', () {
      final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(6)));
      c.setEmitting(true);
      for (var i = 0; i < 60; i++) {
        c.stepOnce();
      }
      final pdf0 = List<double>.from(c.scene.detectorPdf);
      c.setGraphZoom(6);
      expect(c.scene.detectorPdf, pdf0);
    });

    test('noBarrier vs double slit PDF differs', () {
      final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(7)));
      c.setEmitting(true);
      // Traversal time ≈ 2s; stepOnce = 1/60 → need ≥120 steps for wavefront.
      for (var i = 0; i < 150; i++) {
        c.stepOnce();
      }
      final both = List<double>.from(c.scene.detectorPdf);
      expect(both.any((v) => v > 0), isTrue);
      c.setSlitConfiguration(SlitConfiguration.noBarrier);
      c.setEmitting(true);
      for (var i = 0; i < 150; i++) {
        c.stepOnce();
      }
      final none = c.scene.detectorPdf;
      var diff = 0.0;
      for (var i = 0; i < both.length; i++) {
        diff += (both[i] - none[i]).abs();
      }
      expect(diff, greaterThan(0.01));
    });
  });
}

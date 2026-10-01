import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';
import 'package:kratos/physics/quantum_wave_interference/render_data/experiment/detector_render_data.dart';
import 'package:kratos/physics/quantum_wave_interference/render_data/experiment/fraunhofer_render_data.dart';
import 'package:kratos/physics/quantum_wave_interference/view/common/qwi_coordinate_transform.dart';
import 'package:kratos/physics/quantum_wave_interference/view/common/qwi_layout.dart';

void main() {
  group('solver → render data contract', () {
    test('center / left / right samples match FraunhoferSolver', () {
      final model = ExperimentModel(random: SeededQwiRandom(1));
      model.scene.setEmitting(true);
      final data = FraunhoferRenderData.fromScene(
        model.scene,
        visibleHalfWidthM: model.visibleDetectorHalfWidthM,
        samples: 64,
      );
      expect(data.intensities.length, 64);
      final mid = data.intensities[32];
      final left = data.intensities.first;
      final right = data.intensities.last;
      expect(mid, greaterThan(left));
      expect(mid, greaterThan(right));
      expect(data.intensityAtNormalized(0), closeTo(model.scene.intensityAtPhysicalX(0), 1e-12));
    });

    test('single slit vs double slit patterns differ', () {
      final model = ExperimentModel(random: SeededQwiRandom(2));
      model.scene.setEmitting(true);
      final both = FraunhoferRenderData.fromScene(
        model.scene,
        visibleHalfWidthM: model.visibleDetectorHalfWidthM,
      );
      model.scene.slitConfiguration = SlitConfiguration.leftCovered;
      final single = FraunhoferRenderData.fromScene(
        model.scene,
        visibleHalfWidthM: model.visibleDetectorHalfWidthM,
      );
      var diff = 0.0;
      for (var i = 0; i < both.intensities.length; i++) {
        diff += (both.intensities[i] - single.intensities[i]).abs();
      }
      expect(diff, greaterThan(0.1));
    });

    test('DetectorRenderData mode switches without changing probability', () {
      final model = ExperimentModel(random: SeededQwiRandom(3));
      model.scene.setEmitting(true);
      final i0 = model.scene.intensityAtPhysicalX(0);
      final d0 = DetectorRenderData.fromModel(model);
      model.scene.detectionMode = DetectorMode.hits;
      final d1 = DetectorRenderData.fromModel(model);
      expect(d0.mode, DetectorMode.intensity);
      expect(d1.mode, DetectorMode.hits);
      expect(model.scene.intensityAtPhysicalX(0), i0);
    });
  });

  group('detector coordinate contract', () {
    test('top / center / bottom mapping not inverted', () {
      final t = QwiCoordinateTransform.experimentDefault();
      final top = t.normalizedYToDesignY(-1);
      final center = t.normalizedYToDesignY(0);
      final bottom = t.normalizedYToDesignY(1);
      expect(top, lessThan(center));
      expect(center, lessThan(bottom));
      expect(top, closeTo(QwiLayout.frontFacingDetectorRect.top, 0.5));
      expect(bottom, closeTo(QwiLayout.frontFacingDetectorRect.bottom, 0.5));
    });

    test('normalized x left/center/right', () {
      final t = QwiCoordinateTransform.experimentDefault();
      final left = t.normalizedXToDesignX(-1);
      final center = t.normalizedXToDesignX(0);
      final right = t.normalizedXToDesignX(1);
      expect(left, lessThan(center));
      expect(center, lessThan(right));
      // Round-trip
      expect(t.designXToNormalizedX(center), closeTo(0, 1e-9));
      expect(t.designYToNormalizedY(t.normalizedYToDesignY(0.5)), closeTo(0.5, 1e-9));
    });

    test('layout bounds are 768×504', () {
      expect(QwiLayout.designWidth, 768);
      expect(QwiLayout.designHeight, 504);
      expect(QwiLayout.detectorScreenWidth, 376);
      expect(QwiLayout.frontFacingRowHeight, 155);
      expect(QwiLayout.frontFacingRowTop, 160);
      expect(QwiLayout.screenViewXMargin, 15);
      expect(QwiLayout.screenViewYMargin, 15);
    });
  });

  group('graph direction contract', () {
    test('histogram bins follow detector x left→right', () {
      final hits = [
        const DetectorHit(x: -1, y: 0, domain: DetectorHitDomain.experiment),
        const DetectorHit(x: 0.999, y: 0, domain: DetectorHitDomain.experiment),
      ];
      final hist = HitsHistogramData.fromHits(hits);
      expect(hist.bins.first, greaterThan(0));
      expect(hist.bins.last, greaterThan(0));
      expect(hist.bins[50], 0);
    });
  });

  group('ruler scale contract', () {
    test('ruler half-width tracks DetectorScreenScale', () {
      final model = ExperimentModel(random: SeededQwiRandom(1));
      expect(DetectorScreenScale.visibleFullWidthMm(0), 40);
      model.setDetectorScreenScaleIndex(3);
      expect(DetectorScreenScale.visibleFullWidthMm(3), 10);
      expect(model.ruler.scaleHalfWidthMm, 5);
    });
  });
}

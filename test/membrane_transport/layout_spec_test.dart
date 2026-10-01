import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/membrane_transport/layout/membrane_transport_layout.dart';
import 'package:kratos/membrane_transport/membrane_transport_feature_set.dart';

void main() {
  group('LayoutSpec formulas (LAYOUT_SPEC.md)', () {
    test('design canvas 1024×618 (joist DEFAULT_LAYOUT_BOUNDS)', () {
      expect(MembraneTransportLayoutPrimitives.designWidth, 1024);
      expect(MembraneTransportLayoutPrimitives.designHeight, 618);
      expect(MembraneTransportLayoutPrimitives.obsWidth, 534);
      expect(MembraneTransportLayoutPrimitives.obsHeight, 400);
      expect(MembraneTransportLayoutPrimitives.marginX, 8);
      expect(MembraneTransportLayoutPrimitives.marginY, 8);
    });

    test('observation centered horizontally, top = margin', () {
      final obs = MembraneTransportLayoutSpec.observation;
      expect(obs.left, closeTo(245, 0.01));
      expect(obs.top, 8);
      expect(obs.width, 534);
      expect(obs.height, 400);
      expect(obs.center.dx, 512);
      expect(obs.center.dy, 208);
      expect(obs.right, closeTo(779, 0.01));
      expect(obs.bottom, 408);
    });

    test('time / eraser / checks relative to observation', () {
      final s = MembraneTransportLayoutSpec.resolve(
        featureSet: MembraneTransportFeatureSet.simpleDiffusion,
      );
      expect(s.timeControlTop, 416);
      expect(s.timeControlCenterX, 512);
      expect(s.eraserLeft, s.observation.left);
      expect(s.eraserCenterY, s.timeControlCenterY);
      expect(s.checksRight, s.observation.right);
      expect(s.checksCenterY, s.timeControlCenterY);
    });

    test('solutes / gap / cell formulas', () {
      final s = MembraneTransportLayoutSpec.resolve(
        featureSet: MembraneTransportFeatureSet.facilitatedDiffusion,
      );
      expect(s.solutesPanelLeft, 8);
      expect(s.solutesPanelCenterY, 208);
      expect(s.graphLeft, 8);
      expect(s.graphTop, 476); // timeTop 416 + h 48 + gap 12
      expect(s.graphBottom, 610);
      // solutesRight=88; gap mid = 88 + (245-88)/2 = 166.5
      expect(s.soluteControlCenterX, closeTo(166.5, 0.01));
      expect(s.cellLeft, closeTo(166.5 - 44 + 3, 0.01));
      expect(s.cellTop, 208);
      expect(s.showProteinPanel, isTrue);
      expect(s.proteinPanelTop, 8);
      expect(s.proteinPanelRight, 1016);
    });

    test('simpleDiffusion hides protein panel; others show', () {
      final sd = MembraneTransportLayoutSpec.resolve(
        featureSet: MembraneTransportFeatureSet.simpleDiffusion,
      );
      final at = MembraneTransportLayoutSpec.resolve(
        featureSet: MembraneTransportFeatureSet.activeTransport,
      );
      expect(sd.showProteinPanel, isFalse);
      expect(at.showProteinPanel, isTrue);
      expect(sd.observation, at.observation);
      expect(sd.timeControlTop, at.timeControlTop);
    });

    test('uniform fitScale scales up and preserves aspect', () {
      final s1 = MembraneTransportLayoutPrimitives.fitScale(1024, 618);
      final s2 = MembraneTransportLayoutPrimitives.fitScale(2048, 1236);
      final s3 = MembraneTransportLayoutPrimitives.fitScale(512, 309);
      expect(s1, 1.0);
      expect(s2, 2.0);
      expect(s3, closeTo(0.5, 0.001));
      final phys = MembraneTransportLayoutPrimitives.physicalSize(s3);
      expect(phys.width / phys.height, closeTo(1024 / 618, 0.001));
    });

    test('MVT: model origin → observation center', () {
      final v = MembraneTransportLayoutSpec.modelToObservationView(0, 0);
      expect(v.dx, 267);
      expect(v.dy, 200);
      final m = MembraneTransportLayoutSpec.observationViewToModel(v);
      expect(m.dx, closeTo(0, 1e-9));
      expect(m.dy, closeTo(0, 1e-9));
    });
  });
}

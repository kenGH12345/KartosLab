import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/quantum_measurement/bloch_sphere/projection/bloch_projection.dart';
import 'package:kratos/quantum_measurement/layout/qm_bloch_layout_spec.dart';
import 'package:kratos/quantum_measurement/layout/qm_coins_layout_spec.dart';
import 'package:kratos/quantum_measurement/layout/qm_global_layout_spec.dart';
import 'package:kratos/quantum_measurement/layout/qm_photons_layout_spec.dart';
import 'package:kratos/quantum_measurement/layout/qm_spin_layout_spec.dart';

void main() {
  group('Global layout', () {
    const global = QmGlobalLayoutSpec();

    test('design canvas 1024×618', () {
      expect(global.designWidth, 1024);
      expect(global.designHeight, 618);
    });

    test('uniform scale is min of axes', () {
      expect(global.layoutScale(1024, 618), 1.0);
      expect(global.layoutScale(2048, 1236), 2.0);
      expect(global.layoutScale(512, 618), 0.5);
      expect(global.layoutScale(1024, 309), 0.5);
    });

    test('reset all anchors to bottom-right inset', () {
      final a = global.resetAllAnchor(1024, 618);
      expect(a.right, 1014);
      expect(a.bottom, 608);
    });

    test('layout scale deterministic', () {
      expect(global.layoutScale(1280, 800), global.layoutScale(1280, 800));
      expect(global.layoutScale(800, 600), closeTo(800 / 1024, 1e-12));
    });
  });

  group('Coins layout', () {
    const coins = QmCoinsLayoutSpec();

    test('divider X from design width ratios', () {
      expect(coins.dividerXDuringPreparation, 389); // floor(1024*0.38)
      expect(coins.dividerXDuringMeasurement, 205); // ceil(1024*0.2)
    });

    test('prep/measure centerX from divider', () {
      expect(coins.preparationCenterX(389), closeTo(194.5, 1e-9));
      expect(coins.measurementCenterX(389), closeTo(389 + (1024 - 389) / 2, 1e-9));
      expect(coins.preparationCenterX(205), closeTo(102.5, 1e-9));
    });

    test('10000 pixel grid side = 100', () {
      expect(coins.pixelGridSideLength, 100);
    });

    test('test box fixed sizes', () {
      expect(QmCoinsLayoutSpec.singleCoinTestBoxWidth, 165);
      expect(QmCoinsLayoutSpec.multiCoinTestBoxSize, 200);
    });
  });

  group('Photons layout', () {
    const photons = QmPhotonsLayoutSpec();

    test('experiment area center and MVT scale', () {
      expect(QmPhotonsLayoutSpec.experimentAreaCenterX, 420);
      expect(QmPhotonsLayoutSpec.experimentAreaCenterY, 225);
      expect(QmPhotonsLayoutSpec.modelViewScale, 640);
    });

    test('modelToView inverts Y and scales', () {
      final p = photons.modelToView(0.15, 0.1);
      expect(p.x, closeTo(96, 1e-9));
      expect(p.y, closeTo(-64, 1e-9));
    });

    test('laser is left of PBS in model', () {
      expect(QmPhotonsLayoutSpec.laserToBeamSplitterDistance, 0.15);
      final laser = photons.modelToView(-0.15, 0);
      expect(laser.x, lessThan(0));
    });
  });

  group('Spin layout', () {
    const spin = QmSpinLayoutSpec();

    test('divider and measurement left', () {
      expect(QmSpinLayoutSpec.dividingLineX, 300);
      expect(spin.measurementAreaLeft, 300);
    });

    test('modelToView scale 180', () {
      final p = spin.modelToView(0.8, 0);
      expect(p.x, closeTo(144, 1e-9));
      expect(p.y, 0);
    });
  });

  group('Bloch layout', () {
    const bloch = QmBlochLayoutSpec();

    test('divider and measurement left', () {
      expect(QmBlochLayoutSpec.dividingLineX, 350);
      expect(bloch.measurementAreaLeft, 390);
    });

    test('preparation centered in left column', () {
      expect(bloch.preparationCenterX(0, 350), 175);
      expect(bloch.preparationTop(0), 10);
    });

    test('sphere radius and +Z tip', () {
      expect(QmBlochLayoutSpec.sphereRadius, 100);
      final tip = BlochProjection().stateVectorTip(polar: 0, azimuthal: 0);
      expect(tip.dx, closeTo(0, 1e-12));
      expect(tip.dy, closeTo(-100, 1e-12));
    });
  });
}

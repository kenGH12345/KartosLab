/// PHASE 7 — shared ScreenView scale/offset for all four QM screens.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/quantum_measurement/bloch_sphere/composer/bloch_composer.dart';
import 'package:kratos/quantum_measurement/coins/composer/coins_composer.dart';
import 'package:kratos/quantum_measurement/common/qm_typography.dart';
import 'package:kratos/quantum_measurement/common/qm_visual.dart';
import 'package:kratos/quantum_measurement/layout/qm_global_layout_spec.dart';
import 'package:kratos/quantum_measurement/photons/composer/photons_composer.dart';
import 'package:kratos/quantum_measurement/spin/composer/spin_composer.dart';
import 'package:kratos/quantum_measurement/spin/configuration/spin_experiment_view_configuration.dart';
import 'package:kratos/quantum_measurement/spin/model/spin_model.dart';
import 'package:kratos/quantum_measurement/common/qm_random.dart';

void main() {
  const global = QmGlobalLayoutSpec();
  const coins = CoinsComposer();
  const photons = PhotonsComposer();
  const spin = SpinComposer();
  const bloch = BlochComposer();

  const viewports = <Size>[
    Size(1024, 618),
    Size(1280, 800),
    Size(800, 600),
    Size(1366, 768),
  ];

  test('four screens share identical global transform per viewport', () {
    for (final vp in viewports) {
      final g = global.designFrame(vp);
      final c = coins.designFrame(vp);
      final p = photons.designFrame(vp);
      final s = spin.designFrame(vp);
      final b = bloch.designFrame(vp);
      expect(c.scale, g.scale, reason: '$vp coins scale');
      expect(p.scale, g.scale, reason: '$vp photons scale');
      expect(s.scale, g.scale, reason: '$vp spin scale');
      expect(b.scale, g.scale, reason: '$vp bloch scale');
      expect(c.origin, g.origin);
      expect(p.origin, g.origin);
      expect(s.origin, g.origin);
      expect(b.origin, g.origin);
      expect(g.contentBounds.width, closeTo(qmDesignWidth * g.scale, 1e-9));
      expect(g.contentBounds.height, closeTo(qmDesignHeight * g.scale, 1e-9));
    }
  });

  test('canonical 1024×618 scale=1 origin=0', () {
    final f = global.designFrame(const Size(1024, 618));
    expect(f.scale, 1.0);
    expect(f.origin, Offset.zero);
  });

  test('1280×800 uses min scale and centers leftover axis', () {
    final f = global.designFrame(const Size(1280, 800));
    final expected = 1280 / 1024 < 800 / 618 ? 1280 / 1024 : 800 / 618;
    expect(f.scale, closeTo(expected, 1e-12));
    expect(f.origin.dx, closeTo((1280 - 1024 * f.scale) / 2, 1e-9));
    expect(f.origin.dy, closeTo((800 - 618 * f.scale) / 2, 1e-9));
  });

  test('screen-specific dividers remain independent', () {
    expect(coins.compose(viewport: const Size(1024, 618), preparing: true).dividerX, 389);
    expect(
      spin
          .compose(
            viewport: const Size(1024, 618),
            config: spinConfigFor(),
          )
          .dividerX,
      300,
    );
    expect(bloch.compose(viewport: const Size(1024, 618)).dividerX, 350);
  });

  test('typography constants match QuantumMeasurementConstants', () {
    expect(QmTypography.header.fontSize, 20);
    expect(QmTypography.title.fontSize, 16);
    expect(QmTypography.control.fontSize, 14);
    expect(QmTypography.smallLabel.fontSize, 12);
    expect(QmTypography.tinyLabel.fontSize, 8);
    expect(QmTypography.sceneSelector.fontSize, 26);
    expect(QmTypography.boldHeader.fontWeight, FontWeight.bold);
    expect(QmTypography.fontFamily, 'Arial');
  });

  test('shared divider dash pattern is source [6,5] width 2 height 525', () {
    expect(QmExperimentDividingLine.dash, 6);
    expect(QmExperimentDividingLine.gap, 5);
    expect(QmExperimentDividingLine.strokeWidth, 2);
    expect(qmDividerHeight, 525);
  });

  test('visual debug overlay is off on production path', () {
    expect(qmVisualDebugEnabled, isFalse);
  });

  test('global transform determinism ×3', () {
    const vp = Size(1280, 800);
    final a = global.designFrame(vp);
    final b = global.designFrame(vp);
    final c = global.designFrame(vp);
    expect(a.scale, b.scale);
    expect(b.scale, c.scale);
    expect(a.origin, c.origin);
  });
}

SpinExperimentViewConfiguration spinConfigFor() =>
    SpinExperimentViewConfiguration.fromModel(SpinModel(random: SeededQmRandom(1)));

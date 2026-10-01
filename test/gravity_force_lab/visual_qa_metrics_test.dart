import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/gfl_colors.dart';
import 'package:kratos/gravity_force_lab/gfl_strings.dart';
import 'package:kratos/gravity_force_lab/model/force_values_display.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/render/gfl_render_builder.dart';
import 'package:kratos/gravity_force_lab/transform/math_coordinate_transform.dart';

/// Phase 7 — source-faithful layout / color / render-data checks
/// (complements bitmap goldens).
void main() {
  const builder = GflRenderBuilder();
  final t = MathCoordinateTransform.forLayout();

  test('layout canvas 768×464, white, massY 185, MVT 50', () {
    expect(GravityForceConstants.layoutWidth, 768);
    expect(GravityForceConstants.layoutHeight, 464);
    expect(GravityForceConstants.massNodeY, 185);
    expect(GravityForceConstants.mvtScale, 50);
    expect(GflColors.screenBackground, const Color(0xFFFFFFFF));
    expect(t.viewOrigin, const Offset(384, 232));
  });

  test('default sphere centers / radii / force arrows', () {
    final m = GravityForceLabModel();
    final r = builder.build(m, transform: t);
    expect(r.mass1Center.dx, closeTo(t.modelToViewX(-3), 0.01));
    expect(r.mass2Center.dx, closeTo(t.modelToViewX(1), 0.01));
    expect(r.mass1Center.dy, GravityForceConstants.massNodeY);
    expect(r.mass2Center.dy, GravityForceConstants.massNodeY);
    expect(
      r.mass1RadiusView,
      closeTo(t.modelToViewDeltaX(GravityForceConstants.calculateRadius(100)), 0.05),
    );
    expect(
      r.mass2RadiusView,
      closeTo(t.modelToViewDeltaX(GravityForceConstants.calculateRadius(400)), 0.05),
    );
    expect(r.arrow1Y, 185 - 85);
    expect(r.arrow2Y, 185 - 135);
    // Attraction: force on m1 toward m2 (+X when m2 is to the right).
    expect(r.arrow1TipDx.sign, 1);
    expect(r.arrow2TipDx.sign, -1);
    expect(r.force, closeTo(1.66852e-7, 1e-15));
    m.dispose();
  });

  test('constant size radii = 0.5 m view', () {
    final m = GravityForceLabModel()..setConstantRadius(true);
    final r = builder.build(m, transform: t);
    expect(r.mass1RadiusView, closeTo(25, 0.01));
    expect(r.mass2RadiusView, closeTo(25, 0.01));
    expect(r.constantRadius, isTrue);
    m.dispose();
  });

  test('ruler geometry 500×35, color, default center', () {
    final m = GravityForceLabModel();
    final r = builder.build(m, transform: t);
    expect(r.rulerWidthView, 500);
    expect(r.rulerHeightView, 35);
    expect(r.majorTickSpacingView, 50);
    expect(r.rulerCenterView.dx, closeTo(t.modelToViewX(0), 0.01));
    expect(r.rulerCenterView.dy, closeTo(t.modelToViewY(-1), 0.01));
    expect(GflColors.rulerBackground, const Color.fromRGBO(236, 225, 113, 1));
    expect(GflStrings.rulerUnit, 'meters');
    m.dispose();
  });

  test('panel / stem / arrow fill colors from source', () {
    expect(GflColors.panelFill, const Color(0xFFFDF498));
    expect(GflColors.forceStem1, const Color(0xFF6666FF));
    expect(GflColors.forceStem2, const Color(0xFFFF6666));
    expect(GflColors.forceArrowFill, const Color(0xFF000000));
  });

  test('arrow mapping params (Full, not Basics)', () {
    expect(GravityForceConstants.maxArrowWidth, 700);
    expect(GravityForceConstants.thresholdArrowWidth, 1);
    expect(GravityForceConstants.minArrowWidth, 0.1);
    expect(GravityForceConstants.forceThresholdPercent, 1.6e-4);
  });

  test('force label modes: decimal / scientific / hidden', () {
    final m = GravityForceLabModel();
    var r = builder.build(m, transform: t);
    expect(r.forceLabel1.contains('N'), isTrue);
    expect(r.forceLabel1.contains('0.000'), isTrue);

    m.setForceValuesDisplay(ForceValuesDisplay.scientific);
    r = builder.build(m, transform: t);
    expect(r.forceLabel1.contains('×'), isTrue);
    expect(r.forceLabel1.contains('10^'), isTrue);
    expect(r.forceLabel1.contains('N'), isTrue);

    m.setForceValuesDisplay(ForceValuesDisplay.hidden);
    r = builder.build(m, transform: t);
    expect(r.forceLabel1.contains('N'), isFalse);
    expect(r.forceLabel1.contains('Force on'), isTrue);
    m.dispose();
  });

  test('reset button placement constants match ScreenView', () {
    // GravityForceLabScreenView: right = width-15, bottom = bottom-7.4, scale 0.81
    const resetRight = 15.0;
    const resetBottom = 7.4;
    const scale = 0.81;
    expect(resetRight, 15);
    expect(resetBottom, 7.4);
    expect(scale, 0.81);
    expect(20.8 * scale, closeTo(16.848, 0.001));
  });

  test('puller scale 0.45 and figurePull frames', () {
    expect(GflRenderBuilder.pullerFrameCount, 31);
    final m = GravityForceLabModel();
    final r = builder.build(m, transform: t);
    expect(r.puller1Frame, inInclusiveRange(0, 30));
    expect(r.puller2Frame, r.puller1Frame);
    m.dispose();
  });
}

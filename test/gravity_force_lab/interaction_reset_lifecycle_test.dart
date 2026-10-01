import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/gravity_force_lab/gfl_strings.dart';
import 'package:kratos/gravity_force_lab/model/force_values_display.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/render/gfl_render_builder.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';
import 'package:kratos/gravity_force_lab/screens/gravity_force_lab_screen.dart';
import 'package:kratos/gravity_force_lab/transform/math_coordinate_transform.dart';
import 'package:kratos/gravity_force_lab/widgets/gfl_page_shell.dart';

void main() {
  const builder = GflRenderBuilder();
  final t = MathCoordinateTransform.forLayout();

  group('Reset', () {
    test('reset restores all defaults after full interaction', () {
      final fresh = GravityForceLabModel();
      final m = GravityForceLabModel();
      m.setMassValue(1, 500);
      m.setMassValue(2, 200);
      m.beginDrag(1);
      m.setPositionWhileDragging(1, -4);
      m.endDrag(1);
      m.beginDrag(2);
      m.setPositionWhileDragging(2, 3);
      m.endDrag(2);
      m.setConstantRadius(true);
      m.setForceValuesDisplay(ForceValuesDisplay.scientific);
      m.setRulerPosition(1.5, 0.5);
      m.reset();

      expect(m.mass1.value, fresh.mass1.value);
      expect(m.mass2.value, fresh.mass2.value);
      expect(m.mass1.positionX, fresh.mass1.positionX);
      expect(m.mass2.positionX, fresh.mass2.positionX);
      expect(m.distance, 4);
      expect(m.constantRadius, fresh.constantRadius);
      expect(m.forceValuesDisplay, ForceValuesDisplay.decimal);
      expect(m.showForceValues, isTrue);
      expect(m.ruler.positionX, 0);
      expect(m.ruler.positionY, -1);
      expect(m.force, closeTo(fresh.force, 1e-20));

      final r = builder.build(m, transform: t);
      final rf = builder.build(fresh, transform: t);
      expect(r.mass1Center, rf.mass1Center);
      expect(r.mass2Center, rf.mass2Center);
      expect(r.forceValuesDisplay, ForceValuesDisplay.decimal);
      expect(r.rulerCenterView, rf.rulerCenterView);
    });

    testWidgets('ResetAllButton triggers model.reset', (tester) async {
      final model = GravityForceLabModel();
      model.setMassValue(1, 700);
      model.setRulerPosition(2, 1);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GflPageShell(child: GflScreenBody(model: model)),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(KratosResetAllButton));
      await tester.pump();
      expect(model.mass1.value, 100);
      expect(model.ruler.positionX, 0);
      expect(model.ruler.positionY, -1);
    });
  });

  group('Lifecycle', () {
    testWidgets('dispose / recreate screen yields fresh model', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GravityForceLabScreen()),
      );
      await tester.pump();
      final state = tester.state<GravityForceLabScreenState>(
        find.byType(GravityForceLabScreen),
      );
      state.model.setMassValue(1, 900);
      expect(state.model.mass1.value, 900);

      state.recreateModel();
      await tester.pump();
      expect(state.model.mass1.value, 100);
      expect(state.model.ruler.positionX, 0);

      // Interact again — no stale callbacks.
      state.model.setMassValue(2, 500);
      expect(state.model.mass2.value, 500);
      expect(state.model.force.isFinite, isTrue);
    });
  });

  group('Rapid interaction regression', () {
    test('rapid mass drag left-right', () {
      final m = GravityForceLabModel();
      for (var i = 0; i < 40; i++) {
        m.beginDrag(1);
        m.setPositionWhileDragging(1, i.isEven ? -4.5 : -1.0);
        m.endDrag(1);
        m.beginDrag(2);
        m.setPositionWhileDragging(2, i.isEven ? 4.5 : 1.5);
        m.endDrag(2);
        expect(m.force.isFinite, isTrue);
        expect(m.force.isNaN, isFalse);
        expect(m.mass1.positionX, lessThan(m.mass2.positionX));
        expect(
          m.distance + 1e-9,
          greaterThanOrEqualTo(m.getSumRadiusWithSeparation()),
        );
      }
    });

    test('rapid ruler 2D drag', () {
      final m = GravityForceLabModel();
      final f0 = m.force;
      for (var i = 0; i < 30; i++) {
        m.setRulerPosition(i * 0.3 - 4, (i % 5) * 0.4 - 1);
        expect(m.ruler.positionX, greaterThanOrEqualTo(m.ruler.dragMinX));
        expect(m.ruler.positionX, lessThanOrEqualTo(m.ruler.dragMaxX));
        expect(m.force, f0);
      }
    });

    test('rapid force notation switch', () {
      final m = GravityForceLabModel();
      final modes = [
        ForceValuesDisplay.decimal,
        ForceValuesDisplay.scientific,
        ForceValuesDisplay.hidden,
      ];
      for (var i = 0; i < 30; i++) {
        m.setForceValuesDisplay(modes[i % 3]);
        final r = builder.build(m, transform: t);
        expect(r.forceLabel1.isNotEmpty, isTrue);
        expect(m.force.isFinite, isTrue);
      }
      expect(m.mass1.value, 100);
    });

    test('rapid Constant Size + mass', () {
      final m = GravityForceLabModel();
      for (var i = 0; i < 20; i++) {
        m.setConstantRadius(i.isEven);
        m.setMassValue(1, 10.0 + (i % 10) * 100);
        expect(m.radius1.isFinite, isTrue);
        expect(m.force.isFinite, isTrue);
        if (m.constantRadius) {
          expect(m.radius1, 0.5);
        }
      }
    });
  });

  group('Widget control live path', () {
    testWidgets('notation + constant size + mass step live', (tester) async {
      final model = GravityForceLabModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GflPageShell(child: GflScreenBody(model: model)),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text(GflStrings.scientificNotation));
      await tester.pump();
      expect(model.forceValuesDisplay, ForceValuesDisplay.scientific);

      await tester.tap(find.text(GflStrings.hidden));
      await tester.pump();
      expect(model.showForceValues, isFalse);

      await tester.tap(find.text(GflStrings.decimalNotation));
      await tester.pump();
      expect(model.forceValuesDisplay, ForceValuesDisplay.decimal);

      await tester.tap(find.text(GflStrings.constantSize));
      await tester.pump();
      expect(model.constantRadius, isTrue);
      expect(model.radius1, 0.5);

      final plus = find.byKey(const ValueKey('mass1_inc'));
      await tester.tap(plus);
      await tester.pump();
      expect(model.mass1.value, 110);
    });
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/render/gfl_render_builder.dart';
import 'package:kratos/gravity_force_lab/transform/math_coordinate_transform.dart';
import 'package:kratos/gravity_force_lab/widgets/ruler_widget.dart';

void main() {
  const builder = GflRenderBuilder();
  final t = MathCoordinateTransform.forLayout();

  group('Ruler interaction', () {
    test('X and Y drag update position; snap 0.1 on X', () {
      final m = GravityForceLabModel();
      final f0 = m.force;
      final d0 = m.distance;
      final x1 = m.mass1.positionX;
      final x2 = m.mass2.positionX;

      m.setRulerPosition(1.04, 0.5);
      expect(m.ruler.positionX, 1.0);
      expect(m.ruler.positionY, closeTo(0.5, 1e-9));

      m.setRulerPosition(2.06, -0.8);
      expect(m.ruler.positionX, 2.1);

      expect(m.force, f0);
      expect(m.distance, d0);
      expect(m.mass1.positionX, x1);
      expect(m.mass2.positionX, x2);
    });

    test('ruler bounds clamp', () {
      final m = GravityForceLabModel();
      m.setRulerPosition(-100, 100);
      expect(m.ruler.positionX, greaterThanOrEqualTo(m.ruler.dragMinX));
      expect(m.ruler.positionX, lessThanOrEqualTo(m.ruler.dragMaxX));
      expect(m.ruler.positionY, greaterThanOrEqualTo(m.ruler.dragMinY));
      expect(m.ruler.positionY, lessThanOrEqualTo(m.ruler.dragMaxY));
    });

    test('measurement: 1 m = 50 view px', () {
      expect(GravityForceConstants.mvtScale, 50);
      expect(GravityForceConstants.rulerWidthView / 50, 10);
      final m = GravityForceLabModel();
      final r = builder.build(m, transform: t);
      expect(r.majorTickSpacingView, 50);
    });

    test('J+H jumpHome — physics unchanged', () {
      final m = GravityForceLabModel();
      m.setRulerPosition(3, 1);
      final f = m.force;
      m.jumpRulerHome();
      expect(m.ruler.positionX, 0);
      expect(m.ruler.positionY, -1);
      expect(m.mass1.positionX, -3);
      expect(m.force, f);
    });

    test('J+C zero to m1 center — physics unchanged', () {
      final m = GravityForceLabModel();
      final f = m.force;
      final x1 = m.mass1.positionX;
      final x2 = m.mass2.positionX;
      m.jumpRulerZeroToMass1Center();
      expect(
        m.ruler.positionX,
        closeTo(x1 + GravityForceConstants.rulerHalfWidthModel, 1e-9),
      );
      expect(m.ruler.positionY, GravityForceConstants.rulerModelYForCenterJump);
      expect(m.force, f);
      expect(m.mass1.positionX, x1);
      expect(m.mass2.positionX, x2);
    });

    testWidgets('keyboard J+H / J+C via RulerKeyboardShortcuts', (tester) async {
      final model = GravityForceLabModel();
      model.setRulerPosition(2, 1);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RulerKeyboardShortcuts(
              model: model,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final focus = tester.widget<Focus>(
        find.byKey(const ValueKey('gfl_ruler_hotkeys')),
      );
      focus.focusNode!.requestFocus();
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyJ);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyH);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyH);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyJ);
      await tester.pump();
      expect(model.ruler.positionX, 0);
      expect(model.ruler.positionY, -1);

      model.setRulerPosition(1, 0);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyJ);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyJ);
      await tester.pump();
      expect(
        model.ruler.positionX,
        closeTo(
          model.mass1.positionX + GravityForceConstants.rulerHalfWidthModel,
          1e-9,
        ),
      );
    });
  });
}

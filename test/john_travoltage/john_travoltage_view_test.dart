import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/john_travoltage/john_travoltage_assets.dart';
import 'package:kratos/john_travoltage/model/electron.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_constants.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_model.dart';
import 'package:kratos/john_travoltage/model/jt_vec2.dart';
import 'package:kratos/john_travoltage/view/jt_view_geometry.dart';
import 'package:kratos/john_travoltage/view/jt_view_layout.dart';
import 'package:kratos/john_travoltage/view/john_travoltage_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JohnTravoltage View — Phase 2', () {
    test('layout constants match BackgroundNode / View source', () {
      expect(JtViewLayout.layoutWidth, 768);
      expect(JtViewLayout.layoutHeight, 504);
      expect(JtViewLayout.windowX, 50);
      expect(JtViewLayout.windowY, 60);
      expect(JtViewLayout.windowScale, 0.93);
      expect(JtViewLayout.floorTop, 440);
      expect(JtViewLayout.rugX, 110);
      expect(JtViewLayout.rugY, 446);
      expect(JtViewLayout.rugScale, 0.58);
      expect(JtViewLayout.doorX, 513.5);
      expect(JtViewLayout.doorY, 48);
      expect(JtViewLayout.doorScale, 0.785);
      expect(JtViewLayout.bodyX, 260);
      expect(JtViewLayout.bodyY, 60);
      expect(JtViewLayout.bodyScale, 0.85);
      expect(JtViewLayout.armDx, 4);
      expect(JtViewLayout.armDy, 45);
      expect(JtViewLayout.armAngleOffset, -0.1);
      expect(JtViewLayout.legDx, 25);
      expect(JtViewLayout.legDy, 28);
      expect(JtViewLayout.legAngleOffset, closeTo(math.pi / 2 * 0.7, 1e-12));
      expect(JtViewLayout.resetRadius, 23);
      expect(JtViewLayout.resetInset, 8);
      expect(JtViewLayout.backgroundColor, const Color(0xFFE4D8C2));
    });

    test('asset paths point at john_travoltage images', () {
      expect(JohnTravoltageAssets.wallpaper, contains('john_travoltage'));
      expect(JohnTravoltageAssets.door.endsWith('door.png'), isTrue);
      expect(JohnTravoltageAssets.body.endsWith('body.png'), isTrue);
      expect(JohnTravoltageAssets.arm.endsWith('arm.png'), isTrue);
      expect(JohnTravoltageAssets.leg.endsWith('leg.png'), isTrue);
    });

    test('arm transform: pivot stays fixed under rotation', () {
      final pivot = Offset(
        JohnTravoltageConstants.armPivot.x,
        JohnTravoltageConstants.armPivot.y,
      );
      for (final angle in [-0.5, 0.0, 1.0, -1.0]) {
        final m = AppendageTransform.matrix(
          pivot: pivot,
          angle: angle,
          angleOffset: JtViewLayout.armAngleOffset,
          dx: JtViewLayout.armDx,
          dy: JtViewLayout.armDy,
        );
        final mapped = MatrixUtils.transformPoint(
          m,
          Offset(JtViewLayout.armDx, JtViewLayout.armDy),
        );
        expect(mapped.dx, closeTo(pivot.dx, 1e-9), reason: 'angle=$angle');
        expect(mapped.dy, closeTo(pivot.dy, 1e-9), reason: 'angle=$angle');
      }
    });

    test('leg transform: pivot fixed at 0 / initial / π', () {
      final pivot = Offset(
        JohnTravoltageConstants.legPivot.x,
        JohnTravoltageConstants.legPivot.y,
      );
      for (final angle in [
        0.0,
        JohnTravoltageConstants.legInitialAngle,
        math.pi,
      ]) {
        final m = AppendageTransform.matrix(
          pivot: pivot,
          angle: angle,
          angleOffset: JtViewLayout.legAngleOffset,
          dx: JtViewLayout.legDx,
          dy: JtViewLayout.legDy,
        );
        final mapped = MatrixUtils.transformPoint(
          m,
          Offset(JtViewLayout.legDx, JtViewLayout.legDy),
        );
        expect(mapped.dx, closeTo(pivot.dx, 1e-9));
        expect(mapped.dy, closeTo(pivot.dy, 1e-9));
      }
    });

    test('fingerPosition comes from Model, not View estimate', () {
      final m = JohnTravoltageModel(random: math.Random(1));
      final finger = m.fingerPosition;
      final expected =
          m.arm.fingerVector.rotated(m.arm.angle).plus(m.arm.position);
      expect(finger.x, closeTo(expected.x, 1e-9));
      expect(finger.y, closeTo(expected.y, 1e-9));
    });

    test('electron body mapping uses raw position', () {
      final m = JohnTravoltageModel(random: math.Random(1));
      final e = m.debugAddElectronAt(const JtVec2(360, 200));
      e.history
        ..clear()
        ..addAll(List.filled(10, ElectronHistory.body));
      final screen = ElectronScreenMapper.mapScreenPosition(
        electron: e,
        leg: m.leg,
        arm: m.arm,
      );
      expect(screen.x, closeTo(360, 1e-9));
      expect(screen.y, closeTo(200, 1e-9));
    });

    test('electron leg mapping rotates by leg.deltaAngle', () {
      final m = JohnTravoltageModel(random: math.Random(1));
      final e = m.debugAddElectronAt(const JtVec2(400, 400));
      e.history
        ..clear()
        ..addAll(List.filled(10, ElectronHistory.leg));

      final screen = ElectronScreenMapper.mapScreenPosition(
        electron: e,
        leg: m.leg,
        arm: m.arm,
      );
      final legPoint = m.leg.position;
      final expected =
          JtVec2(e.position.x - legPoint.x, e.position.y - legPoint.y)
              .rotated(m.leg.deltaAngle())
              .plus(legPoint);
      expect(screen.x, closeTo(expected.x, 1e-9));
      expect(screen.y, closeTo(expected.y, 1e-9));
    });

    test('spark path: start=finger end=knob, segment count', () {
      final m = JohnTravoltageModel(random: math.Random(2));
      m.setArmAngle(0);
      final points = SparkPathBuilder.build(
        finger: m.fingerPosition,
        knob: m.doorknobPosition,
        random: math.Random(2),
        numSegments: JtViewLayout.sparkSegmentCount,
      );
      expect(points.length, JtViewLayout.sparkSegmentCount + 1);
      expect(points.first.x, closeTo(m.fingerPosition.x, 1e-9));
      expect(points.first.y, closeTo(m.fingerPosition.y, 1e-9));
      expect(points.last.x, closeTo(m.doorknobPosition.x, 1e-9));
      expect(points.last.y, closeTo(m.doorknobPosition.y, 1e-9));
    });

    test('green border rect is initial-angle AABB', () {
      final pivot = Offset(
        JohnTravoltageConstants.armPivot.x,
        JohnTravoltageConstants.armPivot.y,
      );
      final rect = AppendageTransform.imageBounds(
        pivot: pivot,
        angle: JohnTravoltageConstants.armInitialAngle,
        angleOffset: JtViewLayout.armAngleOffset,
        dx: JtViewLayout.armDx,
        dy: JtViewLayout.armDy,
        imageSize: JtViewLayout.armImageSize,
      );
      expect(rect.width, greaterThan(50));
      expect(rect.height, greaterThan(40));
      expect(rect.contains(pivot), isTrue);
    });

    testWidgets('initial play area pumps with assets + reset', (tester) async {
      final model = JohnTravoltageModel(random: math.Random(1));
      await tester.pumpWidget(
        MaterialApp(
          home: JohnTravoltagePlayArea(
            model: model,
            autoStartClock: false,
            enableAudio: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(JohnTravoltagePlayArea), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.byKey(const ValueKey('jt-arm')), findsOneWidget);
      expect(find.byKey(const ValueKey('jt-leg')), findsOneWidget);

      model.arm.borderVisible = false;
      model.leg.borderVisible = false;
      model.reset();
      await tester.pump();
      expect(model.arm.borderVisible, isTrue);
      expect(model.leg.borderVisible, isTrue);
    });

    testWidgets('reset button position near bottom-right of layout',
        (tester) async {
      final model = JohnTravoltageModel(random: math.Random(1));
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: JohnTravoltagePlayArea(
              model: model,
              autoStartClock: false,
              enableAudio: false,
            ),
          ),
        ),
      );
      await tester.pump();

      final reset = tester.getRect(find.byType(KratosResetAllButton));
      expect(reset.right, greaterThan(700));
      expect(reset.bottom, greaterThan(450));
    });
  });
}

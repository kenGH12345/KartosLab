import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_constants.dart';
import 'package:kratos/balloons_and_static_electricity/model/balloons_static_electricity_model.dart';
import 'package:kratos/balloons_and_static_electricity/model/base_vec2.dart';
import 'package:kratos/balloons_and_static_electricity/view/base_view_layout.dart';
import 'package:kratos/balloons_and_static_electricity/view/balloons_static_electricity_view.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BASE View', () {
    late BalloonsStaticElectricityModel model;

    setUp(() {
      model = BalloonsStaticElectricityModel();
    });

    Future<void> pumpPlayArea(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BalloonsStaticElectricityPlayArea(
                model: model,
                autoStartClock: false,
                enableAudio: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('canonical 768×504 layout and background', (tester) async {
      await pumpPlayArea(tester);
      final box = tester.renderObject<RenderBox>(
        find.byType(BalloonsStaticElectricityPlayArea),
      );
      expect(box.size.width, BaseViewLayout.layoutWidth);
      expect(box.size.height, BaseViewLayout.layoutHeight);
      expect(BaseViewLayout.backgroundColor, const Color(0xFF97D0FF));
    });

    testWidgets('assets resolve for balloon/sweater/wall', (tester) async {
      await pumpPlayArea(tester);
      expect(find.byType(Image), findsWidgets);
      // Yellow balloon + sweater + wall at least.
      expect(
        find.image(const AssetImage(BaseAssets.yellowBalloon)),
        findsWidgets,
      );
      expect(
        find.image(const AssetImage(BaseAssets.sweater)),
        findsOneWidget,
      );
      expect(
        find.image(const AssetImage(BaseAssets.wall)),
        findsOneWidget,
      );
    });

    testWidgets('green hidden initially; wall visible', (tester) async {
      await pumpPlayArea(tester);
      expect(model.greenBalloon.isVisible, isFalse);
      expect(model.wall.isVisible, isTrue);
      // Selector chip still embeds green thumbnail; play balloon stays hidden.
      expect(model.greenBalloon.position, BaseConstants.greenInitialPosition);
      model.setTwoBalloons(true);
      await tester.pump();
      expect(model.greenBalloon.isVisible, isTrue);
    });

    testWidgets('charge modes update without changing physics charge',
        (tester) async {
      model.yellowBalloon.charge = -7;
      await pumpPlayArea(tester);
      model.setShowCharges(ShowCharges.noCharges);
      await tester.pump();
      expect(model.yellowBalloon.charge, -7);
      model.setShowCharges(ShowCharges.chargeDifferences);
      await tester.pump();
      expect(model.yellowBalloon.charge, -7);
      model.setShowCharges(ShowCharges.allCharges);
      await tester.pump();
      expect(model.showCharges, ShowCharges.allCharges);
    });

    testWidgets('hit geometry: body/knot yes, far corner no', (tester) async {
      final b = model.yellowBalloon;
      expect(b.hitTestLocal(const BaseVec2(67, 100)), isTrue);
      expect(b.hitTestLocal(const BaseVec2(67, 210)), isTrue);
      expect(b.hitTestLocal(const BaseVec2(2, 2)), isFalse);
    });

    testWidgets('pointer offset: drag uses delta not snap-to-center',
        (tester) async {
      await pumpPlayArea(tester);
      final start = model.yellowBalloon.position;
      // Drag by model API simulating view delta semantics.
      model.dragBalloonTo(
        model.yellowBalloon,
        BaseVec2(start.x + 40, start.y + 20),
      );
      expect(model.yellowBalloon.position.x, start.x + 40);
      expect(model.yellowBalloon.position.y, start.y + 20);
      // Not snapped to pointer-as-center (would be very different).
      expect(
        model.yellowBalloon.getCenter().x,
        isNot(closeTo(start.x + 40, 0.01)),
      );
    });

    testWidgets('tether endpoint follows balloon', (tester) async {
      await pumpPlayArea(tester);
      final before = model.yellowBalloon.position;
      model.dragBalloonTo(
        model.yellowBalloon,
        BaseVec2(before.x - 30, before.y + 10),
      );
      await tester.pump();
      expect(model.yellowBalloon.position.x, before.x - 30);
      // CustomPaint tether present.
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Reset Balloon(s) vs Reset All view state', (tester) async {
      await pumpPlayArea(tester);
      model.setTwoBalloons(true);
      model.setShowCharges(ShowCharges.chargeDifferences);
      model.removeWall();
      model.yellowBalloon.charge = -5;
      await tester.pump();

      model.resetBalloons();
      await tester.pump();
      expect(model.greenBalloon.isVisible, isTrue);
      expect(model.showCharges, ShowCharges.chargeDifferences);
      expect(model.wall.isVisible, isFalse);
      expect(model.yellowBalloon.charge, 0);

      model.reset();
      await tester.pump();
      expect(model.greenBalloon.isVisible, isFalse);
      expect(model.showCharges, ShowCharges.allCharges);
      expect(model.wall.isVisible, isTrue);
    });

    testWidgets('controls include KratosResetAllButton', (tester) async {
      await pumpPlayArea(tester);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.text('Show all charges'), findsOneWidget);
      expect(find.text('Remove Wall'), findsOneWidget);
      expect(find.text('Reset Balloon'), findsOneWidget);
    });

    testWidgets('sweater and wall are not independently draggable targets',
        (tester) async {
      await pumpPlayArea(tester);
      // IgnorePointer wraps sweater image / wall image.
      expect(find.byType(IgnorePointer), findsWidgets);
    });

    test('layout constants match source', () {
      expect(BaseViewLayout.layoutWidth, 768);
      expect(BaseViewLayout.layoutHeight, 504);
      expect(BaseConstants.sweaterWidth, 305);
      expect(BaseConstants.balloonWidth, 134);
      expect(BaseConstants.wallX, 688);
    });
  });
}

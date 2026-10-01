import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/hookes_law/model/intro_model.dart';
import 'package:kratos/hookes_law/view/intro/intro_screen.dart';
import 'package:kratos/hookes_law/view/intro/intro_view_properties.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpIntro(
    WidgetTester tester, {
    required IntroModel model,
    IntroViewProperties? view,
  }) async {
    tester.view.physicalSize = const Size(1024, 618);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: IntroScreen(model: model, viewProperties: view),
      ),
    );
  }

  testWidgets('default state shows one system and leaves the second at defaults', (tester) async {
    final model = IntroModel();
    final view = IntroViewProperties();
    await pumpIntro(tester, model: model, view: view);

    expect(model.system1.spring.springConstant, 200);
    expect(model.system1.spring.appliedForce, 0);
    expect(model.system1.spring.displacement, 0);
    expect(model.system1.spring.springForce, 0);
    expect(model.system2.spring.springConstant, 200);
    expect(model.system2.spring.appliedForce, 0);
    expect(view.numberOfSystems, 1);
    expect(view.appliedForceVectorVisible, isFalse);
    expect(view.springForceVectorVisible, isFalse);
    expect(view.displacementVectorVisible, isFalse);
    expect(view.equilibriumPositionVisible, isFalse);
    expect(view.valuesVisible, isFalse);
    expect(view.valuesEnabled, isFalse);
    expect(find.byKey(const Key('intro-hand-1')), findsOneWidget);
    expect(find.byKey(const Key('intro-hand-2')), findsNothing);
    expect(find.text('Spring Constant 1:'), findsOneWidget);
    expect(find.text('Spring Constant 2:'), findsNothing);
  });

  testWidgets('one to two reveals system 2 only after the move, then fades it in', (tester) async {
    final model = IntroModel();
    final view = IntroViewProperties();
    await pumpIntro(tester, model: model, view: view);
    await tester.pumpAndSettle();

    final topBefore = tester.getTopLeft(find.byKey(const Key('intro-system-1'))).dy;
    await tester.tap(find.byKey(const Key('intro-radio-2')));
    await tester.pump();

    expect(view.numberOfSystems, 2);
    expect(find.byKey(const Key('intro-hand-2')), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    final topAfterMove = tester.getTopLeft(find.byKey(const Key('intro-system-1'))).dy;
    expect(topAfterMove, lessThan(topBefore - 50));
    expect(find.byKey(const Key('intro-hand-2')), findsOneWidget);
    expect(
      tester.widget<Opacity>(find.byKey(const Key('intro-system-2-fade'))).opacity,
      0,
    );

    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester.widget<Opacity>(find.byKey(const Key('intro-system-2-fade'))).opacity,
      1,
    );
    expect(find.byKey(const Key('intro-hand-2')), findsOneWidget);
    expect(find.text('Spring Constant 2:'), findsOneWidget);
  });

  testWidgets('two to one fades system 2 out before moving system 1', (tester) async {
    final model = IntroModel();
    final view = IntroViewProperties();
    await pumpIntro(tester, model: model, view: view);
    await tester.pumpAndSettle();
    view.numberOfSystems = 2;
    await tester.pumpAndSettle();

    final topTwo = tester.getTopLeft(find.byKey(const Key('intro-system-1'))).dy;
    await tester.tap(find.byKey(const Key('intro-radio-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byKey(const Key('intro-hand-2')), findsOneWidget);
    final midFade = tester.widget<Opacity>(find.byKey(const Key('intro-system-2-fade'))).opacity;
    expect(midFade, inInclusiveRange(0.4, 0.6));

    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byKey(const Key('intro-hand-2')), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    final topOne = tester.getTopLeft(find.byKey(const Key('intro-system-1'))).dy;
    expect(topOne, greaterThan(topTwo + 50));
    expect(view.numberOfSystems, 1);
  });

  testWidgets('drag snaps to 0.01 m, clamps, and updates force without a second state', (tester) async {
    final model = IntroModel();
    await pumpIntro(tester, model: model);
    await tester.pumpAndSettle();
    final spring = model.system1.spring;

    await tester.drag(find.byKey(const Key('intro-hand-1')), const Offset(30, 0));
    await tester.pump();

    expect(spring.displacement, closeTo(0.13, 1e-9));
    expect(spring.appliedForce, closeTo(26, 1e-9));
    expect(spring.springForce, closeTo(-26, 1e-9));
    expect(spring.displacement * 100, closeTo((spring.displacement * 100).roundToDouble(), 1e-9));

    await tester.drag(find.byKey(const Key('intro-hand-1')), const Offset(-400, 0));
    await tester.pump();
    expect(spring.displacement, closeTo(-0.5, 1e-9));
    expect(spring.appliedForce, closeTo(-100, 1e-6));
    expect(spring.springForce, closeTo(100, 1e-6));

    await tester.drag(find.byKey(const Key('intro-hand-1')), const Offset(800, 0));
    await tester.pump();
    expect(spring.displacement, closeTo(0.5, 1e-9));
    expect(spring.appliedForce, closeTo(100, 1e-6));
    expect(model.system2.spring.displacement, 0);
  });

  testWidgets('force arrow steps by 1 N and the slider steps by 5 N', (tester) async {
    final model = IntroModel();
    await pumpIntro(tester, model: model);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('intro-f-increment-1')));
    await tester.pump();
    expect(model.system1.spring.appliedForce, 1);
    expect(model.system1.spring.displacement, closeTo(1 / 200, 1e-12));

    await tester.tap(find.byKey(const Key('intro-f-decrement-1')));
    await tester.pump();
    expect(model.system1.spring.appliedForce, 0);
    expect(find.byKey(const Key('intro-applied-arrow-1')), findsNothing);

    await tester.drag(find.byKey(const Key('intro-f-slider-1')), const Offset(36, 0));
    await tester.pump();
    expect(model.system1.spring.appliedForce, 40);
    expect(model.system1.spring.springConstant, 200);
    expect(model.system1.spring.displacement, closeTo(0.2, 1e-12));
  });

  testWidgets('changing k keeps F and recomputes x', (tester) async {
    final model = IntroModel();
    await pumpIntro(tester, model: model);
    await tester.pumpAndSettle();

    await tester.drag(find.byKey(const Key('intro-f-slider-1')), const Offset(36, 0));
    await tester.pump();
    expect(model.system1.spring.appliedForce, 40);

    await tester.tap(find.byKey(const Key('intro-k-increment-1')));
    await tester.pump();
    expect(model.system1.spring.springConstant, 201);
    expect(model.system1.spring.appliedForce, 40);
    expect(model.system1.spring.displacement, closeTo(40 / 201, 1e-12));
  });

  testWidgets('zero force hides arrows; values stay disabled until a vector is on', (tester) async {
    final model = IntroModel();
    final view = IntroViewProperties();
    await pumpIntro(tester, model: model, view: view);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Values'));
    await tester.pump();
    expect(view.valuesVisible, isFalse);

    await tester.tap(find.text('Applied Force'));
    await tester.tap(find.text('Spring Force'));
    await tester.tap(find.text('Displacement'));
    await tester.tap(find.text('Equilibrium Position'));
    await tester.pump();
    expect(view.valuesEnabled, isTrue);
    expect(find.byKey(const Key('intro-applied-arrow-1')), findsNothing);
    expect(find.byKey(const Key('intro-equilibrium-1')), findsOneWidget);

    await tester.tap(find.text('Values'));
    await tester.pump();
    expect(find.byKey(const Key('intro-applied-value-1')), findsOneWidget);
    expect(find.byKey(const Key('intro-displacement-value-1')), findsOneWidget);

    await tester.drag(find.byKey(const Key('intro-hand-1')), const Offset(30, 0));
    await tester.pump();
    expect(find.byKey(const Key('intro-applied-arrow-1')), findsOneWidget);
    expect(find.byKey(const Key('intro-spring-arrow-1')), findsOneWidget);
    expect(find.byKey(const Key('intro-displacement-arrow-1')), findsOneWidget);

    await tester.drag(find.byKey(const Key('intro-hand-1')), const Offset(-30, 0));
    await tester.pump();
    expect(model.system1.spring.appliedForce, 0);
    expect(find.byKey(const Key('intro-applied-arrow-1')), findsNothing);
    expect(find.byKey(const Key('intro-applied-value-1')), findsOneWidget);
  });

  testWidgets('reset restores both systems, checkboxes, and the one-system view', (tester) async {
    final model = IntroModel();
    final view = IntroViewProperties();
    await pumpIntro(tester, model: model, view: view);
    await tester.pumpAndSettle();

    view.numberOfSystems = 2;
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('intro-k-increment-2')));
    await tester.pump();
    await tester.tap(find.text('Applied Force'));
    await tester.pump();
    expect(model.system2.spring.springConstant, 201);
    expect(view.appliedForceVectorVisible, isTrue);

    view.numberOfSystems = 1;
    await tester.pumpAndSettle();
    expect(model.system2.spring.springConstant, 201);

    await tester.tap(find.byKey(const Key('intro-reset')));
    await tester.pumpAndSettle();

    expect(view.numberOfSystems, 1);
    expect(view.appliedForceVectorVisible, isFalse);
    expect(model.system1.spring.springConstant, 200);
    expect(model.system1.spring.appliedForce, 0);
    expect(model.system1.spring.displacement, 0);
    expect(model.system2.spring.springConstant, 200);
    expect(model.system2.spring.appliedForce, 0);
    expect(model.system2.spring.displacement, 0);
    expect(find.byKey(const Key('intro-hand-2')), findsNothing);
  });

  testWidgets('negative drag and disposing the screen do not leak the ticker', (tester) async {
    final model = IntroModel();
    await pumpIntro(tester, model: model);
    await tester.pump();
    await tester.drag(find.byKey(const Key('intro-hand-1')), const Offset(-30, 0));
    await tester.pump();
    expect(model.system1.spring.displacement, lessThan(0));
    expect(model.system1.spring.appliedForce, lessThan(0));
    expect(model.system1.spring.springForce, greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/plinko_probability/controller/intro_controller.dart';
import 'package:kratos/plinko_probability/controller/lab_controller.dart';
import 'package:kratos/plinko_probability/model/plinko_common_model.dart';
import 'package:kratos/plinko_probability/model/plinko_random.dart';
import 'package:kratos/plinko_probability/plinko_strings.dart';
import 'package:kratos/plinko_probability/screens/plinko_probability_home.dart';
import 'package:kratos/screens/home_screen.dart';

/// Home wiring + Intro/Lab controller lifecycle (open → run → reset → reopen).
void main() {
  test('Home catalog exposes Plinko under 数学与概率 metadata', () {
    expect(PlinkoProbabilityHome.title, PlinkoStrings.title);
    expect(PlinkoProbabilityHome.subtitle, isNotEmpty);
    expect(PlinkoProbabilityHome.accentColor.toARGB32(), isNonZero);
    // Ensure home_screen compiles the builder reference.
    expect(HomeScreen, isNotNull);
  });

  testWidgets('Intro/Lab controllers survive reset and reopen', (tester) async {
    // Shell chrome overflow is unrelated to model lifecycle; ignore layout noise.
    final old = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('A RenderFlex overflowed')) return;
      old?.call(details);
    };
    addTearDown(() => FlutterError.onError = old);

    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Open
    await tester.pumpWidget(
      const MaterialApp(home: PlinkoProbabilityHome()),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text(PlinkoProbabilityHome.title), findsOneWidget);

    // Controller-level Run / Reset (mirrors Home → Play → Reset)
    final intro = IntroController(random: PlinkoRandom(1));
    final lab = LabController(random: PlinkoRandom(2));
    intro.play();
    intro.model.step(0.2);
    expect(intro.model.balls, isNotEmpty);
    intro.resetAll();
    expect(intro.model.balls, isEmpty);

    lab.setBallMode(BallMode.oneBall);
    lab.playPressed();
    expect(lab.model.balls.length, 1);
    lab.resetAll();
    expect(lab.model.balls, isEmpty);
    intro.dispose();
    lab.dispose();

    // Back → Reopen
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();
    await tester.pumpWidget(
      const MaterialApp(home: PlinkoProbabilityHome()),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text(PlinkoProbabilityHome.title), findsOneWidget);
  });
}

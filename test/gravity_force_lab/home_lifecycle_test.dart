import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio.dart';
import 'package:kratos/gravity_force_lab/model/force_values_display.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/screens/gravity_force_lab_screen.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';
import 'package:kratos/screens/home_screen.dart';

class _PopObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
  }
}

Future<void> _openHome(
  WidgetTester tester, {
  NavigatorObserver? observer,
}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: const HomeScreen(),
      navigatorObservers: [
        ?observer,
      ],
    ),
  );
  await tester.pump();
}

Future<void> _enterFull(WidgetTester tester) async {
  await tester.ensureVisible(find.text(GravityForceLabScreen.title).first);
  await tester.tap(find.text(GravityForceLabScreen.title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(GravityForceLabScreen), findsOneWidget);
}

Future<void> _back(WidgetTester tester, _PopObserver observer) async {
  final before = observer.popCount;
  final backButton = find.byType(BackButton);
  if (backButton.evaluate().isNotEmpty) {
    await tester.tap(backButton);
  } else {
    await tester.tap(find.byType(IconButton).first);
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  expect(observer.popCount, greaterThan(before));
  expect(find.byType(GravityForceLabScreen), findsNothing);
  expect(find.byType(HomeScreen), findsOneWidget);
}

void main() {
  testWidgets('Back returns to Home; re-entry is fresh instance',
      (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enterFull(tester);

    final first = tester
        .state<GravityForceLabScreenState>(find.byType(GravityForceLabScreen));
    first.model.setMassValue(1, 800);
    first.model.setMassValue(2, 900);
    first.model.setPosition(1, -4.0);
    first.model.setForceValuesDisplay(ForceValuesDisplay.scientific);
    first.model.setConstantRadius(true);
    first.model.setRulerPosition(1.5, 0.2);
    await tester.pump();

    await _back(tester, observer);
    expect(find.byType(GflScreenBody), findsNothing);

    await _enterFull(tester);
    final second = tester
        .state<GravityForceLabScreenState>(find.byType(GravityForceLabScreen));
    expect(identical(first, second), isFalse);
    expect(identical(first.model, second.model), isFalse);
    // KartosLab convention: push → fresh Screen → defaults (not preserve).
    expect(second.model.mass1.value, GravityForceConstants.initialMass1);
    expect(second.model.mass2.value, GravityForceConstants.initialMass2);
    expect(second.model.mass1.positionX, GravityForceConstants.initialPosition1);
    expect(second.model.constantRadius, isFalse);
    expect(second.model.showForceValues, isTrue);
    expect(second.model.ruler.positionX, GravityForceConstants.rulerInitialX);
  });

  testWidgets('injected audio detaches on dispose; re-attach is single session',
      (tester) async {
    final audio = GflAudio(playEnabled: false);
    addTearDown(() async => audio.dispose());

    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GravityForceLabScreen(audio: audio),
                  ),
                );
              },
              child: const Text('open-full'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-full'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(audio.attachCount, 1);

    final state = tester
        .state<GravityForceLabScreenState>(find.byType(GravityForceLabScreen));
    state.model.setPosition(1, -4.0);
    await tester.pump();

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(GravityForceLabScreen), findsNothing);
    expect(audio.isForcePlaying, isFalse);
    expect(audio.isRulerGrabbed, isFalse);

    await tester.tap(find.text('open-full'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(audio.attachCount, 2); // re-attach once, not duplicated listeners
    expect(find.byType(GravityForceLabScreen), findsOneWidget);
  });

  testWidgets('repeated enter/back does not crash or leave Full mounted',
      (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);

    for (var i = 0; i < 3; i++) {
      await _enterFull(tester);
      final state = tester
          .state<GravityForceLabScreenState>(find.byType(GravityForceLabScreen));
      state.model.setMassValue(1, 200 + i * 10);
      await tester.pump();
      await _back(tester, observer);
    }
    expect(observer.popCount, 3);
    expect(find.byType(GravityForceLabScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}

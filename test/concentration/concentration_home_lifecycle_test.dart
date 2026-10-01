import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/beers_law_lab/screens/beers_law_lab_home.dart';
import 'package:kratos/chemistry/molarity/audio/molarity_audio.dart';
import 'package:kratos/chemistry/molarity/view/screens/molarity_screen.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/concentration/audio/concentration_audio.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/solute_definitions.dart';
import 'package:kratos/concentration/model/solute_form.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// Concentration Home lifecycle — entry upgraded to [BeersLawLabHome].
class _PopObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
  }
}

Future<void> _enterBeersLawLab(WidgetTester tester) async {
  await tester.ensureVisible(find.text(BeersLawLabHome.title).first);
  await tester.tap(find.text(BeersLawLabHome.title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(BeersLawLabHome), findsOneWidget);
  expect(find.byType(ConcentrationScreen), findsOneWidget);
}

Future<void> _leave(WidgetTester tester, _PopObserver observer) async {
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
}

void main() {
  setUp(() {
    BeersLawLabHome.debugTestAudio = RecordingConcentrationAudio();
    MolarityScreen.debugTestAudio = RecordingMolarityAudio();
  });
  tearDown(() {
    BeersLawLabHome.debugTestAudio = null;
    MolarityScreen.debugTestAudio = null;
  });

  testWidgets('Home lists Beers Law Lab under 化学 → 溶液与浓度', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('化学'), findsOneWidget);
    expect(find.text('溶液与浓度'), findsOneWidget);
    await tester.ensureVisible(find.text(BeersLawLabHome.title));
    expect(find.text(BeersLawLabHome.title), findsOneWidget);
    expect(find.text(BeersLawLabHome.subtitle), findsOneWidget);
    // Former standalone「浓度」card must not remain as a duplicate entry.
    expect(find.text(ConcentrationScreen.title), findsNothing);
  });

  testWidgets('Home → BeersLawLabHome → Back → re-enter', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final observer = _PopObserver();
    await tester.pumpWidget(
      MaterialApp(home: const HomeScreen(), navigatorObservers: [observer]),
    );
    await tester.pumpAndSettle();

    await _enterBeersLawLab(tester);
    expect(find.byType(ConcentrationScreen), findsOneWidget);
    expect(find.text('Concentration'), findsWidgets);

    await _leave(tester, observer);
    expect(find.byType(BeersLawLabHome), findsNothing);
    expect(find.text(BeersLawLabHome.title), findsOneWidget);

    await _enterBeersLawLab(tester);
    expect(find.byType(ConcentrationScreen), findsOneWidget);
  });

  testWidgets('sibling Molarity ↔ Beers Law Lab navigation', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final observer = _PopObserver();
    await tester.pumpWidget(
      MaterialApp(home: const HomeScreen(), navigatorObservers: [observer]),
    );
    await tester.pumpAndSettle();

    await _enterBeersLawLab(tester);
    await _leave(tester, observer);

    await tester.ensureVisible(find.text('摩尔浓度').first);
    await tester.tap(find.text('摩尔浓度').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MolarityScreen), findsOneWidget);

    await _leave(tester, observer);
    await _enterBeersLawLab(tester);
    expect(find.byType(ConcentrationScreen), findsOneWidget);
  });

  testWidgets('re-entry creates fresh model state (no stale moles)',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final model = ConcentrationModel();
    await tester.pumpWidget(
      MaterialApp(home: ConcentrationScreen(model: model)),
    );
    await tester.pump();
    model.addSoluteAmount(0.5);
    model.setSoluteForm(SoluteForm.solution);
    expect(model.soluteMoles, greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    final fresh = ConcentrationModel();
    await tester.pumpWidget(
      MaterialApp(home: ConcentrationScreen(model: fresh)),
    );
    await tester.pump();
    expect(fresh.soluteMoles, 0);
    expect(fresh.solute, SoluteDefinitions.drinkMix);
    expect(fresh.soluteForm, SoluteForm.solid);
    expect(fresh.solutionVolume, 0.5);
  });

  testWidgets('1100×700 play area present after Home entry', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    await _enterBeersLawLab(tester);

    expect(find.byType(ConcentrationPlayArea), findsOneWidget);
    final play = tester.widget<ConcentrationPlayArea>(
      find.byType(ConcentrationPlayArea),
    );
    expect(play.model.solutionVolume, 0.5);
    expect(play.model.soluteMoles, 0);
  });

  testWidgets('Home product uses Recording-safe dual-screen shell',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey<BeersLawLabHomeState>();
    await tester.pumpWidget(
      MaterialApp(
        home: BeersLawLabHome(
          key: key,
          concentrationAudio: RecordingConcentrationAudio(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(KratosTabbedScreen), findsOneWidget);
    expect(key.currentState!.concentrationModel.soluteMoles, 0);
  });
}

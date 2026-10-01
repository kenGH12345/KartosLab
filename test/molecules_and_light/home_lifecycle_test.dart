import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/molecule_polarity/screens/molecule_polarity_home.dart';
import 'package:kratos/molecules_and_light/molecules_and_light_constants.dart';
import 'package:kratos/molecules_and_light/view/molecules_and_light_screen.dart';
import 'package:kratos/screens/home_screen.dart';

class _PopObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
  }
}

Future<void> _openHome(WidgetTester tester, {NavigatorObserver? observer}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: const HomeScreen(),
      navigatorObservers: [?observer],
    ),
  );
  await tester.pump();
}

Future<void> _enter(WidgetTester tester) async {
  await tester.ensureVisible(find.text(MoleculesAndLightScreen.title).first);
  await tester.tap(find.text(MoleculesAndLightScreen.title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(MoleculesAndLightScreen), findsOneWidget);
}

Future<void> _back(WidgetTester tester, _PopObserver observer) async {
  final before = observer.popCount;
  expect(find.byType(BackButton), findsOneWidget);
  await tester.tap(find.byType(BackButton));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  expect(observer.popCount, greaterThan(before));
  expect(find.byType(MoleculesAndLightScreen), findsNothing);
}

MoleculesAndLightScreenState _state(WidgetTester tester) {
  return tester.state<MoleculesAndLightScreenState>(
    find.byType(MoleculesAndLightScreen),
  );
}

void main() {
  testWidgets('Home lists Molecules and Light under 化学 / 光与分子',
      (tester) async {
    await _openHome(tester);
    await tester.ensureVisible(find.text('化学').first);
    expect(find.text('化学'), findsWidgets);
    await tester.ensureVisible(find.text('光与分子').first);
    expect(find.text('光与分子'), findsOneWidget);
    await tester.ensureVisible(find.text(MoleculesAndLightScreen.title).first);
    expect(find.text(MoleculesAndLightScreen.title), findsOneWidget);
    expect(find.text(MoleculesAndLightScreen.subtitle), findsOneWidget);
    expect(find.byIcon(Icons.flare_rounded), findsOneWidget);
    await tester.ensureVisible(find.text(MoleculePolarityHome.title).first);
    expect(find.text(MoleculePolarityHome.title), findsOneWidget);
  });

  testWidgets('Home → MAL → Back → Home (scenario A)', (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enter(tester);
    final state = _state(tester);
    expect(state.model.light, LightType.infrared);
    expect(state.model.emitterOn, isFalse);
    expect(state.model.moleculeType, MoleculeType.carbonMonoxide);
    expect(state.clock.isRunning, isTrue);

    await _back(tester, observer);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(observer.popCount, 1);

    await _enter(tester);
    final again = _state(tester);
    expect(again.model.light, LightType.infrared);
    expect(again.model.emitterOn, isFalse);
    expect(again.model.moleculeType, MoleculeType.carbonMonoxide);
    expect(again.spectrumOpen, isFalse);
  });

  testWidgets('Playing → Back stops clock; re-entry is fresh (scenario B)',
      (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enter(tester);
    final first = _state(tester);
    first.model.setLight(LightType.ultraviolet);
    first.model.setMolecule(MoleculeType.ozone);
    first.model.setEmitterOn(true);
    first.model.running = true;
    await tester.pump(const Duration(milliseconds: 100));
    expect(first.model.photons, isNotEmpty);
    expect(first.clock.isRunning, isTrue);

    await _back(tester, observer);
    expect(find.byType(MoleculesAndLightScreen), findsNothing);

    await _enter(tester);
    final second = _state(tester);
    expect(identical(second.model, first.model), isFalse);
    expect(second.model.light, LightType.infrared);
    expect(second.model.emitterOn, isFalse);
    expect(second.model.moleculeType, MoleculeType.carbonMonoxide);
    expect(second.model.photons, isEmpty);
    expect(second.model.molecule.vibrating, isFalse);
    expect(second.model.molecule.rotating, isFalse);
    expect(second.spectrumOpen, isFalse);
  });

  testWidgets('Spectrum open → Back clears overlay; reopen closed (scenario C)',
      (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enter(tester);

    await tester.tap(find.byKey(const Key('spectrum-button')));
    await tester.pump();
    expect(find.byKey(const Key('spectrum-dialog')), findsOneWidget);
    expect(_state(tester).spectrumOpen, isTrue);

    await _back(tester, observer);
    expect(find.byKey(const Key('spectrum-dialog')), findsNothing);

    await _enter(tester);
    expect(_state(tester).spectrumOpen, isFalse);
    expect(find.byKey(const Key('spectrum-dialog')), findsNothing);
  });

  testWidgets('mutate then Reset is distinct from dispose re-entry',
      (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enter(tester);
    final state = _state(tester);
    state.model.setMolecule(MoleculeType.water);
    state.model.setLight(LightType.microwave);
    state.model.setEmitterOn(true);
    await tester.pump();
    expect(state.model.moleculeType, MoleculeType.water);

    state.model.reset();
    await tester.pump();
    expect(state.model.light, LightType.infrared);
    expect(state.model.emitterOn, isFalse);
    expect(state.model.moleculeType, MoleculeType.carbonMonoxide);

    state.model.setMolecule(MoleculeType.methane);
    state.model.setLight(LightType.visible);
    await tester.pump();

    await _back(tester, observer);
    await _enter(tester);
    final again = _state(tester);
    expect(again.model.moleculeType, MoleculeType.carbonMonoxide);
    expect(again.model.light, LightType.infrared);
    expect(again.model.emitterOn, isFalse);
  });

  testWidgets('open and close twice does not leak routes', (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    for (var i = 0; i < 2; i++) {
      await _enter(tester);
      await tester.tap(find.byKey(const Key('spectrum-button')));
      await tester.pump();
      await _back(tester, observer);
    }
    expect(observer.popCount, 2);
    expect(find.byType(MoleculesAndLightScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

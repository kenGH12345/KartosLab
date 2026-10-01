import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/beers_law_lab/screens/beers_law_lab_home.dart';
import 'package:kratos/beers_law_lab/view/beers_law_screen.dart';
import 'package:kratos/chemistry/acid_base_solutions/screens/acid_base_solutions_home.dart';
import 'package:kratos/chemistry/molarity/audio/molarity_audio.dart';
import 'package:kratos/chemistry/molarity/view/screens/molarity_screen.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/concentration/audio/concentration_audio.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// Phase 5 — Home integration / product routing (H5-01..H5-12).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    BeersLawLabHome.debugTestAudio = RecordingConcentrationAudio();
    MolarityScreen.debugTestAudio = RecordingMolarityAudio();
  });
  tearDown(() {
    BeersLawLabHome.debugTestAudio = null;
    MolarityScreen.debugTestAudio = null;
  });

  Future<void> pumpHome(WidgetTester tester, {NavigatorObserver? observer}) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeScreen(),
        navigatorObservers: [
          ?observer,
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> enterProduct(WidgetTester tester) async {
    await tester.ensureVisible(find.text(BeersLawLabHome.title).first);
    await tester.tap(find.text(BeersLawLabHome.title).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BeersLawLabHome), findsOneWidget);
  }

  Future<void> leaveProduct(WidgetTester tester, _PopObserver observer) async {
    final before = observer.popCount;
    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back);
    } else {
      await tester.tap(find.byType(IconButton).first);
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(observer.popCount, greaterThan(before));
  }

  Future<void> switchToBeersLaw(WidgetTester tester) async {
    await tester.tap(find.descendant(
      of: find.byType(TabBar),
      matching: find.text("Beer's Law"),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
  }

  Future<void> switchToConcentration(WidgetTester tester) async {
    await tester.tap(find.descendant(
      of: find.byType(TabBar),
      matching: find.text('Concentration'),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
  }

  // H5-01 / H5-02
  testWidgets('H5-01/02 product under 化学 → 溶液与浓度 with correct title',
      (tester) async {
    await pumpHome(tester);
    expect(find.text('化学'), findsOneWidget);
    expect(find.text('溶液与浓度'), findsOneWidget);
    await tester.ensureVisible(find.text(BeersLawLabHome.title));
    expect(find.text(BeersLawLabHome.title), findsOneWidget);
    expect(find.text(BeersLawLabHome.subtitle), findsOneWidget);
    // No duplicate standalone「浓度」card
    expect(find.text(ConcentrationScreen.title), findsNothing);
  });

  // H5-03 / H5-04
  testWidgets('H5-03/04 card opens BeersLawLabHome', (tester) async {
    await pumpHome(tester);
    await enterProduct(tester);
    expect(find.byType(BeersLawLabHome), findsOneWidget);
    expect(find.byType(KratosTabbedScreen), findsOneWidget);
    expect(find.text(BeersLawLabHome.title), findsWidgets);
  });

  // H5-05 / H5-06
  testWidgets('H5-05/06 Concentration and Beers Law screens accessible',
      (tester) async {
    await pumpHome(tester);
    await enterProduct(tester);
    expect(find.byType(ConcentrationScreen), findsOneWidget);
    expect(find.byType(ConcentrationPlayArea), findsOneWidget);

    await switchToBeersLaw(tester);
    expect(find.byType(BeersLawScreen), findsOneWidget);
    expect(find.byKey(const Key('beers_law_layout_1100x700')), findsOneWidget);
  });

  // H5-07 / H5-08
  testWidgets('H5-07/08 screen switch ×10 preserves isolation', (tester) async {
    final key = GlobalKey<BeersLawLabHomeState>();
    await tester.binding.setSurfaceSize(const Size(1100, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: BeersLawLabHome(
          key: key,
          concentrationAudio: RecordingConcentrationAudio(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    final state = key.currentState!;
    final conc = state.concentrationModel;
    final bl = state.beersLawModel;
    conc.addSoluteAmount(0.35);
    conc.setVolumeDirect(0.65);
    bl.setLightOn(true);
    bl.setConcentration(0.28);

    for (var i = 0; i < 10; i++) {
      await switchToBeersLaw(tester);
      await switchToConcentration(tester);
    }

    expect(identical(state.concentrationModel, conc), isTrue);
    expect(identical(state.beersLawModel, bl), isTrue);
    expect(conc.solution.volume, closeTo(0.65, 1e-9));
    expect(conc.solution.soluteMoles, closeTo(0.35, 1e-9));
    expect(bl.light.isOn, isTrue);
    expect(bl.solution.concentration, closeTo(0.28, 1e-9));
  });

  // H5-09 / H5-10 / H5-11
  testWidgets('H5-09/10/11 back Home → reopen fresh models', (tester) async {
    final observer = _PopObserver();
    await pumpHome(tester, observer: observer);
    await enterProduct(tester);

    final homeState = tester.state<BeersLawLabHomeState>(
      find.byType(BeersLawLabHome),
    );
    final firstConc = homeState.concentrationModel;
    final firstBl = homeState.beersLawModel;
    firstConc.addSoluteAmount(0.4);
    firstBl.setLightOn(true);

    await leaveProduct(tester, observer);
    expect(find.byType(BeersLawLabHome), findsNothing);
    expect(find.text(BeersLawLabHome.title), findsWidgets);

    await enterProduct(tester);
    final homeState2 = tester.state<BeersLawLabHomeState>(
      find.byType(BeersLawLabHome),
    );
    expect(identical(homeState2.concentrationModel, firstConc), isFalse);
    expect(identical(homeState2.beersLawModel, firstBl), isFalse);
    expect(homeState2.concentrationModel.soluteMoles, 0);
    expect(homeState2.beersLawModel.light.isOn, isFalse);
  });

  // H5-12 sibling regression
  testWidgets('H5-12 sibling Molarity / AcidBase still open', (tester) async {
    final observer = _PopObserver();
    await pumpHome(tester, observer: observer);

    await tester.ensureVisible(find.text('摩尔浓度').first);
    await tester.tap(find.text('摩尔浓度').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MolarityScreen), findsOneWidget);
    await leaveProduct(tester, observer);

    await tester.ensureVisible(find.text(AcidBaseSolutionsHome.title).first);
    await tester.tap(find.text(AcidBaseSolutionsHome.title).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AcidBaseSolutionsHome), findsOneWidget);
    await leaveProduct(tester, observer);

    await enterProduct(tester);
    expect(find.byType(BeersLawLabHome), findsOneWidget);
  });

  testWidgets('H5 reopen cycle ×3 no zombie product', (tester) async {
    final observer = _PopObserver();
    await pumpHome(tester, observer: observer);
    for (var i = 0; i < 3; i++) {
      await enterProduct(tester);
      await switchToBeersLaw(tester);
      await switchToConcentration(tester);
      await leaveProduct(tester, observer);
      expect(find.byType(BeersLawLabHome), findsNothing);
    }
    expect(find.text(BeersLawLabHome.title), findsWidgets);
  });

  testWidgets('H5 Beers Law has no Concentration clock ownership leak',
      (tester) async {
    final key = GlobalKey<BeersLawLabHomeState>();
    await tester.binding.setSurfaceSize(const Size(1100, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: BeersLawLabHome(
          key: key,
          concentrationAudio: RecordingConcentrationAudio(),
        ),
      ),
    );
    await tester.pump();
    final bl = key.currentState!.beersLawModel;
    final c0 = bl.solution.concentration;
    await tester.pump(const Duration(milliseconds: 500));
    // Reactive model: idle time must not change concentration.
    expect(bl.solution.concentration, c0);
  });
}

class _PopObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
  }
}

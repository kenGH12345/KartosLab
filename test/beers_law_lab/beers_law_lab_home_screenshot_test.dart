import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/beers_law_lab/screens/beers_law_lab_home.dart';
import 'package:kratos/concentration/audio/concentration_audio.dart';
import 'package:kratos/screens/home_screen.dart';

/// Phase 5 Home screenshots — DPR 1 raster evidence.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    BeersLawLabHome.debugTestAudio = RecordingConcentrationAudio();
  });
  tearDown(() {
    BeersLawLabHome.debugTestAudio = null;
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(1280, 900),
            devicePixelRatio: 1,
            textScaler: TextScaler.linear(1),
          ),
          child: HomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
  }

  testWidgets('H5S-01 chemistry category with Beers Law Lab card',
      (tester) async {
    await pumpHome(tester);
    await tester.ensureVisible(find.text(BeersLawLabHome.title));
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home/H5S-01_chemistry_category.png'),
    );
  });

  testWidgets('H5S-02 opened product Concentration tab', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BeersLawLabHome(
          concentrationAudio: RecordingConcentrationAudio(),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 120));
    });
    await tester.pump();
    await expectLater(
      find.byType(BeersLawLabHome),
      matchesGoldenFile('goldens/home/H5S-02_opened_concentration.png'),
    );
  });

  testWidgets("H5S-03 opened product Beer's Law tab", (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BeersLawLabHome(
          concentrationAudio: RecordingConcentrationAudio(),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.descendant(
      of: find.byType(TabBar),
      matching: find.text("Beer's Law"),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    await expectLater(
      find.byType(BeersLawLabHome),
      matchesGoldenFile('goldens/home/H5S-03_opened_beers_law.png'),
    );
  });

  testWidgets('H5S-04 Home → product → back Home', (tester) async {
    final observer = _PopObserver();
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [observer],
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(1280, 900),
            devicePixelRatio: 1,
            textScaler: TextScaler.linear(1),
          ),
          child: HomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.ensureVisible(find.text(BeersLawLabHome.title).first);
    await tester.tap(find.text(BeersLawLabHome.title).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BeersLawLabHome), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(observer.popCount, greaterThan(0));
    expect(find.byType(HomeScreen), findsOneWidget);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home/H5S-04_back_home.png'),
    );
  });
}

class _PopObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
  }
}

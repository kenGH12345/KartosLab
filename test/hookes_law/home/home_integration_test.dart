import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/hookes_law/constants/hookes_law_constants.dart';
import 'package:kratos/hookes_law/model/spring.dart';
import 'package:kratos/hookes_law/screens/hookes_law_home.dart';
import 'package:kratos/hookes_law/view/hookes_law_stage.dart';
import 'package:kratos/masses_and_springs_basics/screens/masb_home.dart';
import 'package:kratos/pendulum_lab/pl_strings.dart';
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
      theme: ThemeData(fontFamily: 'Courier'),
      home: const HomeScreen(),
      navigatorObservers: [?observer],
    ),
  );
  await tester.pump();
}

Future<void> _enter(WidgetTester tester) async {
  await tester.ensureVisible(find.text(HookesLawHome.title).first);
  await tester.tap(find.text(HookesLawHome.title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(HookesLawHome), findsOneWidget);
}

Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(Tab, label));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _back(WidgetTester tester) async {
  expect(find.byType(BackButton), findsOneWidget);
  await tester.tap(find.byType(BackButton));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

HookesLawHomeState _state(WidgetTester tester) {
  return tester.state<HookesLawHomeState>(find.byType(HookesLawHome));
}

void main() {
  testWidgets('Home lists Hooke\'s Law in 力学 and keeps the neighboring cards', (tester) async {
    await _openHome(tester);
    await tester.ensureVisible(find.text('力学').first);
    expect(find.text('力学'), findsWidgets);
    await tester.ensureVisible(find.text(HookesLawHome.title).first);
    expect(find.text(HookesLawHome.title), findsOneWidget);
    expect(find.text(HookesLawHome.subtitle), findsOneWidget);
    expect(find.byIcon(Icons.swap_vert_rounded), findsOneWidget);
    await tester.ensureVisible(find.text(MasbHome.title).first);
    expect(find.text(MasbHome.title), findsOneWidget);
    await tester.ensureVisible(find.text(PlStrings.title).first);
    expect(find.text(PlStrings.title), findsOneWidget);
  });

  testWidgets('the card opens Intro inside the 1024×618 stage', (tester) async {
    await _openHome(tester);
    await _enter(tester);

    expect(find.text('Intro'), findsWidgets);
    expect(find.byKey(const Key('intro-hand-1')), findsOneWidget);
    expect(find.byType(HookesLawStage), findsNWidgets(3));
    expect(HookesLawConstants.layoutBoundsWidth, 1024);
    expect(HookesLawConstants.layoutBoundsHeight, 618);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 1024 && widget.height == 618,
      ),
      findsNWidgets(3),
    );

    final label = tester.widget<Text>(find.text('Spring Constant 1:'));
    expect(label.style?.fontFamily, 'Arial');
    expect(label.style?.fontFamily, isNot('Courier'));

    await tester.tap(find.byKey(const Key('intro-hand-1')));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Systems and Energy stay available and tab changes do not reset', (tester) async {
    await _openHome(tester);
    await _enter(tester);
    final state = _state(tester);
    state.intro.system1.spring.setAppliedForce(50);
    await tester.pump();
    expect(state.intro.system1.spring.displacement, closeTo(0.25, 1e-12));

    await _tab(tester, 'Systems');
    expect(find.byKey(const Key('systems-hand-parallel')), findsOneWidget);
    expect(state.systems.parallelSystem.equivalentSpring.appliedForce, 0);
    expect(state.intro.system1.spring.appliedForce, 50);

    state.systems.parallelSystem.topSpring.setSpringConstant(300);
    await tester.pump();

    await _tab(tester, 'Energy');
    expect(find.text('Displacement:'), findsWidgets);
    expect(state.energy.spring.displacement, 0);
    expect(state.energy.spring.springConstant, 100);
    state.energy.spring.setDisplacement(0.5);
    await tester.pump();

    await _tab(tester, 'Intro');
    expect(state.intro.system1.spring.appliedForce, 50);
    expect(state.systems.parallelSystem.topSpring.springConstant, 300);
    expect(state.energy.spring.displacement, closeTo(0.5, 1e-12));
  });

  testWidgets('Back returns Home, and reopening builds fresh defaults', (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enter(tester);

    final Spring stale = _state(tester).intro.system1.spring;
    var updates = 0;
    stale.appliedForceProperty.addListener((_) => updates++);
    stale.setAppliedForce(40);
    expect(updates, 1);
    expect(stale.appliedForce, 40);

    await _back(tester);
    expect(observer.popCount, 1);
    expect(find.byType(HookesLawHome), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);

    final before = updates;
    stale.setAppliedForce(15);
    expect(updates, before + 1);
    expect(tester.takeException(), isNull);

    await _enter(tester);
    final again = _state(tester);
    expect(identical(again.intro.system1.spring, stale), isFalse);
    expect(again.intro.system1.spring.appliedForce, 0);
    expect(again.intro.system1.spring.springConstant, 200);
    expect(again.systems.parallelSystem.topSpring.springConstant, 200);
    expect(again.energy.spring.displacement, 0);
    expect(again.energy.spring.springConstant, 100);
    expect(find.byKey(const Key('intro-hand-1')), findsOneWidget);
  });

  testWidgets('open and close twice does not throw or leave the route up', (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    for (var i = 0; i < 2; i++) {
      await _enter(tester);
      await _tab(tester, 'Energy');
      await _back(tester);
      expect(find.byType(HookesLawHome), findsNothing);
    }
    expect(observer.popCount, 2);
    expect(find.text(PlStrings.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

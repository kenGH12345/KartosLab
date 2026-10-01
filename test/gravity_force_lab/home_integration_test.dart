import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/gfl_strings.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/screens/gravity_force_lab_screen.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';
import 'package:kratos/gravity_force_lab_basics/gflb_strings.dart';
import 'package:kratos/gravity_force_lab_basics/screens/gflb_home.dart';
import 'package:kratos/screens/home_screen.dart';

Future<void> _openHome(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
  await tester.pump();
}

Future<void> _enterFull(WidgetTester tester) async {
  await tester.ensureVisible(find.text(GravityForceLabScreen.title).first);
  await tester.tap(find.text(GravityForceLabScreen.title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(GravityForceLabScreen), findsOneWidget);
}

void main() {
  testWidgets('Home card exists with Full title/subtitle/icon', (tester) async {
    await _openHome(tester);
    await tester.ensureVisible(find.text('力学').first);
    expect(find.text('力学'), findsWidgets);

    await tester.ensureVisible(find.text(GravityForceLabScreen.title).first);
    expect(find.text(GravityForceLabScreen.title), findsOneWidget);
    expect(find.text(GflStrings.subtitle), findsOneWidget);
    expect(find.byIcon(GravityForceLabScreen.homeIcon), findsOneWidget);
  });

  testWidgets('Full card is in 力学 next to Basics', (tester) async {
    await _openHome(tester);
    await tester.ensureVisible(find.text(GflbHome.title).first);
    expect(find.text(GflbStrings.title), findsOneWidget);
    await tester.ensureVisible(find.text(GravityForceLabScreen.title).first);
    expect(find.text(GravityForceLabScreen.title), findsOneWidget);
    // Distinct titles — no merge of Full/Basics cards.
    expect(GravityForceLabScreen.title, isNot(GflbHome.title));
  });

  testWidgets('Home route opens GravityForceLabScreen (not GflbHome)',
      (tester) async {
    await _openHome(tester);
    await _enterFull(tester);

    expect(find.byType(GravityForceLabScreen), findsOneWidget);
    expect(find.byType(GflScreenBody), findsOneWidget);
    expect(find.byType(GflbHome), findsNothing);
    expect(find.text(GflStrings.forceValues), findsOneWidget);
    expect(find.text(GflStrings.decimalNotation), findsOneWidget);
    expect(find.text('billion kg'), findsNothing);
    expect(find.text('Distance'), findsNothing);
  });

  testWidgets('Full default state on entry matches source defaults',
      (tester) async {
    await _openHome(tester);
    await _enterFull(tester);

    final state =
        tester.state<GravityForceLabScreenState>(find.byType(GravityForceLabScreen));
    final m = state.model;
    expect(m.mass1.value, GravityForceConstants.initialMass1);
    expect(m.mass2.value, GravityForceConstants.initialMass2);
    expect(m.mass1.positionX, GravityForceConstants.initialPosition1);
    expect(m.mass2.positionX, GravityForceConstants.initialPosition2);
    expect(m.distance, closeTo(4.0, 1e-12));
    expect(m.forceMagnitude, closeTo(1.66852e-7, 1e-15));
    expect(m.constantRadius, GravityForceConstants.defaultConstantRadius);
    expect(m.showForceValues, isTrue);
    expect(m.ruler.positionX, GravityForceConstants.rulerInitialX);
    expect(m.ruler.positionY, GravityForceConstants.rulerInitialY);
  });
}

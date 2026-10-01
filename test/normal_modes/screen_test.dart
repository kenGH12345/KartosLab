import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/normal_modes/controller/one_dimension_controller.dart';
import 'package:kratos/normal_modes/model/amplitude_direction.dart';
import 'package:kratos/normal_modes/normal_modes_constants.dart';
import 'package:kratos/normal_modes/normal_modes_strings.dart';
import 'package:kratos/normal_modes/screens/one_dimension_screen.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  testWidgets('Home lists Normal Modes card', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.ensureVisible(find.text(NormalModesStrings.title));
    expect(find.text(NormalModesStrings.title), findsOneWidget);
  });

  testWidgets('enter Normal Modes, switch tab, back, reopen', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.ensureVisible(find.text(NormalModesStrings.title).first);
    await tester.tap(find.text(NormalModesStrings.title).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(NormalModesStrings.oneDimension), findsWidgets);
    await tester.tap(find.text(NormalModesStrings.twoDimensions));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(NormalModesStrings.normalModeAmplitudes), findsWidgets);
    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(NormalModesStrings.title), findsWidgets);
    await tester.tap(find.text(NormalModesStrings.title).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(NormalModesStrings.oneDimension), findsWidgets);
  });

  testWidgets('1D controls: springs, phases, reset, zero, initial', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    final c = OneDimensionController();
    await tester.pumpWidget(
      MaterialApp(home: OneDimensionScreen(controller: c, embedded: true)),
    );
    await tester.pump();
    expect(find.text(NormalModesStrings.showSprings), findsWidgets);
    expect(find.text(NormalModesStrings.showPhases), findsWidgets);
    expect(find.text(NormalModesStrings.amplitude), findsWidgets);
    expect(find.byKey(const ValueKey('freq-label-0')), findsWidgets);
    c.setModeAmplitude(0, 0.08);
    await tester.pump();
    expect(c.model.masses[1].displacement.y, isNot(0));
    await tester.tap(find.text(NormalModesStrings.zeroPositions));
    await tester.pump();
    expect(c.model.modeAmplitudes[0], 0);
    expect(c.model.playing, isTrue);
    c.setModeAmplitude(0, 0.05);
    await tester.tap(find.text(NormalModesStrings.initialPositions));
    await tester.pump();
    expect(c.model.playing, isFalse);
    expect(c.model.time, 0);
    c.reset();
    await tester.pump();
    expect(c.model.numberOfMasses, 3);
    expect(c.model.playing, isTrue);
  });

  testWidgets('spectrum collapse keeps frequency labels in tree', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    final c = OneDimensionController();
    await tester.pumpWidget(
      MaterialApp(home: OneDimensionScreen(controller: c, embedded: true)),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('freq-label-0')), findsOneWidget);
    c.setSpectrumExpanded(false);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('freq-label-0'), skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('amplitude direction radio changes model', (tester) async {
    final c = OneDimensionController();
    expect(c.model.amplitudeDirection, AmplitudeDirection.vertical);
    c.setAmplitudeDirection(AmplitudeDirection.horizontal);
    expect(c.model.amplitudeDirection, AmplitudeDirection.horizontal);
  });

  test('step while paused advances one FIXED_DT', () {
    final c = OneDimensionController();
    c.model.playing = false;
    c.model.modeAmplitudes[0] = 0.05;
    final t0 = c.model.time;
    c.stepOnce();
    expect(c.model.time, closeTo(t0 + NormalModesConstants.fixedDt, 1e-12));
  });
}

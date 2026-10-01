import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/normal_modes/controller/one_dimension_controller.dart';
import 'package:kratos/normal_modes/controller/two_dimensions_controller.dart';
import 'package:kratos/normal_modes/screens/one_dimension_screen.dart';
import 'package:kratos/normal_modes/screens/two_dimensions_screen.dart';
import 'package:kratos/normal_modes/widgets/nm_page_shell.dart';
import 'package:kratos/normal_modes/widgets/nm_control_panel.dart';
import 'package:kratos/normal_modes/widgets/spectrum_accordion.dart';
import 'package:kratos/normal_modes/widgets/amplitudes_accordion.dart';
import 'package:kratos/normal_modes/widgets/one_dimension_play_area.dart';
import 'package:kratos/normal_modes/widgets/two_dimensions_play_area.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('NmPageMetrics 1D reserves bottom + right without negative viewport', () {
    final m = NmPageMetrics.oneDimension(
      const BoxConstraints.tightFor(width: 1200, height: 800),
    );
    expect(m.rightPanelWidth, greaterThan(0));
    expect(m.bottomPanelHeight, greaterThan(0));
    expect(m.simViewportWidth + m.rightPanelWidth, closeTo(1200, 0.5));
    expect(m.simViewportHeight + m.bottomPanelHeight, closeTo(800, 0.5));
  });

  test('NmPageMetrics 2D has zero bottom and exclusive right column', () {
    final m = NmPageMetrics.twoDimensions(
      const BoxConstraints.tightFor(width: 1200, height: 800),
    );
    expect(m.bottomPanelHeight, 0);
    expect(m.rightPanelWidth, inInclusiveRange(300, 380));
    expect(m.simViewportWidth + m.rightPanelWidth, closeTo(1200, 0.5));
  });

  testWidgets('1D: spectrum and control are siblings, not stacked over play',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final c = OneDimensionController()..model.playing = false;
    await tester.pumpWidget(
      MaterialApp(home: OneDimensionScreen(controller: c, embedded: true)),
    );
    await tester.pump();

    expect(find.byType(OneDimensionPlayArea), findsOneWidget);
    expect(find.byType(NmControlPanel), findsOneWidget);
    expect(find.byType(SpectrumAccordion), findsOneWidget);
    expect(find.byType(SimulationViewport), findsOneWidget);
    expect(find.byType(ControlColumn), findsOneWidget);

    final playBox = tester.getRect(find.byType(SimulationViewport));
    final controlBox = tester.getRect(find.byType(ControlColumn));
    final spectrumBox = tester.getRect(find.byType(SpectrumAccordion));

    expect(controlBox.left, greaterThanOrEqualTo(playBox.right - 1));
    expect(spectrumBox.top, greaterThanOrEqualTo(playBox.bottom - 1));
    expect(spectrumBox.right, lessThanOrEqualTo(controlBox.left + 1));
    expect(playBox.overlaps(controlBox), isFalse);
    expect(spectrumBox.overlaps(controlBox), isFalse);
  });

  testWidgets('2D: amplitudes stay in right column, do not overlap sim',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final c = TwoDimensionsController()..model.playing = false;
    await tester.pumpWidget(
      MaterialApp(home: TwoDimensionsScreen(controller: c, embedded: true)),
    );
    await tester.pump();

    expect(find.byType(TwoDimensionsPlayArea), findsOneWidget);
    expect(find.byType(AmplitudesAccordion), findsOneWidget);
    expect(find.byType(NmControlPanel), findsOneWidget);

    final playBox = tester.getRect(find.byType(SimulationViewport));
    final controlBox = tester.getRect(find.byType(ControlColumn));
    final ampBox = tester.getRect(find.byType(AmplitudesAccordion));

    expect(controlBox.left, greaterThanOrEqualTo(playBox.right - 1));
    expect(playBox.overlaps(controlBox), isFalse);
    expect(ampBox.left, greaterThanOrEqualTo(playBox.right - 1));
    expect(playBox.overlaps(ampBox), isFalse);
  });

  testWidgets('capture flutter-one-dimension / flutter-two-dimensions png',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final outDir =
        Directory('requirements/req-normal-modes/visual-qa/screenshots');
    outDir.createSync(recursive: true);

    Future<void> capture(Widget screen, String name) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(key: key, child: screen),
          ),
        ),
      );
      // One frame only — do not pumpAndSettle (Ticker never quiets).
      await tester.pump();
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1.0);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('${outDir.path}/$name.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    final one = OneDimensionController()
      ..model.playing = false
      ..setModeAmplitude(0, 0.08);
    await capture(
      OneDimensionScreen(controller: one, embedded: true),
      'flutter-one-dimension',
    );

    final two = TwoDimensionsController()
      ..model.playing = false
      ..toggleAmplitudeCell(0, 0);
    await capture(
      TwoDimensionsScreen(controller: two, embedded: true),
      'flutter-two-dimensions',
    );

    expect(
      File('${outDir.path}/flutter-one-dimension.png').existsSync(),
      isTrue,
    );
    expect(
      File('${outDir.path}/flutter-two-dimensions.png').existsSync(),
      isTrue,
    );
  });
}

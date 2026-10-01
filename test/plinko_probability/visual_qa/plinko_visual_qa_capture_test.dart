import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/plinko_probability/controller/intro_controller.dart';
import 'package:kratos/plinko_probability/controller/lab_controller.dart';
import 'package:kratos/plinko_probability/model/plinko_common_model.dart';
import 'package:kratos/plinko_probability/model/plinko_random.dart';
import 'package:kratos/plinko_probability/painters/peg_raster.dart';
import 'package:kratos/plinko_probability/screens/intro_screen.dart';
import 'package:kratos/plinko_probability/screens/lab_screen.dart';
import 'package:kratos/plinko_probability/transform/plinko_mvt.dart';

/// Flutter Visual QA matrix (pairs with ORIGINAL).
///
/// ORIGINAL 1280×800 includes PhET navbar (~63px → content 737).
/// ScreenView.DEFAULT_LAYOUT_BOUNDS = **1024×618**; capture fills the content
/// band so [PlinkoMvt.fromCanvasSize] matches PhET `min(w/1024,h/618)` scale.
/// Uses [WidgetTester.runAsync] so `toImage` does not hang FakeAsync.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final arial = FontLoader('Arial')
      ..addFont(File(r'C:\Windows\Fonts\arial.ttf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)));
    await arial.load();
    await PegRaster.ensureLoaded();
  });

  const outDir = 'requirements/req-plinko-probability/visual-qa/FLUTTER';
  const viewport = Size(1280, 800);
  // Match ORIGINAL content band above navbar (detected y=737 @ 1280×800).
  const contentH = 737.0;
  const contentW = 1280.0;

  Future<void> settle(WidgetTester tester, [int n = 8]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> capture(
    WidgetTester tester,
    String name,
    Widget child,
    List<String> actions,
  ) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          fontFamily: 'Arial',
          useMaterial3: false,
          textTheme: ThemeData(fontFamily: 'Arial').textTheme.apply(
                fontFamily: 'Arial',
                bodyColor: Colors.black,
                displayColor: Colors.black,
              ),
        ),
        home: Scaffold(
          backgroundColor: Colors.black,
          body: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: viewport.width,
              height: viewport.height,
              child: ColoredBox(
                color: Colors.black,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      width: contentW,
                      height: contentH,
                      child: ClipRect(child: child),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester, 15);

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bd = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = bd!.buffer.asUint8List();
      Directory(outDir).createSync(recursive: true);
      File('$outDir/$name.png').writeAsBytesSync(bytes);
      final mvt = PlinkoMvt.fromCanvasSize(const Size(contentW, contentH));
      File('$outDir/$name.meta.txt').writeAsStringSync([
        'state: $name',
        'viewport: 1280x800',
        'content: ${contentW.toInt()}x${contentH.toInt()}',
        'layout: ${PlinkoMvt.layoutWidth}x${PlinkoMvt.layoutHeight}',
        'mvt: scale=${mvt.layoutScale.toStringAsFixed(4)} '
            'origin=(${mvt.layoutOriginX.toStringAsFixed(1)},'
            '${mvt.layoutOriginY.toStringAsFixed(1)})',
        'DPR: 1',
        'actions: ${actions.join(',')}',
        'source: local-flutter-widget-test',
        'captured_at: ${DateTime.now().toUtc().toIso8601String()}',
      ].join('\n'));
      // ignore: avoid_print
      print('CAPTURED $name ${bytes.length}');
    });
  }

  void step(dynamic c, int frames) {
    for (var i = 0; i < frames; i++) {
      c.model.step(1 / 60);
    }
  }

  testWidgets('matrix Intro+Lab', (tester) async {
    // Intro
    {
      final c = IntroController(random: PlinkoRandom(1));
      addTearDown(c.dispose);
      await capture(tester, '01_Intro_initial', IntroScreen(controller: c),
          ['open_intro']);
    }
    {
      final c = IntroController(random: PlinkoRandom(2));
      addTearDown(c.dispose);
      c.setBallMode(BallMode.oneBall);
      c.play();
      step(c, 400);
      await capture(tester, '02_Intro_oneBall', IntroScreen(controller: c),
          ['play_x1']);
    }
    {
      final c = IntroController(random: PlinkoRandom(3));
      addTearDown(c.dispose);
      c.setBallMode(BallMode.tenBalls);
      c.play();
      for (var i = 0; i < 10; i++) {
        c.model.ballCreationTimeElapsed = 1;
        c.model.step(0.05);
      }
      step(c, 400);
      await capture(tester, '03_Intro_tenBalls', IntroScreen(controller: c),
          ['x10']);
    }
    {
      final c = IntroController(random: PlinkoRandom(4));
      addTearDown(c.dispose);
      c.setBallMode(BallMode.maxBalls);
      c.play();
      for (var i = 0; i < 40; i++) {
        c.model.ballCreationTimeElapsed = 1;
        c.model.step(0.05);
      }
      step(c, 150);
      await capture(tester, '04_Intro_hundredBalls', IntroScreen(controller: c),
          ['x100_partial']);
    }
    {
      final c = IntroController(random: PlinkoRandom(5));
      addTearDown(c.dispose);
      c.setBallMode(BallMode.tenBalls);
      c.play();
      for (var i = 0; i < 10; i++) {
        c.model.ballCreationTimeElapsed = 1;
        c.model.step(0.05);
      }
      step(c, 400);
      c.setHistogramMode(HistogramDisplayMode.counter);
      await capture(tester, '05_Intro_counterMode', IntroScreen(controller: c),
          ['counter']);
      c.setHistogramMode(HistogramDisplayMode.cylinder);
      await capture(tester, '06_Intro_cylinderMode', IntroScreen(controller: c),
          ['cylinder']);
    }
    {
      final c = IntroController(random: PlinkoRandom(6));
      addTearDown(c.dispose);
      c.play();
      c.model.ballCreationTimeElapsed = 1;
      c.model.step(0.2);
      step(c, 80);
      c.erase();
      await capture(
          tester, '07_Intro_erase', IntroScreen(controller: c), ['erase']);
    }
    {
      final c = IntroController(random: PlinkoRandom(7));
      addTearDown(c.dispose);
      c.setBallMode(BallMode.tenBalls);
      c.play();
      c.resetAll();
      await capture(
          tester, '08_Intro_reset', IntroScreen(controller: c), ['reset']);
    }

    // Lab
    {
      final c = LabController(random: PlinkoRandom(10));
      addTearDown(c.dispose);
      await capture(
          tester, '01_Lab_initial', LabScreen(controller: c), ['open_lab']);
      c.setNumberOfRows(3);
      await capture(
          tester, '02_Lab_rows_low', LabScreen(controller: c), ['rows_3']);
      c.setNumberOfRows(22);
      await capture(
          tester, '03_Lab_rows_high', LabScreen(controller: c), ['rows_22']);
      c.setNumberOfRows(12);
      c.setProbability(0.1);
      await capture(
          tester, '04_Lab_p_low', LabScreen(controller: c), ['p_0.1']);
      c.setProbability(0.9);
      await capture(
          tester, '05_Lab_p_high', LabScreen(controller: c), ['p_0.9']);
      c.setProbability(0.5);
    }
    {
      final c = LabController(random: PlinkoRandom(15));
      addTearDown(c.dispose);
      c.setBallMode(BallMode.oneBall);
      c.playPressed();
      step(c, 350);
      await capture(
          tester, '06_Lab_one_mode', LabScreen(controller: c), ['one']);
    }
    {
      final c = LabController(random: PlinkoRandom(16));
      addTearDown(c.dispose);
      c.setBallMode(BallMode.continuous);
      c.playPressed();
      step(c, 160);
      c.pausePressed();
      await capture(tester, '07_Lab_continuous_mode', LabScreen(controller: c),
          ['continuous']);
    }
    {
      final c = LabController(random: PlinkoRandom(17));
      addTearDown(c.dispose);
      c.setHopperMode(HopperMode.ball);
      c.playPressed();
      step(c, 280);
      await capture(
          tester, '08_Lab_ball_mode', LabScreen(controller: c), ['ball']);
    }
    {
      final c = LabController(random: PlinkoRandom(18));
      addTearDown(c.dispose);
      c.setHopperMode(HopperMode.path);
      for (var i = 0; i < 6; i++) {
        c.playPressed();
        c.model.step(0.02);
      }
      await capture(
          tester, '09_Lab_path_mode', LabScreen(controller: c), ['path']);
    }
    {
      final c = LabController(random: PlinkoRandom(19));
      addTearDown(c.dispose);
      c.setHopperMode(HopperMode.none);
      c.setBallMode(BallMode.continuous);
      c.playPressed();
      step(c, 100);
      c.pausePressed();
      await capture(
          tester, '10_Lab_none_mode', LabScreen(controller: c), ['none']);
    }
    {
      final c = LabController(random: PlinkoRandom(20));
      addTearDown(c.dispose);
      c.setHopperMode(HopperMode.none);
      c.setBallMode(BallMode.continuous);
      c.playPressed();
      step(c, 350);
      c.pausePressed();
      await capture(tester, '11_Lab_statistics', LabScreen(controller: c),
          ['stats']);
      c.setIdealVisible(true);
      await capture(tester, '12_Lab_ideal_distribution',
          LabScreen(controller: c), ['ideal']);
    }
    {
      final c = LabController(random: PlinkoRandom(21));
      addTearDown(c.dispose);
      c.setNumberOfRows(20);
      c.setProbability(0.2);
      c.resetAll();
      await capture(
          tester, '13_Lab_reset', LabScreen(controller: c), ['reset']);
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}

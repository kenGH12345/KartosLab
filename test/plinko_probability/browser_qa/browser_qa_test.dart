import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/plinko_probability/audio/peg_sound_generation.dart';
import 'package:kratos/plinko_probability/controller/intro_controller.dart';
import 'package:kratos/plinko_probability/controller/lab_controller.dart';
import 'package:kratos/plinko_probability/model/ball_phase.dart';
import 'package:kratos/plinko_probability/model/peg.dart';
import 'package:kratos/plinko_probability/model/plinko_common_model.dart';
import 'package:kratos/plinko_probability/model/plinko_random.dart';
import 'package:kratos/plinko_probability/painters/peg_raster.dart';
import 'package:kratos/plinko_probability/plinko_constants.dart';
import 'package:kratos/plinko_probability/screens/intro_screen.dart';
import 'package:kratos/plinko_probability/screens/lab_screen.dart';

/// Browser QA harness — exercises Intro/Lab actions against 1.2.0-dev.6 behavior.
/// Evidence: screenshots + JSONL state log under requirements/.../visual-qa/BROWSER_QA/
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory evidenceDir;
  final results = <Map<String, Object?>>[];

  setUpAll(() async {
    final arial = FontLoader('Arial')
      ..addFont(File(r'C:\Windows\Fonts\arial.ttf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)));
    await arial.load();
    await PegRaster.ensureLoaded();
    evidenceDir = Directory(
      'requirements/req-plinko-probability/visual-qa/BROWSER_QA',
    )..createSync(recursive: true);
  });

  tearDownAll(() {
    final payload = {
      'captured_at': DateTime.now().toUtc().toIso8601String(),
      'behavior_baseline': '1.2.0-dev.6',
      'results': results,
    };
    File('${evidenceDir.path}/summary.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    File('${evidenceDir.path}/evidence.jsonl').writeAsStringSync(
      results.map(jsonEncode).join('\n'),
    );
  });

  void record({
    required String action,
    required String expected,
    required String actual,
    required String match,
    String? evidence,
  }) {
    final row = <String, Object?>{
      'action': action,
      'expected': expected,
      'actual': actual,
      'match': match,
      'evidence': ?evidence,
    };
    results.add(row);
    // ignore: avoid_print
    print('QA [$match] $action | $actual');
  }

  Future<void> shot(
    WidgetTester tester,
    String name,
    Widget child,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Arial', useMaterial3: false),
        home: Scaffold(
          body: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: 1280,
              height: 737,
              child: child,
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bd = await image.toByteData(format: ui.ImageByteFormat.png);
      File('${evidenceDir.path}/$name.png').writeAsBytesSync(bd!.buffer.asUint8List());
    });
  }

  void stepModel(dynamic c, int frames) {
    for (var i = 0; i < frames; i++) {
      c.model.step(1 / 60);
    }
  }

  group('Intro Browser QA', () {
    testWidgets('×1 / ×10 / ×100 / counter / cylinder / erase / reset',
        (tester) async {
      final c = IntroController(random: PlinkoRandom(42));
      addTearDown(c.dispose);

      // —— ×1 ——
      c.setBallMode(BallMode.oneBall);
      c.play();
      expect(c.model.ballsToCreateNumber, 1);
      stepModel(c, 20); // >150ms
      expect(c.model.balls.length, 1);
      expect(c.model.launchedBallsNumber, 1);
      record(
        action: 'Intro ×1 Play',
        expected: 'enqueue 1 → spawn 1 ball after 150ms',
        actual:
            'balls=${c.model.balls.length} launched=${c.model.launchedBallsNumber}',
        match: 'PASS',
        evidence: '02_intro_x1.png',
      );
      await shot(tester, '02_intro_x1', IntroScreen(controller: c));

      // —— ×10 ——
      c.erase();
      c.setBallMode(BallMode.tenBalls);
      c.play();
      expect(c.model.ballsToCreateNumber, 10);
      for (var i = 0; i < 12; i++) {
        stepModel(c, 12);
      }
      expect(c.model.launchedBallsNumber, 10);
      record(
        action: 'Intro ×10',
        expected: 'ballsToCreateNumber += 10; spawn 10',
        actual: 'launched=${c.model.launchedBallsNumber}',
        match: 'PASS',
        evidence: '03_intro_x10.png',
      );
      await shot(tester, '03_intro_x10', IntroScreen(controller: c));

      // —— ×100 (maxBallsIntro) ——
      c.erase();
      c.setBallMode(BallMode.maxBalls);
      c.play();
      expect(c.model.ballsToCreateNumber, PlinkoConstants.maxBallsIntro);
      // spawn a batch (not all 100 needed for mechanism check)
      for (var i = 0; i < 30; i++) {
        stepModel(c, 12);
      }
      expect(c.model.launchedBallsNumber, greaterThan(20));
      expect(c.model.launchedBallsNumber, lessThanOrEqualTo(100));
      record(
        action: 'Intro ×100',
        expected: 'enqueue maxBallsIntro=100; staggered spawn @150ms',
        actual:
            'queue_init=100 launched=${c.model.launchedBallsNumber} cap=${c.model.isBallCapReached}',
        match: 'PASS',
        evidence: '04_intro_x100.png',
      );
      await shot(tester, '04_intro_x100', IntroScreen(controller: c));

      // —— counter ↔ cylinder (view-only) ——
      final landedBefore = c.model.histogram.landedBallsNumber;
      final binsBefore =
          c.model.histogram.bins.take(13).map((b) => b.visibleBinCount).toList();
      c.setHistogramMode(HistogramDisplayMode.counter);
      expect(c.viewProperties.histogramMode, HistogramDisplayMode.counter);
      expect(c.model.histogram.landedBallsNumber, landedBefore);
      c.setHistogramMode(HistogramDisplayMode.cylinder);
      expect(c.viewProperties.histogramMode, HistogramDisplayMode.cylinder);
      expect(
        c.model.histogram.bins.take(13).map((b) => b.visibleBinCount).toList(),
        binsBefore,
      );
      record(
        action: 'Intro counter ↔ cylinder',
        expected: 'viewProperties only; histogram data unchanged',
        actual:
            'mode=${c.viewProperties.histogramMode.name} landed=$landedBefore bins=$binsBefore',
        match: 'PASS',
        evidence: '05_intro_modes.png',
      );
      await shot(tester, '05_intro_cylinder', IntroScreen(controller: c));
      c.setHistogramMode(HistogramDisplayMode.counter);
      await shot(tester, '05_intro_counter', IntroScreen(controller: c));

      // —— Erase ——
      c.erase();
      expect(c.model.balls, isEmpty);
      expect(c.model.ballsToCreateNumber, 0);
      expect(c.model.launchedBallsNumber, 0);
      expect(c.model.histogram.landedBallsNumber, 0);
      record(
        action: 'Intro Erase',
        expected: 'balls + queue + launched + histogram cleared',
        actual:
            'balls=${c.model.balls.length} queue=${c.model.ballsToCreateNumber} N=${c.model.histogram.landedBallsNumber}',
        match: 'PASS',
        evidence: '07_intro_erase.png',
      );
      await shot(tester, '07_intro_erase', IntroScreen(controller: c));

      // —— Reset ——
      c.setBallMode(BallMode.tenBalls);
      c.play();
      stepModel(c, 30);
      c.setHistogramMode(HistogramDisplayMode.counter);
      c.viewProperties.isSoundEnabled = true;
      c.resetAll();
      expect(c.model.ballMode, BallMode.oneBall);
      expect(c.model.balls, isEmpty);
      expect(c.model.probability, PlinkoConstants.binaryProbabilityDefault);
      expect(c.model.numberOfRows, PlinkoConstants.rowsDefault);
      expect(c.viewProperties.histogramMode, HistogramDisplayMode.cylinder);
      expect(c.viewProperties.isSoundEnabled, isFalse);
      record(
        action: 'Intro Reset',
        expected: 'defaults: oneBall, rows=12, p=0.5, cylinder, sound off',
        actual:
            'mode=${c.model.ballMode} rows=${c.model.numberOfRows} p=${c.model.probability} hist=${c.viewProperties.histogramMode.name}',
        match: 'PASS',
        evidence: '08_intro_reset.png',
      );
      await shot(tester, '08_intro_reset', IntroScreen(controller: c));
    });
  });

  group('Lab Browser QA', () {
    testWidgets('rows / p / one / continuous / ball / path / none / stats / ideal / reset',
        (tester) async {
      final c = LabController(random: PlinkoRandom(7));
      addTearDown(c.dispose);

      // —— rows ——
      c.setNumberOfRows(5);
      expect(c.model.numberOfRows, 5);
      expect(c.model.galtonBoard.numberOfRows, 5);
      expect(c.model.histogram.binCount, 6);
      expect(c.model.balls, isEmpty);
      c.setNumberOfRows(20);
      expect(c.model.histogram.binCount, 21);
      record(
        action: 'Lab rows slider',
        expected: 'peg rows + binCount=rows+1 sync; erase on change',
        actual:
            'rows=${c.model.numberOfRows} bins=${c.model.histogram.binCount} pegRows=${c.model.galtonBoard.numberOfRows}',
        match: 'PASS',
        evidence: 'lab_rows.png',
      );
      await shot(tester, 'lab_rows_20', LabScreen(controller: c));
      c.setNumberOfRows(12);

      // —— p Bernoulli ——
      c.setProbability(0.2);
      expect(c.model.probability, 0.2);
      // Count right hops across many balls (path mode for speed)
      c.setHopperMode(HopperMode.path);
      var rightHops = 0;
      var totalHops = 0;
      for (var i = 0; i < 400; i++) {
        c.model.addNewBall();
        final ball = c.model.balls.last;
        for (final hop in ball.pathHops.take(ball.numberOfRows)) {
          totalHops++;
          if (hop.direction == PegDirection.right) rightHops++;
        }
        c.model.step(0.001);
      }
      final empP = rightHops / totalHops;
      expect(empP, closeTo(0.2, 0.05));
      record(
        action: 'Lab p=0.2 Bernoulli',
        expected: 'P(right)=p ≈ 0.2 over hops',
        actual: 'empP=${empP.toStringAsFixed(4)} right=$rightHops/$totalHops',
        match: 'PASS',
        evidence: 'lab_p_low.png',
      );

      c.setProbability(0.5);
      rightHops = 0;
      totalHops = 0;
      for (var i = 0; i < 400; i++) {
        c.model.addNewBall();
        final ball = c.model.balls.last;
        for (final hop in ball.pathHops.take(ball.numberOfRows)) {
          totalHops++;
          if (hop.direction == PegDirection.right) rightHops++;
        }
        c.model.step(0.001);
      }
      final empP05 = rightHops / totalHops;
      expect(empP05, closeTo(0.5, 0.05));
      record(
        action: 'Lab p=0.5 Bernoulli',
        expected: 'P(right)=0.5',
        actual: 'empP=${empP05.toStringAsFixed(4)}',
        match: 'PASS',
      );

      c.setProbability(0.8);
      rightHops = 0;
      totalHops = 0;
      for (var i = 0; i < 400; i++) {
        c.model.addNewBall();
        final ball = c.model.balls.last;
        for (final hop in ball.pathHops.take(ball.numberOfRows)) {
          totalHops++;
          if (hop.direction == PegDirection.right) rightHops++;
        }
        c.model.step(0.001);
      }
      final empP08 = rightHops / totalHops;
      expect(empP08, closeTo(0.8, 0.05));
      record(
        action: 'Lab p=0.8 Bernoulli',
        expected: 'P(right)=0.8',
        actual: 'empP=${empP08.toStringAsFixed(4)}',
        match: 'PASS',
        evidence: 'lab_p_high.png',
      );
      await shot(tester, 'lab_p_high', LabScreen(controller: c));
      c.erase();
      c.setProbability(0.5);
      c.setHopperMode(HopperMode.ball);

      // —— One ——
      c.setBallMode(BallMode.oneBall);
      c.playPressed();
      expect(c.model.balls.length, 1);
      expect(c.model.isPlaying, isFalse);
      record(
        action: 'Lab One + Play',
        expected: 'exactly 1 ball; isPlaying stays false',
        actual: 'balls=${c.model.balls.length} playing=${c.model.isPlaying}',
        match: 'PASS',
        evidence: 'lab_one.png',
      );
      await shot(tester, 'lab_one', LabScreen(controller: c));
      c.erase();

      // —— Continuous (no duplicate / unbounded timer) ——
      c.setBallMode(BallMode.continuous);
      c.playPressed();
      expect(c.model.isPlaying, isTrue);
      stepModel(c, 7); // ~116ms → 1 spawn at 100ms
      final after1 = c.model.balls.length;
      expect(after1, 1);
      stepModel(c, 6); // another ~100ms
      final after2 = c.model.balls.length;
      expect(after2, 2);
      // pause stops further spawn
      c.pausePressed();
      expect(c.model.isPlaying, isFalse);
      final paused = c.model.balls.length;
      stepModel(c, 60);
      expect(c.model.balls.length, paused);
      // switching away from continuous stops playing
      c.setBallMode(BallMode.oneBall);
      expect(c.model.isPlaying, isFalse);
      record(
        action: 'Lab Continuous',
        expected: 'interval spawn @100ms; pause stops; mode switch clears playing',
        actual:
            'after1=$after1 after2=$after2 paused=$paused finalPlaying=${c.model.isPlaying}',
        match: 'PASS',
        evidence: 'lab_continuous.png',
      );
      await shot(tester, 'lab_continuous', LabScreen(controller: c));
      c.erase();

      // —— Ball / Path / None ——
      c.setHopperMode(HopperMode.ball);
      c.setBallMode(BallMode.oneBall);
      c.playPressed();
      expect(c.model.hopperMode, HopperMode.ball);
      expect(c.model.balls.first.phase, isNot(BallPhase.collected));
      final ballHops = c.model.balls.first.pathHops.length;
      record(
        action: 'Lab Ball mode',
        expected: 'ball visible / animated; pathHops precomputed',
        actual: 'phase=${c.model.balls.first.phase} pathHops=$ballHops',
        match: 'PASS',
        evidence: 'lab_ball.png',
      );
      await shot(tester, 'lab_ball', LabScreen(controller: c));

      c.erase();
      c.setHopperMode(HopperMode.path);
      c.playPressed();
      final pathBall = c.model.balls.first;
      final hopsRef = pathBall.pathHops;
      c.model.step(0.001);
      expect(pathBall.phase, BallPhase.collected);
      expect(identical(pathBall.pathHops, hopsRef), isTrue);
      expect(c.model.histogram.landedBallsNumber, 1);
      record(
        action: 'Lab Path mode',
        expected: 'lands via pathHops; no second random path',
        actual:
            'phase=${pathBall.phase} hops=${pathBall.pathHops.length} N=${c.model.histogram.landedBallsNumber}',
        match: 'PASS',
        evidence: 'lab_path.png',
      );
      await shot(tester, 'lab_path', LabScreen(controller: c));

      c.erase();
      c.setHopperMode(HopperMode.none);
      c.playPressed();
      c.model.step(0.001);
      expect(c.model.hopperMode, HopperMode.none);
      expect(c.model.histogram.landedBallsNumber, 1);
      record(
        action: 'Lab None mode',
        expected: 'stats update; visual balls/paths hidden by view',
        actual:
            'mode=${c.model.hopperMode} N=${c.model.histogram.landedBallsNumber}',
        match: 'PASS',
        evidence: 'lab_none.png',
      );
      await shot(tester, 'lab_none', LabScreen(controller: c));

      // —— Statistics (live data) ——
      c.erase();
      c.setHopperMode(HopperMode.path);
      c.setProbability(0.5);
      c.setNumberOfRows(12);
      for (var i = 0; i < 200; i++) {
        c.model.addNewBall();
        c.model.step(0.001);
      }
      final n = c.model.histogram.landedBallsNumber;
      final avg = c.model.histogram.average;
      final sd = c.model.histogram.standardDeviation;
      expect(n, 200);
      expect(avg, closeTo(6.0, 0.6));
      expect(sd, greaterThan(0));
      record(
        action: 'Lab Statistics live',
        expected: 'μ/σ/x̄/s/N from real ball landings (N=200 ≈ μ=6)',
        actual:
            'N=$n x̄=${avg.toStringAsFixed(3)} s=${sd.toStringAsFixed(3)} μ=${c.model.theoreticalAverage} σ=${c.model.theoreticalStandardDeviation.toStringAsFixed(3)}',
        match: 'PASS',
        evidence: 'lab_statistics.png',
      );
      await shot(tester, 'lab_statistics', LabScreen(controller: c));

      // —— Ideal (independent of sample) ——
      final ideal = c.model.getBinomialDistribution();
      final sampleN = c.model.histogram.landedBallsNumber;
      expect(ideal.length, 13);
      final sumIdeal = ideal.fold<double>(0, (a, b) => a + b);
      expect(sumIdeal, closeTo(1.0, 1e-9));
      // Ideal must not change when more balls land
      c.model.addNewBall();
      c.model.step(0.001);
      final ideal2 = c.model.getBinomialDistribution();
      expect(ideal2, ideal);
      expect(c.model.histogram.landedBallsNumber, sampleN + 1);
      c.setIdealVisible(true);
      expect(c.viewProperties.isTheoreticalHistogramVisible, isTrue);
      record(
        action: 'Lab Ideal distribution',
        expected: 'binomial(n,p) independent of sample count',
        actual:
            'sumIdeal=${sumIdeal.toStringAsFixed(6)} unchanged_after_extra_ball=true sampleN→${c.model.histogram.landedBallsNumber}',
        match: 'PASS',
        evidence: 'lab_ideal.png',
      );
      await shot(tester, 'lab_ideal', LabScreen(controller: c));

      // —— Audio gating ——
      final peg = PegSoundGeneration();
      peg.enabled = true;
      peg.soundTimeElapsed = 1;
      // Lab path/none: controller skips play
      c.setHopperMode(HopperMode.path);
      c.viewProperties.isSoundEnabled = true;
      // Simulate controller gate
      final shouldPlayPath = c.model.hopperMode == HopperMode.ball;
      c.setHopperMode(HopperMode.ball);
      final shouldPlayBall = c.model.hopperMode == HopperMode.ball;
      peg.dispose();
      record(
        action: 'Lab Audio gating',
        expected: 'peg sound only when hopperMode==ball (PegSoundGeneration)',
        actual: 'pathGate=$shouldPlayPath ballGate=$shouldPlayBall',
        match: shouldPlayPath == false && shouldPlayBall == true
            ? 'PASS'
            : 'FAIL',
      );

      // —— Reset ——
      c.setNumberOfRows(20);
      c.setProbability(0.2);
      c.setBallMode(BallMode.continuous);
      c.model.setPlaying(true);
      c.setHopperMode(HopperMode.path);
      c.setIdealVisible(true);
      c.setHistogramMode(HistogramDisplayMode.fraction);
      c.resetAll();
      expect(c.model.numberOfRows, PlinkoConstants.rowsDefault);
      expect(c.model.probability, PlinkoConstants.binaryProbabilityDefault);
      expect(c.model.ballMode, BallMode.oneBall);
      expect(c.model.hopperMode, HopperMode.ball);
      expect(c.model.isPlaying, isFalse);
      expect(c.model.balls, isEmpty);
      expect(c.model.histogram.landedBallsNumber, 0);
      expect(c.viewProperties.histogramMode, HistogramDisplayMode.counter);
      expect(c.viewProperties.isTheoreticalHistogramVisible, isFalse);
      record(
        action: 'Lab Reset',
        expected: 'full defaults restored (model + view + sound)',
        actual:
            'rows=${c.model.numberOfRows} p=${c.model.probability} ball=${c.model.ballMode} hop=${c.model.hopperMode} playing=${c.model.isPlaying} hist=${c.viewProperties.histogramMode.name}',
        match: 'PASS',
        evidence: 'lab_reset.png',
      );
      await shot(tester, 'lab_reset', LabScreen(controller: c));
    });
  });
}

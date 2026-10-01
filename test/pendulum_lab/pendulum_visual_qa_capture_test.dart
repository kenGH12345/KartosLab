import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/pendulum_lab/controller/pendulum_lab_controller.dart';
import 'package:kratos/pendulum_lab/model/energy_model.dart';
import 'package:kratos/pendulum_lab/model/lab_model.dart';
import 'package:kratos/pendulum_lab/model/pendulum_lab_model.dart';
import 'package:kratos/pendulum_lab/pl_constants.dart';
import 'package:kratos/pendulum_lab/widgets/pendulum_lab_screen_layout.dart';
import 'package:kratos/pendulum_lab/widgets/pl_simulation_shell.dart';

/// Flutter screenshot matrix for Visual QA (1024×618 design space).
///
/// Run (dedicated tool, NOT part of the unit-test gate):
///   tool\run_pendulum_capture.bat
///
/// ENVIRONMENT NOTE: on this machine, once `toImage` (or any real-async
/// future) completes inside the FakeAsync zone of `testWidgets`, the
/// framework's post-test `pump` never completes. Each capture therefore:
///   1. writes its PNG **synchronously** as the last statement, and
///   2. is expected to end with a `TimeoutException` AFTER the file is on
///      disk — the run reports "failed" but the artifacts are valid.
/// Success criterion for this tool: all 18 PNG + meta files exist, and the
/// log contains a `CAPTURED <name>` marker for each.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Widget-test environments substitute a wide fixed-width fallback font,
  // which inflates text-based chrome (e.g. StopwatchNode measured 174 vs 99
  // design px wide). Load the real Trebuchet MS so capture metrics match the
  // deployed app (where the OS resolves the font natively).
  setUpAll(() async {
    final trebuchet = FontLoader('Trebuchet MS')
      ..addFont(
        File(r'C:\Windows\Fonts\trebuc.ttf').readAsBytes().then(
            (bytes) => ByteData.view(bytes.buffer)),
      );
    // Most widgets use fontFamily 'Arial'; register the real Arial so test
    // metrics match the deployed app instead of the Ahem fallback (1em wide
    // squares), which was causing layout overflows (e.g. gravity display).
    final arial = FontLoader('Arial')
      ..addFont(
        File(r'C:\Windows\Fonts\arial.ttf').readAsBytes().then(
            (bytes) => ByteData.view(bytes.buffer)),
      );
    await trebuchet.load();
    await arial.load();
  });

  const outDir = 'requirements/req-pendulum-lab/visual-qa/FLUTTER';
  const viewport = Size(1280, 800);
  const dpr = 1.0;
  // 15s is ample: PNG is written synchronously BEFORE the by-design
  // FakeAsync timeout fires. Shorter timeout = matrix no longer looks "hung"
  // (previously 30s x 18 caused manual kills that truncated captures at 05).
  const perTestTimeout = Timeout(Duration(seconds: 15));

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
  }

  /// Pumps the screen, applies [arrange], settles, then captures one PNG with
  /// a synchronous write as the FINAL statement of the test body.
  Future<void> captureState(
    WidgetTester tester,
    String name,
    PendulumLabModel model,
    FutureOr<void> Function(PendulumLabModel model, PendulumLabController c)
        arrange, {
    bool energy = false,
    bool lab = false,
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = dpr;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final key = GlobalKey();
    final controller = PendulumLabController(model);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: viewport.width,
            height: viewport.height,
            child: RepaintBoundary(
              key: key,
              child: PlSimulationShell(
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (_, _) => PendulumLabScreenLayout(
                    controller: controller,
                    hasGravityTweakers: lab,
                    showEnergyGraph: energy || lab,
                    showArrowPanel: lab,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
    await arrange(model, controller);
    await settle(tester);

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: dpr);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    // Synchronous I/O: completes inside the FakeAsync zone without awaiting
    // the real event loop (which is poisoned after toImage on this machine).
    File('$outDir/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List(), flush: true);
    File('$outDir/$name.meta.txt').writeAsStringSync([
      'state: $name',
      'viewport: ${viewport.width.toInt()}x${viewport.height.toInt()}',
      'DPR: $dpr',
      'design: ${PlConstants.layoutWidth}x${PlConstants.layoutHeight}',
      'source: local-flutter-widget-test',
      'captured_at: ${DateTime.now().toIso8601String()}',
    ].join('\n'), flush: true);
    // ignore: avoid_print
    print('CAPTURED $name');
  }

  void step(PendulumLabModel m, int frames) {
    for (var i = 0; i < frames; i++) {
      m.step(1 / 60);
    }
  }

  // ---------------- Intro ----------------

  testWidgets('01_Intro_initial', (tester) async {
    await captureState(tester, '01_Intro_initial', PendulumLabModel(),
        (_, _) {});
  }, timeout: perTestTimeout);

  testWidgets('02_Intro_running', (tester) async {
    await captureState(tester, '02_Intro_running', PendulumLabModel(), (m, _) {
      m.pendula[0].angle = math.pi / 4;
      m.pendula[0].updateDerivedVariables(false);
      m.setPlaying(true);
      step(m, 30);
    });
  }, timeout: perTestTimeout);

  testWidgets('03_Intro_paused', (tester) async {
    await captureState(tester, '03_Intro_paused', PendulumLabModel(), (m, _) {
      m.pendula[0].angle = math.pi / 4;
      m.pendula[0].updateDerivedVariables(false);
      m.setPlaying(true);
      step(m, 30);
      m.setPlaying(false);
    });
  }, timeout: perTestTimeout);

  testWidgets('04_Intro_modified', (tester) async {
    await captureState(tester, '04_Intro_modified', PendulumLabModel(), (m, _) {
      m.setLength(0, 0.4);
      m.setMass(0, 1.2);
      m.setGravity(24.79);
      m.setFriction(0.2);
      m.setNumberOfPendula(2);
      m.setPeriodTraceVisible(true);
      m.setStopwatchVisible(true);
    });
  }, timeout: perTestTimeout);

  testWidgets('05_Intro_reset', (tester) async {
    await captureState(tester, '05_Intro_reset', PendulumLabModel(), (m, c) {
      m.setNumberOfPendula(2);
      step(m, 10);
      c.reset();
    });
  }, timeout: perTestTimeout);

  // ---------------- Energy ----------------

  testWidgets('06_Energy_initial', (tester) async {
    await captureState(tester, '06_Energy_initial', EnergyModel(), (_, _) {},
        energy: true);
  }, timeout: perTestTimeout);

  testWidgets('07_Energy_running', (tester) async {
    await captureState(tester, '07_Energy_running', EnergyModel(), (m, _) {
      m.pendula[0].angle = math.pi / 3;
      m.pendula[0].updateDerivedVariables(false);
      m.setPlaying(true);
      step(m, 40);
    }, energy: true);
  }, timeout: perTestTimeout);

  testWidgets('08_Energy_paused', (tester) async {
    await captureState(tester, '08_Energy_paused', EnergyModel(), (m, _) {
      m.pendula[0].angle = math.pi / 3;
      m.pendula[0].updateDerivedVariables(false);
      m.setPlaying(true);
      step(m, 40);
      m.setPlaying(false);
    }, energy: true);
  }, timeout: perTestTimeout);

  testWidgets('09_Energy_pendulum2', (tester) async {
    await captureState(tester, '09_Energy_pendulum2', EnergyModel(), (m, _) {
      final em = m as EnergyModel;
      em.setNumberOfPendula(2);
      em.setActiveEnergyPendulum(em.pendula[1]);
      em.pendula[1].angle = math.pi / 5;
      em.pendula[1].updateDerivedVariables(false);
      em.setPlaying(true);
      step(em, 20);
    }, energy: true);
  }, timeout: perTestTimeout);

  testWidgets('10_Energy_reset', (tester) async {
    await captureState(tester, '10_Energy_reset', EnergyModel(), (m, c) {
      m.pendula[0].angle = math.pi / 3;
      m.pendula[0].updateDerivedVariables(false);
      m.setPlaying(true);
      step(m, 40);
      c.reset();
    }, energy: true);
  }, timeout: perTestTimeout);

  // ---------------- Lab ----------------

  testWidgets('11_Lab_initial', (tester) async {
    await captureState(tester, '11_Lab_initial', LabModel(), (_, _) {},
        lab: true);
  }, timeout: perTestTimeout);

  testWidgets('12_Lab_running', (tester) async {
    await captureState(tester, '12_Lab_running', LabModel(), (m, _) {
      m.pendula[0].angle = math.pi / 4;
      m.pendula[0].updateDerivedVariables(false);
      m.setPlaying(true);
      step(m, 30);
    }, lab: true);
  }, timeout: perTestTimeout);

  testWidgets('13_Lab_paused', (tester) async {
    await captureState(tester, '13_Lab_paused', LabModel(), (m, _) {
      m.pendula[0].angle = math.pi / 4;
      m.pendula[0].updateDerivedVariables(false);
      m.setPlaying(true);
      step(m, 30);
      m.setPlaying(false);
    }, lab: true);
  }, timeout: perTestTimeout);

  testWidgets('14_Lab_modified', (tester) async {
    await captureState(tester, '14_Lab_modified', LabModel(), (m, _) {
      final lm = m as LabModel;
      lm.setLength(0, 0.5);
      lm.setGravity(1.62);
      lm.setVelocityVisible(true);
      lm.setAccelerationVisible(true);
      lm.setNumberOfPendula(2);
      lm.setPlaying(true);
      step(lm, 25);
      lm.setPlaying(false);
    }, lab: true);
  }, timeout: perTestTimeout);

  testWidgets('15_Lab_dragged', (tester) async {
    await captureState(tester, '15_Lab_dragged', LabModel(), (m, _) {
      m.pendula[0].setUserControlled(true);
      m.pendula[0].setAngle(math.pi / 2.2, fromUser: true);
    }, lab: true);
  }, timeout: perTestTimeout);

  testWidgets('16_Lab_released', (tester) async {
    await captureState(tester, '16_Lab_released', LabModel(), (m, _) {
      m.pendula[0].setUserControlled(true);
      m.pendula[0].setAngle(math.pi / 2.2, fromUser: true);
      m.pendula[0].setUserControlled(false);
      m.setPlaying(true);
      step(m, 15);
    }, lab: true);
  }, timeout: perTestTimeout);

  testWidgets('17_Lab_period_timer', (tester) async {
    await captureState(tester, '17_Lab_period_timer', LabModel(), (m, _) {
      final lm = m as LabModel;
      lm.pendula[0].angle = math.pi / 4;
      lm.pendula[0].updateDerivedVariables(false);
      lm.setPeriodTraceVisible(true);
      // Mirror the ORIGINAL capture actions (checkbox then play): the source
      // PeriodTimer forces isRunning back to false while invisible.
      lm.periodTimer!.setVisible(true);
      lm.periodTimer!.setRunning(true);
      lm.setPlaying(true);
      for (var i = 0; i < 50; i++) {
        lm.step(1 / 60);
        lm.periodTimer!.syncFromTrace();
      }
    }, lab: true);
  }, timeout: perTestTimeout);

  testWidgets('18_Lab_reset', (tester) async {
    await captureState(tester, '18_Lab_reset', LabModel(), (m, c) {
      m.setPlaying(true);
      step(m, 20);
      c.reset();
    }, lab: true);
  }, timeout: perTestTimeout);
}

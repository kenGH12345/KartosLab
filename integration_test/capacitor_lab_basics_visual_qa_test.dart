// Visual QA screenshot harness — Capacitance Lab: Basics
// Runs on a real device/emulator via:
//   flutter test integration_test/capacitor_lab_basics_visual_qa_test.dart -d emulator-5554
//
// Does NOT alter Model / Voltmeter / Circuit / Tab / Clock architecture.
// Only configures existing model APIs, then captures frames.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kratos/capacitor_lab_basics/clb_constants.dart';
import 'package:kratos/capacitor_lab_basics/common/model/circuit_state.dart';
import 'package:kratos/capacitor_lab_basics/screens/capacitor_lab_basics_home.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const outDir =
      'requirements/req-capacitor-lab-basics/visual-qa/final/flutter';
  const designW = ClbConstants.canvasWidth; // 1024
  const designH = ClbConstants.canvasHeight; // 618
  const viewport = Size(1280, 800);
  const dpr = 1.0;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> capture(
    WidgetTester tester,
    GlobalKey repaintKey,
    String name,
  ) async {
    await settle(tester);
    final boundary = repaintKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: dpr);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$outDir/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    final meta = File('$outDir/$name.meta.txt');
    await meta.writeAsString([
      'state: $name',
      'viewport: ${viewport.width.toInt()}x${viewport.height.toInt()}',
      'DPR: $dpr',
      'device resolution: ${viewport.width.toInt()}x${viewport.height.toInt()} @ $dpr',
      'design resolution: ${designW}x$designH',
      'actual screenshot path: ${file.path}',
      'captured_at: ${DateTime.now().toIso8601String()}',
    ].join('\n'));
  }

  testWidgets('CLB Final Visual QA — 9 states', (tester) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = dpr;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final homeKey = GlobalKey<CapacitorLabBasicsHomeState>();
    final repaintKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: repaintKey,
          child: CapacitorLabBasicsHome(key: homeKey),
        ),
      ),
    );
    await settle(tester);

    final state = homeKey.currentState!;
    final cap = state.capacitance;
    final lb = state.lightBulb;

    // 1 Capacitance_Default
    await capture(tester, repaintKey, '01_Capacitance_Default');

    // 2 Capacitance_Modified
    cap.circuit.battery.voltage = 1.5;
    cap.circuit.capacitor.setPlateSeparation(0.010);
    cap.circuit.capacitor.setPlateWidth(0.02); // ~400 mm²
    await settle(tester);
    await capture(tester, repaintKey, '02_Capacitance_Modified');

    // 3 Capacitance_Voltmeter (valid probes on plates)
    cap.setVoltmeterVisible(true);
    cap.voltmeter.bodyX = 0.055;
    cap.voltmeter.bodyY = 0.028;
    final bat = cap.circuit.battery;
    cap.voltmeter.positiveProbeX = bat.x + 0.018;
    cap.voltmeter.positiveProbeY = bat.y - 0.010;
    cap.voltmeter.negativeProbeX = bat.x + 0.018;
    cap.voltmeter.negativeProbeY = bat.y + 0.002;
    cap.setVoltmeterVisible(true); // refresh + notify
    await settle(tester);
    await capture(tester, repaintKey, '03_Capacitance_Voltmeter');

    // 4 Capacitance_InvalidProbe
    cap.voltmeter.positiveProbeX = 0.08;
    cap.voltmeter.positiveProbeY = 0.05;
    cap.voltmeter.negativeProbeX = 0.085;
    cap.voltmeter.negativeProbeY = 0.045;
    cap.setVoltmeterVisible(true);
    await settle(tester);
    await capture(tester, repaintKey, '04_Capacitance_InvalidProbe');

    // Switch to Light Bulb tab
    await tester.tap(find.textContaining('Light Bulb').first);
    await settle(tester);

    // 5 LightBulb_Charging
    lb.circuit.battery.voltage = 1.5;
    lb.circuit.setCircuitConnection(CircuitState.batteryConnected);
    lb.setPlaying(true);
    await settle(tester);
    await capture(tester, repaintKey, '05_LightBulb_Charging');

    // 6 LightBulb_Discharging
    lb.circuit.setCircuitConnection(CircuitState.lightBulbConnected);
    for (var i = 0; i < 8; i++) {
      lb.step(0.05);
    }
    await settle(tester);
    await capture(tester, repaintKey, '06_LightBulb_Discharging');

    // 7 LightBulb_Paused — Pause icon + stopwatch out (TimeControl chrome)
    lb.placeStopwatchAt(const Offset(120, 420));
    lb.stopwatchTime = 3.5;
    lb.stopwatchRunning = false;
    lb.setPlaying(false);
    await settle(tester);
    await capture(tester, repaintKey, '07_LightBulb_Paused');

    // 8 LightBulb_Voltmeter
    lb.setPlaying(true);
    lb.returnStopwatchToToolbox();
    lb.setVoltmeterVisible(true);
    lb.voltmeter.bodyX = 0.055;
    lb.voltmeter.bodyY = 0.028;
    final batLb = lb.circuit.battery;
    lb.voltmeter.positiveProbeX = batLb.x + 0.018;
    lb.voltmeter.positiveProbeY = batLb.y - 0.010;
    lb.voltmeter.negativeProbeX = batLb.x + 0.018;
    lb.voltmeter.negativeProbeY = batLb.y + 0.002;
    lb.setVoltmeterVisible(true);
    await settle(tester);
    await capture(tester, repaintKey, '08_LightBulb_Voltmeter');

    // 9 Reset_State — stay on Light Bulb tab after reset
    lb.reset();
    await settle(tester);
    await capture(tester, repaintKey, '09_Reset_State');
  });
}

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/john_travoltage/john_travoltage_assets.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_constants.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_model.dart';
import 'package:kratos/john_travoltage/model/jt_vec2.dart';
import 'package:kratos/john_travoltage/view/john_travoltage_screen.dart';
import 'package:kratos/john_travoltage/view/jt_view_layout.dart';

/// Discharge-state PNGs for Visual QA.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const outDir = 'test/john_travoltage/FLUTTER';
  const viewport = Size(
    JtViewLayout.layoutWidth,
    JtViewLayout.layoutHeight,
  );

  Future<void> precache(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.expand())),
    );
    final ctx = tester.element(find.byType(Scaffold));
    await tester.runAsync(() async {
      for (final p in [
        JohnTravoltageAssets.wallpaper,
        JohnTravoltageAssets.window,
        JohnTravoltageAssets.floor,
        JohnTravoltageAssets.rug,
        JohnTravoltageAssets.door,
        JohnTravoltageAssets.body,
        JohnTravoltageAssets.arm,
        JohnTravoltageAssets.leg,
      ]) {
        await precacheImage(AssetImage(p), ctx);
      }
    });
    await tester.pump();
  }

  void pointNear(JohnTravoltageModel m) {
    final knob = JohnTravoltageConstants.doorknobPosition;
    final desired = knob - m.arm.position;
    final target = desired.normalize().times(m.arm.fingerVector.magnitude);
    m.setArmAngle(target.angle - m.arm.fingerVector.angle);
    m.arm.borderVisible = false;
    m.leg.borderVisible = false;
  }

  void charge(JohnTravoltageModel m, int n) {
    var i = 0;
    while (m.electronCount < n && i < 2000) {
      m.setLegAngle(1.1 + (i.isEven ? 0.0 : 1.2));
      i++;
    }
    while (m.electronCount < n) {
      m.debugAddElectronAt(JtVec2(400 + m.electronCount * 0.05, 280));
    }
  }

  Future<void> capture(
    WidgetTester tester,
    String name,
    JohnTravoltageModel model,
  ) async {
    Directory(outDir).createSync(recursive: true);
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: viewport.width,
            height: viewport.height,
            child: RepaintBoundary(
              key: key,
              child: JohnTravoltagePlayArea(
                model: model,
                autoStartClock: false,
                enableAudio: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('$outDir/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
    });
  }

  Future<void> advanceToSpark(
    JohnTravoltageModel m,
    WidgetTester? tester,
  ) async {
    pointNear(m);
    final dist = m.fingerPosition.distance(m.doorknobPosition);
    final need =
        (JohnTravoltageConstants.dischargeThreshold * dist).floor() + 1;
    while (m.electronCount < need) {
      m.debugAddElectronAt(JtVec2(400.0 + m.electronCount * 0.1, 280));
    }
    // Spark becomes visible only when an exiting electron is actually removed.
    for (var i = 0; i < 1500; i++) {
      m.step(1 / 60);
      if (tester != null) await tester.pump();
      if (m.sparkVisible) return;
    }
  }

  testWidgets('capture JT discharge screenshots', (tester) async {
    await precache(tester);

    // Low discharge mid-spark
    final low = JohnTravoltageModel(random: math.Random(1));
    charge(low, 20);
    await tester.pumpWidget(
      MaterialApp(
        home: JohnTravoltagePlayArea(
          model: low,
          autoStartClock: false,
          enableAudio: false,
        ),
      ),
    );
    await tester.pump();
    await advanceToSpark(low, tester);
    expect(low.sparkVisible, isTrue);
    await capture(tester, 'JT_discharge_low', low);

    // Medium
    final med = JohnTravoltageModel(random: math.Random(2));
    charge(med, 50);
    await advanceToSpark(med, null);
    expect(med.sparkVisible, isTrue);
    await capture(tester, 'JT_discharge_medium', med);

    // High
    final high = JohnTravoltageModel(random: math.Random(3));
    charge(high, 100);
    await advanceToSpark(high, null);
    expect(high.sparkVisible, isTrue);
    await capture(tester, 'JT_discharge_high', high);

    // Reset after discharge start
    final resetM = JohnTravoltageModel(random: math.Random(4));
    charge(resetM, 40);
    await advanceToSpark(resetM, null);
    resetM.reset();
    resetM.arm.borderVisible = true;
    resetM.leg.borderVisible = true;
    await capture(tester, 'JT_discharge_reset', resetM);
    expect(resetM.sparkVisible, isFalse);
    expect(resetM.electronCount, 0);

    for (final name in [
      'JT_discharge_low',
      'JT_discharge_medium',
      'JT_discharge_high',
      'JT_discharge_reset',
    ]) {
      expect(File('$outDir/$name.png').existsSync(), isTrue, reason: name);
    }
  });
}

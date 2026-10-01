import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/john_travoltage/john_travoltage_assets.dart';
import 'package:kratos/john_travoltage/model/john_travoltage_model.dart';
import 'package:kratos/john_travoltage/view/john_travoltage_screen.dart';
import 'package:kratos/john_travoltage/view/jt_view_layout.dart';

/// Captures charge-state PNGs for Visual QA (not a golden gate).
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
    final paths = [
      JohnTravoltageAssets.wallpaper,
      JohnTravoltageAssets.window,
      JohnTravoltageAssets.floor,
      JohnTravoltageAssets.rug,
      JohnTravoltageAssets.door,
      JohnTravoltageAssets.body,
      JohnTravoltageAssets.arm,
      JohnTravoltageAssets.leg,
    ];
    await tester.runAsync(() async {
      for (final p in paths) {
        await precacheImage(AssetImage(p), ctx);
      }
    });
    await tester.pump();
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
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('$outDir/$name.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    });
  }

  void rubToCount(JohnTravoltageModel m, int target) {
    var i = 0;
    while (m.electronCount < target && i < 2000) {
      m.setLegAngle(1.1 + (i.isEven ? 0.0 : 1.2));
      i++;
    }
    // After real interaction borders are hidden (AppendageNode drag start).
    m.leg.borderVisible = false;
    m.arm.borderVisible = false;
  }

  testWidgets('capture JT charge screenshots', (tester) async {
    await precache(tester);

    // JT_default
    final def = JohnTravoltageModel(random: math.Random(1));
    await capture(tester, 'JT_default', def);
    expect(File('$outDir/JT_default.png').existsSync(), isTrue);

    // JT_charge_low (~8)
    final low = JohnTravoltageModel(random: math.Random(2));
    rubToCount(low, 8);
    for (var i = 0; i < 15; i++) {
      low.step(1 / 60);
    }
    await capture(tester, 'JT_charge_low', low);
    expect(low.electronCount, greaterThanOrEqualTo(8));
    expect(File('$outDir/JT_charge_low.png').existsSync(), isTrue);

    // JT_charge_medium (~40)
    final med = JohnTravoltageModel(random: math.Random(3));
    rubToCount(med, 40);
    for (var i = 0; i < 20; i++) {
      med.step(1 / 60);
    }
    await capture(tester, 'JT_charge_medium', med);
    expect(med.electronCount, greaterThanOrEqualTo(40));
    expect(File('$outDir/JT_charge_medium.png').existsSync(), isTrue);

    // JT_charge_high (~100)
    final high = JohnTravoltageModel(random: math.Random(4));
    rubToCount(high, 100);
    for (var i = 0; i < 30; i++) {
      high.step(1 / 60);
    }
    await capture(tester, 'JT_charge_high', high);
    expect(high.electronCount, 100);
    expect(File('$outDir/JT_charge_high.png').existsSync(), isTrue);
  });
}

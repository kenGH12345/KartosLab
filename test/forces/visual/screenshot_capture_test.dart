import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/famb_assets.dart';
import 'package:kratos/forces/screens/net_force_screen.dart';
import 'package:kratos/forces/screens/motion_screen_v2.dart';

/// Captures Flutter PNGs for Pixel Visual QA (not a golden gate).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const outDir = 'requirements/req-forces-and-motion-basics/visual-qa/FLUTTER';
  const viewport = Size(981, 604);

  Future<void> precacheNetForce(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.expand())),
    );
    final ctx = tester.element(find.byType(Scaffold));
    final paths = <String>[
      FambAssets.grass,
      FambAssets.rope,
      FambAssets.cart,
      for (final color in ['BLUE', 'RED'])
        for (final size in ['', 'lrg', 'small'])
          for (final pose in [0, 3])
            FambAssets.puller(color: color, size: size, pose: pose),
    ];
    await tester.runAsync(() async {
      for (final p in paths) {
        if (p.endsWith('.svg')) continue;
        await precacheImage(AssetImage(p), ctx);
      }
    });
    await tester.pump();
  }

  Future<void> precacheMotion(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.expand())),
    );
    final ctx = tester.element(find.byType(Scaffold));
    final paths = <String>[
      FambAssets.brickTile,
      FambAssets.pusherStanding,
      FambAssets.pusherFallen,
      for (var i = 0; i <= 30; i++) FambAssets.pusher(i),
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
    Widget child, {
    Future<void> Function(WidgetTester)? prepare,
    Future<void> Function(WidgetTester)? interact,
  }) async {
    Directory(outDir).createSync(recursive: true);
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    if (prepare != null) await prepare(tester);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: viewport.width,
            height: viewport.height,
            child: RepaintBoundary(key: key, child: child),
          ),
        ),
      ),
    );
    await tester.pump();
    // SVG FutureBuilder + image decode
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    if (interact != null) {
      await interact(tester);
    }

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('$outDir/$name.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('CAPTURED $name (${file.lengthSync()} bytes)');
    });
  }

  testWidgets('NF_default', (tester) async {
    await capture(
      tester,
      'NF_default',
      const NetForceScreen(),
      prepare: precacheNetForce,
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('NF_pulling', (tester) async {
    await capture(
      tester,
      'NF_pulling',
      const NetForceScreen(),
      prepare: precacheNetForce,
      interact: (t) async {
        await t.dragFrom(const Offset(70, 480), const Offset(-8, -195));
        await t.pump();
        await t.dragFrom(const Offset(900, 480), const Offset(20, -180));
        await t.pump();
        await t.tapAt(const Offset(490.5, 450));
        await t.pump();
        await t.pump(const Duration(milliseconds: 400));
      },
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('MO_default', (tester) async {
    await capture(
      tester,
      'MO_default',
      const MotionScreenV2(style: MotionScreenStyleTab.motion),
      prepare: precacheMotion,
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('FR_default', (tester) async {
    await capture(
      tester,
      'FR_default',
      const MotionScreenV2(style: MotionScreenStyleTab.friction),
      prepare: precacheMotion,
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('AC_default', (tester) async {
    await capture(
      tester,
      'AC_default',
      const MotionScreenV2(style: MotionScreenStyleTab.acceleration),
      prepare: precacheMotion,
    );
  }, timeout: const Timeout(Duration(seconds: 90)));
}

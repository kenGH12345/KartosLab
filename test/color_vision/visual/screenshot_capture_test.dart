import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/color_vision/color_vision_constants.dart';
import 'package:kratos/color_vision/cv_assets.dart';
import 'package:kratos/color_vision/model/rgb_model.dart';
import 'package:kratos/color_vision/model/single_bulb_model.dart';
import 'package:kratos/color_vision/view/rgb_screen_view.dart';
import 'package:kratos/color_vision/view/single_bulb_screen_view.dart';

/// Captures Flutter visual-QA PNGs for Pixel QA (not golden gate).
///
/// Output: `requirements/req-port-color-vision/visual-qa/FLUTTER/`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const outDir = 'requirements/req-port-color-vision/visual-qa/FLUTTER';
  const viewport = Size(
    ColorVisionConstants.layoutWidth,
    ColorVisionConstants.layoutHeight,
  );

  Future<void> precacheAll(WidgetTester tester) async {
    final paths = [
      CvAssets.head,
      CvAssets.headFront,
      CvAssets.silhouette,
      CvAssets.silhouetteFront,
      CvAssets.flashlight0Deg,
      CvAssets.flashlightNeg45Deg,
      CvAssets.flashlightPos45Deg,
      CvAssets.filterLeft,
      CvAssets.filterRight,
      CvAssets.headIcon,
      CvAssets.silhouetteIcon,
      CvAssets.beamViewIcon,
      CvAssets.photonViewIcon,
      CvAssets.whiteLightIcon,
      CvAssets.singleColorLightIcon,
    ];
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.expand())),
    );
    final context = tester.element(find.byType(Scaffold));
    await tester.runAsync(() async {
      for (final p in paths) {
        await precacheImage(AssetImage(p), context);
      }
    });
    await tester.pump();
  }

  Future<void> captureSb(
    WidgetTester tester,
    String name,
    SingleBulbModel model,
  ) async {
    Directory(outDir).createSync(recursive: true);
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await precacheAll(tester);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: SizedBox(
              width: viewport.width,
              height: viewport.height,
              child: RepaintBoundary(
                key: key,
                child: SingleBulbScreenView(
                  model: model,
                  autoStartClock: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

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

  Future<void> captureRgb(
    WidgetTester tester,
    String name,
    RgbModel model,
  ) async {
    Directory(outDir).createSync(recursive: true);
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await precacheAll(tester);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: SizedBox(
              width: viewport.width,
              height: viewport.height,
              child: RepaintBoundary(
                key: key,
                child: RgbScreenView(
                  model: model,
                  autoStartClock: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

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

  testWidgets('S1_default', (tester) async {
    await captureSb(tester, 'S1_default', SingleBulbModel());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('S2_white_beam_on', (tester) async {
    final m = SingleBulbModel()
      ..setLightType(LightType.white)
      ..setBeamType(BeamType.beam)
      ..setFlashlightOn(true);
    await captureSb(tester, 'S2_white_beam_on', m);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('S5_mono_photons_on', (tester) async {
    final m = SingleBulbModel()
      ..setBeamType(BeamType.photon)
      ..setFlashlightOn(true);
    // Advance photons a bit without clock
    for (var i = 0; i < 30; i++) {
      m.manualStep();
    }
    await captureSb(tester, 'S5_mono_photons_on', m);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('S6_filter_on', (tester) async {
    final m = SingleBulbModel()
      ..setFlashlightOn(true)
      ..setFilterVisible(true)
      ..setFilterWavelength(450);
    await captureSb(tester, 'S6_filter_on', m);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('S8_interior', (tester) async {
    final m = SingleBulbModel()..setHeadMode(HeadMode.brain);
    await captureSb(tester, 'S8_interior', m);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('R1_default', (tester) async {
    await captureRgb(tester, 'R1_default', RgbModel());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('R2_red', (tester) async {
    final m = RgbModel()..setRedIntensity(100);
    for (var i = 0; i < 40; i++) {
      m.manualStep();
    }
    await captureRgb(tester, 'R2_red', m);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('R5_rg', (tester) async {
    final m = RgbModel()
      ..setRedIntensity(100)
      ..setGreenIntensity(100);
    for (var i = 0; i < 40; i++) {
      m.manualStep();
    }
    await captureRgb(tester, 'R5_rg', m);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('R8_rgb', (tester) async {
    final m = RgbModel()
      ..setRedIntensity(100)
      ..setGreenIntensity(100)
      ..setBlueIntensity(100);
    for (var i = 0; i < 40; i++) {
      m.manualStep();
    }
    await captureRgb(tester, 'R8_rgb', m);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('R10_interior', (tester) async {
    final m = RgbModel()..setHeadMode(HeadMode.brain);
    await captureRgb(tester, 'R10_interior', m);
  }, timeout: const Timeout(Duration(seconds: 30)));
}

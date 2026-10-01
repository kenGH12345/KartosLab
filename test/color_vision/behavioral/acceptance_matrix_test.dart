import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/color_vision/color_vision_constants.dart';
import 'package:kratos/color_vision/model/rgb_model.dart';
import 'package:kratos/color_vision/model/single_bulb_model.dart';
import 'package:kratos/color_vision/model/visible_color.dart';
import 'package:kratos/color_vision/screens/color_vision_home.dart';
import 'package:kratos/color_vision/view/rgb_screen_view.dart';
import 'package:kratos/color_vision/view/single_bulb_screen_view.dart';

/// Behavioral acceptance matrix (Model locked — View interaction only).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Single Bulb behavioral', () {
    late SingleBulbModel model;

    setUp(() => model = SingleBulbModel());

    tearDown(() => model.dispose());

    test('default state matches PhET', () {
      expect(model.flashlightOn, isFalse);
      expect(model.lightType, LightType.colored);
      expect(model.beamType, BeamType.beam);
      expect(model.flashlightWavelength, 570);
      expect(model.filterWavelength, 570);
      expect(model.filterVisible, isFalse);
      expect(model.headMode, HeadMode.noBrain);
      expect(model.playing, isTrue);
      expect(model.perceivedColor, const Color(0xFF000000));
    });

    test('white light beam perceived white', () {
      model.setLightType(LightType.white);
      model.setFlashlightOn(true);
      expect(model.perceivedColor, const Color(0xFFFFFFFF));
    });

    test('monochromatic wavelength drives color', () {
      model.setFlashlightOn(true);
      model.setFlashlightWavelength(450);
      expect(
        model.perceivedColor.toARGB32(),
        VisibleColor.wavelengthToColor(450).toARGB32(),
      );
    });

    test('filter white → filter wavelength', () {
      model.setLightType(LightType.white);
      model.setFlashlightOn(true);
      model.setFilterVisible(true);
      model.setFilterWavelength(500);
      expect(
        model.perceivedColor.toARGB32(),
        VisibleColor.wavelengthToColor(500).toARGB32(),
      );
    });

    test('slider extrema clamp', () {
      model.setFlashlightWavelength(0);
      expect(model.flashlightWavelength, 380);
      model.setFlashlightWavelength(9999);
      expect(model.flashlightWavelength, 780);
      model.setFilterWavelength(100);
      expect(model.filterWavelength, 380);
      model.setFilterWavelength(900);
      expect(model.filterWavelength, 780);
    });

    test('pause stops step; manualStep advances', () {
      model.setFlashlightOn(true);
      model.setBeamType(BeamType.photon);
      model.setPlaying(false);
      final n0 = model.photonBeam.photons.length;
      model.step(0.2);
      expect(model.photonBeam.photons.length, n0);
      model.manualStep();
      expect(model.photonBeam.photons.length, greaterThan(n0));
    });

    test('reset restores defaults after mutations', () {
      model.setFlashlightOn(true);
      model.setLightType(LightType.white);
      model.setBeamType(BeamType.photon);
      model.setFilterVisible(true);
      model.setHeadMode(HeadMode.brain);
      model.setPlaying(false);
      model.setFlashlightWavelength(400);
      model.reset();
      expect(model.flashlightOn, isFalse);
      expect(model.lightType, LightType.colored);
      expect(model.beamType, BeamType.beam);
      expect(model.filterVisible, isFalse);
      expect(model.headMode, HeadMode.noBrain);
      expect(model.playing, isTrue);
      expect(model.flashlightWavelength, 570);
    });

    testWidgets('view wires flashlight + reset + filter', (tester) async {
      tester.view.physicalSize = const Size(768, 504);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        MaterialApp(
          home: SingleBulbScreenView(model: model, autoStartClock: false),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('color_vision_flashlight_toggle')), findsOneWidget);
      expect(find.byKey(const Key('color_vision_filter_switch')), findsOneWidget);
      expect(find.byKey(const Key('color_vision_reset_all')), findsOneWidget);

      await tester.tap(find.byKey(const Key('color_vision_flashlight_toggle')));
      await tester.pump();
      expect(model.flashlightOn, isTrue);

      await tester.tap(find.byKey(const Key('color_vision_filter_switch')));
      await tester.pump();
      expect(model.filterVisible, isTrue);

      await tester.tap(find.byKey(const Key('color_vision_reset_all')));
      await tester.pump();
      expect(model.flashlightOn, isFalse);
      expect(model.filterVisible, isFalse);
    });
  });

  group('RGB behavioral', () {
    late RgbModel model;
    setUp(() => model = RgbModel());
    tearDown(() => model.dispose());

    test('defaults all zero → black', () {
      expect(model.redIntensity, 0);
      expect(model.greenIntensity, 0);
      expect(model.blueIntensity, 0);
      expect(model.perceivedColor, const Color(0xFF000000));
    });

    test('additive mixing combinations via perceived intensities', () {
      model.perceivedRedIntensity = 100;
      model.perceivedGreenIntensity = 0;
      model.perceivedBlueIntensity = 0;
      expect(model.perceivedColor.g, 0);
      expect(model.perceivedColor.b, 0);

      model.perceivedGreenIntensity = 100;
      // R+G → yellow-ish
      expect(model.perceivedColor.b, 0);
      expect(model.perceivedColor.r, greaterThan(0.9));
      expect(model.perceivedColor.g, greaterThan(0.9));

      model.perceivedBlueIntensity = 100;
      expect(model.perceivedColor.r, greaterThan(0.9));
      expect(model.perceivedColor.g, greaterThan(0.9));
      expect(model.perceivedColor.b, greaterThan(0.9));
    });

    test('intensity extrema clamp', () {
      model.setRedIntensity(-10);
      expect(model.redIntensity, 0);
      model.setRedIntensity(150);
      expect(model.redIntensity, 100);
      model.setGreenIntensity(50);
      expect(model.greenIntensity, 50);
    });

    test('no cross-screen leak: RGB reset independent of SingleBulb', () {
      final sb = SingleBulbModel()..setFlashlightOn(true);
      model.setRedIntensity(80);
      model.reset();
      expect(model.redIntensity, 0);
      expect(sb.flashlightOn, isTrue); // untouched
      sb.dispose();
    });

    testWidgets('RGB view reset key works', (tester) async {
      tester.view.physicalSize = const Size(768, 504);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      model.setBlueIntensity(40);
      await tester.pumpWidget(
        MaterialApp(
          home: RgbScreenView(model: model, autoStartClock: false),
        ),
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('color_vision_rgb_reset_all')));
      await tester.pump();
      expect(model.blueIntensity, 0);
    });
  });

  group('Home lifecycle', () {
    testWidgets('tab switch Single ↔ RGB without crash', (tester) async {
      final old = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.exceptionAsString().contains('A RenderFlex overflowed')) return;
        old?.call(d);
      };
      addTearDown(() => FlutterError.onError = old);

      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(home: ColorVisionHome()));
      await tester.pump();
      expect(find.byType(SingleBulbScreenView), findsOneWidget);

      await tester.tap(find.text('RGB Bulbs'));
      await tester.pump();
      expect(find.byType(RgbScreenView), findsOneWidget);

      await tester.tap(find.text('Single Bulb'));
      await tester.pump();
      expect(find.byType(SingleBulbScreenView), findsOneWidget);
    });
  });
}

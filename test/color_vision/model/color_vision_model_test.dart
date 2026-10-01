import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/color_vision/color_vision_constants.dart';
import 'package:kratos/color_vision/model/event_timer.dart';
import 'package:kratos/color_vision/model/rgb_model.dart';
import 'package:kratos/color_vision/model/single_bulb_model.dart';
import 'package:kratos/color_vision/model/visible_color.dart';

void main() {
  group('VisibleColor', () {
    test('range is 380–780 nm', () {
      expect(VisibleColor.minWavelength, 380);
      expect(VisibleColor.maxWavelength, 780);
    });

    test('570 nm is yellowish (high R+G, low B)', () {
      final c = VisibleColor.wavelengthToColor(570);
      // 570 in 510–580 band: r=(570-510)/70≈0.857, g=1, b=0
      expect(c.r, closeTo(60 / 70, 0.01));
      expect(c.g, closeTo(1.0, 0.01));
      expect(c.b, lessThan(0.1));
    });

    test('440 nm is blue-violet', () {
      final c = VisibleColor.wavelengthToColor(440);
      expect(c.b, greaterThan(0.9));
      expect(c.g, lessThan(0.1));
    });

    test('extrema intensity reduction', () {
      final mid = VisibleColor.wavelengthToColor(550);
      final edge = VisibleColor.wavelengthToColor(380);
      final midLum = mid.r + mid.g + mid.b;
      final edgeLum = edge.r + edge.g + edge.b;
      expect(edgeLum, lessThan(midLum));
    });
  });

  group('SingleBulbModel defaults', () {
    late SingleBulbModel model;

    setUp(() => model = SingleBulbModel(random: CvRandom(1)));

    test('matches PhET defaults', () {
      expect(model.playing, isTrue);
      expect(model.headMode, HeadMode.noBrain);
      expect(model.lightType, LightType.colored);
      expect(model.beamType, BeamType.beam);
      expect(model.flashlightWavelength, 570);
      expect(model.filterWavelength, 570);
      expect(model.flashlightOn, isFalse);
      expect(model.filterVisible, isFalse);
    });

    test('perceived color is black when flashlight off (beam mode)', () {
      expect(model.perceivedColor, const Color(0xFF000000));
    });

    test('monochromatic on → wavelength color', () {
      model.flashlightOn = true;
      final expected = VisibleColor.wavelengthToColor(570);
      expect(model.perceivedColor.toARGB32(), expected.toARGB32());
    });

    test('white light on, no filter → white', () {
      model.flashlightOn = true;
      model.lightType = LightType.white;
      expect(model.perceivedColor, const Color(0xFFFFFFFF));
    });

    test('white light + filter → filter wavelength color', () {
      model.flashlightOn = true;
      model.lightType = LightType.white;
      model.filterVisible = true;
      model.filterWavelength = 450;
      final expected = VisibleColor.wavelengthToColor(450);
      expect(model.perceivedColor.toARGB32(), expected.toARGB32());
    });

    test('colored + filter: full pass when wavelengths match', () {
      model.flashlightOn = true;
      model.filterVisible = true;
      model.flashlightWavelength = 570;
      model.filterWavelength = 570;
      expect(model.perceivedColor.a, closeTo(1.0, 1e-9));
    });

    test('colored + filter: zero alpha outside ±35 nm', () {
      model.flashlightOn = true;
      model.filterVisible = true;
      model.flashlightWavelength = 570;
      model.filterWavelength = 650; // Δ = 80 > 35
      expect(model.perceivedColor.a, 0);
    });

    test('colored + filter: linear alpha inside band', () {
      model.flashlightOn = true;
      model.filterVisible = true;
      model.flashlightWavelength = 570;
      model.filterWavelength = 570 + 17.5; // half of halfWidth → α = 0.5
      expect(model.perceivedColor.a, closeTo(0.5, 1e-9));
    });

    test('reset restores defaults', () {
      model.flashlightOn = true;
      model.lightType = LightType.white;
      model.beamType = BeamType.photon;
      model.flashlightWavelength = 400;
      model.filterWavelength = 700;
      model.filterVisible = true;
      model.headMode = HeadMode.brain;
      model.playing = false;
      model.reset();
      expect(model.flashlightOn, isFalse);
      expect(model.lightType, LightType.colored);
      expect(model.beamType, BeamType.beam);
      expect(model.flashlightWavelength, 570);
      expect(model.filterWavelength, 570);
      expect(model.filterVisible, isFalse);
      expect(model.headMode, HeadMode.noBrain);
      expect(model.playing, isTrue);
    });

    test('pause stops photon emission progress', () {
      model.flashlightOn = true;
      model.beamType = BeamType.photon;
      model.playing = false;
      final before = model.photonBeam.photons.length;
      model.step(0.1);
      expect(model.photonBeam.photons.length, before);
    });

    test('manualStep advances even when paused', () {
      model.flashlightOn = true;
      model.beamType = BeamType.photon;
      model.playing = false;
      model.manualStep();
      // At least event timer may create photons when on
      expect(model.photonBeam.photons, isNotEmpty);
    });

    test('step creates photons when flashlight on', () {
      model.flashlightOn = true;
      model.step(1 / 60);
      expect(model.photonBeam.photons, isNotEmpty);
    });
  });

  group('RgbModel', () {
    late RgbModel model;

    setUp(() => model = RgbModel(random: CvRandom(2)));

    test('defaults all intensities 0 → black perceived', () {
      expect(model.redIntensity, 0);
      expect(model.greenIntensity, 0);
      expect(model.blueIntensity, 0);
      expect(model.perceivedColor, const Color(0xFF000000));
    });

    test('additive mixing formula floor(percent * 2.55)', () {
      model.perceivedRedIntensity = 100;
      model.perceivedGreenIntensity = 100;
      model.perceivedBlueIntensity = 0;
      // yellow
      expect(model.perceivedColor.r, closeTo(1.0, 0.01));
      expect(model.perceivedColor.g, closeTo(1.0, 0.01));
      expect(model.perceivedColor.b, 0);
    });

    test('R=100 G=0 B=0 → near-red (floor(100*2.55) float quirk)', () {
      model.perceivedRedIntensity = 100;
      model.perceivedGreenIntensity = 0;
      model.perceivedBlueIntensity = 0;
      // PhET Math.floor(100 * 2.55) → 254 under IEEE float (same as Dart).
      final channel = (100 * ColorVisionConstants.colorScaleFactor).floor();
      expect(channel, 254);
      expect(
        model.perceivedColor.toARGB32(),
        Color.fromARGB(255, channel, 0, 0).toARGB32(),
      );
    });

    test('R+G+B = 100 → near-white via floor(percent * 2.55)', () {
      model.perceivedRedIntensity = 100;
      model.perceivedGreenIntensity = 100;
      model.perceivedBlueIntensity = 100;
      final channel = (100 * ColorVisionConstants.colorScaleFactor).floor();
      expect(
        model.perceivedColor.toARGB32(),
        Color.fromARGB(255, channel, channel, channel).toARGB32(),
      );
    });

    test('intensity 0 emits black photon and sets perceived to 0', () {
      model.perceivedRedIntensity = 50;
      model.setRedIntensity(0);
      // Run enough frames for black photon to exit beam
      for (var i = 0; i < 200; i++) {
        model.manualStep();
      }
      expect(model.perceivedRedIntensity, 0);
    });

    test('reset clears intensities and beams', () {
      model.setRedIntensity(80);
      model.setGreenIntensity(40);
      model.setBlueIntensity(20);
      model.headMode = HeadMode.brain;
      model.playing = false;
      model.manualStep();
      model.reset();
      expect(model.redIntensity, 0);
      expect(model.greenIntensity, 0);
      expect(model.blueIntensity, 0);
      expect(model.perceivedRedIntensity, 0);
      expect(model.redBeam.photons, isEmpty);
      expect(model.headMode, HeadMode.noBrain);
      expect(model.playing, isTrue);
    });

    test('pause prevents step; manualStep still runs', () {
      model.setRedIntensity(100);
      model.playing = false;
      final before = model.redBeam.photons.length;
      model.step(0.1);
      expect(model.redBeam.photons.length, before);
      model.manualStep();
      expect(model.redBeam.photons.length, greaterThan(before));
    });

    test('photons travel leftward at X_VELOCITY', () {
      model.setGreenIntensity(100);
      model.manualStep();
      expect(model.greenBeam.photons, isNotEmpty);
      final p = model.greenBeam.photons.first;
      final x0 = p.x;
      model.manualStep();
      // Photon may have been culled; if still present, moved left
      if (model.greenBeam.photons.contains(p)) {
        expect(p.x, lessThan(x0));
        expect(p.vx, ColorVisionConstants.xVelocity);
      }
    });
  });

  group('EventTimer', () {
    test('ConstantEventModel 120 Hz fires ~2 times in 1/60 s', () {
      var count = 0;
      final timer = EventTimer(
        getPeriodBeforeNextEvent: () => 1 / 120,
        onEvent: (_) => count++,
      );
      timer.step(1 / 60);
      expect(count, 2);
    });

    test('IntensityEventModel rate 0 never fires', () {
      var count = 0;
      final timer = EventTimer(
        getPeriodBeforeNextEvent: () =>
            IntensityEventModel(() => 0).getPeriodBeforeNextEvent(),
        onEvent: (_) => count++,
      );
      timer.step(1.0);
      expect(count, 0);
    });
  });
}

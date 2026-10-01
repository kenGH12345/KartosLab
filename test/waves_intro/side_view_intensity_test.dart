import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/model/intensity_sample.dart';
import 'package:kratos/waves_intro/model/lattice.dart';
import 'package:kratos/waves_intro/model/scene_kind.dart';
import 'package:kratos/waves_intro/model/water_side_geometry.dart';
import 'package:kratos/waves_intro/model/wave_scene.dart';
import 'package:kratos/waves_intro/model/waves_intro_model.dart';
import 'package:kratos/waves_intro/waves_intro_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('side view', () {
    test('default viewpoint is top; rotation 0', () {
      final model = WavesIntroModel(kind: SceneKind.water)..audio.platformEnabled = false;
      addTearDown(model.dispose);
      expect(model.viewpoint, Viewpoint.top);
      expect(model.rotationAmount, 0);
      expect(model.showTopLattice, isTrue);
      expect(model.showWaterSideView, isFalse);
    });

    test('selecting side drives rotation toward 1 and shows water side', () {
      final model = WavesIntroModel(kind: SceneKind.water)..audio.platformEnabled = false;
      addTearDown(model.dispose);
      model.pause();
      model.setViewpoint(Viewpoint.side);
      // Simulate wall time for rotation (runs even when paused)
      for (var i = 0; i < 40; i++) {
        model.stepWallTime(0.05);
      }
      expect(model.rotationAmount, closeTo(1.0, 1e-6));
      expect(model.showWaterSideView, isTrue);
      expect(model.showTopLattice, isFalse);
    });

    test('waterSideY maps 0鈫抍enter and 5鈫抍enter-47', () {
      const bounds = Rect.fromLTWH(0, 0, 100, 200);
      expect(
        WaterSideGeometry.waterSideYExact(bounds, 0),
        closeTo(100, 1e-9),
      );
      expect(
        WaterSideGeometry.waterSideYExact(bounds, 5),
        closeTo(100 - 47, 1e-9),
      );
    });
  });

  group('light intensity', () {
    test('IntensitySample averages wave虏 history', () {
      final lattice = Lattice(width: 21, height: 21, dampX: 2, dampY: 2);
      // Put energy on right edge cells
      for (var j = 2; j < 19; j++) {
        lattice.setCurrentValue(18, j, 2.0);
        lattice.setLastValue(18, j, 2.0);
        lattice.setCurrentValue(17, j, 2.0);
      }
      final sample = IntensitySample(lattice);
      for (var i = 0; i < 10; i++) {
        sample.step();
      }
      final values = sample.getIntensityValues();
      expect(values, isNotEmpty);
      // intensity ~ 4 from 2虏
      expect(values[values.length ~/ 2], greaterThan(1.0));
    });

    test('light scene steps intensitySample; Widget does not own math', () {
      final scene = WaveScene(config: SceneConfig.light);
      expect(scene.intensitySample, isNotNull);
      scene.setButtonPressed(true);
      for (var i = 0; i < 20; i++) {
        scene.advanceTime(1 / WavesIntroConstants.eventRate, manualStep: true);
      }
      final v = scene.intensitySample!.getIntensityValues();
      expect(v.length, scene.lattice.height - 2 * scene.lattice.dampY);
    });

    test('piecewise brightness monotonic-ish at knots', () {
      expect(WaterSideGeometry.piecewiseBrightness(0), 0);
      expect(WaterSideGeometry.piecewiseBrightness(1), 1);
      expect(
        WaterSideGeometry.piecewiseBrightness(0.002237089269640335),
        closeTo(0.4, 1e-9),
      );
    });

    test('showScreen defaults false; reset clears', () {
      final model = WavesIntroModel(kind: SceneKind.light)..audio.platformEnabled = false;
      addTearDown(model.dispose);
      expect(model.showScreen, isFalse);
      model.setShowScreen(true);
      model.reset();
      expect(model.showScreen, isFalse);
      expect(model.viewpoint, Viewpoint.top);
    });
  });

  group('wave meter samples', () {
    test('series grows while meter in play area', () {
      final model = WavesIntroModel(kind: SceneKind.sound)..audio.platformEnabled = false;
      addTearDown(model.dispose);
      model.pause();
      model.takeOutWaveMeter();
      model.scene.setButtonPressed(true);
      for (var i = 0; i < 5; i++) {
        model.manualStep();
      }
      expect(model.tools.series1, isNotEmpty);
      expect(model.tools.series2.length, model.tools.series1.length);
    });
  });
}

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio_assets.dart';
import 'package:kratos/gravity_force_lab/model/force_solver.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';

void main() {
  group('Continuous force audio (ContinuousPropertySoundClip)', () {
    test('activation + update on force change; stop after fade', () async {
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(model);

      expect(audio.isForcePlaying, isFalse);
      expect(audio.forceActivationCount, 0);

      model.setPosition(1, -4.0);
      expect(audio.forceActivationCount, 1);
      expect(audio.isForcePlaying, isTrue);
      expect(audio.forceUpdateCount, greaterThanOrEqualTo(1));

      final rate1 = audio.lastForcePlaybackRate;
      model.setMassValue(1, 500);
      expect(audio.forceUpdateCount, greaterThanOrEqualTo(2));
      expect(audio.lastForcePlaybackRate, isNot(rate1));
      expect(audio.forceActivationCount, 1);

      audio.step(0.5);
      expect(audio.isForcePlaying, isFalse);
      expect(audio.forceStopCount, 1);

      await audio.dispose();
      model.dispose();
    });

    test('playback rate follows source normalizationMappingExponent 0.15', () {
      final minF = ForceSolver.getMinForceMagnitude();
      final maxF = ForceSolver.getMaxForce();
      final mid = minF + (maxF - minF) * 0.5;
      final rate = GflAudio.forcePlaybackRate(
        mid,
        forceMin: minF,
        forceMax: maxF,
      );
      final expectedMapped = math.pow(0.5, 0.15).toDouble();
      final expectedRate = 0.5 + expectedMapped * 1.5;
      expect(rate, closeTo(expectedRate, 1e-9));
      expect(
        GflAudio.forcePlaybackRate(minF, forceMin: minF, forceMax: maxF),
        closeTo(0.5, 1e-9),
      );
      expect(
        GflAudio.forcePlaybackRate(maxF, forceMin: minF, forceMax: maxF),
        closeTo(2.0, 1e-9),
      );
    });

    test('assets present for continuous force loop', () {
      expect(
        GflAudioAssets.saturatedSineLoopTrimmed,
        contains('saturatedSineLoopTrimmed.wav'),
      );
    });
  });

  group('Mass extra sound (MassSoundGenerator / rubberBand_v3)', () {
    test('step buttons every change; slider thresholds only', () async {
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(model);

      audio.onMassValueChanged(1, 110, 100);
      expect(audio.massExtraCount, 1);
      expect(audio.lastOneShotAsset, GflAudioAssets.rubberBandV3);

      audio.setMassSliderDraggingViaPointer(true);
      audio.onMassValueChanged(1, 110, 100);
      expect(audio.massExtraCount, 1);
      audio.onMassValueChanged(1, 200, 190);
      expect(audio.massExtraCount, 2);

      audio.setMassSliderDraggingViaPointer(false);
      await audio.dispose();
      model.dispose();
    });

    test('mass playback rate pitch mapping', () {
      final low = GflAudio.massPlaybackRate(GravityForceConstants.massMin);
      final high = GflAudio.massPlaybackRate(GravityForceConstants.massMax);
      final mid = GflAudio.massPlaybackRate(505);
      expect(low, greaterThan(high));
      expect(mid, closeTo(1.0, 0.05));
    });

    test('reset suppresses mass sound', () async {
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(model);
      audio.beginReset();
      audio.onMassValueChanged(1, 200, 100);
      expect(audio.massExtraCount, 0);
      audio.endReset();
      await audio.dispose();
      model.dispose();
    });
  });

  group('Boundary sound (MassBoundarySoundGenerator)', () {
    test('outer / inner triggers once per enter', () async {
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(model);

      model.beginDrag(1);
      model.setPositionWhileDragging(1, model.mass1EnabledMin);
      expect(audio.boundaryCount, 1);
      expect(audio.lastOneShotAsset, GflAudioAssets.boundaryReached);

      model.setPositionWhileDragging(1, model.mass1EnabledMin);
      expect(audio.boundaryCount, 1);

      model.setPositionWhileDragging(1, model.mass1EnabledMax);
      expect(audio.boundaryCount, 2);
      expect(
        audio.lastOneShotAsset,
        GflAudioAssets.scrunchedMassCollisionSonicWomp,
      );
      model.endDrag(1);

      await audio.dispose();
      model.dispose();
    });
  });

  group('Ruler audio (ISLCRulerNode)', () {
    test('grab / movement / release lifecycle', () async {
      final model = GravityForceLabModel();
      final audio = GflAudio(playEnabled: false)..attach(model);

      audio.onRulerRelease();
      expect(audio.rulerReleaseCount, 0);

      audio.onRulerGrab();
      expect(audio.rulerGrabCount, 1);
      expect(audio.lastOneShotAsset, GflAudioAssets.grab);

      audio.onRulerGrab();
      expect(audio.rulerGrabCount, 1);

      model.setRulerPosition(model.ruler.positionX + 0.2, model.ruler.positionY);
      audio.onRulerMove();
      expect(audio.rulerMovementCount, 0);

      model.setRulerPosition(model.ruler.positionX + 0.6, model.ruler.positionY);
      audio.onRulerMove();
      expect(audio.rulerMovementCount, 1);
      expect(audio.lastOneShotAsset, GflAudioAssets.rulerMovement000);

      audio.onRulerRelease();
      expect(audio.rulerReleaseCount, 1);
      expect(audio.lastOneShotAsset, GflAudioAssets.release);

      await audio.dispose();
      model.dispose();
    });
  });
}

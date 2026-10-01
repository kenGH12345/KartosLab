import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/audio/audio_state.dart';
import 'package:kratos/waves_intro/audio/waves_intro_audio.dart';
import 'package:kratos/waves_intro/model/scene_kind.dart';
import 'package:kratos/waves_intro/model/waves_intro_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('audio assets paths are PhET lock extracted (no homemade samples)', () {
    expect(WavesIntroAudio.buttonAsset, contains('squishier-button'));
    expect(WavesIntroAudio.dropAsset, contains('water-drop'));
    expect(WavesIntroAudio.speakerAsset, contains('speaker-pulse'));
    expect(WavesIntroAudio.lightAsset, contains('light-beam'));
    expect(WavesIntroAudio.meterSawAsset, contains('wave-meter-saw'));
    expect(WavesIntroAudio.meterSmoothAsset, contains('wave-meter-smooth'));
    expect(WavesIntroAudio.sliderLeftAsset, contains('slider-click'));
  });

  test('platformEnabled=false skips player construction', () {
    final audio = WavesIntroAudio(kind: SceneKind.water)
      ..platformEnabled = false;
    final state = WavesIntroAudioState();
    expect(
      () => audio.playButton(state: state, pressed: true),
      returnsNormally,
    );
  });

  test('mute zeros effective volume and visual meter', () {
    final state = WavesIntroAudioState()
      ..masterVolume = 0.8
      ..ambientOutputLevel = 0.5;
    expect(state.effectiveVolume, closeTo(0.8, 1e-9));
    expect(state.visualMeterLevel, greaterThan(0));
    state.muted = true;
    expect(state.effectiveVolume, 0);
    expect(state.visualMeterLevel, 0);
  });

  test('volume slider updates AudioState masterVolume', () {
    final model = WavesIntroModel(kind: SceneKind.sound)
      ..audio.platformEnabled = false;
    addTearDown(model.dispose);
    model.setMasterVolume(0.35);
    expect(model.audioState.masterVolume, closeTo(0.35, 1e-9));
    model.setMasterVolume(1.5);
    expect(model.audioState.masterVolume, 1.0);
  });

  test('audio meter levels follow waveMeterNodeOutputLevel mapping', () {
    final level = waveMeterNodeOutputLevel(0);
    expect(level, greaterThanOrEqualTo(0));
    final high = waveMeterNodeOutputLevel(1.6);
    expect(high, greaterThan(level));
  });

  test('mute stops ambient via model.setMute', () {
    final model = WavesIntroModel(kind: SceneKind.water)
      ..audio.platformEnabled = false;
    addTearDown(model.dispose);
    model.setMute(true);
    expect(model.audioState.muted, isTrue);
    expect(model.audioState.effectiveVolume, 0);
  });

  test('Play Tone / Sound Effect are screen-specific defaults', () {
    final sound = WavesIntroModel(kind: SceneKind.sound)
      ..audio.platformEnabled = false;
    final light = WavesIntroModel(kind: SceneKind.light)
      ..audio.platformEnabled = false;
    addTearDown(sound.dispose);
    addTearDown(light.dispose);
    expect(sound.audioState.isTonePlaying, isFalse);
    expect(light.audioState.soundEffectEnabled, isFalse);
    sound.setTonePlaying(true);
    light.setSoundEffectEnabled(true);
    expect(sound.audioState.isTonePlaying, isTrue);
    expect(light.audioState.soundEffectEnabled, isTrue);
  });

  test('duckingFactor drops when meter series playing', () {
    final state = WavesIntroAudioState();
    expect(state.duckingFactor, 1.0);
    state.series1Playing = true;
    expect(state.duckingFactor, 0.3);
  });

  test('lifecycle dispose does not throw', () async {
    final model = WavesIntroModel(kind: SceneKind.light)
      ..audio.platformEnabled = false;
    model.setSoundEffectEnabled(true);
    model.setButtonPressed(true);
    model.dispose();
  });

  test('reset clears audio toggles', () {
    final model = WavesIntroModel(kind: SceneKind.sound)
      ..audio.platformEnabled = false;
    addTearDown(model.dispose);
    model.setTonePlaying(true);
    model.setMasterVolume(0.2);
    model.setMute(true);
    model.reset();
    expect(model.audioState.isTonePlaying, isFalse);
    expect(model.audioState.muted, isFalse);
    expect(model.audioState.masterVolume, closeTo(0.7, 1e-9));
  });
}

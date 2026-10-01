import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../model/scene_kind.dart';
import '../waves_intro_constants.dart';
import 'audio_state.dart';

/// Audio renderer for Waves Intro — reads [WavesIntroAudioState] + scene params.
///
/// Architecture: WaveModel → AudioState → this renderer.
/// Painters never call into this class.
///
/// Evidence: WI lock `31ebfd7` WavesScreenSoundView / WaveMeterNode / SineWaveGenerator.
/// No global Audio framework — sim-local only.
class WavesIntroAudio {
  WavesIntroAudio({required this.kind});

  final SceneKind kind;

  /// When false, skip all platform player construction (unit tests).
  bool platformEnabled = true;

  AudioPlayer? _oneShot;
  AudioPlayer? _speaker;
  AudioPlayer? _lightLoop;
  AudioPlayer? _tone;
  AudioPlayer? _meter1;
  AudioPlayer? _meter2;
  AudioPlayer? _slider;

  bool _lightPlaying = false;
  bool _tonePlaying = false;
  bool _meter1Playing = false;
  bool _meter2Playing = false;
  bool _speakerArmed = false;
  Uint8List? _sineWav;
  int _dropClipIndex = 0;

  static const buttonAsset =
      'phet/waves_intro/sounds/squishier-button-v3-007.mp3';
  static const speakerAsset = 'phet/waves_intro/sounds/speaker-pulse-v4.mp3';
  static const lightAsset =
      'phet/waves_intro/sounds/light-beam-loop-v5-eq-out-bass.mp3';
  static const meterSawAsset =
      'phet/waves_intro/sounds/wave-meter-saw-tone.mp3';
  static const meterSmoothAsset =
      'phet/waves_intro/sounds/wave-meter-smooth-tone.mp3';
  static const sliderLeftAsset =
      'phet/waves_intro/sounds/slider-click-v2-left.mp3';
  static const sliderRightAsset =
      'phet/waves_intro/sounds/slider-click-v2-right.mp3';

  static const dropAssets = [
    'phet/waves_intro/sounds/water-drop-v5.mp3',
    'phet/waves_intro/sounds/water-drop-v5-001.mp3',
    'phet/waves_intro/sounds/water-drop-v5-002.mp3',
    'phet/waves_intro/sounds/water-drop-v5-003.mp3',
  ];

  /// Legacy alias used by older tests.
  static const dropAsset = 'phet/waves_intro/sounds/water-drop-v5.mp3';

  AudioPlayer? _ensure(AudioPlayer? existing, void Function(AudioPlayer) assign) {
    if (!platformEnabled) return null;
    if (existing != null) return existing;
    try {
      final p = AudioPlayer();
      assign(p);
      return p;
    } catch (e) {
      debugPrint('WavesIntroAudio init: $e');
      return null;
    }
  }

  Future<void> playButton({
    required WavesIntroAudioState state,
    required bool pressed,
  }) async {
    if (!state.enabled || !platformEnabled) return;
    final p = _ensure(_oneShot, (v) => _oneShot = v);
    if (p == null) return;
    try {
      await p.stop();
      await p.setPlaybackRate(pressed ? 1.0 : 0.891);
      await p.play(
        AssetSource(buttonAsset),
        volume: 0.4 * state.effectiveVolume,
      );
    } catch (e) {
      debugPrint('WavesIntroAudio button: $e');
    }
  }

  Future<void> playWaterDrop({
    required WavesIntroAudioState state,
    required double amplitude,
  }) async {
    if (!state.enabled || !platformEnabled || kind != SceneKind.water) return;
    final p = _ensure(_oneShot, (v) => _oneShot = v);
    if (p == null) return;
    try {
      // [已确认] AMP_RANGE → playbackRate 1.0..0.5
      final rate = WavesIntroConstants.linear(
        WavesIntroConstants.amplitudeMin,
        WavesIntroConstants.amplitudeMax,
        1.0,
        0.5,
        amplitude,
      ).clamp(0.5, 1.5);
      final vol = state.duckingFactor * 0.9 * state.effectiveVolume;
      _dropClipIndex = (_dropClipIndex + 1) % dropAssets.length;
      await p.stop();
      await p.setPlaybackRate(rate);
      await p.play(AssetSource(dropAssets[_dropClipIndex]), volume: vol);
    } catch (e) {
      debugPrint('WavesIntroAudio drop: $e');
    }
  }

  Future<void> playSliderClick({
    required WavesIntroAudioState state,
    required bool increasing,
  }) async {
    if (!state.enabled || !platformEnabled) return;
    final p = _ensure(_slider, (v) => _slider = v);
    if (p == null) return;
    try {
      await p.stop();
      await p.play(
        AssetSource(increasing ? sliderRightAsset : sliderLeftAsset),
        volume: 0.35 * state.effectiveVolume,
      );
    } catch (e) {
      debugPrint('WavesIntroAudio slider: $e');
    }
  }

  /// Frame sync — call from model (not painters).
  Future<void> sync({
    required WavesIntroAudioState state,
    required bool isRunning,
    required bool buttonPressed,
    required bool continuousOscillating,
    required bool pulseFiring,
    required double amplitude,
    required double frequency,
    required double frequencyMin,
    required double frequencyMax,
    required double oscillatorValue,
    required bool meterActive,
  }) async {
    if (!platformEnabled) {
      _updateLevelsOnly(
        state: state,
        isRunning: isRunning,
        continuousOscillating: continuousOscillating,
        pulseFiring: pulseFiring,
        amplitude: amplitude,
        meterActive: meterActive,
      );
      return;
    }

    await _syncTone(
      state: state,
      isRunning: isRunning,
      buttonPressed: buttonPressed,
      amplitude: amplitude,
      frequency: frequency,
    );

    await _syncSpeaker(
      state: state,
      isRunning: isRunning,
      amplitude: amplitude,
      frequency: frequency,
      frequencyMin: frequencyMin,
      frequencyMax: frequencyMax,
      oscillatorValue: oscillatorValue,
    );

    await _syncLight(
      state: state,
      isRunning: isRunning,
      buttonPressed: buttonPressed,
      amplitude: amplitude,
      frequency: frequency,
      frequencyMin: frequencyMin,
      frequencyMax: frequencyMax,
    );

    await _syncMeter(state: state, isRunning: isRunning, meterActive: meterActive);

    _updateAmbient(
      state: state,
      isRunning: isRunning,
      continuousOscillating: continuousOscillating,
      pulseFiring: pulseFiring,
      amplitude: amplitude,
    );
  }

  void _updateLevelsOnly({
    required WavesIntroAudioState state,
    required bool isRunning,
    required bool continuousOscillating,
    required bool pulseFiring,
    required double amplitude,
    required bool meterActive,
  }) {
    _updateMeterLevels(state: state, isRunning: isRunning, meterActive: meterActive);
    _updateAmbient(
      state: state,
      isRunning: isRunning,
      continuousOscillating: continuousOscillating,
      pulseFiring: pulseFiring,
      amplitude: amplitude,
    );
  }

  void _updateMeterLevels({
    required WavesIntroAudioState state,
    required bool isRunning,
    required bool meterActive,
  }) {
    if (!meterActive || !isRunning || !state.enabled) {
      state.series1Playing = false;
      state.series2Playing = false;
      state.series1OutputLevel = 0;
      state.series2OutputLevel = 0;
      return;
    }
    const amplitudeScale = 0.5;
    final s1 = state.meterSample1;
    final s2 = state.meterSample2;
    if (s1 != null) {
      // seriesVolume 1.0 · volumeProperty 0.1
      state.series1OutputLevel =
          waveMeterNodeOutputLevel(s1) * amplitudeScale * 1.0 * 0.1;
      state.series1Playing = true;
    } else {
      state.series1OutputLevel = 0;
      state.series1Playing = false;
    }
    if (s2 != null) {
      // seriesVolume 0.42 · volumeProperty 0.05
      state.series2OutputLevel =
          waveMeterNodeOutputLevel(s2) * amplitudeScale * 0.42 * 0.05;
      state.series2Playing = true;
    } else {
      state.series2OutputLevel = 0;
      state.series2Playing = false;
    }
  }

  void _updateAmbient({
    required WavesIntroAudioState state,
    required bool isRunning,
    required bool continuousOscillating,
    required bool pulseFiring,
    required double amplitude,
  }) {
    if (!isRunning || !state.enabled) {
      state.ambientOutputLevel = 0;
      return;
    }
    if (kind == SceneKind.sound && state.isTonePlaying) {
      state.ambientOutputLevel = WavesIntroConstants.linear(
        WavesIntroConstants.amplitudeMin,
        WavesIntroConstants.amplitudeMax,
        0.0,
        0.3,
        amplitude,
      );
      return;
    }
    if (kind == SceneKind.light &&
        state.soundEffectEnabled &&
        continuousOscillating) {
      state.ambientOutputLevel = WavesIntroConstants.linear(
        WavesIntroConstants.amplitudeMin,
        WavesIntroConstants.amplitudeMax,
        0.0,
        0.67,
        amplitude,
      );
      return;
    }
    if (kind == SceneKind.sound &&
        !state.isTonePlaying &&
        (continuousOscillating || pulseFiring)) {
      state.ambientOutputLevel = WavesIntroConstants.linear(
        WavesIntroConstants.amplitudeMin,
        WavesIntroConstants.amplitudeMax,
        0.0,
        0.3,
        amplitude,
      );
      return;
    }
    state.ambientOutputLevel = 0;
  }

  Future<void> _syncTone({
    required WavesIntroAudioState state,
    required bool isRunning,
    required bool buttonPressed,
    required double amplitude,
    required double frequency,
  }) async {
    if (kind != SceneKind.sound) return;
    final shouldPlay =
        state.isTonePlaying && buttonPressed && isRunning && state.enabled;
    final p = _ensure(_tone, (v) => _tone = v);
    if (p == null) return;
    try {
      if (shouldPlay) {
        final hz = (frequency * 1000).clamp(20.0, 2000.0);
        final level = WavesIntroConstants.linear(
              WavesIntroConstants.amplitudeMin,
              WavesIntroConstants.amplitudeMax,
              0.0,
              0.3,
              amplitude,
            ) *
            state.effectiveVolume;
        if (!_tonePlaying) {
          _sineWav ??= _buildSineWav(hz: 220, seconds: 1);
          await p.setReleaseMode(ReleaseMode.loop);
          await p.play(BytesSource(_sineWav!), volume: level);
          _tonePlaying = true;
        }
        await p.setPlaybackRate((hz / 220).clamp(0.25, 4.0));
        await p.setVolume(level);
      } else if (_tonePlaying) {
        await p.stop();
        _tonePlaying = false;
      }
    } catch (e) {
      debugPrint('WavesIntroAudio tone: $e');
    }
  }

  Future<void> _syncSpeaker({
    required WavesIntroAudioState state,
    required bool isRunning,
    required double amplitude,
    required double frequency,
    required double frequencyMin,
    required double frequencyMax,
    required double oscillatorValue,
  }) async {
    if (kind != SceneKind.sound) return;
    final p = _ensure(_speaker, (v) => _speaker = v);
    if (p == null) return;

    final maxVolume = state.isTonePlaying ? 0.0 : 0.3;
    final outputLevel = WavesIntroConstants.linear(
          WavesIntroConstants.amplitudeMin,
          WavesIntroConstants.amplitudeMax,
          0.0,
          maxVolume,
          amplitude,
        ) *
        state.duckingFactor *
        state.effectiveVolume;
    final playbackRate = WavesIntroConstants.linear(
          frequencyMin,
          frequencyMax,
          1.0,
          1.4,
          frequency,
        ) /
        2;

    try {
      final prev = state.previousOscillatorValue;
      final crossed = prev >= 0 && oscillatorValue < 0;
      if (oscillatorValue == 0 || !isRunning || !state.enabled) {
        if (_speakerArmed) {
          await p.stop();
          _speakerArmed = false;
        }
      } else if (crossed && outputLevel > 0) {
        await p.stop();
        await p.setPlaybackRate(playbackRate.clamp(0.5, 2.0));
        await p.play(AssetSource(speakerAsset), volume: outputLevel);
        _speakerArmed = true;
      }
      state.previousOscillatorValue = oscillatorValue;
    } catch (e) {
      debugPrint('WavesIntroAudio speaker: $e');
    }
  }

  Future<void> _syncLight({
    required WavesIntroAudioState state,
    required bool isRunning,
    required bool buttonPressed,
    required double amplitude,
    required double frequency,
    required double frequencyMin,
    required double frequencyMax,
  }) async {
    if (kind != SceneKind.light) return;
    final shouldPlay =
        buttonPressed && isRunning && state.soundEffectEnabled && state.enabled;
    final p = _ensure(_lightLoop, (v) => _lightLoop = v);
    if (p == null) return;
    try {
      final outputLevel = WavesIntroConstants.linear(
            WavesIntroConstants.amplitudeMin,
            WavesIntroConstants.amplitudeMax,
            0.0,
            0.67,
            amplitude,
          ) *
          state.duckingFactor *
          state.effectiveVolume;
      final playbackRate = WavesIntroConstants.linear(
        frequencyMin,
        frequencyMax,
        1.0,
        1.8,
        frequency,
      );
      if (shouldPlay) {
        if (!_lightPlaying) {
          await p.setReleaseMode(ReleaseMode.loop);
          await p.play(AssetSource(lightAsset), volume: outputLevel);
          _lightPlaying = true;
        }
        await p.setVolume(outputLevel);
        await p.setPlaybackRate(playbackRate.clamp(0.5, 2.5));
      } else if (_lightPlaying) {
        await p.stop();
        _lightPlaying = false;
      }
    } catch (e) {
      debugPrint('WavesIntroAudio light: $e');
    }
  }

  Future<void> _syncMeter({
    required WavesIntroAudioState state,
    required bool isRunning,
    required bool meterActive,
  }) async {
    _updateMeterLevels(
      state: state,
      isRunning: isRunning,
      meterActive: meterActive,
    );

    // Tone takes precedence: duck meter to 0.2 when Play Tone on sound scene
    final toneDuck =
        kind == SceneKind.sound && state.isTonePlaying ? 0.2 : 1.0;

    await _syncMeterSeries(
      player: _meter1,
      assign: (v) => _meter1 = v,
      playing: _meter1Playing,
      setPlaying: (v) => _meter1Playing = v,
      asset: meterSawAsset,
      level: state.series1OutputLevel * toneDuck * state.effectiveVolume,
      rate: 1.0,
      shouldPlay: state.series1Playing && state.enabled && isRunning,
    );
    await _syncMeterSeries(
      player: _meter2,
      assign: (v) => _meter2 = v,
      playing: _meter2Playing,
      setPlaying: (v) => _meter2Playing = v,
      asset: meterSmoothAsset,
      level: state.series2OutputLevel * toneDuck * state.effectiveVolume,
      rate: 1.01,
      shouldPlay: state.series2Playing && state.enabled && isRunning,
    );
  }

  Future<void> _syncMeterSeries({
    required AudioPlayer? player,
    required void Function(AudioPlayer) assign,
    required bool playing,
    required void Function(bool) setPlaying,
    required String asset,
    required double level,
    required double rate,
    required bool shouldPlay,
  }) async {
    final p = _ensure(player, assign);
    if (p == null) return;
    try {
      if (shouldPlay && level > 0) {
        if (!playing) {
          await p.setReleaseMode(ReleaseMode.loop);
          await p.play(AssetSource(asset), volume: level.clamp(0.0, 1.0));
          setPlaying(true);
        }
        await p.setVolume(level.clamp(0.0, 1.0));
        await p.setPlaybackRate(rate.clamp(0.5, 2.0));
      } else if (playing) {
        await p.stop();
        setPlaying(false);
      }
    } catch (e) {
      debugPrint('WavesIntroAudio meter: $e');
    }
  }

  Future<void> stopAll() async {
    try {
      await _oneShot?.stop();
      await _speaker?.stop();
      await _lightLoop?.stop();
      await _tone?.stop();
      await _meter1?.stop();
      await _meter2?.stop();
      await _slider?.stop();
    } catch (_) {}
    _lightPlaying = false;
    _tonePlaying = false;
    _meter1Playing = false;
    _meter2Playing = false;
    _speakerArmed = false;
  }

  Future<void> dispose() async {
    await stopAll();
    await _oneShot?.dispose();
    await _speaker?.dispose();
    await _lightLoop?.dispose();
    await _tone?.dispose();
    await _meter1?.dispose();
    await _meter2?.dispose();
    await _slider?.dispose();
  }

  /// Minimal mono 16-bit PCM WAV for Play Tone oscillator — mirrors PhET
  /// `SineWaveGenerator` (Web Audio OscillatorNode), not a homemade sample asset.
  static Uint8List _buildSineWav({required double hz, required double seconds}) {
    const sampleRate = 22050;
    final n = (sampleRate * seconds).round();
    final dataSize = n * 2;
    final bytes = BytesBuilder();
    void u32(int v) {
      bytes.add([v & 255, (v >> 8) & 255, (v >> 16) & 255, (v >> 24) & 255]);
    }

    void u16(int v) {
      bytes.add([v & 255, (v >> 8) & 255]);
    }

    bytes.add([0x52, 0x49, 0x46, 0x46]); // RIFF
    u32(36 + dataSize);
    bytes.add([0x57, 0x41, 0x56, 0x45]); // WAVE
    bytes.add([0x66, 0x6d, 0x74, 0x20]); // fmt
    u32(16);
    u16(1); // PCM
    u16(1); // mono
    u32(sampleRate);
    u32(sampleRate * 2);
    u16(2);
    u16(16);
    bytes.add([0x64, 0x61, 0x74, 0x61]); // data
    u32(dataSize);
    for (var i = 0; i < n; i++) {
      final s = math.sin(2 * math.pi * hz * i / sampleRate);
      final sample = (s * 0.35 * 32767).round().clamp(-32768, 32767);
      u16(sample & 0xFFFF);
    }
    return bytes.toBytes();
  }
}

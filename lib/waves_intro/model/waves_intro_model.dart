import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../audio/audio_state.dart';
import '../audio/waves_intro_audio.dart';
import '../waves_intro_constants.dart';
import 'scene_kind.dart';
import 'wave_scene.dart';
import 'waves_intro_tools_state.dart';

enum Viewpoint { top, side }

/// ChangeNotifier model for one MediumScreen (one [WaveScene]).
///
/// EventTimer-like accumulator at EVENT_RATE — [已确认] WavesModel.ts
/// Audio: WaveModel → [audioState] → [audio] renderer (not Painter).
class WavesIntroModel extends ChangeNotifier {
  WavesIntroModel({
    required SceneKind kind,
    bool autoTick = true,
  })  : scene = WaveScene(config: SceneConfig.forKind(kind)),
        audio = WavesIntroAudio(kind: kind) {
    _ticker = Ticker(_onTick);
    if (autoTick) {
      _ticker.start();
    }
    scene.onWaterDropAbsorbed = (amp) {
      audio.playWaterDrop(state: audioState, amplitude: amp);
    };
  }

  final WaveScene scene;
  final WavesIntroToolsState tools = WavesIntroToolsState();
  final WavesIntroAudioState audioState = WavesIntroAudioState();
  final WavesIntroAudio audio;

  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  double _eventAccumulator = 0;

  bool isRunning = true;
  bool showGraph = false;

  /// [已确认] WavesModel.viewpointProperty default TOP
  Viewpoint viewpoint = Viewpoint.top;

  /// 0 = top, 1 = side — [已确认] rotationAmountProperty
  double rotationAmount = 0;

  /// Light screen checkbox — [已确认] showScreenProperty default false
  bool showScreen = false;

  /// View-level wall-time scale (Normal/Slow) — does not change Lattice FDTD.
  bool slowMotion = false;

  bool get isRotating => rotationAmount > 0 && rotationAmount < 1;

  /// Fully side + water → water side view
  bool get showWaterSideView =>
      scene.isWater && rotationAmount >= 0.999;

  /// Top lattice visible when not mid-rotation and not water-side
  bool get showTopLattice => !isRotating && !showWaterSideView;

  WaveScene get activeScene => scene;

  void _onTick(Duration elapsed) {
    final dtSeconds = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dtSeconds <= 0 || dtSeconds > 0.25) return;
    final scaled = slowMotion ? dtSeconds * 0.25 : dtSeconds;
    stepWallTime(scaled);
  }

  /// Feed wall time into EventTimer-style fixed steps.
  void stepWallTime(double wallDt) {
    _updateRotation(wallDt);

    if (!isRunning) {
      _syncAudio();
      notifyListeners();
      return;
    }
    _eventAccumulator += wallDt;
    final period = 1 / WavesIntroConstants.eventRate;
    while (_eventAccumulator >= period) {
      _eventAccumulator -= period;
      scene.lattice.interpolationRatio =
          (_eventAccumulator / period).clamp(0.0, 1.0);
      _advanceOneFrame(period, manualStep: false);
    }
    scene.lattice.interpolationRatio =
        (_eventAccumulator / period).clamp(0.0, 1.0);
    notifyListeners();
  }

  void _updateRotation(double wallDt) {
    final sign = viewpoint == Viewpoint.top ? -1.0 : 1.0;
    rotationAmount =
        (rotationAmount + wallDt * sign * 1.4).clamp(0.0, 1.0);
  }

  void _advanceOneFrame(double wallPeriod, {required bool manualStep}) {
    final sceneDt = wallPeriod * scene.config.timeScaleFactor;
    tools.stepStopwatch(sceneDt);
    scene.advanceTime(wallPeriod, manualStep: manualStep);
    if (tools.isWaveMeterInPlayArea) {
      _sampleWaveMeter();
    } else {
      audioState.meterSample1 = null;
      audioState.meterSample2 = null;
    }
    _syncAudio();
  }

  void _sampleWaveMeter() {
    final size = WavesIntroConstants.waveAreaViewSize;
    double? sampleAt(Offset p) {
      final nx = (p.dx / size);
      final ny = (p.dy / size);
      if (nx < 0 || nx > 1 || ny < 0 || ny > 1) return null;
      final i = scene.lattice.visibleMinX +
          (nx * (scene.lattice.visibleMaxX - scene.lattice.visibleMinX - 1))
              .round();
      final j = scene.lattice.visibleMinY +
          (ny * (scene.lattice.visibleMaxY - scene.lattice.visibleMinY - 1))
              .round();
      return scene.lattice.getInterpolatedValue(i, j);
    }

    final v1 = sampleAt(tools.probe1);
    final v2 = sampleAt(tools.probe2);
    audioState.meterSample1 = v1;
    audioState.meterSample2 = v2;
    tools.pushMeterSamples(v1 ?? double.nan, v2 ?? double.nan);
  }

  void _syncAudio() {
    // Fire-and-forget; failures are swallowed inside renderer.
    audio.sync(
      state: audioState,
      isRunning: isRunning,
      buttonPressed: scene.buttonPressed,
      continuousOscillating: scene.continuousOscillating,
      pulseFiring: scene.pulseFiring,
      amplitude: scene.amplitude,
      frequency: scene.isWater ? scene.desiredFrequency : scene.frequency,
      frequencyMin: scene.config.frequencyMin,
      frequencyMax: scene.config.frequencyMax,
      oscillatorValue: scene.oscillatorValue,
      meterActive: tools.isWaveMeterInPlayArea,
    );
  }

  void play() {
    if (isRunning) return;
    isRunning = true;
    notifyListeners();
  }

  void pause() {
    if (!isRunning) return;
    isRunning = false;
    _syncAudio();
    notifyListeners();
  }

  void togglePlayPause() {
    isRunning = !isRunning;
    if (!isRunning) _syncAudio();
    notifyListeners();
  }

  void manualStep() {
    final period = 1 / WavesIntroConstants.eventRate;
    scene.lattice.interpolationRatio = 1;
    _advanceOneFrame(period, manualStep: true);
    notifyListeners();
  }

  void reset() {
    scene.reset();
    tools.resetAll();
    audioState.reset();
    audio.stopAll();
    isRunning = true;
    showGraph = false;
    viewpoint = Viewpoint.top;
    rotationAmount = 0;
    showScreen = false;
    slowMotion = false;
    _eventAccumulator = 0;
    notifyListeners();
  }

  void setSlowMotion(bool value) {
    if (slowMotion == value) return;
    slowMotion = value;
    notifyListeners();
  }

  void setShowGraph(bool value) {
    showGraph = value;
    notifyListeners();
  }

  void setViewpoint(Viewpoint v) {
    if (viewpoint == v) return;
    viewpoint = v;
    notifyListeners();
  }

  void setShowScreen(bool value) {
    showScreen = value;
    notifyListeners();
  }

  void setAmplitude(double v) {
    final prev = scene.controlAmplitude;
    scene.setAmplitude(v);
    if ((v - prev).abs() > 1e-9) {
      audio.playSliderClick(state: audioState, increasing: v > prev);
    }
    notifyListeners();
  }

  void setFrequency(double v) {
    final prev = scene.controlFrequency;
    scene.setFrequency(v);
    if ((v - prev).abs() > 1e-9) {
      audio.playSliderClick(state: audioState, increasing: v > prev);
    }
    notifyListeners();
  }

  void setMute(bool muted) {
    audioState.muted = muted;
    if (muted) {
      audio.stopAll();
    } else {
      _syncAudio();
    }
    notifyListeners();
  }

  void setMasterVolume(double v) {
    audioState.masterVolume = v.clamp(0.0, 1.0);
    _syncAudio();
    notifyListeners();
  }

  void setTonePlaying(bool value) {
    audioState.isTonePlaying = value;
    _syncAudio();
    notifyListeners();
  }

  void setSoundEffectEnabled(bool value) {
    audioState.soundEffectEnabled = value;
    _syncAudio();
    notifyListeners();
  }

  void setDisturbanceType(DisturbanceType type) {
    scene.setDisturbanceType(type);
    notifyListeners();
  }

  void setButtonPressed(bool pressed) {
    scene.setButtonPressed(pressed);
    // [已确认] SoundScene.waveGeneratorButtonSound = no-op; Water/Light use button clip
    // Light: button sound suppressed when soundEffect enabled (plays beam instead)
    if (scene.config.kind == SceneKind.water) {
      audio.playButton(state: audioState, pressed: pressed);
    } else if (scene.config.kind == SceneKind.light &&
        !audioState.soundEffectEnabled) {
      audio.playButton(state: audioState, pressed: pressed);
    }
    _syncAudio();
    notifyListeners();
  }

  void setSoundViewType(SoundViewType type) {
    scene.soundViewType = type;
    notifyListeners();
  }

  // —— Tools ——

  void takeOutMeasuringTape() {
    tools.isMeasuringTapeInPlayArea = true;
    notifyListeners();
  }

  void returnMeasuringTape() {
    tools.resetMeasuringTape();
    notifyListeners();
  }

  void setMeasuringTapeBase(Offset o) {
    tools.measuringTapeBase = o;
    notifyListeners();
  }

  void setMeasuringTapeTip(Offset o) {
    tools.measuringTapeTip = o;
    notifyListeners();
  }

  void takeOutStopwatch() {
    tools.isStopwatchVisible = true;
    notifyListeners();
  }

  void returnStopwatch() {
    tools.resetStopwatch();
    notifyListeners();
  }

  void toggleStopwatchRunning() {
    tools.isStopwatchRunning = !tools.isStopwatchRunning;
    notifyListeners();
  }

  void clearStopwatchTime() {
    tools.stopwatchTime = 0;
    notifyListeners();
  }

  void takeOutWaveMeter() {
    tools.isWaveMeterInPlayArea = true;
    notifyListeners();
  }

  void returnWaveMeter() {
    tools.resetWaveMeter();
    audioState.meterSample1 = null;
    audioState.meterSample2 = null;
    audioState.series1Playing = false;
    audioState.series2Playing = false;
    _syncAudio();
    notifyListeners();
  }

  void setWaveMeterBody(Offset o) {
    tools.waveMeterBody = o;
    notifyListeners();
  }

  void setProbe1(Offset o) {
    tools.probe1 = o;
    notifyListeners();
  }

  void setProbe2(Offset o) {
    tools.probe2 = o;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    audio.dispose();
    super.dispose();
  }
}

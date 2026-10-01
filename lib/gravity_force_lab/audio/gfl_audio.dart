import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../model/gravity_force_constants.dart';
import '../model/gravity_force_lab_model.dart';
import 'gfl_audio_assets.dart';

/// Source-faithful Gravity Force Lab Full audio.
///
/// Maps:
/// - ContinuousPropertySoundClip(force, saturatedSineLoopTrimmed)
/// - MassSoundGenerator(rubberBand_v3) × 2 (EXTRA)
/// - MassBoundarySoundGenerator (scrunched + boundaryReached)
/// - ISLCRulerNode (grab / release / rulerMovement000)
class GflAudio {
  GflAudio({
    this.playEnabled = true,
    AudioPlayer? forcePlayer,
    AudioPlayer? oneShotPlayer,
  })  : _forcePlayer = forcePlayer,
        _oneShotPlayer = oneShotPlayer;

  /// When false, logic/counters still run but no AudioPlayer is created
  /// (widget tests without plugins).
  final bool playEnabled;

  AudioPlayer? _forcePlayer;
  AudioPlayer? _oneShotPlayer;

  GravityForceLabModel? _model;
  VoidCallback? _modelListener;
  VoidCallback? _paintListener;

  bool _disposed = false;
  bool _isResetting = false;
  bool _massSliderDraggingViaPointer = false;
  bool _forcePlaying = false;
  bool _rulerGrabbed = false;

  double _lastForce = double.nan;
  double _lastPos1 = double.nan;
  double _lastPos2 = double.nan;
  double _lastRulerSoundX = double.nan;
  double _lastRulerSoundY = double.nan;

  /// ContinuousPropertySoundClip fade countdown (seconds).
  double remainingFadeTime = 0;

  static const double forceOutputLevel = 0.15;
  static const double massSoundLevel = 0.7;
  static const double boundarySoundsLevel = 1.0;
  static const double fadeStartDelay = 0.2;
  static const double fadeTime = 0.15;
  static const double delayBeforeStop = 0.1;
  static const double playbackRateMin = 0.5;
  static const double playbackRateMax = 2.0;
  static const double normalizationMappingExponent = 0.15;
  static const double pitchRangeInSemiTones = 30;
  static const double rulerMovementSoundDistance = 0.5;

  static const List<double> massSoundThresholds = [
    10,
    100,
    200,
    300,
    400,
    500,
    600,
    700,
    800,
    900,
    1000,
  ];

  // —— Test observables ——
  int attachCount = 0;
  int forceActivationCount = 0;
  int forceUpdateCount = 0;
  int forceStopCount = 0;
  int massExtraCount = 0;
  int boundaryCount = 0;
  int rulerGrabCount = 0;
  int rulerMovementCount = 0;
  int rulerReleaseCount = 0;
  double lastForcePlaybackRate = 1;
  double lastForceOutputLevel = 0;
  double lastMassPlaybackRate = 1;
  String? lastOneShotAsset;

  bool get isDisposed => _disposed;
  bool get isForcePlaying => _forcePlaying;
  bool get isRulerGrabbed => _rulerGrabbed;
  bool get isMassSliderDragging => _massSliderDraggingViaPointer;
  bool get isResetting => _isResetting;

  /// Attach once to a model. Duplicate attach is a no-op (no second listeners).
  void attach(GravityForceLabModel model) {
    if (_disposed) return;
    if (_model == model && _modelListener != null) return;
    detach();
    _model = model;
    attachCount++;
    _lastForce = model.forceMagnitude;
    _lastPos1 = model.mass1.positionX;
    _lastPos2 = model.mass2.positionX;
    _lastRulerSoundX = model.ruler.positionX;
    _lastRulerSoundY = model.ruler.positionY;

    _modelListener = _onModelChanged;
    _paintListener = _onModelChanged;
    model.addListener(_modelListener!);
    model.paintEpoch.addListener(_paintListener!);
  }

  void detach() {
    final m = _model;
    if (m != null && _modelListener != null) {
      m.removeListener(_modelListener!);
      m.paintEpoch.removeListener(_paintListener!);
    }
    _model = null;
    _modelListener = null;
    _paintListener = null;
    // Screen leave / re-attach: stop continuous force and clear grab state.
    resetContinuousForce();
    _rulerGrabbed = false;
    _massSliderDraggingViaPointer = false;
  }

  void setMassSliderDraggingViaPointer(bool dragging) {
    _massSliderDraggingViaPointer = dragging;
  }

  /// MassSoundGenerator listener (lazyLink semantics: first seed via attach).
  void onMassValueChanged(int which, double newMass, double previousMass) {
    if (_disposed || _isResetting) return;

    var playForThisChange = true;
    if (_massSliderDraggingViaPointer) {
      playForThisChange = massSoundThresholds.any((t) {
        return newMass == t ||
            (newMass > t && previousMass < t) ||
            (newMass < t && previousMass > t);
      });
    }
    if (!playForThisChange) return;

    final rate = massPlaybackRate(newMass);
    lastMassPlaybackRate = rate;
    massExtraCount++;
    _playOneShot(
      GflAudioAssets.rubberBandV3,
      volume: massSoundLevel,
      playbackRate: rate,
    );
  }

  void beginReset() {
    _isResetting = true;
    resetContinuousForce();
    _rulerGrabbed = false;
  }

  void endReset() {
    final m = _model;
    if (m != null) {
      _lastForce = m.forceMagnitude;
      _lastPos1 = m.mass1.positionX;
      _lastPos2 = m.mass2.positionX;
      _lastRulerSoundX = m.ruler.positionX;
      _lastRulerSoundY = m.ruler.positionY;
    }
    _isResetting = false;
  }

  void resetContinuousForce() {
    remainingFadeTime = 0;
    lastForceOutputLevel = 0;
    if (_forcePlaying) {
      _forcePlaying = false;
      forceStopCount++;
      _stopForcePlayer();
    }
  }

  /// ContinuousPropertySoundClip.step(dt).
  void step(double dt) {
    if (_disposed || remainingFadeTime <= 0) return;
    remainingFadeTime = math.max(remainingFadeTime - dt, 0);

    if (remainingFadeTime < fadeTime + delayBeforeStop &&
        lastForceOutputLevel > 0) {
      final level =
          math.max((remainingFadeTime - delayBeforeStop) / fadeTime, 0.0);
      lastForceOutputLevel = level * forceOutputLevel;
      _setForceVolume(lastForceOutputLevel);
    }

    if (remainingFadeTime == 0 && _forcePlaying) {
      _forcePlaying = false;
      forceStopCount++;
      _stopForcePlayer();
      lastForceOutputLevel = 0;
    }
  }

  void onRulerGrab() {
    if (_disposed || _isResetting) return;
    if (_rulerGrabbed) return;
    _rulerGrabbed = true;
    rulerGrabCount++;
    final m = _model;
    if (m != null) {
      _lastRulerSoundX = m.ruler.positionX;
      _lastRulerSoundY = m.ruler.positionY;
    }
    _playOneShot(GflAudioAssets.grab, volume: 0.7);
  }

  void onRulerMove() {
    if (_disposed || _isResetting || !_rulerGrabbed) return;
    final m = _model;
    if (m == null) return;
    final dx = m.ruler.positionX - _lastRulerSoundX;
    final dy = m.ruler.positionY - _lastRulerSoundY;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist > rulerMovementSoundDistance) {
      _lastRulerSoundX = m.ruler.positionX;
      _lastRulerSoundY = m.ruler.positionY;
      rulerMovementCount++;
      _playOneShot(GflAudioAssets.rulerMovement000, volume: 0.7);
    }
  }

  void onRulerRelease() {
    if (_disposed) return;
    if (!_rulerGrabbed) return;
    _rulerGrabbed = false;
    if (_isResetting) return;
    rulerReleaseCount++;
    _playOneShot(GflAudioAssets.release, volume: 0.7);
  }

  /// Public helpers for unit tests (source mapping).
  static double forcePlaybackRate(
    double force, {
    required double forceMin,
    required double forceMax,
  }) {
    final span = forceMax - forceMin;
    if (span.abs() < 1e-30) return playbackRateMin;
    final normalized = ((force - forceMin) / span).clamp(0.0, 1.0);
    final mapped = math.pow(normalized, normalizationMappingExponent).toDouble();
    return playbackRateMin + mapped * (playbackRateMax - playbackRateMin);
  }

  static double massPlaybackRate(
    double mass, {
    double massMin = GravityForceConstants.massMin,
    double massMax = GravityForceConstants.massMax,
  }) {
    final normalizedMass = (mass - massMin) / (massMax - massMin);
    final centerAndFlippedNormMass = ((1 - normalizedMass) - 0.5);
    final midiNote = pitchRangeInSemiTones / 2 * centerAndFlippedNormMass;
    return math.pow(2, midiNote / 12).toDouble();
  }

  void _onModelChanged() {
    if (_disposed || _model == null || _isResetting) return;
    final m = _model!;
    final f = m.forceMagnitude;
    if (f != _lastForce && !f.isNaN) {
      // ContinuousPropertySoundClip uses lazyLink — skip only the attach seed.
      if (!_lastForce.isNaN) {
        _onForceChanged(f);
      }
      _lastForce = f;
    }

    _checkBoundary(
      which: 1,
      position: m.mass1.positionX,
      previous: _lastPos1,
      minPos: m.mass1EnabledMin,
      maxPos: m.mass1EnabledMax,
      sideLeft: true,
    );
    _checkBoundary(
      which: 2,
      position: m.mass2.positionX,
      previous: _lastPos2,
      minPos: m.mass2EnabledMin,
      maxPos: m.mass2EnabledMax,
      sideLeft: false,
    );
    _lastPos1 = m.mass1.positionX;
    _lastPos2 = m.mass2.positionX;
  }

  void _onForceChanged(double force) {
    final m = _model!;
    final rate = forcePlaybackRate(
      force,
      forceMin: m.minForceMagnitude,
      forceMax: m.maxForce,
    );
    lastForcePlaybackRate = rate;
    lastForceOutputLevel = forceOutputLevel;
    forceUpdateCount++;
    remainingFadeTime = fadeStartDelay + fadeTime + delayBeforeStop;

    if (!_forcePlaying) {
      _forcePlaying = true;
      forceActivationCount++;
      _startForceLoop(rate);
    } else {
      _setForceRate(rate);
      _setForceVolume(forceOutputLevel);
    }
  }

  void _checkBoundary({
    required int which,
    required double position,
    required double previous,
    required double minPos,
    required double maxPos,
    required bool sideLeft,
  }) {
    if (position == previous) return;
    final m = _model!;
    // MassBoundarySoundGenerator: skip when massWasPushed().
    if (m.pushedObject != null) return;

    if (position == minPos) {
      boundaryCount++;
      final asset = sideLeft
          ? GflAudioAssets.boundaryReached
          : GflAudioAssets.scrunchedMassCollisionSonicWomp;
      _playOneShot(asset, volume: boundarySoundsLevel);
    } else if (position == maxPos) {
      boundaryCount++;
      final asset = sideLeft
          ? GflAudioAssets.scrunchedMassCollisionSonicWomp
          : GflAudioAssets.boundaryReached;
      _playOneShot(asset, volume: boundarySoundsLevel);
    }
  }

  Future<void> _startForceLoop(double rate) async {
    if (_disposed || !playEnabled) return;
    try {
      _forcePlayer ??= AudioPlayer();
      await _forcePlayer!.stop();
      await _forcePlayer!.setReleaseMode(ReleaseMode.loop);
      await _forcePlayer!.setPlaybackRate(rate);
      await _forcePlayer!.setVolume(forceOutputLevel);
      await _forcePlayer!.play(
        AssetSource(GflAudioAssets.relative(
          GflAudioAssets.saturatedSineLoopTrimmed,
        )),
      );
    } catch (e) {
      debugPrint('GflAudio force: $e');
    }
  }

  Future<void> _setForceRate(double rate) async {
    if (_disposed || !playEnabled || _forcePlayer == null) return;
    try {
      await _forcePlayer!.setPlaybackRate(rate);
    } catch (_) {}
  }

  Future<void> _setForceVolume(double v) async {
    if (_disposed || !playEnabled || _forcePlayer == null) return;
    try {
      await _forcePlayer!.setVolume(v);
    } catch (_) {}
  }

  Future<void> _stopForcePlayer() async {
    if (!playEnabled || _forcePlayer == null) return;
    try {
      await _forcePlayer!.stop();
    } catch (_) {}
  }

  Future<void> _playOneShot(
    String asset, {
    required double volume,
    double playbackRate = 1.0,
  }) async {
    lastOneShotAsset = asset;
    if (_disposed || !playEnabled) return;
    try {
      _oneShotPlayer ??= AudioPlayer();
      await _oneShotPlayer!.stop();
      await _oneShotPlayer!.setPlaybackRate(playbackRate);
      await _oneShotPlayer!.setVolume(volume);
      await _oneShotPlayer!.play(
        AssetSource(GflAudioAssets.relative(asset)),
      );
    } catch (e) {
      debugPrint('GflAudio oneShot: $e');
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    detach();
    remainingFadeTime = 0;
    _forcePlaying = false;
    _rulerGrabbed = false;
    try {
      await _forcePlayer?.dispose();
    } catch (_) {}
    try {
      await _oneShotPlayer?.dispose();
    } catch (_) {}
    _forcePlayer = null;
    _oneShotPlayer = null;
  }
}

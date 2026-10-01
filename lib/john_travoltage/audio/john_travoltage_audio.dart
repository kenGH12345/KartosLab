import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../john_travoltage_assets.dart';
import '../model/john_travoltage_constants.dart';
import '../model/john_travoltage_model.dart';

/// Audio constants from PhET `JohnTravoltageView.js`.
abstract final class JtAudioConstants {
  /// Delay before ouch/gazouch after spark becomes visible.
  static const double ouchExclamationDelaySeconds = 0.5;

  /// `CHARGES_SOUND_GAIN_FACTOR` in JohnTravoltageView.js.
  static const double chargesSoundGainFactor = 0.1;

  static const double electricDischargeVolume = 0.75;
  static const double ouchVolume = 0.7;
  static const double gazouchVolume = 0.8;
  static const double armPositionVolume = 0.2;

  static const int armSoundPositions = 32;
  static const int maxArmSoundsPerIteration = 3;
  static const double armAngleOfHighestPitch = 0.45;
}

/// Central audio controller — PhET sound wiring in `JohnTravoltageView.js`.
///
/// Does not play from GestureDetector / CustomPainter / build.
class JohnTravoltageAudio {
  JohnTravoltageAudio(
    this.model, {
    math.Random? random,
    this.enabled = true,
  }) : _random = random ?? math.Random() {
    model.addListener(_onModel);
    model.addDischargeStartedListener(_onDischargeStarted);
    model.addDischargeEndedListener(_onDischargeEnded);
    model.addResetListener(_onReset);
    _previousElectronCount = model.electronCount;
    _previousArmAngle = model.arm.angle;
  }

  final JohnTravoltageModel model;
  final math.Random _random;
  final bool enabled;

  AudioPlayer? _electricDischarge;
  AudioPlayer? _chargesInBody;
  AudioPlayer? _ouch;
  AudioPlayer? _armRatchet;

  Timer? _ouchTimer;
  bool _disposed = false;
  bool _chargesPlaying = false;

  int _previousElectronCount = 0;
  double? _previousArmAngle;
  int _previousRatchetIndex = -1;

  /// Test hooks (updated even when [enabled] is false).
  int electricDischargeStartCount = 0;
  int electricDischargeStopCount = 0;
  int ouchScheduledCount = 0;
  int ouchCancelledCount = 0;
  int gazouchScheduledCount = 0;
  int chargesStartCount = 0;
  int chargesStopCount = 0;
  int armClickCount = 0;

  bool get hasPendingOuch => _ouchTimer?.isActive ?? false;

  static String _relative(String assetPath) =>
      assetPath.startsWith('assets/') ? assetPath.substring(7) : assetPath;

  void _onModel() {
    if (_disposed) return;
    _updateChargesInBody();
    _updateArmPositionSounds();
  }

  void _onDischargeStarted() {
    if (_disposed) return;
    electricDischargeStartCount++;
    _scheduleOuchOrGazouch(model.electronCount);
    if (enabled) {
      unawaited(_startElectricDischargePlayer());
    }
  }

  void _onDischargeEnded() {
    if (_disposed) return;
    electricDischargeStopCount++;
    if (enabled) {
      unawaited(_stopElectricDischargePlayer());
    }
  }

  void _onReset() {
    _cancelOuchTimer();
    unawaited(_stopElectricDischargePlayer());
    unawaited(_stopChargesInBodyPlayer());
    _previousElectronCount = 0;
    _previousArmAngle = model.arm.angle;
  }

  Future<void> _startElectricDischargePlayer() async {
    try {
      _electricDischarge ??= AudioPlayer();
      await _electricDischarge!.stop();
      await _electricDischarge!.setReleaseMode(ReleaseMode.loop);
      await _electricDischarge!
          .setVolume(JtAudioConstants.electricDischargeVolume);
      await _electricDischarge!.play(
        AssetSource(_relative(JohnTravoltageAssets.electricDischarge)),
      );
    } catch (e) {
      debugPrint('JT audio electricDischarge: $e');
    }
  }

  Future<void> _stopElectricDischargePlayer() async {
    try {
      await _electricDischarge?.stop();
    } catch (_) {}
  }

  void _scheduleOuchOrGazouch(int numElectronsInBody) {
    _cancelOuchTimer();
    void fire(String asset, double volume) {
      if (!enabled) return;
      unawaited(_playOneShot(asset, volume));
    }

    if (numElectronsInBody > 85) {
      gazouchScheduledCount++;
      _ouchTimer = Timer(
        Duration(
          milliseconds:
              (JtAudioConstants.ouchExclamationDelaySeconds * 1000).round(),
        ),
        () => fire(
              JohnTravoltageAssets.gazouch,
              JtAudioConstants.gazouchVolume,
            ),
      );
    } else if (numElectronsInBody > 30) {
      ouchScheduledCount++;
      _ouchTimer = Timer(
        Duration(
          milliseconds:
              (JtAudioConstants.ouchExclamationDelaySeconds * 1000).round(),
        ),
        () => fire(
              JohnTravoltageAssets.ouch,
              JtAudioConstants.ouchVolume,
            ),
      );
    }
  }

  void _cancelOuchTimer() {
    if (_ouchTimer != null) {
      if (_ouchTimer!.isActive) {
        ouchCancelledCount++;
      }
      _ouchTimer!.cancel();
      _ouchTimer = null;
    }
  }

  Future<void> _playOneShot(String asset, double volume) async {
    if (_disposed || !enabled) return;
    try {
      _ouch ??= AudioPlayer();
      await _ouch!.stop();
      await _ouch!.setReleaseMode(ReleaseMode.release);
      await _ouch!.setVolume(volume);
      await _ouch!.play(AssetSource(_relative(asset)));
    } catch (e) {
      debugPrint('JT audio one-shot: $e');
    }
  }

  Future<void> _updateChargesInBody() async {
    final n = model.electronCount;
    if (n == _previousElectronCount) return;
    _previousElectronCount = n;

    if (n == 0) {
      await _stopChargesInBodyPlayer();
      return;
    }

    if (!_chargesPlaying) {
      chargesStartCount++;
      _chargesPlaying = true;
    }

    if (!enabled) return;

    final level = 0.01 +
        0.99 *
            (n / JohnTravoltageConstants.maxElectrons) *
            JtAudioConstants.chargesSoundGainFactor;
    final rate = 1 + 0.25 * (n / JohnTravoltageConstants.maxElectrons);

    try {
      _chargesInBody ??= AudioPlayer();
      await _chargesInBody!.setVolume(level.clamp(0.0, 1.0));
      await _chargesInBody!.setPlaybackRate(rate.clamp(0.5, 2.0));
      await _chargesInBody!.setReleaseMode(ReleaseMode.loop);
      // Restart only when newly becoming non-zero was tracked above; keep loop.
      final state = _chargesInBody!.state;
      if (state != PlayerState.playing) {
        await _chargesInBody!.play(
          AssetSource(_relative(JohnTravoltageAssets.chargesInBody)),
        );
      }
    } catch (e) {
      debugPrint('JT audio chargesInBody: $e');
    }
  }

  Future<void> _stopChargesInBodyPlayer() async {
    if (_chargesPlaying) {
      chargesStopCount++;
    }
    _chargesPlaying = false;
    try {
      await _chargesInBody?.stop();
    } catch (_) {}
  }

  void _updateArmPositionSounds() {
    final angle = model.arm.angle;
    final previous = _previousArmAngle;
    _previousArmAngle = angle;
    if (previous == null) return;

    const binSize = 2 * math.pi / JtAudioConstants.armSoundPositions;
    var numClicks =
        ((previous / binSize).floor() - (angle / binSize).floor()).abs();
    if (numClicks > JtAudioConstants.armSoundPositions / 2) {
      numClicks = 0;
    }
    final toPlay =
        math.min(numClicks, JtAudioConstants.maxArmSoundsPerIteration);
    if (toPlay <= 0) return;

    var angularDistanceFromKnob =
        (JtAudioConstants.armAngleOfHighestPitch - angle).abs();
    if (angularDistanceFromKnob > math.pi) {
      angularDistanceFromKnob = math.pi - angularDistanceFromKnob % math.pi;
    }
    final playbackRate =
        0.75 + 0.75 * (1 - angularDistanceFromKnob / math.pi);

    for (var i = 0; i < toPlay; i++) {
      armClickCount++;
      if (enabled) {
        unawaited(_playArmRatchet(playbackRate));
      }
    }
  }

  Future<void> _playArmRatchet(double playbackRate) async {
    if (_disposed || !enabled) return;
    try {
      var index = _random.nextInt(JohnTravoltageAssets.armPositionSounds.length);
      if (index == _previousRatchetIndex &&
          JohnTravoltageAssets.armPositionSounds.length > 1) {
        index = (index + 1) % JohnTravoltageAssets.armPositionSounds.length;
      }
      _previousRatchetIndex = index;
      _armRatchet ??= AudioPlayer();
      await _armRatchet!.stop();
      await _armRatchet!.setReleaseMode(ReleaseMode.release);
      await _armRatchet!.setVolume(JtAudioConstants.armPositionVolume);
      await _armRatchet!.setPlaybackRate(playbackRate.clamp(0.5, 2.0));
      await _armRatchet!.play(
        AssetSource(_relative(JohnTravoltageAssets.armPositionSounds[index])),
      );
    } catch (e) {
      debugPrint('JT audio arm ratchet: $e');
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _cancelOuchTimer();
    model.removeListener(_onModel);
    model.removeDischargeStartedListener(_onDischargeStarted);
    model.removeDischargeEndedListener(_onDischargeEnded);
    model.removeResetListener(_onReset);
    await _stopElectricDischargePlayer();
    await _stopChargesInBodyPlayer();
    await _electricDischarge?.dispose();
    await _chargesInBody?.dispose();
    await _ouch?.dispose();
    await _armRatchet?.dispose();
    _electricDischarge = null;
    _chargesInBody = null;
    _ouch = null;
    _armRatchet = null;
  }
}

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../model/balloon_model.dart';
import '../model/balloons_static_electricity_constants.dart';
import '../model/balloons_static_electricity_model.dart';
import '../view/base_view_layout.dart';

/// Audio volumes from PhET `BalloonNode` / generators (approximate).
abstract final class BaseAudioConstants {
  static const double grabReleaseLevel = 0.1;
  static const double hitSweaterLevel = 0.075;
  static const double wallContactLevel = 0.15;
  static const double chargeDeflectionLevel = 0.3;
  static const double popLevel = 0.3;
  static const double rubbingLevel = 0.25;
  static const double velocityLevel = 0.2;

  /// Min wall-charge displacement delta to trigger deflection clip.
  static const double deflectionTriggerDelta = 2.0;

  /// Cooldown between deflection one-shots (seconds).
  static const double deflectionCooldownSeconds = 0.12;

  /// Free-flight velocity magnitude to start drift carrier.
  static const double velocitySoundThreshold = 0.0005;
}

/// Central audio controller — PhET BalloonNode / BASEView sound wiring.
///
/// Observes [BalloonsStaticElectricityModel] only; does not alter physics.
/// Test counters update even when [enabled] is false.
class BaseAudio {
  BaseAudio(
    this.model, {
    this.enabled = true,
  }) {
    model.addListener(_onModel);
    model.addStepListener(_onStep);
    _snapshot();
  }

  final BalloonsStaticElectricityModel model;
  final bool enabled;

  bool _disposed = false;

  AudioPlayer? _oneShot;
  AudioPlayer? _rubbing;
  AudioPlayer? _velocity;

  bool _rubbingPlaying = false;
  bool _velocityPlaying = false;
  double _deflectionCooldown = 0;

  // Previous-state snapshot for edge detection.
  late bool _yellowControlled;
  late bool _greenControlled;
  late int _yellowCharge;
  late int _greenCharge;
  late bool _yellowOnSweater;
  late bool _greenOnSweater;
  late bool _yellowTouchingWall;
  late bool _greenTouchingWall;
  late double _yellowSpeed;
  late double _greenSpeed;
  late double _wallDisplacementSum;

  // --- Test hooks ---
  int grabCount = 0;
  int releaseCount = 0;
  int hitSweaterCount = 0;
  int wallContactCount = 0;
  int chargePopCount = 0;
  int chargeDeflectionCount = 0;
  int rubbingStartCount = 0;
  int rubbingStopCount = 0;
  int velocityStartCount = 0;
  int velocityStopCount = 0;
  int resetStopCount = 0;

  static String _relative(String assetPath) =>
      assetPath.startsWith('assets/') ? assetPath.substring(7) : assetPath;

  void _snapshot() {
    final y = model.yellowBalloon;
    final g = model.greenBalloon;
    _yellowControlled = y.userControlled;
    _greenControlled = g.userControlled;
    _yellowCharge = y.charge;
    _greenCharge = g.charge;
    _yellowOnSweater = y.onSweater;
    _greenOnSweater = g.onSweater;
    _yellowTouchingWall = y.touchingWall;
    _greenTouchingWall = g.touchingWall;
    _yellowSpeed = y.velocity.magnitude;
    _greenSpeed = g.velocity.magnitude;
    _wallDisplacementSum = _sumWallDisplacement();
  }

  double _sumWallDisplacement() {
    var sum = 0.0;
    for (final c in model.wall.minusCharges) {
      sum += c.getDisplacement();
    }
    return sum;
  }

  void _onStep(double dt) {
    if (_disposed) return;
    if (_deflectionCooldown > 0) {
      _deflectionCooldown -= dt;
      if (_deflectionCooldown < 0) _deflectionCooldown = 0;
    }
  }

  void _onModel() {
    if (_disposed) return;
    _detectGrabRelease(model.yellowBalloon, wasControlled: _yellowControlled);
    _detectGrabRelease(model.greenBalloon, wasControlled: _greenControlled);
    _detectChargePop(model.yellowBalloon, previous: _yellowCharge);
    _detectChargePop(model.greenBalloon, previous: _greenCharge);
    _detectHitSweater(
      model.yellowBalloon,
      wasOnSweater: _yellowOnSweater,
      previousSpeed: _yellowSpeed,
    );
    _detectHitSweater(
      model.greenBalloon,
      wasOnSweater: _greenOnSweater,
      previousSpeed: _greenSpeed,
    );
    _detectWallContact(model.yellowBalloon, wasTouching: _yellowTouchingWall);
    _detectWallContact(model.greenBalloon, wasTouching: _greenTouchingWall);
    _detectDeflection();
    _updateRubbing();
    _updateVelocity();
    _snapshot();
  }

  void _detectGrabRelease(BalloonModel balloon, {required bool wasControlled}) {
    if (!balloon.isVisible) return;
    if (!wasControlled && balloon.userControlled) {
      grabCount++;
      unawaited(_playOneShot(
        BaseAssets.balloonGrab,
        BaseAudioConstants.grabReleaseLevel,
      ));
    } else if (wasControlled && !balloon.userControlled) {
      releaseCount++;
      unawaited(_playOneShot(
        BaseAssets.balloonRelease,
        BaseAudioConstants.grabReleaseLevel,
      ));
    }
  }

  void _detectChargePop(BalloonModel balloon, {required int previous}) {
    if (!balloon.isVisible) return;
    if (balloon.charge < previous) {
      // More negative = acquired electrons.
      chargePopCount++;
      unawaited(_playOneShot(
        BaseAssets.carrier000,
        BaseAudioConstants.popLevel *
            (balloon.charge.abs() / 57).clamp(0.05, 1.0),
      ));
    }
  }

  void _detectHitSweater(
    BalloonModel balloon, {
    required bool wasOnSweater,
    required double previousSpeed,
  }) {
    if (!balloon.isVisible) return;
    // PhET: velocity → 0 while on sweater after free motion.
    final nowSpeed = balloon.velocity.magnitude;
    if (balloon.onSweater &&
        !balloon.userControlled &&
        previousSpeed > 0 &&
        nowSpeed == 0) {
      hitSweaterCount++;
      unawaited(_playOneShot(
        BaseAssets.balloonHitSweater,
        BaseAudioConstants.hitSweaterLevel,
      ));
    } else if (!wasOnSweater && balloon.onSweater && balloon.userControlled) {
      // Soft cue when drag first overlaps sweater.
      hitSweaterCount++;
      unawaited(_playOneShot(
        BaseAssets.balloonHitSweater,
        BaseAudioConstants.hitSweaterLevel * 0.6,
      ));
    }
  }

  void _detectWallContact(BalloonModel balloon, {required bool wasTouching}) {
    if (!balloon.isVisible || !model.wall.isVisible) return;
    if (!wasTouching && balloon.touchingWall) {
      wallContactCount++;
      unawaited(_playOneShot(
        BaseAssets.wallContact,
        BaseAudioConstants.wallContactLevel,
      ));
    }
  }

  void _detectDeflection() {
    if (!model.wall.isVisible) return;
    if (model.showCharges != ShowCharges.allCharges) return;
    final sum = _sumWallDisplacement();
    final delta = sum - _wallDisplacementSum;
    if (delta > BaseAudioConstants.deflectionTriggerDelta &&
        _deflectionCooldown <= 0) {
      chargeDeflectionCount++;
      _deflectionCooldown = BaseAudioConstants.deflectionCooldownSeconds;
      unawaited(_playOneShot(
        BaseAssets.chargeDeflection,
        BaseAudioConstants.chargeDeflectionLevel,
      ));
    }
  }

  void _updateRubbing() {
    final active = _anyRubbing();
    if (active && !_rubbingPlaying) {
      rubbingStartCount++;
      _rubbingPlaying = true;
      if (enabled) {
        unawaited(_startLoop(
          _rubbing ??= AudioPlayer(),
          BaseAssets.carrier000,
          BaseAudioConstants.rubbingLevel,
        ));
      }
    } else if (!active && _rubbingPlaying) {
      rubbingStopCount++;
      _rubbingPlaying = false;
      if (enabled) {
        unawaited(_stopPlayer(_rubbing));
      }
    }
  }

  bool _anyRubbing() {
    for (final b in model.balloons) {
      if (!b.isVisible || !b.userControlled) continue;
      if ((b.onSweater || b.touchingWall) &&
          b.dragVelocity.magnitude > 0) {
        return true;
      }
    }
    return false;
  }

  void _updateVelocity() {
    final drifting = _anyDrifting();
    if (drifting && !_velocityPlaying) {
      velocityStartCount++;
      _velocityPlaying = true;
      if (enabled) {
        unawaited(_startLoop(
          _velocity ??= AudioPlayer(),
          BaseAssets.carrier002,
          BaseAudioConstants.velocityLevel,
        ));
      }
    } else if (!drifting && _velocityPlaying) {
      velocityStopCount++;
      _velocityPlaying = false;
      if (enabled) unawaited(_stopPlayer(_velocity));
    }
  }

  bool _anyDrifting() {
    for (final b in model.balloons) {
      if (!b.isVisible || b.userControlled) continue;
      if (b.touchingWall) continue;
      if (b.velocity.magnitude > BaseAudioConstants.velocitySoundThreshold) {
        return true;
      }
    }
    return false;
  }

  Future<void> _playOneShot(String asset, double volume) async {
    if (!enabled) return;
    try {
      _oneShot ??= AudioPlayer();
      await _oneShot!.stop();
      await _oneShot!.setReleaseMode(ReleaseMode.release);
      await _oneShot!.setVolume(volume.clamp(0.0, 1.0));
      await _oneShot!.play(AssetSource(_relative(asset)));
    } catch (e) {
      debugPrint('BASE audio oneShot: $e');
    }
  }

  Future<void> _startLoop(
    AudioPlayer player,
    String asset,
    double volume,
  ) async {
    try {
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.play(AssetSource(_relative(asset)));
    } catch (e) {
      debugPrint('BASE audio loop: $e');
    }
  }

  Future<void> _stopPlayer(AudioPlayer? player) async {
    try {
      await player?.stop();
    } catch (_) {}
  }

  /// Call on Reset All / Reset Balloons to clear loops (PhET resets sounds).
  void onReset() {
    resetStopCount++;
    _rubbingPlaying = false;
    _velocityPlaying = false;
    _deflectionCooldown = 0;
    unawaited(_stopPlayer(_rubbing));
    unawaited(_stopPlayer(_velocity));
    unawaited(_stopPlayer(_oneShot));
    _snapshot();
  }

  void dispose() {
    _disposed = true;
    model.removeListener(_onModel);
    model.removeStepListener(_onStep);
    unawaited(_stopPlayer(_rubbing));
    unawaited(_stopPlayer(_velocity));
    unawaited(_stopPlayer(_oneShot));
    unawaited(_rubbing?.dispose());
    unawaited(_velocity?.dispose());
    unawaited(_oneShot?.dispose());
  }
}

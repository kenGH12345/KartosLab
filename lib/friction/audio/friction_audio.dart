import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';

import '../friction_assets.dart';
import '../friction_constants.dart';

/// One-shot sound playback for Friction (PhET SoundClip ports).
///
/// Rub / molecule / cooling NoiseGenerators are P2 (procedural WebAudio).
class FrictionAudio {
  FrictionAudio();

  final AudioPlayer _oneShot = AudioPlayer();
  final math.Random _random = math.Random();
  bool _disposed = false;
  int _shearCountSinceReset = 0;

  Future<void> playSimplePickup() => _play(FrictionAssets.simplePickup, 0.1);
  Future<void> playSimpleDrop() => _play(FrictionAssets.simpleDrop, 0.1);
  Future<void> playHarpPickup() => _play(FrictionAssets.harpPickup, 0.1);
  Future<void> playHarpDrop() => _play(FrictionAssets.harpDrop, 0.1);
  Future<void> playContact() => _play(FrictionAssets.contactLower, 0.06);

  Future<void> onShearedOff() async {
    _shearCountSinceReset += 1;
    // PhET: play every 4th shear with random pentatonic rate
    if (_shearCountSinceReset % 4 != 0) return;
    final rates = FrictionConstants.majorPentatonicPlaybackRates;
    final rate = rates[_random.nextInt(rates.length)];
    await _play(FrictionAssets.breakOff, 0.05, playbackRate: rate);
  }

  void reset() {
    _shearCountSinceReset = 0;
  }

  Future<void> _play(String asset, double volume, {double playbackRate = 1.0}) async {
    if (_disposed) return;
    try {
      await _oneShot.stop();
      await _oneShot.setPlaybackRate(playbackRate);
      await _oneShot.setVolume(volume);
      await _oneShot.play(AssetSource(asset.replaceFirst('assets/', '')));
    } catch (_) {
      // Audio failures must not crash the sim.
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await _oneShot.dispose();
  }
}

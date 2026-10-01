import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../model/peg.dart';
import '../plinko_assets.dart';
import '../plinko_constants.dart';

/// Peg hit sounds — `PegSoundGeneration.js`.
///
/// left → bonk1, right → bonk2; throttled by [PlinkoConstants.soundTimeInterval].
/// AudioPlayer is created lazily so widget tests (no plugin) stay clean.
class PegSoundGeneration {
  PegSoundGeneration();

  AudioPlayer? _player;
  double soundTimeElapsed = 1;
  bool enabled = false;

  void step(double dt) {
    soundTimeElapsed += dt;
  }

  void reset() {
    soundTimeElapsed = 0;
  }

  Future<void> playBallHittingPegSound(PegDirection direction) async {
    if (!enabled) return;
    if (soundTimeElapsed <= PlinkoConstants.soundTimeInterval) return;
    soundTimeElapsed = 0;
    final asset = direction == PegDirection.left
        ? PlinkoAssets.bonkLeft
        : PlinkoAssets.bonkRight;
    final relative = asset.startsWith('assets/')
        ? asset.substring('assets/'.length)
        : asset;
    try {
      _player ??= AudioPlayer();
      await _player!.stop();
      await _player!.play(AssetSource(relative), volume: 0.6);
    } catch (e) {
      debugPrint('PegSoundGeneration: $e');
    }
  }

  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
  }
}

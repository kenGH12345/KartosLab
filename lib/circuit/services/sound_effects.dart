import 'package:audioplayers/audioplayers.dart';

/// Optional one-shot SFX. Player is created lazily so golden / VM tests that
/// never play sounds do not require the audioplayers plugin.
class SoundEffects {
  SoundEffects();

  AudioPlayer? _player;
  bool _unavailable = false;

  Future<AudioPlayer?> _ensurePlayer() async {
    if (_unavailable) return null;
    if (_player != null) return _player;
    try {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      _player = player;
      return player;
    } catch (_) {
      _unavailable = true;
      return null;
    }
  }

  Future<void> tap() async {
    try {
      final player = await _ensurePlayer();
      if (player == null) return;
      await player.stop();
      await player.play(AssetSource('sounds/tap.wav'), volume: 0.25);
    } catch (_) {
      // Audio must never crash the sim.
    }
  }

  Future<void> dispose() async {
    final player = _player;
    _player = null;
    if (player != null) {
      try {
        await player.dispose();
      } catch (_) {}
    }
  }
}

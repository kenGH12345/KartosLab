import 'package:audioplayers/audioplayers.dart';

class SoundEffects {
  SoundEffects() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  final AudioPlayer _player = AudioPlayer();

  Future<void> tap() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/tap.wav'), volume: 0.25);
    } catch (_) {
      // 异常
    }
  }

  Future<void> dispose() => _player.dispose();
}

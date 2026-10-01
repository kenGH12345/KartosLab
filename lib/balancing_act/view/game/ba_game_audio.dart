/// Minimal Vegas [GameAudioPlayer] semantic adapter.
/// Source audio lives in vegas package (ding/boing/cheer); local BA audio = 0.
/// Hooks are always invoked; playback is optional / muted when assets missing.
class BaGameAudioPlayer {
  BaGameAudioPlayer({this.enabled = true});

  final bool enabled;
  final List<String> eventLog = [];

  void correctAnswer() => _log('correctAnswer');
  void wrongAnswer() => _log('wrongAnswer');
  void gameOverPerfectScore() => _log('gameOverPerfectScore');
  void gameOverImperfectScore() => _log('gameOverImperfectScore');
  void gameOverZeroScore() => _log('gameOverZeroScore');

  void _log(String event) {
    eventLog.add(event);
    // Local BA audio assets = 0. Vegas built-in sounds are not bundled in
    // this Flutter port; trigger semantics are preserved for tests / future.
    if (!enabled) return;
  }

  void clearLog() => eventLog.clear();
}

import 'package:audioplayers/audioplayers.dart';

import '../concentration_assets.dart';

/// Source-defined Concentration basic-sound API (View layer only).
///
/// Official beers-law-lab uses scenery-phet:
/// - `SoundDragListener` / `SoundKeyboardDragListener`
/// - tambo `sharedSoundPlayers.get('grab'|'release')`
///
/// Bound in source to Shaker, Probe, and Faucet (`FaucetNode`).
abstract class ConcentrationAudio {
  Future<void> onDragStart();
  Future<void> onDragEnd({bool interrupted = false});
  Future<void> onFaucetClosed();
  Future<void> stopAll();
  Future<void> dispose();

  bool get isDragging;
  bool get isDisposed;
  int get grabCount;
  int get releaseCount;
}

/// Real player — tambo `grab.mp3` / `release.mp3` at default UI level 0.7.
class ConcentrationAudioPlayer implements ConcentrationAudio {
  ConcentrationAudioPlayer({
    AudioPlayer? player,
    this.enabled = true,
  }) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  final bool enabled;

  bool _disposed = false;
  bool _dragging = false;
  int _grabCount = 0;
  int _releaseCount = 0;

  /// Source `DEFAULT_SOUND_CLIP_PLAYER_OPTIONS` initialOutputLevel.
  static const double defaultVolume = 0.7;

  @override
  bool get isDragging => _dragging;

  @override
  bool get isDisposed => _disposed;

  @override
  int get grabCount => _grabCount;

  @override
  int get releaseCount => _releaseCount;

  @override
  Future<void> onDragStart() async {
    if (_disposed || !enabled) return;
    if (_dragging) return;
    _dragging = true;
    _grabCount++;
    await _play(ConcentrationAssets.grabSound);
  }

  @override
  Future<void> onDragEnd({bool interrupted = false}) async {
    if (_disposed || !enabled) return;
    if (!_dragging) return;
    _dragging = false;
    if (interrupted) return;
    _releaseCount++;
    await _play(ConcentrationAssets.releaseSound);
  }

  @override
  Future<void> onFaucetClosed() async {
    if (_disposed || !enabled) return;
    _dragging = false;
    _releaseCount++;
    await _play(ConcentrationAssets.releaseSound);
  }

  @override
  Future<void> stopAll() async {
    if (_disposed) return;
    _dragging = false;
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> _play(String assetPath) async {
    if (_disposed) return;
    try {
      final relative = assetPath.startsWith('assets/')
          ? assetPath.substring('assets/'.length)
          : assetPath;
      await _player.stop();
      await _player.setVolume(defaultVolume);
      await _player.play(AssetSource(relative));
    } catch (_) {
      // Platform / missing decode must not crash the sim.
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _dragging = false;
    try {
      await _player.stop();
      await _player.dispose();
    } catch (_) {}
  }
}

/// In-memory sink for lifecycle / wiring tests (no platform audio).
class RecordingConcentrationAudio implements ConcentrationAudio {
  final List<String> events = <String>[];
  bool _dragging = false;
  bool _disposed = false;
  int _grabCount = 0;
  int _releaseCount = 0;

  @override
  bool get isDragging => _dragging;

  @override
  bool get isDisposed => _disposed;

  @override
  int get grabCount => _grabCount;

  @override
  int get releaseCount => _releaseCount;

  @override
  Future<void> onDragStart() async {
    if (_disposed) return;
    if (_dragging) return;
    _dragging = true;
    _grabCount++;
    events.add('grab');
  }

  @override
  Future<void> onDragEnd({bool interrupted = false}) async {
    if (_disposed) return;
    if (!_dragging) return;
    _dragging = false;
    if (interrupted) return;
    _releaseCount++;
    events.add('release');
  }

  @override
  Future<void> onFaucetClosed() async {
    if (_disposed) return;
    _dragging = false;
    _releaseCount++;
    events.add('faucetClosed');
  }

  @override
  Future<void> stopAll() async {
    if (_disposed) return;
    _dragging = false;
    events.add('stopAll');
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _dragging = false;
    events.add('dispose');
  }
}

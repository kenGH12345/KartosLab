import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

import '../assets/qwi_assets.dart';

/// Plays original PhET `snapshotCaptured.mp3` on successful snapshot capture.
///
/// Lazily constructs [AudioPlayer] only when a Flutter binding exists, so pure
/// unit tests can exercise `takeSnapshot` without audioplayers plugins.
class QwiSnapshotAudio {
  QwiSnapshotAudio({this.enabled = true});

  final bool enabled;
  AudioPlayer? _player;
  bool _disposed = false;
  int playCount = 0;

  bool get _bindingReady {
    try {
      WidgetsBinding.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> playSnapshotCaptured() async {
    if (_disposed) {
      return;
    }
    playCount++;
    if (!enabled || !_bindingReady) {
      return;
    }
    try {
      _player ??= AudioPlayer();
      await _player!.stop();
      await _player!.play(
        AssetSource(QwiAssets.snapshotCaptured.replaceFirst('assets/', '')),
      );
    } catch (e) {
      debugPrint('QwiSnapshotAudio: $e');
    }
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    final p = _player;
    _player = null;
    if (p != null) {
      try {
        await p.dispose();
      } catch (_) {}
    }
  }
}

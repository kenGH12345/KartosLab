import 'package:audioplayers/audioplayers.dart';

import '../model/molarity_constants.dart';
import 'molarity_audio_assets.dart';

/// Source-mapped audio events for Molarity (View/controller layer only).
///
/// Generators (source):
/// - [SoluteSelectionSoundGenerator]
/// - [ConcentrationSoundGenerator]
/// - [PrecipitateSoundGenerator]
///
/// Mute while [resetInProgress] (source `resetInProgressProperty`).
abstract class MolarityAudio {
  /// Solute combo changed (muted during reset).
  Future<void> onSoluteSelected(int index);

  /// Solute amount / volume bin change → concentration sound path.
  Future<void> onConcentrationCue({
    required double concentration,
    required double previousConcentration,
    required bool saturated,
  });

  /// Precipitate amount bin / rail change while user dragging.
  Future<void> onPrecipitateCue({
    required double precipitateAmount,
    required double previousPrecipitateAmount,
  });

  Future<void> stopAll();
  Future<void> dispose();

  bool get isDisposed;
  int get soluteSelectionCount;
  int get concentrationCueCount;
  int get zeroConcentrationCueCount;
  int get precipitateCueCount;
}

/// Real player — plays available molarity assets; other cues still increment counters.
class MolarityAudioPlayer implements MolarityAudio {
  MolarityAudioPlayer({
    AudioPlayer? player,
    this.enabled = true,
  }) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  final bool enabled;

  bool _disposed = false;
  int _soluteSelection = 0;
  int _concentration = 0;
  int _zeroConcentration = 0;
  int _precipitate = 0;

  static const double defaultVolume = 0.4;

  @override
  bool get isDisposed => _disposed;
  @override
  int get soluteSelectionCount => _soluteSelection;
  @override
  int get concentrationCueCount => _concentration;
  @override
  int get zeroConcentrationCueCount => _zeroConcentration;
  @override
  int get precipitateCueCount => _precipitate;

  @override
  Future<void> onSoluteSelected(int index) async {
    if (_disposed || !enabled) return;
    _soluteSelection++;
    // Shared tambo arpeggios not bundled — count only (hook verified).
  }

  @override
  Future<void> onConcentrationCue({
    required double concentration,
    required double previousConcentration,
    required bool saturated,
  }) async {
    if (_disposed || !enabled) return;
    if (saturated) return; // source: concentration sounds muted when precipitate > 0

    if (concentration > 0) {
      _concentration++;
      // brightMarimba not bundled — count only.
    } else if (previousConcentration > 0) {
      _zeroConcentration++;
      _concentration++;
      // transition-to-zero also uses marimba in source.
    } else {
      _zeroConcentration++;
      _concentration++;
      await _play(MolarityAudioAssets.softNoSolute);
    }
  }

  @override
  Future<void> onPrecipitateCue({
    required double precipitateAmount,
    required double previousPrecipitateAmount,
  }) async {
    if (_disposed || !enabled) return;
    _precipitate++;
    await _play(MolarityAudioAssets.precipitate);
  }

  @override
  Future<void> stopAll() async {
    if (_disposed) return;
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
      // Missing plugin / decode must not crash the sim.
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    try {
      await _player.stop();
      await _player.dispose();
    } catch (_) {}
  }
}

/// In-memory sink for wiring / lifecycle tests (no platform audio).
class RecordingMolarityAudio implements MolarityAudio {
  final List<String> events = <String>[];
  bool _disposed = false;
  int _soluteSelection = 0;
  int _concentration = 0;
  int _zeroConcentration = 0;
  int _precipitate = 0;

  @override
  bool get isDisposed => _disposed;
  @override
  int get soluteSelectionCount => _soluteSelection;
  @override
  int get concentrationCueCount => _concentration;
  @override
  int get zeroConcentrationCueCount => _zeroConcentration;
  @override
  int get precipitateCueCount => _precipitate;

  @override
  Future<void> onSoluteSelected(int index) async {
    if (_disposed) return;
    _soluteSelection++;
    events.add('soluteSelected:$index');
  }

  @override
  Future<void> onConcentrationCue({
    required double concentration,
    required double previousConcentration,
    required bool saturated,
  }) async {
    if (_disposed) return;
    if (saturated) {
      events.add('concentrationMutedSaturated');
      return;
    }
    _concentration++;
    if (concentration > 0) {
      events.add('concentration:$concentration');
    } else if (previousConcentration > 0) {
      _zeroConcentration++;
      events.add('transitionToZero');
    } else {
      _zeroConcentration++;
      events.add('softNoSolute');
    }
  }

  @override
  Future<void> onPrecipitateCue({
    required double precipitateAmount,
    required double previousPrecipitateAmount,
  }) async {
    if (_disposed) return;
    _precipitate++;
    events.add('precipitate:$precipitateAmount');
  }

  @override
  Future<void> stopAll() async {
    if (_disposed) return;
    events.add('stopAll');
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    events.add('dispose');
  }
}

/// Maps continuous values into bins — PhET `tambo/BinMapper`.
class MolarityBinMapper {
  MolarityBinMapper(this.min, this.max, this.numBins)
      : assert(numBins > 0),
        assert(max > min);

  final double min;
  final double max;
  final int numBins;

  int mapToBin(double value) {
    if (value <= min) return 0;
    if (value >= max) return numBins - 1;
    final t = (value - min) / (max - min);
    final bin = (t * numBins).floor();
    return bin.clamp(0, numBins - 1);
  }
}

/// Source bin counts from ConcentrationSoundGenerator / PrecipitateSoundGenerator.
class MolarityAudioBins {
  MolarityAudioBins._();
  static final soluteAmount =
      MolarityBinMapper(0, 1, 13);
  static final volume =
      MolarityBinMapper(MolarityConstants.volumeMin, MolarityConstants.volumeMax, 10);
  static final precipitate = MolarityBinMapper(0, 1, 50);
}

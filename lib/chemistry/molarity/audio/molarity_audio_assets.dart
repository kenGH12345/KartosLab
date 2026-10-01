/// Asset paths for Molarity simulation-specific sounds.
///
/// Source: `molarity/sounds/` + tambo shared clips used by sound generators.
class MolarityAudioAssets {
  MolarityAudioAssets._();

  /// `PrecipitateSoundGenerator` — `precipitate.mp3`
  static const String precipitate =
      'assets/chemistry/molarity/sounds/precipitate.mp3';

  /// `ConcentrationSoundGenerator` zero-concentration volume case —
  /// `softNoSolute_v2.mp3`
  static const String softNoSolute =
      'assets/chemistry/molarity/sounds/softNoSolute_v2.mp3';

  // brightMarimba + selectionArpeggio* live in PhET tambo (not shipped here).
  // Event hooks still fire; playback for those events is no-op / softNoSolute
  // fallback when [MolarityAudioPlayer] is enabled without shared tambo assets.
}

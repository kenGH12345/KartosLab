/// PhET Gravity Force Lab Full sound assets.
///
/// SOURCE → Flutter:
/// - `sounds/saturatedSineLoopTrimmed.wav` → ContinuousPropertySoundClip (force)
/// - `sounds/rubberBand_v3.mp3` → MassSoundGenerator
/// - `sounds/scrunchedMassCollisionSonicWomp.mp3` → MassBoundarySoundGenerator (inner)
/// - tambo `boundaryReached.mp3` → MassBoundarySoundGenerator (outer)
/// - tambo `grab.mp3` / `release.mp3` → ISLCRulerNode grab/release
/// - ISLC `rulerMovement000.mp3` → ISLCRulerNode movement
class GflAudioAssets {
  GflAudioAssets._();

  static const String dir = 'assets/phet/gravity_force_lab/sounds';

  static const String saturatedSineLoopTrimmed =
      '$dir/saturatedSineLoopTrimmed.wav';
  static const String rubberBandV3 = '$dir/rubberBand_v3.mp3';
  static const String scrunchedMassCollisionSonicWomp =
      '$dir/scrunchedMassCollisionSonicWomp.mp3';
  static const String boundaryReached = '$dir/boundaryReached.mp3';
  static const String grab = '$dir/grab.mp3';
  static const String release = '$dir/release.mp3';
  static const String rulerMovement000 = '$dir/rulerMovement000.mp3';

  /// Relative path for [AssetSource] (no `assets/` prefix).
  static String relative(String assetPath) => assetPath.startsWith('assets/')
      ? assetPath.substring('assets/'.length)
      : assetPath;
}

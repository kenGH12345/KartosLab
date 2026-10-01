/// PhET energy-skate-park asset paths (extracted from local *_png.ts / *_jpg.ts).
class EspAssets {
  EspAssets._();

  static const String base = 'assets/energy_skate_park';

  // Scenery (BackgroundNode.ts)
  static const String mountains = '$base/mountains.png';
  static const String cementTextureDark = '$base/cementTextureDark.jpg';

  // Screen tab icons (IntroScreen.ts / MeasureScreen.ts / …)
  static const String introScreenIcon = '$base/introScreenIcon.png';
  static const String measureScreenIcon = '$base/measureScreenIcon.png';
  static const String graphsScreenIcon = '$base/graphsScreenIcon.png';
  static const String playgroundScreenIcon = '$base/playgroundScreenIcon.png';

  // Legacy / license-listed (not referenced in current JS — kept for mapping)
  static const String attach = '$base/attach.png';
  static const String detach = '$base/detach.png';
  static const String skaterIcon = '$base/skater-icon.png';

  static const String usaLocale = '$base/usa';

  /// scenery-phet (MeasuringTapeNode.ts / EraserButton.ts) — SHA 6035eb4.
  static const String sceneryPhet = '$base/scenery_phet';
  static const String measuringTape = '$sceneryPhet/measuringTape.png';
  static const String eraserSvg = '$sceneryPhet/eraser.svg';

  /// All bundle paths required at runtime for usa locale (8 characters × 3 poses).
  static List<String> get usaSkaterBundle => [
        for (var i = 1; i <= 6; i++) ...[
          '$usaLocale/usaSkater${i}Headshot.png',
          '$usaLocale/usaSkater${i}Left.png',
          '$usaLocale/usaSkater${i}Right.png',
        ],
        '$usaLocale/usaDogHeadshot.png',
        '$usaLocale/usaDogLeft.png',
        '$usaLocale/usaDogRight.png',
        '$usaLocale/usaCatHeadshot.png',
        '$usaLocale/usaCatLeft.png',
        '$usaLocale/usaCatRight.png',
      ];

  /// Scenery + usa skater bundle — minimum set for Intro smoke tests.
  static List<String> get coreRuntimeBundle => [
        mountains,
        cementTextureDark,
        ...usaSkaterBundle,
      ];

  static List<String> get sceneryPhetBundle => [
        measuringTape,
        eraserSvg,
      ];
}

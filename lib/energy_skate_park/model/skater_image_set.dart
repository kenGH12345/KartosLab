import 'package:kratos/energy_skate_park/assets/esp_assets.dart';

/// PhET SkaterImageSet.ts — presentation assets only (independent of mass physics).
class SkaterImageSet {
  const SkaterImageSet({
    required this.headshotAsset,
    required this.leftAsset,
    required this.rightAsset,
  });

  final String headshotAsset;
  final String leftAsset;
  final String rightAsset;

  /// Eight characters: skater1–6 + dog + cat (usa locale default).
  static const List<SkaterImageSet> sets = [
    SkaterImageSet(
      headshotAsset: '${EspAssets.usaLocale}/usaSkater1Headshot.png',
      leftAsset: '${EspAssets.usaLocale}/usaSkater1Left.png',
      rightAsset: '${EspAssets.usaLocale}/usaSkater1Right.png',
    ),
    SkaterImageSet(
      headshotAsset: '${EspAssets.usaLocale}/usaSkater2Headshot.png',
      leftAsset: '${EspAssets.usaLocale}/usaSkater2Left.png',
      rightAsset: '${EspAssets.usaLocale}/usaSkater2Right.png',
    ),
    SkaterImageSet(
      headshotAsset: '${EspAssets.usaLocale}/usaSkater3Headshot.png',
      leftAsset: '${EspAssets.usaLocale}/usaSkater3Left.png',
      rightAsset: '${EspAssets.usaLocale}/usaSkater3Right.png',
    ),
    SkaterImageSet(
      headshotAsset: '${EspAssets.usaLocale}/usaSkater4Headshot.png',
      leftAsset: '${EspAssets.usaLocale}/usaSkater4Left.png',
      rightAsset: '${EspAssets.usaLocale}/usaSkater4Right.png',
    ),
    SkaterImageSet(
      headshotAsset: '${EspAssets.usaLocale}/usaSkater5Headshot.png',
      leftAsset: '${EspAssets.usaLocale}/usaSkater5Left.png',
      rightAsset: '${EspAssets.usaLocale}/usaSkater5Right.png',
    ),
    SkaterImageSet(
      headshotAsset: '${EspAssets.usaLocale}/usaSkater6Headshot.png',
      leftAsset: '${EspAssets.usaLocale}/usaSkater6Left.png',
      rightAsset: '${EspAssets.usaLocale}/usaSkater6Right.png',
    ),
    SkaterImageSet(
      headshotAsset: '${EspAssets.usaLocale}/usaDogHeadshot.png',
      leftAsset: '${EspAssets.usaLocale}/usaDogLeft.png',
      rightAsset: '${EspAssets.usaLocale}/usaDogRight.png',
    ),
    SkaterImageSet(
      headshotAsset: '${EspAssets.usaLocale}/usaCatHeadshot.png',
      leftAsset: '${EspAssets.usaLocale}/usaCatLeft.png',
      rightAsset: '${EspAssets.usaLocale}/usaCatRight.png',
    ),
  ];

  static const int count = 8;
  static const int defaultIndex = 0;

  static SkaterImageSet at(int index) {
    if (index < 0) return sets.first;
    if (index >= sets.length) return sets.last;
    return sets[index];
  }

  /// SkaterNode.ts massToScale: center 60 kg → 0.46, max 100 kg → 0.614.
  static double massToImageScale(double massKg) {
    const center = 60.0;
    const maxMass = 100.0;
    final t = ((massKg - center) / (maxMass - center)).clamp(0.0, 1.0);
    return 0.46 + t * (0.614 - 0.46);
  }
}

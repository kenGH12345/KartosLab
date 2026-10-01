/// Dialog 时间轴参照点。对标 `BANTimescalePoints.ts`。
///
/// 纯数据：字母标记、英文描述、秒数。不查核素表。
library;

import '../model/half_life_number_line.dart';

class BanTimescalePoint {
  const BanTimescalePoint({
    required this.marker,
    required this.description,
    required this.seconds,
  });

  /// [已确认] strings A…J
  final String marker;

  /// [已确认] build-a-nucleus-strings_en.json
  final String description;

  /// [已确认] BANTimescalePoints.numberOfSeconds
  final double seconds;

  double get pointerExponent =>
      HalfLifeNumberLine.logScaleNumberToLinearScaleNumber(seconds);
}

class BanTimescalePoints {
  const BanTimescalePoints._();

  static const double secondsInAYear = 365 * 24 * 60 * 60;
  static const double timeForLightToCrossAnAtom = 1e-19;

  static const BanTimescalePoint timeForLightToCrossANucleus = BanTimescalePoint(
    marker: 'A',
    description: 'Time for light to cross a nucleus',
    seconds: 1e-23,
  );

  static const BanTimescalePoint timeForLightToCrossAnAtomPoint =
      BanTimescalePoint(
    marker: 'B',
    description: 'Time for light to cross an atom',
    seconds: timeForLightToCrossAnAtom,
  );

  static const BanTimescalePoint timeForLightToCrossOneThousandAtoms =
      BanTimescalePoint(
    marker: 'C',
    description: 'Time for light to cross 1000 atoms',
    seconds: timeForLightToCrossAnAtom * 1000,
  );

  static const BanTimescalePoint timeForSoundToTravelOneMillimeter =
      BanTimescalePoint(
    marker: 'D',
    description: 'Time for sound to travel 1 mm',
    seconds: 2e-6,
  );

  static const BanTimescalePoint aBlinkOfAnEye = BanTimescalePoint(
    marker: 'E',
    description: 'A blink of an eye',
    seconds: 1 / 3,
  );

  static const BanTimescalePoint oneMinute = BanTimescalePoint(
    marker: 'F',
    description: 'One minute',
    seconds: 60,
  );

  static const BanTimescalePoint oneYear = BanTimescalePoint(
    marker: 'G',
    description: 'One year',
    seconds: secondsInAYear,
  );

  static const BanTimescalePoint averageHumanLifespan = BanTimescalePoint(
    marker: 'H',
    description: 'Average human lifespan',
    seconds: 72.6 * secondsInAYear,
  );

  static const BanTimescalePoint ageOfTheUniverse = BanTimescalePoint(
    marker: 'I',
    description: 'Age of the Universe',
    seconds: 13.77e9 * secondsInAYear,
  );

  static const BanTimescalePoint lifetimeOfLongestLivedStars = BanTimescalePoint(
    marker: 'J',
    description: 'Lifetime of longest lived stars',
    seconds: 450e18,
  );

  /// Dialog 图例左列。[已确认] HalfLifeInfoDialog.leftSideTimescalePoints
  static const List<BanTimescalePoint> leftColumn = [
    timeForLightToCrossANucleus,
    timeForLightToCrossAnAtomPoint,
    timeForLightToCrossOneThousandAtoms,
    timeForSoundToTravelOneMillimeter,
    aBlinkOfAnEye,
  ];

  /// Dialog 图例右列。[已确认]
  static const List<BanTimescalePoint> rightColumn = [
    oneMinute,
    oneYear,
    averageHumanLifespan,
    ageOfTheUniverse,
    lifetimeOfLongestLivedStars,
  ];

  /// 数轴上 A–J 箭头顺序。[已确认]
  static const List<BanTimescalePoint> all = [
    ...leftColumn,
    ...rightColumn,
  ];
}

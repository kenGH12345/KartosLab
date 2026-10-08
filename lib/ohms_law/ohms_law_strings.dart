/// Ohm's Law UI strings — Chinese defaults (PHASE 4).
class OhmsLawStrings {
  OhmsLawStrings._();

  static const String title = '欧姆定律';
  static const String subtitle = '欧姆定律 · 电压 · 电阻 · 电流';
  static const String voltage = '电压';
  static const String resistance = '电阻';
  static const String current = '电流';
  static const String resetAll = '全部重置';
  static const String units = '单位';
  static const String currentUnits = '电流单位';
  static const String milliamps = '毫安 (mA)';
  static const String amps = '安培 (A)';

  static String currentEquals(String value, String unit) =>
      '电流等于 $value $unit';
}

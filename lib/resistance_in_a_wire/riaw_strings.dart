/// Resistance in a Wire UI strings — Chinese defaults (PHASE 4).
class RiawStrings {
  RiawStrings._();

  static const String title = '导线电阻';
  static const String subtitle = '电阻率 · 长度 · 截面积 · R = ρL/A';
  static const String resistivity = '电阻率';
  static const String length = '长度';
  static const String area = '截面积';
  static const String resetAll = '全部重置';
  static const String theWire = '导线';

  static String resistanceReadout(String formatted) =>
      '电阻 = $formatted ohms';

  static const String semanticResistivity = 'ρ，电阻率';
  static const String semanticLength = 'L，长度';
  static const String semanticArea = 'A，截面积';

  static String equationA11y() =>
      '电阻公式。电阻 R 等于电阻率 ρ 乘以长度 L 再除以截面积 A。';
}

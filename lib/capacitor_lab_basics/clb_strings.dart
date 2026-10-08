/// Capacitor Lab: Basics strings — Chinese defaults (PHASE 4).
/// Unit patterns preserve V / mm / mm² / pF / pC / pJ.
class ClbStrings {
  ClbStrings._();

  static const String title = '电容器实验室：基础';
  static const String screenCapacitance = '电容';
  static const String screenLightBulb = '灯泡';

  static const String capacitance = '电容';
  static const String barGraphs = '柱状图';
  static const String electricField = '电场';
  static const String plateCharges = '极板电荷';
  static const String currentDirection = '电流方向';
  static const String electrons = '电子';
  static const String conventional = '常规电流';
  static const String plateArea = '极板面积';
  static const String separation = '间距';
  static const String topPlateCharge = '上极板电荷';
  static const String storedEnergy = '储存能量';
  static const String voltage = '电压';
  static const String voltsUnknown = '?';

  /// Voltmeter readout — `Utils.toFixed(value, 3)` + unit.
  static String voltsPattern(num value) {
    final fixed = value.toStringAsFixed(3);
    return '$fixed V';
  }

  static String voltsTickLabel(num value) {
    final s = value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
    return '$s V';
  }

  static String millimetersPattern(num value) =>
      '${value.toStringAsFixed(1)} mm';
  static String millimetersSquaredPattern(num value) => '$value mm²';
  static String picoFaradsPattern(num value) =>
      '${value.toStringAsFixed(2)} pF';
  static String picoCoulombsPattern(num value) =>
      '${value.toStringAsFixed(2)} pC';
  static String picoJoulesPattern(num value) =>
      '${value.toStringAsFixed(2)} pJ';
}

/// Strings from `capacitor-lab-basics-strings_en.json`.
class ClbStrings {
  ClbStrings._();

  static const String title = 'Capacitor Lab: Basics';
  static const String screenCapacitance = 'Capacitance';
  static const String screenLightBulb = 'Light Bulb';

  static const String capacitance = 'Capacitance';
  static const String barGraphs = 'Bar Graphs';
  static const String electricField = 'Electric Field';
  static const String plateCharges = 'Plate Charges';
  static const String currentDirection = 'Current Direction';
  static const String electrons = 'Electrons';
  static const String conventional = 'Conventional';
  static const String plateArea = 'Plate Area';
  static const String separation = 'Separation';
  static const String topPlateCharge = 'Top Plate Charge';
  static const String storedEnergy = 'Stored Energy';
  static const String voltage = 'Voltage';
  static const String voltsUnknown = '?';

  /// Voltmeter readout — `Utils.toFixed(value, 3)` + `voltsPattern`.
  static String voltsPattern(num value) {
    final fixed = value.toStringAsFixed(3);
    return '$fixed V';
  }

  /// Battery slider tick labels — `BatteryNode` createTickLabel (raw value).
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

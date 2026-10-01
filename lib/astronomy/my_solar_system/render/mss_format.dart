/// Formatting helpers for ValuesPanel — never dump Dart toString() to UI.
library;

import '../my_solar_system_constants.dart';

class MssFormat {
  MssFormat._();

  static String mass(double kg) =>
      kg.toStringAsFixed(MySolarSystemConstants.massDecimalPlaces);

  static String positionAu(double v) =>
      v.toStringAsFixed(MySolarSystemConstants.positionDecimalPlaces);

  static String velocityKms(double v) =>
      v.toStringAsFixed(MySolarSystemConstants.velocityDecimalPlaces);

  static String tapeAu(double v) =>
      v.toStringAsFixed(MySolarSystemConstants.tapeDecimalPlaces);
}

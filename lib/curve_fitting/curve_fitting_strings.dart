/// Strings from `curve-fitting-strings_en.json`.
class CurveFittingStrings {
  CurveFittingStrings._();

  static const String title = 'Curve Fitting';
  static const String subtitle = 'Best fit · residuals · χ²';
  static const String adjustableFit = 'Adjustable fit';
  static const String resetAll = 'Reset All';
  static const String bestFit = 'Best fit';
  static const String cubic = 'Cubic';
  static const String curve = 'Curve';
  static const String deviations = 'Deviations';
  static const String equation = 'Equation';
  static const String linear = 'Linear';
  static const String undefinedLabel = 'undefined';
  static const String quadratic = 'Quadratic';
  static const String residuals = 'Residuals';
  static const String values = 'Values';

  static const String aSymbol = 'a';
  static const String bSymbol = 'b';
  static const String cSymbol = 'c';
  static const String dSymbol = 'd';
  static const String fSymbol = 'f';
  static const String nSymbol = 'N';
  static const String xSymbol = 'x';
  static const String ySymbol = 'y';
  static const String rSymbol = 'r';
  static const String chiSymbol = 'X';

  static const String theReducedChiSquaredStatisticIs =
      'The reduced chi-squared statistic is:';

  static String fEqualsNumberOfParametersPattern({
    String f = fSymbol,
  }) =>
      '$f = number of parameters in fit (e.g. $f = 4, for a cubic fit)';

  static String nEqualsNumberOfDataPointsPattern({
    String n = nSymbol,
  }) =>
      '$n = number of data points';

  static String deltaEqualsPattern({
    required String y,
    required String deltaValue,
  }) =>
      'Δ $y = $deltaValue';

  static String pointCoordinatesPattern({
    required String xCoordinate,
    required String yCoordinate,
  }) =>
      '($xCoordinate, $yCoordinate)';
}

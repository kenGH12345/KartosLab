/// Curve Fitting UI strings — Chinese defaults (PHASE 7B remediation).
class CurveFittingStrings {
  CurveFittingStrings._();

  static const String title = '曲线拟合';
  static const String subtitle = '最佳拟合 · 残差 · χ²';
  static const String adjustableFit = '可调拟合';
  static const String resetAll = '全部重置';
  static const String bestFit = '最佳拟合';
  static const String cubic = '三次';
  static const String curve = '曲线';
  static const String deviations = '偏差';
  static const String equation = '方程';
  static const String linear = '线性';
  static const String undefinedLabel = '未定义';
  static const String quadratic = '二次';
  static const String residuals = '残差';
  static const String values = '数值';

  static const String aSymbol = 'a';
  static const String bSymbol = 'b';
  static const String cSymbol = 'c';
  static const String dSymbol = 'd';
  static const String fSymbol = 'f';
  static const String nSymbol = 'N';
  static const String xSymbol = 'x';
  static const String ySymbol = 'y';
  static const String rSymbol = 'r';
  static const String chiSymbol = 'χ';

  static const String theReducedChiSquaredStatisticIs = '约化卡方统计量为：';

  static String fEqualsNumberOfParametersPattern({
    String f = fSymbol,
  }) =>
      '$f = 拟合参数个数（例如三次拟合 $f = 4）';

  static String nEqualsNumberOfDataPointsPattern({
    String n = nSymbol,
  }) =>
      '$n = 数据点个数';

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

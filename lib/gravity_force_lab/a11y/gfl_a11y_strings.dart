/// Gravity Force Lab a11y — PHASE 2 Chinese (synced with `loc.accessibility` / mechanics).
///
/// Automation / Key IDs unchanged. Only user-perceivable text localized.
class GflA11yStrings {
  GflA11yStrings._();

  static const String screen = '万有引力实验室';
  static const String simulationGroup = '模拟';
  static const String spherePositionsGroup = '球体位置';
  static const String massControlsGroup = '质量控制';

  static const String mass1 = '质量 1';
  static const String mass2 = '质量 2';

  static String moveObject(String label) => '移动 $label';

  static String massAndUnit(double kg) => '${kg.round()} 千克';

  static const String measureDistanceRuler = '测距尺';
  static const String rulerGrabbed = '已抓取尺子';
  static const String rulerReleased = '已释放尺子';

  static const String forceValues = '力的数值';
  static const String forceValuesHelp = '选择力的数值显示方式。';
  static const String decimalNotation = '十进制记数';
  static const String scientificNotation = '科学计数法';
  static const String hidden = '隐藏';
  static const String forceValuesHidden = '已隐藏力的数值。';
  static const String forceValuesInNewtons = '力的数值（牛顿）。';
  static const String forceValuesScientific = '力的数值（牛顿，科学计数法）。';

  static const String constantSize = '恒定大小';
  static const String constantSizeHelp = '改变质量时保持两个质量外观大小不变。';

  static const String resetAll = '全部重置';

  static const String keyboardHelp = '键盘快捷键';
  static const String keyboardHelpButton = '键盘快捷键';

  static const String moveSpheresHeading = '移动球体';
  static const String moveSphereLabel = '移动球体（方向键）';
  static const String moveInSmallerSteps = '较小步长移动';
  static const String moveInLargerSteps = '较大步长移动';
  static const String jumpToLeft = '跳到左侧';
  static const String jumpToRight = '跳到右侧';

  static const String changeMassHeading = '改变质量';
  static const String changeMassLabel = '改变质量（方向键）';
  static const String changeMassInSmallerSteps = '较小步长改变质量';
  static const String changeMassInLargerSteps = '较大步长改变质量';
  static const String jumpToMinimumMass = '跳到最小质量';
  static const String jumpToMaximumMass = '跳到最大质量';

  static const String grabReleaseRulerHeading = '抓取或释放尺子';
  static const String moveOrJumpGrabbedRuler = '移动或跳转已抓取的尺子';
  static const String moveGrabbedRuler = '移动已抓取的尺子';
  static const String jumpStartOfSphere = '将尺子起点跳到 m1 球心 (J+C)';
  static const String jumpHome = '将尺子跳回并释放到初始位置 (J+H)';

  static const String moveSphereDescription = '用方向键左右移动球体。';
  static const String changeMassPDOM = '用左右方向键改变质量。';
}

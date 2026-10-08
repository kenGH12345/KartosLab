/// Pendulum Lab strings — PHASE 2 Chinese (synced with `loc.*`).
class PlStrings {
  PlStrings._();

  static const String title = '单摆实验室';
  static const String subtitle = '介绍 · 能量 · 实验室';

  static const String screenIntro = '介绍';
  static const String screenEnergy = '能量';
  static const String screenLab = '实验室';

  static const String length = '长度';
  static const String mass = '质量';
  static const String gravity = '重力';
  static const String friction = '摩擦';
  static const String ruler = '尺子';
  static const String stopwatch = '秒表';
  static const String periodTrace = '周期轨迹';
  static const String periodTimer = '周期计时器';
  static const String period = '周期';
  static const String velocity = '速度';
  static const String acceleration = '加速度';
  static const String normal = '正常';
  static const String slowMotion = '慢速';
  static const String none = '无';
  static const String lots = '很多';
  static const String energyGraph = '能量图像';
  static const String energyLegend = '能量图例';
  static const String whatIsTheValueOfGravity = '重力加速度的值是多少？';

  static const String moon = '月球';
  static const String earth = '地球';
  static const String jupiter = '木星';
  static const String planetX = '行星 X';
  static const String custom = '自定义';

  static const String rulerUnits = 'cm';

  static const String keAbbr = 'KE';
  static const String peAbbr = 'PE';
  static const String thermAbbr = 'E_therm';
  static const String totalAbbr = 'E_total';
  static const String keName = '动能';
  static const String peName = '势能';
  static const String thermName = '热能';
  static const String totalName = '总能量';

  static String lengthTitle(int n) => '长度 $n';
  static String massTitle(int n) => '质量 $n';
  static String meters(String v) => '$v m';
  static String kilograms(String v) => '$v kg';
  static String degrees(String v) => '$v°';
  static String seconds(String v) => '$v s';
  static String gravityValue(String v) => '$v m/s²';
  static String pendulumMass(int n) => '质量 $n';
}

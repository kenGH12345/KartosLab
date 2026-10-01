/// Strings from `pendulum-lab-strings_en.json`.
class PlStrings {
  PlStrings._();

  static const String title = 'Pendulum Lab';
  static const String subtitle = 'Intro · Energy · Lab';

  static const String screenIntro = 'Intro';
  static const String screenEnergy = 'Energy';
  static const String screenLab = 'Lab';

  static const String length = 'Length';
  static const String mass = 'Mass';
  static const String gravity = 'Gravity';
  static const String friction = 'Friction';
  static const String ruler = 'Ruler';
  static const String stopwatch = 'Stopwatch';
  static const String periodTrace = 'Period Trace';
  static const String periodTimer = 'Period Timer';
  static const String period = 'Period';
  static const String velocity = 'Velocity';
  static const String acceleration = 'Acceleration';
  static const String normal = 'Normal';
  static const String slowMotion = 'Slow';
  static const String none = 'None';
  static const String lots = 'Lots';
  static const String energyGraph = 'Energy Graph';
  static const String energyLegend = 'Energy Legend';
  static const String whatIsTheValueOfGravity = 'What is the value of gravity?';

  static const String moon = 'Moon';
  static const String earth = 'Earth';
  static const String jupiter = 'Jupiter';
  static const String planetX = 'Planet X';
  static const String custom = 'Custom';

  static const String rulerUnits = 'cm';

  static const String keAbbr = 'KE';
  static const String peAbbr = 'PE';
  static const String thermAbbr = 'E_therm';
  static const String totalAbbr = 'E_total';
  static const String keName = 'Kinetic Energy';
  static const String peName = 'Potential Energy';
  static const String thermName = 'Thermal Energy';
  static const String totalName = 'Total Energy';

  static String lengthTitle(int n) => 'Length $n';
  static String massTitle(int n) => 'Mass $n';
  static String meters(String v) => '$v m';
  static String kilograms(String v) => '$v kg';
  static String degrees(String v) => '$v°';
  static String seconds(String v) => '$v s';
  static String gravityValue(String v) => '$v m/s²';
  static String pendulumMass(int n) => 'Mass $n';
}

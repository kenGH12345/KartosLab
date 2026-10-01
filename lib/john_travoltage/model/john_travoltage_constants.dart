import 'jt_vec2.dart';

/// Constants and sampled geometry from PhET `JohnTravoltageModel.js` / appendages.
abstract final class JohnTravoltageConstants {
  /// ScreenView layoutBounds: Bounds2(0, 0, 768, 504).
  static const double layoutWidth = 768;
  static const double layoutHeight = 504;

  static const int maxElectrons = 100;

  /// Foot-on-carpet angle window (radians, exclusive bounds in source).
  static const double footOnCarpetMinAngle = 1;
  static const double footOnCarpetMaxAngle = 2.4;

  /// Charge accumulation: one electron per π/16 of |Δangle| on carpet.
  static const double accumulatedAngleThreshold = 3.141592653589793 / 16;

  static const JtVec2 doorknobPosition =
      JtVec2(548.4318903113076, 257.5894162536105);

  /// Minimum finger–knob distance when pointed at knob (`actualMin` in model.step).
  static const double fingerKnobActualMin = 15;

  /// Discharge threshold numerator: `threshold = 10 / actualMin`.
  static const double dischargeThresholdNumerator = 10;

  static double get dischargeThreshold =>
      dischargeThresholdNumerator / fingerKnobActualMin;

  // --- Arm (Arm.js) ---
  static const JtVec2 armPivot =
      JtVec2(423.6179673321235, 229.84969476984);
  static const double armInitialAngle = -0.5;
  static const double armAngleMin = -3.141592653589793 + 0.41;
  static const double armAngleMax = 3.141592653589793 + 0.41;

  /// Sampled finger tip in ScreenView coords (Arm.js).
  static const JtVec2 armFingerSample =
      JtVec2(534.3076704, 206.6376636);

  // --- Leg (Leg.js) ---
  static const JtVec2 legPivot = JtVec2(398, 335);
  static const double legInitialAngle = 1.3175443221852239;
  static const double legAngleMin = 0;
  static const double legAngleMax = 3.141592653589793;

  // --- Electron (Electron.js) ---
  static const double electronRadius = 8;
  static const double frictionFactor = 0.98;
  static const double maxSpeed = 500;
  static const double maxForceSquared = 100000000;
  static const double repulsionScale = 12000;
  static const double bounceEnergyRetain = 0.8;
  static const double interactionProbability = 0.4;
  static const double sparkSpeed = 200;
  static const double sparkArriveDistancePerSecond = 100;
  static const JtVec2 electronInitialVelocity = JtVec2(-50, -100);

  /// Electron spawn segment (JohnTravoltageModel electronGroup factory).
  static const JtVec2 electronSpawnP0 =
      JtVec2(424.0642054574639, 452.28892455858755);
  static const JtVec2 electronSpawnP1 =
      JtVec2(433.3097913322633, 445.5088282504014);

  /// dt clamp in model.step — navigating away/back (#25).
  static const double maxDt = 2 / 60;

  /// Spark cancel hysteresis (#27).
  static const double sparkCancelExtraDistance = 10;
  static const double sparkCancelElectronKnobDistance = 100;

  /// Body outline vertices (JohnTravoltageModel.bodyVertices) — 31 points.
  static const List<JtVec2> bodyVertices = [
    JtVec2(422.21508828250404, 455.370786516854),
    JtVec2(403.10754414125205, 424.5521669341895),
    JtVec2(379.68539325842704, 328.3980738362762),
    JtVec2(357.4959871589086, 335.17817014446234),
    JtVec2(309.4189406099519, 448.5906902086678),
    JtVec2(322.362760834671, 473.86195826645275),
    JtVec2(284.14767255216697, 461.5345104333869),
    JtVec2(327.9101123595506, 341.95826645264856),
    JtVec2(281.6821829855538, 296.34670947030503),
    JtVec2(286.6131621187801, 202.65810593900486),
    JtVec2(318.66452648475126, 147.800963081862),
    JtVec2(349.48314606741576, 118.83146067415731),
    JtVec2(387.08186195826653, 110.20224719101125),
    JtVec2(407.42215088282506, 75.06902086677371),
    JtVec2(425.9133226324238, 75.06902086677371),
    JtVec2(439.4735152487962, 85.54735152487964),
    JtVec2(433.9261637239166, 118.21508828250404),
    JtVec2(420.9823434991975, 126.2279293739968),
    JtVec2(403.7239165329053, 128.07704654895667),
    JtVec2(393.2455858747994, 142.25361155698238),
    JtVec2(408.0385232744784, 171.22311396468703),
    JtVec2(423.44783306581064, 221.14927768860358),
    JtVec2(487.5505617977529, 217.45104333868383),
    JtVec2(485.701444622793, 228.54574638844306),
    JtVec2(432.07704654895673, 240.25682182985557),
    JtVec2(392.0128410914928, 224.23113964687002),
    JtVec2(390.7800963081863, 280.9373996789728),
    JtVec2(404.34028892455865, 319.1524879614768),
    JtVec2(414.81861958266455, 404.2118780096309),
    JtVec2(435.15890850722315, 433.18138041733556),
    JtVec2(464.1284109149278, 433.79775280898883),
  ];

  /// Force lines for spark travel (JohnTravoltageModel.forceLines) — 12 segments.
  static const List<(double, double, double, double)> forceLineCoords = [
    (300.6483412322275, 443.79905213270143, 341.41421800947865, 338.97251184834124),
    (341.41421800947865, 335.33270142180095, 373.44454976303314, 204.29952606635067),
    (423.6739336492891, 438.703317535545, 406.2028436018957, 406.6729857819905),
    (406.2028436018957, 405.2170616113744, 393.0995260663507, 330.2369668246445),
    (392.37156398104264, 327.3251184834123, 375.6284360189573, 253.80094786729856),
    (377.08436018957343, 212.30710900473932, 395.28341232227484, 205.02748815165873),
    (398.92322274881514, 206.48341232227486, 418.5781990521327, 225.4104265402843),
    (418.5781990521327, 225.4104265402843, 516.8530805687203, 219.58672985781985),
    (417.85023696682464, 100.9289099526066, 385.81990521327015, 127.13554502369666),
    (379.9962085308057, 134.41516587677722, 366.89289099526064, 167.17345971563978),
    (369.8047393364929, 172.26919431279617, 392.37156398104264, 195.563981042654),
    (317.3914691943128, 255.98483412322273, 355.9734597156398, 222.4985781990521),
  ];

  /// Carpet vertices (touch / a11y — not charge generation).
  static const List<JtVec2> carpetVertices = [
    JtVec2(126.67410358565739, 492.91474103585665),
    JtVec2(233.76573705179285, 446.4063745019921),
    JtVec2(580.7426294820718, 447.01832669322715),
    JtVec2(520.1593625498009, 495.3625498007969),
  ];
}

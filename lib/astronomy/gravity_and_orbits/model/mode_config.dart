/// Body configuration + ModeConfig.center() — `BodyConfiguration.ts` / `ModeConfig.ts`.
library;

import '../gao_constants.dart';
import 'body_type.dart';
import 'gao_vec.dart';

class BodyConfiguration {
  BodyConfiguration({
    required this.type,
    required this.mass,
    required this.radius,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.isMovable = true,
    this.rotationPeriod,
    this.massSettable = true,
    this.massReadoutBelow = true,
    this.pathLengthBuffer = 0,
    this.maxPathLength,
    this.touchDilation = 15,
    this.tickLabel = '',
    this.labelAngle,
  });

  final GaoBodyType type;
  double mass;
  double radius;
  double x;
  double y;
  double vx;
  double vy;
  bool isMovable;
  final double? rotationPeriod;
  final bool massSettable;
  final bool massReadoutBelow;
  final double pathLengthBuffer;
  final double? maxPathLength;
  final double touchDilation;
  final String tickLabel;

  /// Leader-line angle in radians (`BodyNode` labelAngle).
  /// Default: moon −3π/4, others −π/4.
  final double? labelAngle;

  double get resolvedLabelAngle =>
      labelAngle ??
      (type == GaoBodyType.moon ? -3 * 3.141592653589793 / 4 : -3.141592653589793 / 4);

  GaoVec get momentum => GaoVec(vx * mass, vy * mass);
}

class ModeConfigResult {
  ModeConfigResult({
    required this.id,
    required this.bodies,
    required this.zoom,
    required this.dt,
    required this.forceScale,
    required this.velocityVectorScale,
    required this.gridSpacing,
    required this.gridCenter,
    required this.timeInDays,
    required this.adjustMoonOrbit,
    this.measuringTapeStart,
    this.measuringTapeEnd,
  });

  final GaoSceneId id;
  final List<BodyConfiguration> bodies;
  final double zoom;
  final double dt;
  final double forceScale;
  final double velocityVectorScale;
  final double gridSpacing;
  final GaoVec gridCenter;
  final bool timeInDays;
  final bool adjustMoonOrbit;
  final GaoVec? measuringTapeStart;
  final GaoVec? measuringTapeEnd;
}

/// Apply center-of-momentum frame correction (`ModeConfig.center`).
void centerBodies(List<BodyConfiguration> bodies) {
  var totalMass = 0.0;
  var px = 0.0;
  var py = 0.0;
  for (final b in bodies) {
    totalMass += b.mass;
    px += b.vx * b.mass;
    py += b.vy * b.mass;
  }
  if (totalMass == 0) return;
  final dvx = -px / totalMass;
  final dvy = -py / totalMass;
  for (final b in bodies) {
    b.vx += dvx;
    b.vy += dvy;
  }
}

/// Build the four scene presets for Model or To Scale.
List<ModeConfigResult> buildSceneConfigs({required bool isModelScreen}) {
  return [
    _sunEarth(isModelScreen),
    _sunEarthMoon(isModelScreen),
    _planetMoon(isModelScreen),
    _earthSatellite(isModelScreen),
  ];
}

ModeConfigResult _sunEarth(bool isModel) {
  final sunR = GaoConstants.sunRadius * (isModel ? GaoConstants.sunRadiusMultiplier : 1);
  final earthR = GaoConstants.earthRadius *
      (isModel ? GaoConstants.earthMoonRadiusMultiplierSunModes : 1);

  final sun = BodyConfiguration(
    type: GaoBodyType.star,
    mass: GaoConstants.sunMass,
    radius: sunR,
    x: 0,
    y: 0,
    vx: 0,
    vy: 0,
    isMovable: !isModel,
    tickLabel: 'Our Sun',
    maxPathLength: 345608942000,
  );
  final planet = BodyConfiguration(
    type: GaoBodyType.planet,
    mass: GaoConstants.earthMass,
    radius: earthR,
    x: GaoConstants.earthPerihelion,
    y: 0,
    vx: 0,
    vy: GaoConstants.earthOrbitalSpeedAtPerihelion,
    tickLabel: 'Earth',
  );
  final bodies = [sun, planet];
  centerBodies(bodies);

  var forceScale = GaoConstants.forceScaleBase * 120;
  if (isModel) forceScale *= 0.58;

  return ModeConfigResult(
    id: GaoSceneId.starPlanet,
    bodies: bodies,
    zoom: 1.25,
    dt: GaoConstants.defaultDt,
    forceScale: forceScale,
    velocityVectorScale: GaoConstants.sunModesVelocityScale,
    gridSpacing: GaoConstants.earthPerihelion / 2,
    gridCenter: GaoVec.zero(),
    timeInDays: true,
    adjustMoonOrbit: false,
    measuringTapeStart: GaoVec(
      (sun.x + planet.x) / 3,
      -GaoConstants.earthPerihelion / 2,
    ),
    measuringTapeEnd: GaoVec(
      (sun.x + planet.x) / 3 + 80000000 * 1000,
      -GaoConstants.earthPerihelion / 2,
    ),
  );
}

ModeConfigResult _sunEarthMoon(bool isModel) {
  final sunR = GaoConstants.sunRadius * (isModel ? GaoConstants.sunRadiusMultiplier : 1);
  final earthR = GaoConstants.earthRadius *
      (isModel ? GaoConstants.earthMoonRadiusMultiplierSunModes : 1);
  final moonR = GaoConstants.moonRadius *
      (isModel ? GaoConstants.earthMoonRadiusMultiplierSunModes : 1);

  final sun = BodyConfiguration(
    type: GaoBodyType.star,
    mass: GaoConstants.sunMass,
    radius: sunR,
    x: 0,
    y: 0,
    vx: 0,
    vy: 0,
    isMovable: !isModel,
    tickLabel: 'Our Sun',
    maxPathLength: 345608942000,
  );
  final planet = BodyConfiguration(
    type: GaoBodyType.planet,
    mass: GaoConstants.earthMass,
    radius: earthR,
    x: GaoConstants.earthPerihelion,
    y: 0,
    vx: 0,
    vy: GaoConstants.earthOrbitalSpeedAtPerihelion,
    tickLabel: 'Earth',
    touchDilation: 2,
  );

  var moonVx = GaoConstants.moonSpeedAtPerigee;
  var moonY = GaoConstants.moonPerigee;
  if (isModel) {
    moonVx *= 21;
    moonY = earthR * 1.7;
  }

  final moon = BodyConfiguration(
    type: GaoBodyType.moon,
    mass: GaoConstants.moonMass,
    radius: moonR,
    x: GaoConstants.earthPerihelion,
    y: moonY,
    vx: moonVx,
    vy: GaoConstants.earthOrbitalSpeedAtPerihelion,
    tickLabel: 'Our Moon',
    massSettable: false,
    massReadoutBelow: false,
    pathLengthBuffer: isModel ? GaoConstants.earthPerihelion / 2 : 0,
    touchDilation: 5,
  );

  final bodies = [sun, planet, moon];
  centerBodies(bodies);

  var forceScale = GaoConstants.forceScaleBase * 120;
  if (isModel) forceScale *= 0.58;

  return ModeConfigResult(
    id: GaoSceneId.starPlanetMoon,
    bodies: bodies,
    zoom: 1.25,
    dt: GaoConstants.defaultDt,
    forceScale: forceScale,
    velocityVectorScale: GaoConstants.sunModesVelocityScale,
    gridSpacing: GaoConstants.earthPerihelion / 2,
    gridCenter: GaoVec.zero(),
    timeInDays: true,
    adjustMoonOrbit: isModel,
    measuringTapeStart: GaoVec(
      (0 + GaoConstants.earthPerihelion) / 3,
      -GaoConstants.earthPerihelion / 2,
    ),
    measuringTapeEnd: GaoVec(
      (0 + GaoConstants.earthPerihelion) / 3 + 80000000 * 1000,
      -GaoConstants.earthPerihelion / 2,
    ),
  );
}

ModeConfigResult _planetMoon(bool isModel) {
  final radiusMul = isModel ? GaoConstants.planetMoonRadiusMultiplier : 1.0;
  final planetVelocityX =
      GaoConstants.moonMass * 1082 / (GaoConstants.earthMass + GaoConstants.moonMass);
  // TS: planetVelocityX - Math.abs(MOON_SPEED_AT_PERIGEE) where MOON_SPEED = -1082
  final moonVelocityX = planetVelocityX - 1082;

  final planet = BodyConfiguration(
    type: GaoBodyType.planet,
    mass: GaoConstants.earthMass,
    radius: GaoConstants.earthRadius * radiusMul,
    x: GaoConstants.earthPerihelion,
    y: 0,
    vx: planetVelocityX,
    vy: 0,
    tickLabel: 'Earth',
  );
  final moon = BodyConfiguration(
    type: GaoBodyType.moon,
    mass: GaoConstants.moonMass,
    radius: GaoConstants.moonRadius * radiusMul,
    x: GaoConstants.earthPerihelion,
    y: GaoConstants.moonPerigee,
    vx: moonVelocityX,
    vy: 0,
    tickLabel: 'Our Moon',
    rotationPeriod: isModel ? 27.322 * GaoConstants.secondsPerDay : null,
  );
  final bodies = [planet, moon];
  centerBodies(bodies);

  var forceScale = GaoConstants.forceScaleBase * 45;
  if (isModel) forceScale *= 0.79;

  return ModeConfigResult(
    id: GaoSceneId.planetMoon,
    bodies: bodies,
    zoom: 400,
    dt: GaoConstants.defaultDt / 3,
    forceScale: forceScale,
    velocityVectorScale: GaoConstants.sunModesVelocityScale * 0.06,
    gridSpacing: GaoConstants.moonPerigee / 2,
    gridCenter: GaoVec(GaoConstants.earthPerihelion, 0),
    timeInDays: true,
    adjustMoonOrbit: false,
    measuringTapeStart: GaoVec(
      GaoConstants.earthPerihelion + GaoConstants.earthRadius * radiusMul * 2,
      -GaoConstants.moonPerigee * 0.7,
    ),
    measuringTapeEnd: GaoVec(
      GaoConstants.earthPerihelion +
          GaoConstants.earthRadius * radiusMul * 2 +
          150000 * 1000,
      -GaoConstants.moonPerigee * 0.7,
    ),
  );
}

ModeConfigResult _earthSatellite(bool isModel) {
  final planetR = GaoConstants.earthRadius * (isModel ? 0.8 : 1);
  final satR = GaoConstants.spaceStationRadius * (isModel ? 20000 : 1);
  final satX = GaoConstants.spaceStationPerigee +
      GaoConstants.earthRadius +
      GaoConstants.spaceStationRadius;

  final planet = BodyConfiguration(
    type: GaoBodyType.planet,
    mass: GaoConstants.earthMass,
    radius: planetR,
    x: 0,
    y: 0,
    vx: 0,
    vy: 0,
    tickLabel: 'Earth',
    maxPathLength: 35879455,
    touchDilation: 0,
  );
  final satellite = BodyConfiguration(
    type: GaoBodyType.satellite,
    mass: GaoConstants.spaceStationMass,
    radius: satR,
    x: satX,
    y: 0,
    vx: 0,
    vy: GaoConstants.spaceStationSpeed,
    tickLabel: 'Space Station',
    rotationPeriod: GaoConstants.spaceStationOrbitalPeriod,
  );
  final bodies = [planet, satellite];
  centerBodies(bodies);

  const x0 = 3162119.0;
  return ModeConfigResult(
    id: GaoSceneId.planetSatellite,
    bodies: bodies,
    zoom: 21600,
    dt: GaoConstants.defaultDt * 9e-4,
    forceScale: GaoConstants.forceScaleBase * 3e13,
    velocityVectorScale: GaoConstants.sunModesVelocityScale / 10000,
    gridSpacing: satX,
    gridCenter: GaoVec.zero(),
    timeInDays: false,
    adjustMoonOrbit: false,
    measuringTapeStart: GaoVec(x0, 7680496),
    measuringTapeEnd: GaoVec(x0 + 3000 * 1000, 7680496),
  );
}

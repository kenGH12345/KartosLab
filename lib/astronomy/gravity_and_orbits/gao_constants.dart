/// Gravity and Orbits constants — literals from local PhET source 1.7.0-dev.7.
///
/// Source: `js/common/SceneFactory.ts`, `GravityAndOrbitsClock.ts`,
/// `ModelState.ts`, `VectorNode.ts`, `GravityAndOrbitsConstants.ts`,
/// `GravityAndOrbitsSceneView.ts`.
library;

import 'package:flutter/material.dart';

class GaoConstants {
  GaoConstants._();

  /// PhET `PhysicalConstants.GRAVITATIONAL_CONSTANT` (SI). Locked for orbit fidelity.
  static const double G = 6.67430e-11;

  // ── PEFRL (`ModelState.ts`) ──────────────────────────────────────────────
  static const double pefrlXi = 0.1786178958448091;
  static const double pefrlLambda = -0.2123418310626054;
  static const double pefrlChi = -0.06626458266981849;

  // ── Clock (`GravityAndOrbitsClock.ts`) ───────────────────────────────────
  static const double clockFrameRate = 60;
  static const double daysPerTick = 1 / (60 / 25); // 1/2.4
  static const double secondsPerDay = 86400;
  static const double defaultDt = daysPerTick * secondsPerDay; // 36000
  static const double smallestTimeStepFactor = 0.13125;

  static const int substepsSlow = 1;
  static const int substepsNormal = 4;
  static const int substepsFast = 7;

  // ── Bodies (`SceneFactory.ts`) ───────────────────────────────────────────
  static const double sunMass = 1.989e30;
  static const double sunRadius = 6.957e8;
  static const double earthMass = 5.9724e24;
  static const double earthRadius = 6.371e6;
  static const double earthPerihelion = 147098074e3;
  static const double earthOrbitalSpeedAtPerihelion = 30300;
  static const double moonMass = 7.346e22;
  static const double moonRadius = 1727.4e3;
  static const double moonSpeedAtPerigee = -1082;
  static const double moonPerigee = 363300e3;
  static const double spaceStationMass = 419725;
  static const double spaceStationRadius = 91 / 2;
  static const double spaceStationSpeed = 7706;
  static const double spaceStationPerigee = 347000;
  static const double spaceStationOrbitalPeriod = 91.4 * 60;

  static const double moonOrbitFudgeFactor = 10200;

  // Model screen radius multipliers (`ModelSceneFactory.ts`)
  static const double sunRadiusMultiplier = 50;
  static const double earthMoonRadiusMultiplierSunModes = 800;
  static const double planetMoonRadiusMultiplier = 15;

  // ── Vectors ──────────────────────────────────────────────────────────────
  static const double forceScaleBase = 76.0 / 5.179e15;
  static const double sunModesVelocityScale = 4.48e6;

  // ── View (`GravityAndOrbitsSceneView.ts`) ────────────────────────────────
  static const double stageScale = 0.8;
  static const double stageWidth = 790 / stageScale;
  static const double stageHeight = 618 / stageScale;
  static const double mvtScaleFactor = 1.5e-9;
  static const double zoomMin = 0.5;
  static const double zoomMax = 1.3;
  static const double zoomStep = 0.1;
  static const double pathLengthLimit = 6000;
  static const double pathFadeFraction = 0.15;
  static const double pathStrokeWidth = 3;

  static const Color background = Color(0xFF000000);
  static const Color foreground = Color(0xFFFFFFFF);
  static const Color controlPanelStroke = Color(0xFF8E9097);
  static const Color gravitationalForce = Color.fromARGB(255, 50, 130, 215);
  static const Color velocity = Color.fromARGB(255, 50, 255, 50);
  static const Color vectorOutline = Color.fromARGB(255, 64, 64, 64);
  static const Color returnObjectsBg = Color.fromARGB(255, 255, 250, 125);

  /// Path stroke = `Body.color` in `SceneFactory.ts` / `PathsCanvasNode.ts`.
  /// Star yellow, planet/satellite CSS gray, moon `Color.magenta`.
  static const Color starPath = Color(0xFFFFFF00);
  static const Color planetPath = Color(0xFF808080);
  static const Color moonPath = Color(0xFFFF00FF);
  static const Color satellitePath = Color(0xFF808080);

  static const String assetRoot = 'assets/astronomy/gravity_and_orbits';
  static const String sunAsset = '$assetRoot/sun.png';
  static const String earthAsset = '$assetRoot/earth.png';
  static const String moonAsset = '$assetRoot/moon.png';
  static const String moonGenericAsset = '$assetRoot/moonGeneric.png';
  static const String planetGenericAsset = '$assetRoot/planetGeneric.png';
  static const String spaceStationAsset = '$assetRoot/spaceStation.png';
  static const String pathIconAsset = '$assetRoot/pathIcon.png';
  static const String iconMassAsset = '$assetRoot/iconMass.png';
  static const String modelIconAsset = '$assetRoot/modelIcon.png';
  static const String toScaleIconAsset = '$assetRoot/toScaleIcon.png';
}

enum GaoTimeSpeed { slow, normal, fast }

enum GaoSceneId {
  starPlanet,
  starPlanetMoon,
  planetMoon,
  planetSatellite,
}

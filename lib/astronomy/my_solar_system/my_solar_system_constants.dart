/// My Solar System constants — **唯一字面量来源**.
///
/// Tags: `[MSS-SOURCE]` `[KEPLER-SECONDARY]` `[TEMPORARY]` `[INFERRED]`
/// See `requirements/req-my-solar-system/PARAMETER_AUDIT.md`.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

class MySolarSystemConstants {
  MySolarSystemConstants._();

  // ── Physics ──────────────────────────────────────────────────────────────

  /// [KEPLER-SECONDARY] Kepler `EllipticalOrbitEngine.INITIAL_G`.
  /// Not an MSS first-hand literal. See `G-SOURCE-OF-TRUTH.md`.
  static const double G = 4.45669;

  /// [MSS-SOURCE] `MySolarSystemModel.ts` engineTimeScale
  static const double engineTimeScale = 0.05;

  /// [MSS-SOURCE] `NumericalEngine.run` 4000 / N
  static const double pefrlIterationBudget = 4000;

  /// [MSS-SOURCE] PEFRL coefficients `NumericalEngine.ts`
  static const double pefrlXi = 0.1786178958448091;
  static const double pefrlLambda = -0.2123418310626054;
  static const double pefrlChi = -0.06626458266981849;

  /// [MSS-SOURCE] `stepOnce` desiredStepsPerSecond
  static const double desiredStepsPerSecond = 30;

  /// [MSS-SOURCE] TimePanel stepForward `stepOnce(1/8)`
  static const double stepButtonDt = 1 / 8;

  /// [KEPLER-SECONDARY] `modelToViewTime: 1000/12.6`
  static const double modelToViewTime = 1000 / 12.6;

  /// [KEPLER-SECONDARY] `SolarSystemCommonModel` timeSpeedMap
  static const double timeSpeedFast = 7 / 4;
  static const double timeSpeedNormal = 1;
  static const double timeSpeedSlow = 1 / 4;

  // ── Zoom [MSS-SOURCE] ────────────────────────────────────────────────────

  static const int zoomLevelMin = 1;
  static const int zoomLevelMax = 6;
  static const int zoomLevelDefault = 4;
  static const double zoomScaleMin = 25;
  static const double zoomScaleMax = 125;

  /// [MSS-SOURCE] `Utils.linear(min, max, 25, 125, zoomLevel)`
  static double zoomScaleForLevel(int zoomLevel) {
    final t = (zoomLevel - zoomLevelMin) / (zoomLevelMax - zoomLevelMin);
    return zoomScaleMin + (zoomScaleMax - zoomScaleMin) * t;
  }

  // ── Body radius [KEPLER-SECONDARY] ───────────────────────────────────────

  static const double minBodyRadius = 0.03;
  static const double massToRadiusCoeff = 0.023;

  /// [INFERRED] paint/hit clamp so tiny masses stay visible/hittable
  static const double bodyViewRadiusMin = 4;
  static const double bodyViewRadiusMax = 80;

  /// [KEPLER-SECONDARY] BodyNode touch dilation
  static const double bodyHitDilation = 10;

  // ── Path [TEMPORARY] ─────────────────────────────────────────────────────

  /// [TEMPORARY] common uses MAX_PATH_DISTANCE (view length); point cap until common lands.
  static const int maxPathPoints = 800;

  /// [MSS-SOURCE] PathsCanvasNode strokeWidth
  static const double pathStrokeWidth = 3;

  // ── Mass / ValuesPanel [MSS-SOURCE + TEMPORARY] ───────────────────────────

  /// [MSS-SOURCE] ValuesColumnNode MASS_RANGE.min
  static const double massUiMin = 0.1;

  /// [TEMPORARY] Body.massProperty.range.max in common; doc ≈ 1.5 sun × 200 = 300
  static const double massUiMax = 300;

  /// [TEMPORARY] `MASS_SLIDER_STEP` lives in solar-system-common [BLOCKED]
  static const double massSliderStep = 0.1;

  /// [MSS-SOURCE] ValuesColumnNode decimal places
  static const int massDecimalPlaces = 2;
  static const int positionDecimalPlaces = 2;
  static const int velocityDecimalPlaces = 2;

  /// [MSS-SOURCE] ValuesColumnNode ranges
  static const double positionXMin = -14;
  static const double positionXMax = 14;
  static const double positionYMin = -8;
  static const double positionYMax = 8;
  static const double velocityComponentMin = -100;
  static const double velocityComponentMax = 100;

  // ── CoM [MSS-SOURCE] ─────────────────────────────────────────────────────

  /// following ⇔ |r| < this AND |v| < followComSpeedMax
  static const double followComPositionMax = 1;
  static const double followComSpeedMax = 0.01;

  // ── Velocity / Gravity vectors [KEPLER-SECONDARY] ─────────────────────────

  static const double positionMultiplier = 0.01;
  static const double velocityMultiplier = 10.00537695437279;
  static const double velocityToViewMultiplier =
      50 * positionMultiplier / velocityMultiplier;
  static const double velocityMinMagnitude = 1.055;
  static const double velocityGrabRadius = 18;

  /// [KEPLER-SECONDARY] VectorNode INITIAL_VECTOR_OFFSCALE
  static const double initialVectorOffscale = -3;

  /// [KEPLER-SECONDARY] gravityForceScalePowerProperty
  static const double gravityScalePowerMin = -2;
  static const double gravityScalePowerMax = 8;
  static const double gravityScalePowerDefault = 0;

  /// [MSS-SOURCE] Four Star Ballet LabModel sets -1.1
  static const double fourStarBalletGravityScalePower = -1.1;

  /// [MSS-SOURCE] Lab has 4 body slots; spinner drives active count.
  /// Range literal lives in common NumberProperty — [TEMPORARY] 1..4 from LabModel body count.
  static const int labBodiesMin = 1;
  static const int labBodiesMax = 4;
  static const int introBodiesFixed = 2;

  /// [KEPLER-SECONDARY] gravity offscale: log10(|F|) < 3.2 - scalePower
  static const double gravityOffscaleLogThreshold = 3.2;

  /// [TEMPORARY] Body.isOffscreen in common missing; |r| above this marks returnable.
  static const double offscreenRadiusAu = 50;

  /// [KEPLER-SECONDARY] VectorNode arrow geometry
  static const double vectorTailWidth = 5;
  static const double vectorHeadHeight = 15;
  static const double vectorHeadWidth = 12;

  // ── Grid [KEPLER-SECONDARY] ───────────────────────────────────────────────

  static const double gridSpacing = 1;
  static const int gridHalfCount = 30;

  // ── Measuring tape [KEPLER-SECONDARY] ────────────────────────────────────

  static const double tapeDefaultBaseX = 0;
  static const double tapeDefaultBaseY = 1;
  static const double tapeDefaultTipX = 1;
  static const double tapeDefaultTipY = 1;
  static const int tapeDecimalPlaces = 2;
  static const double tapeHandleRadius = 12;

  // ── Layout [KEPLER-SECONDARY / INFERRED] ─────────────────────────────────

  /// [KEPLER-SECONDARY] SCREEN_VIEW margins
  static const double screenMargin = 10;
  static const double panelCornerRadius = 5;
  static const double panelMargin = 10;
  static const double timePanelInnerSpacing = 10;

  /// [MSS-SOURCE] ScreenView centerOrbitOffset — parent MVT formula [BLOCKED]; ignored in Flutter MVT
  static const double centerOrbitOffsetX = 100;
  static const double centerOrbitOffsetY = 100;

  /// [INFERRED] overlay width clamp for narrow viewports
  static const double overlayWidthRatio = 0.42;
  static const double overlayWidthMin = 160;
  static const double overlayWidthMax = 320;

  /// [INFERRED] narrow phone — keep corner panels from covering entire canvas
  static const double narrowLayoutBreakpoint = 600;
  static const double overlayWidthNarrowRatio = 0.38;
  static const double overlayWidthNarrowMin = 130;
  static const double overlayWidthNarrowMax = 168;
  static const double overlayBottomHeightRatio = 0.45;
  static const double overlayBottomHeightNarrowRatio = 0.34;
  static const double offscaleCenterExtraWidth = 80;
  static const double presetComboMinWidth = 80;
  static const double presetComboMaxWidth = 200;
  static const double resetAllButtonSize = 48;

  /// [INFERRED] ValuesPanel slider track clamp
  static const double valuesSliderTrackMin = 60;
  static const double valuesSliderTrackMax = 200;
  static const double valuesBodyDotSize = 21;
  static const double valuesNumFieldHeight = 28;

  /// [TEMPORARY] preventCollision loop guard + nudge step
  static const double preventCollisionNudgeAu = 0.05;
  static const int preventCollisionMaxIterations = 100;

  /// [INFERRED / BLOCKED VectorNode] offscale indicator geometry
  static const double velocityOffscaleIndicatorOffsetX = 14;
  static const double velocityOffscaleIndicatorOffsetY = -14;
  static const double velocityOffscaleIndicatorRadius = 8;
  static const double velocityOffscaleIndicatorStroke = 2;
  static const double velocityGrabStrokeWidth = 3;
  static const double velocityLabelFontSize = 22;
  static const double velocityOffscaleLabelFontSize = 14;
  static const Color velocityGrabRingColor = Color(0xFFD3D3D3);
  static const Color velocityLabelColor = Color(0xFF808080);

  static bool isNarrowLayout(double screenWidth) =>
      screenWidth < narrowLayoutBreakpoint;

  static double overlayMaxWidth(double screenWidth) {
    if (isNarrowLayout(screenWidth)) {
      return (screenWidth * overlayWidthNarrowRatio).clamp(
        overlayWidthNarrowMin,
        overlayWidthNarrowMax,
      );
    }
    return (screenWidth * overlayWidthRatio).clamp(
      overlayWidthMin,
      overlayWidthMax,
    );
  }

  static double overlayBottomMaxHeight(
    double screenHeight,
    double screenWidth,
  ) {
    final ratio = isNarrowLayout(screenWidth)
        ? overlayBottomHeightNarrowRatio
        : overlayBottomHeightRatio;
    return screenHeight * ratio;
  }

  /// Clamp mass to UI slider range + step (does not change preset masses below min).
  static double clampMassUi(double mass) {
    final stepped = massSliderStep *
        (mass / massSliderStep).roundToDouble();
    return stepped.clamp(massUiMin, massUiMax);
  }

  /// [KEPLER-SECONDARY] `10^(power + INITIAL_VECTOR_OFFSCALE) * VELOCITY_TO_VIEW`
  static double gravityArrowScale(double gravityForceScalePower) {
    return math.pow(
          10,
          gravityForceScalePower + initialVectorOffscale,
        ).toDouble() *
        velocityToViewMultiplier;
  }
}

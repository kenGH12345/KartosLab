/// Constants shared across the States of Matter model (from PhET SOMConstants / MPM).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'model/atom_type.dart';

/// States of Matter shared constants — ported from PhET `SOMConstants.ts`.
class SomConstants {
  SomConstants._();

  static const double maxDt = 0.320;
  static const double nominalTimeStep = 1 / 60;

  static const double triplePointMonatomicModelTemperature = 0.26;
  static const double criticalPointMonatomicModelTemperature = 0.8;
  static const double triplePointDiatomicModelTemperature = 0.3;
  static const double criticalPointDiatomicModelTemperature = 1.5;
  static const double triplePointWaterModelTemperature = 0.28;
  static const double criticalPointWaterModelTemperature = 2.0;

  static const double neonTriplePointInKelvin = 24.5;
  static const double neonCriticalPointInKelvin = 45;
  static const double argonTriplePointInKelvin = 75;
  static const double argonCriticalPointInKelvin = 151;
  static const double o2TriplePointInKelvin = 54;
  static const double o2CriticalPointInKelvin = 155;
  static const double waterTriplePointInKelvin = 273;
  static const double waterCriticalPointInKelvin = 647;

  /// Adjustable-atom Kelvin anchors (from MultipleParticleModel.ts).
  static const double adjustableAtomTriplePointInKelvin = 75;
  static const double adjustableAtomCriticalPointInKelvin = 140;

  static const int maxNumAtoms = 500;

  static const double epsilonForWater = 200;
  static const double sigmaForWater = 444;
  static const double epsilonForDiatomicOxygen = 113;
  static const double sigmaForDiatomicOxygen = 365;

  static const double maxSigma = 500;
  static const double minSigma = 75;
  static const double maxEpsilon = 450;
  static const double minEpsilon = 20;

  static const double thetaHoh = 120 * math.pi / 180;
  static const double distanceFromOxygenToHydrogen = 1.0 / 3.12;
  static const double diatomicParticleDistance = 0.9;

  // Radii from BamElement / Element van der Waals (pm)
  static const double neonRadius = 154;
  static const double argonRadius = 188;
  static const double oxygenRadius = 152;
  static const double hydrogenRadius = 120;
  static const double adjustableAttractionDefaultRadius = 175;

  static const Color neonColor = Color(0xFF1AFFFB);
  static const Color argonColor = Color(0xFFFFAFAF);
  static const Color oxygenColor = Color(0xFFFF5500);
  static const Color hydrogenColor = Color(0xFFFFFFFF);
  static const Color adjustableAttractionColor = Color(0xFFCC66CC);

  /// SOMConstants.NEON_ATOM_EPSILON used for adjustable range (not InteractionStrengthTable).
  static const double neonAtomEpsilon = 32.8;

  static const double minAdjustableEpsilon = 1.5 * neonAtomEpsilon; // 49.2
  static const double maxAdjustableEpsilon = epsilonForWater * 1.7; // 340

  static const double kBoltzmann = 1.38e-23;

  static const double solidTemperature = 0.15;
  static const double liquidTemperature = 0.34;
  static const double gasTemperature = 1.0;
  static const double initialTemperature = solidTemperature;

  // MultipleParticleModel container / dynamics
  static const double containerWidth = 10000;
  static const double containerInitialHeight = 10000;
  static const double maxTemperature = 50.0;
  static const double minTemperature = 0.00001;
  static const double nominalGravitationalAccel = -0.045;
  static const double temperatureChangeRate = 0.07;
  static const double particleSpeedUpFactor = 4;
  static const double maxParticleMotionTimeStep = 0.025;
  static const double approachingAbsoluteZeroTemperature =
      solidTemperature * 0.85;
  static const double maxContainerExpandRate = 1500;
  static const double postExplosionContainerExpansionRate = 9000;
  static const double temperatureClosenessRange = 0.15;

  static const double pressureCalcTimeWindow = 12;
  static const double explosionPressure = 41;
  static const double explosionTime = 1;
  static const double pressureDisplayMultiplier = 5;

  static const double particleInteractionDistanceThreshSqrd = 6.25;
  static const double minDistanceSquared = 0.90;

  static AtomAttributesForType attributesFor(AtomType type) {
    switch (type) {
      case AtomType.neon:
        return const AtomAttributesForType(
          radius: neonRadius,
          mass: 20.1797,
          color: neonColor,
        );
      case AtomType.argon:
        return const AtomAttributesForType(
          radius: argonRadius,
          mass: 39.948,
          color: argonColor,
        );
      case AtomType.oxygen:
        return const AtomAttributesForType(
          radius: oxygenRadius,
          mass: 15.9994,
          color: oxygenColor,
        );
      case AtomType.hydrogen:
        return const AtomAttributesForType(
          radius: hydrogenRadius,
          mass: 1.00794,
          color: hydrogenColor,
        );
      case AtomType.adjustable:
        return const AtomAttributesForType(
          radius: adjustableAttractionDefaultRadius,
          mass: 25,
          color: adjustableAttractionColor,
        );
    }
  }
}

/// Radius / mass / color bundle for an [AtomType].
class AtomAttributesForType {
  const AtomAttributesForType({
    required this.radius,
    required this.mass,
    required this.color,
  });

  final double radius;
  final double mass;
  final Color color;
}

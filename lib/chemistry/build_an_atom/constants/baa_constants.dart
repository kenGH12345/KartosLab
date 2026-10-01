/// Build an Atom domain / layout constants — PhET `BAAConstants` + `BAAModel` + shred.
///
/// Model limits live here. Pure layout numbers used only by View are also
/// documented but must not be re-defined as particle-count semantics elsewhere.
library;

import 'dart:ui' show Size;

/// Shared constants for Build an Atom (model + design coordinate system).
class BAAConstants {
  BAAConstants._();

  // ── Design coordinate system (PhET ScreenView layoutBounds) ──────────────
  static const double designWidth = 768;
  static const double designHeight = 464;
  static const Size designSize = Size(designWidth, designHeight);

  // ── Particle pool maxima (`BAAModel.ts`) ─────────────────────────────────
  static const int maxProtons = 10;
  static const int maxNeutrons = 13;
  static const int maxElectrons = 10;

  // ── Particle radii (`shred/ShredConstants.ts`) ────────────────────────────
  static const double nucleonRadius = 10;
  static const double electronRadius = 8;

  // ── Electron shells (`shred/ParticleAtom.ts` defaults) ────────────────────
  static const double innerElectronShellRadius = 85;
  static const double outerElectronShellRadius = 130;
  static const int innerShellCapacity = 2;
  static const int outerShellCapacity = 8;
  static const int numElectronPositions = 10; // 2 + 8

  /// Electron capture multiplier vs outer shell radius (`BAAModel.ts`).
  static const double electronCaptureRadiusMultiplier = 1.1;

  static double get electronCaptureRadius =>
      outerElectronShellRadius * electronCaptureRadiusMultiplier;

  /// Nucleon capture radius from atom center (`BAAModel.ts`).
  static const double nucleonCaptureRadius = 100;

  // ── Nuclear instability jump (`BAAModel.ts`) ─────────────────────────────
  static const double nucleusJumpPeriod = 0.1; // seconds
  static double get maxNucleusJump => nucleonRadius * 0.5;

  // ── Reset All button (`BAAConstants.RESET_BUTTON_RADIUS`) ─────────────────
  static const double resetButtonRadius = 20;

  /// Touch drag offset in model space (`BAAConstants.PARTICLE_TOUCH_DRAG_OFFSET`).
  static const double particleTouchDragOffsetX = 0;
  static const double particleTouchDragOffsetY = -20;

  /// shred `DEFAULT_PARTICLE_SPEED` (model units / second).
  static const double defaultParticleSpeed = 200;

  // ── MVT: createSinglePointScaleInvertedYMapping(ZERO, (0.3W, 0.45H), 1) ─
  static const double mvtScale = 1.0;
  static double get mvtViewX => designWidth * 0.3; // 230.4
  static double get mvtViewY => designHeight * 0.45; // 208.8

  // ── Colors (shred PARTICLE_COLORS + DISPLAY_PANEL) ───────────────────────
  static const int protonColorValue = 0xFFD14600;
  static const int neutronColorValue = 0xFF5A5A5A; // Color.GRAY.darkerColor(0.1)
  static const int electronColorValue = 0xFF0000FF;
  static const int displayPanelBackgroundValue = 0xFFFEFF99;

  static const int controlsInset = 10;

  // ── Game (`BAAConstants` / `GameModel` / `BAAQueryParameters`) ────────────
  static const int numberOfGameLevels = 4;
  static const int challengesPerLevel = 5;
  static const int pointsFirstAttempt = 2;
  static const int pointsSecondAttempt = 1;
  static const int maxAttemptsPerChallenge = 2;
  static const int maxPointsPerGameLevel =
      challengesPerLevel * pointsFirstAttempt; // 10

  /// Schematic challenges use `protonCount < this` (`ChallengeDescriptorSetFactory`).
  static const int maxProtonNumberForSchematicChallenges = 3;

  // ── Bucket geometry (View/layout metadata; not particle-count semantics) ─
  static const double bucketWidth = 120;
  static const double bucketHeight = bucketWidth * 0.45; // 54
  static const double bucketYOffset = -205;
  static const double protonBucketX = -bucketWidth * 1.1; // -132
  static const double neutronBucketX = 0;
  static const double electronBucketX = bucketWidth * 1.1; // +132
}

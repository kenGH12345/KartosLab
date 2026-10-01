import 'dart:ui';

/// Constants from beers-law-lab `BLLConstants` + `ConcentrationModel`.
abstract final class ConcentrationConstants {
  static const Size layoutBounds = Size(1100, 700);

  static const double beakerVolume = 1.0; // L

  /// moles · RangeWithValue(0, 7, 0)
  static const double soluteAmountMin = 0;
  static const double soluteAmountMax = 7;
  static const double soluteAmountDefault = 0;

  /// L · RangeWithValue(0, BEAKER_VOLUME, 0.5)
  static const double solutionVolumeMin = 0;
  static const double solutionVolumeMax = beakerVolume;
  static const double solutionVolumeDefault = 0.5;

  static const double dropperFlowRate = 0.05; // L/s
  static const double shakerMaxDispensingRate = 0.2; // mol/s
  static const double faucetMaxFlowRate = 0.25; // L/s
  static const double maxEvaporationRate = 0.25; // L/s
  static const double faucetSpoutWidth = 45; // cm

  /// Drain stream height — `ConcentrationScreenView` `DRAIN_FLUID_HEIGHT`.
  static const double drainFluidHeight = 1000;

  /// Shaker particle kinematics (visual units, source `ShakerParticles.ts`).
  static const double shakerInitialSpeed = 100;
  static const double gravitationalAcceleration = 150;
  static const double shakerMaxXOffset = 20;
  static const double shakerMaxYOffset = 5;

  static const int decimalPlacesConcentrationMolesPerLiter = 3;
  static const int decimalPlacesConcentrationPercent = 1;
  static const int decimalPlacesVolumeLiters = 2;

  /// Beaker geometry (model coords, identity transform).
  static const Offset beakerPosition = Offset(350, 550);
  static const Size beakerSize = Size(600, 300);

  static const Offset shakerPosition = Offset(350, 170);
  static const Rect shakerDragBounds = Rect.fromLTRB(250, 50, 575, 210);

  /// 0.75π — source `ConcentrationModel` shaker orientation.
  static const double shakerOrientation = 2.356194490192345; // 0.75 * pi

  static const Offset dropperPosition = Offset(410, 225);

  static const Offset solventFaucetPosition = Offset(155, 220);
  static const double solventFaucetPipeMinX = -400;

  static const Offset drainFaucetPosition = Offset(750, 630);

  static const Offset meterBodyPosition = Offset(785, 210);
  static const Offset probeInitialPosition = Offset(750, 370);
  static const Rect probeDragBounds = Rect.fromLTRB(30, 150, 966, 680);

  /// Minimum non-zero solution height in view px (source `SolutionNode`).
  static const double minNonzeroSolutionHeight = 5;
}

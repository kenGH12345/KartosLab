/// Rutherford Scattering — constants from PhET RSConstants.ts
class RsConstants {
  RsConstants._();

  // Alpha particle energy (used as speed in model units)
  static const double minAlphaEnergy = 50;
  static const double maxAlphaEnergy = 100;
  static const double defaultAlphaEnergy = 80;

  static const bool defaultShowTraces = false;

  static const int minProtonCount = 20;
  static const int maxProtonCount = 100;
  static const int defaultProtonCount = 79;

  static const int minNeutronCount = 20;
  static const int maxNeutronCount = 150;
  static const int defaultNeutronCount = 118;

  static const double spaceNodeWidth = 510;
  static const double spaceNodeHeight = 510;
  static const double spaceBuffer = 10;

  static const double beamWidth = 40;
  static const double beamHeight = 110;

  static const double panelMinWidth = 230;
  static const double panelMaxWidth = 250;
  static const double panelSpaceMargin = 35;
  static const double panelTopMargin = 15;
  static const double panelVerticalMargin = 10;
  static const double panelXMargin = 15;
  static const double panelYMargin = 8;
  static const double panelChildSpacing = 5;
  static const double targetSpaceMargin = 50;

  /// PhET Joist ScreenView default layout.
  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;

  static const double resetAllRadius = 20.5;

  /// Atomic-scale atom deflection bounding width (RutherfordAtomSpace).
  static const double deflectionWidth = 30;

  static const double manualStepDt = 1 / 60;

  static const int maxParticles = 20;
  static const double gunIntensity = 1;
  static const double x0MinFraction = 0.04;

  // Atom collection visual (AtomCollectionNode)
  static const double ionizationEnergy = 13.6;
  static const double radiusScale = 5.95;
  static const int energyLevels = 6;

  // Particle rendering radii (ParticleNodeFactory)
  static const double electronRadius = 2.5;
  static const double electronLineWidth = 0.5;
  static const double protonRadius = 4;
  static const double neutronRadius = 4;
  static const double particleRadius = 2;
  static const double nucleusRadius = 2;

  static const double particleTraceWidth = 1.5;
  static const int fadeoutSegments = 80;

  // Scale label values (from ScreenView string formatting)
  static const String atomicScaleValue = '6.0 × 10⁻¹⁰';
  static const String nuclearScaleValue = '1.5 × 10⁻¹³';
  static const String plumPuddingScaleValue = '3.0 × 10⁻¹⁰';
}

/// Global preferences shared across all Molecule Polarity screens.
/// Source: `js/common/model/MPPreferences.ts`
enum DipoleDirection {
  /// Default PhET / Jmol style.
  positiveToNegative,

  /// IUPAC convention.
  negativeToPositive,
}

enum SurfaceColor {
  blueWhiteRed,
  rainbow,
}

enum SurfaceType {
  none,
  electrostaticPotential,
  electronDensity,
}

class MpPreferences {
  MpPreferences({
    this.dipoleDirection = DipoleDirection.positiveToNegative,
    this.surfaceColor = SurfaceColor.blueWhiteRed,
  });

  DipoleDirection dipoleDirection;
  SurfaceColor surfaceColor;

  void reset() {
    dipoleDirection = DipoleDirection.positiveToNegative;
    surfaceColor = SurfaceColor.blueWhiteRed;
  }
}

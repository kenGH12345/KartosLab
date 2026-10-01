/// PhET `TimeSpeed` values used by WOAS (`NORMAL` / `SLOW`).
enum WoasTimeSpeed {
  /// `speedMultiplier = 1`
  normal,

  /// `speedMultiplier = 0.25`
  slow,
}

extension WoasTimeSpeedX on WoasTimeSpeed {
  /// Source `speedMultiplier` in `WOASModel.manualStep`.
  double get speedMultiplier => this == WoasTimeSpeed.normal ? 1.0 : 0.25;
}

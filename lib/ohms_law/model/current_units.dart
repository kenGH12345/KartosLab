import 'ohms_law_constants.dart';

/// PhET `CurrentUnit` (`CurrentUnit.js`) — display unit for current readout.
///
/// Does **not** change [OhmsLawModel.currentProperty] physics (always mA).
enum CurrentUnit {
  milliamps,
  amps;

  /// Source default: `CurrentUnit.MILLIAMPS`.
  static const CurrentUnit sourceDefault = CurrentUnit.milliamps;

  /// `CurrentUnit.getSigFigs` — decimal places for `getFixedCurrent`.
  int get sigFigs {
    switch (this) {
      case CurrentUnit.milliamps:
        return OhmsLawConstants.currentMilliampsSigFigs;
      case CurrentUnit.amps:
        return OhmsLawConstants.currentAmpsSigFigs;
    }
  }

  /// Matches PhET `enumeration` `.name` used by `currentUnitsNameProperty`.
  String get sourceName {
    switch (this) {
      case CurrentUnit.milliamps:
        return 'MILLIAMPS';
      case CurrentUnit.amps:
        return 'AMPS';
    }
  }
}

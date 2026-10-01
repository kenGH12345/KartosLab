/// Visibility flags.
///
/// [已确认] `KeplersLawsVisibleProperties.ts` + `SolarSystemCommonVisibleProperties.ts`
library;

import 'law_mode.dart';

class KeplersLawsVisible {
  bool speedVisible = false;
  bool velocityVisible = true;
  bool gravityVisible = false;
  bool pathVisible = true;
  bool gridVisible = false;
  bool measuringTapeVisible = false;
  bool stopwatchVisible = false;
  bool targetOrbitPanelVisible = true;

  bool axesVisible = false;
  bool semiaxesChecked = false;
  bool fociVisible = false;
  bool stringChecked = false;
  bool eccentricityVisible = false;

  bool apoapsisVisible = false;
  bool periapsisVisible = false;
  bool areaValuesVisible = false;
  bool timeValuesVisible = false;
  bool secondLawAccordionExpanded = true;

  bool semiMajorAxisVisible = true;
  bool periodVisible = false;
  bool thirdLawAccordionExpanded = true;

  bool get semiaxesVisible => axesVisible && semiaxesChecked;
  bool get stringVisible => fociVisible && stringChecked;

  Map<LawMode, List<bool Function()>> get _getters => {
        LawMode.first: [
          () => stringChecked,
          () => semiaxesChecked,
          () => axesVisible,
          () => fociVisible,
          () => eccentricityVisible,
        ],
        LawMode.second: [
          () => apoapsisVisible,
          () => periapsisVisible,
          () => areaValuesVisible,
          () => timeValuesVisible,
          () => secondLawAccordionExpanded,
        ],
        LawMode.third: [
          () => semiMajorAxisVisible,
          () => periodVisible,
          () => thirdLawAccordionExpanded,
        ],
      };

  final Map<LawMode, List<bool>> _saved = {};

  /// [已确认] saveAndDisableVisibilityState
  void saveAndDisable(LawMode law) {
    final getters = _getters[law]!;
    _saved[law] = getters.map((g) => g()).toList();
    _setLaw(law, false);
  }

  /// [已确认] resetVisibilityState — restore saved initials
  void restore(LawMode law) {
    final saved = _saved[law];
    if (saved == null) return;
    _writeLaw(law, saved);
  }

  /// [已确认] hardVisibilityReset
  void hardReset() {
    stringChecked = false;
    semiaxesChecked = false;
    axesVisible = false;
    fociVisible = false;
    eccentricityVisible = false;
    apoapsisVisible = false;
    periapsisVisible = false;
    areaValuesVisible = false;
    timeValuesVisible = false;
    periodVisible = false;
    semiMajorAxisVisible = true;
    secondLawAccordionExpanded = true;
    thirdLawAccordionExpanded = true;
    stopwatchVisible = false;
    speedVisible = false;
    velocityVisible = true;
    gravityVisible = false;
    pathVisible = true;
    gridVisible = false;
    measuringTapeVisible = false;
    _saved.clear();
  }

  void _setLaw(LawMode law, bool value) {
    switch (law) {
      case LawMode.first:
        stringChecked = value;
        semiaxesChecked = value;
        axesVisible = value;
        fociVisible = value;
        eccentricityVisible = value;
      case LawMode.second:
        apoapsisVisible = value;
        periapsisVisible = value;
        areaValuesVisible = value;
        timeValuesVisible = value;
        secondLawAccordionExpanded = value;
      case LawMode.third:
        semiMajorAxisVisible = value;
        periodVisible = value;
        thirdLawAccordionExpanded = value;
    }
  }

  void _writeLaw(LawMode law, List<bool> v) {
    switch (law) {
      case LawMode.first:
        stringChecked = v[0];
        semiaxesChecked = v[1];
        axesVisible = v[2];
        fociVisible = v[3];
        eccentricityVisible = v[4];
      case LawMode.second:
        apoapsisVisible = v[0];
        periapsisVisible = v[1];
        areaValuesVisible = v[2];
        timeValuesVisible = v[3];
        secondLawAccordionExpanded = v[4];
      case LawMode.third:
        semiMajorAxisVisible = v[0];
        periodVisible = v[1];
        thirdLawAccordionExpanded = v[2];
    }
  }
}

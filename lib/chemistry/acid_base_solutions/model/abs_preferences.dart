/// Global preferences — PhET `ABSPreferences.ts` + `ABSQueryParameters.ts`.
///
/// Not cleared by Reset All.
class AbsPreferences {
  AbsPreferences({bool? showSolvent})
      : showSolvent = showSolvent ?? defaultShowSolvent;

  /// Query-parameter default: `showSolvent: false`.
  static const bool defaultShowSolvent = false;

  /// Whether to show solvent (H2O) image in Particles view.
  bool showSolvent;

  void resetToDefaults() {
    showSolvent = defaultShowSolvent;
  }
}

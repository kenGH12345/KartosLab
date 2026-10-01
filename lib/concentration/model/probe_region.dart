/// Concentration meter display units — `BLLPreferences.concentrationMeterUnitsProperty`.
enum ConcentrationMeterUnits {
  molesPerLiter,
  percent,
}

/// Probe fluid region for meter reading — abstracted from view shape intersection.
///
/// Source `ConcentrationMeterNode.updateValue` order:
/// solution OR drain → solution concentration
/// solvent stream → 0
/// stock stream → stock concentration
/// else → null
enum ProbeRegion {
  none,
  solution,
  waterStream,
  stockSolution,
  drainStream,
}

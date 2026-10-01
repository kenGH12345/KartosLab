/// Graph Source Audit (Phase 4 gate) — condensed from PhET `js/common/view/graph/`.
///
/// ## Screens
/// - Macro: NO graph
/// - Micro: YES — log + linear, heights 485 / 440, indicators read-only
/// - My Solution: YES — log only, height 565, H3O+/OH- indicators DRAGGABLE
///
/// ## Semantics (CRITICAL)
/// NOT continuous curves. Vertical thermometer-like scale + 3 indicator callouts
/// pointing to H2O / H3O+ / OH- concentration or quantity values.
///
/// ## Axes
/// - No X axis
/// - Log Y: exponents -16 … 2, value = 10^exponent
/// - Linear Y (Micro): mantissa 0…8 × 10^exponent, exponent -14…1 (default 1)
///
/// ## Defaults
/// Units: MOLES_PER_LITER; Scale: LOGARITHMIC; Expanded: true
///
/// ## Data
/// SolutionDerivedProperties concentration* / quantity* selected by GraphUnits
library;

// Documentation-only library marker for audit trail.
void graphSourceAuditAnchor() {}

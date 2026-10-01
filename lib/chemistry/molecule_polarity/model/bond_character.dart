import '../mp_constants.dart';

/// Bond character continuum position from dipole magnitude.
/// Source: `BondCharacterPanel.ts` — maps |dipole| over EN range length to [0,1].
double bondCharacterFraction(double dipoleMagnitude) {
  final max = MpConstants.electronegativityRangeLength;
  if (max <= 0) return 0;
  return (dipoleMagnitude / max).clamp(0.0, 1.0);
}

/// Intensity meter reading (`Reading.ts`).
class Reading {
  const Reading(this.value, {this.isMiss = false});

  final double value;
  final bool isMiss;

  static const Reading miss = Reading(0, isMiss: true);

  bool isHit() => !isMiss;

  /// Display percent string value = value * 100, 2 decimals (UI later).
  double get displayPercent => value * 100;
}

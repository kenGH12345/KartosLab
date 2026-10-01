/// PhET `OrientationEnum` — bar magnet polarity (no physical rotation).
enum MagnetOrientation {
  /// North (red) on the left, South (blue) on the right — default.
  ns,

  /// South on the left, North on the right.
  sn,
}

extension MagnetOrientationX on MagnetOrientation {
  MagnetOrientation get flipped =>
      this == MagnetOrientation.ns ? MagnetOrientation.sn : MagnetOrientation.ns;

  /// B-field sign from `Coil.updateMagneticField`:
  /// `orientation === NS ? -1 : 1`
  double get magneticFieldSign => this == MagnetOrientation.ns ? -1.0 : 1.0;
}

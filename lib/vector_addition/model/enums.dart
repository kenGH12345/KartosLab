/// Enumerations mirrored from PhET vector-addition model.
library;

enum CoordinateSnapMode {
  /// Tail and tip snap to integer grid coordinates.
  cartesian,

  /// Tip: integer magnitude + angle multiple of 5°.
  /// Tail: attract to other tip/tail or integer grid.
  polar,
}

enum GraphOrientation {
  horizontal,
  vertical,
  twoDimensional,
}

enum ComponentVectorStyle {
  invisible,
  triangle,
  parallelogram,
  projection,
}

enum EquationType {
  /// a + b = c
  addition,

  /// a - b = c
  subtraction,

  /// a + b + c = 0  ⇒  c = -(a + b)
  negation,
}

enum AngleConvention {
  /// [-180, 180)
  signed,

  /// (0, 360]
  unsigned,
}

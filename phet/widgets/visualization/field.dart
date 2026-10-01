/// PhET Field — abstract vector / scalar field with sampling.
///
/// Any simulation can provide a [Field] implementation (electric, magnetic,
/// gravitational, velocity, pressure, temperature) and the generic
/// [FieldArrowPainter] / [FieldLineRenderer] will visualize it.
library;

import 'package:flutter/material.dart';
import '../core/phet_types.dart';

/// Abstract vector field: given a point, return B(x,y) or E(x,y).
abstract class Field {
  /// Get field vector at [point].
  PhetVector valueAt(Offset point);

  /// Get field magnitude at [point].
  double magnitudeAt(Offset point) => valueAt(point).magnitude;

  /// Get field angle at [point].
  double angleAt(Offset point) => valueAt(point).angle;
}

/// A simple scalar field (temperature, pressure, etc.).
abstract class ScalarField {
  double valueAt(Offset point);
}

/// A [Field] backed by a function pointer.
class FunctionField extends Field {
  final PhetVector Function(Offset) fn;
  FunctionField(this.fn);

  @override
  PhetVector valueAt(Offset point) => fn(point);
}

/// A [ScalarField] backed by a function pointer.
class FunctionScalarField extends ScalarField {
  final double Function(Offset) fn;
  FunctionScalarField(this.fn);

  @override
  double valueAt(Offset point) => fn(point);
}

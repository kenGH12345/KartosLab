import 'package:flutter/material.dart';

import '../som_constants.dart';
import 'atom_type.dart';

/// Per-atom visual/physical attributes (from BamElement / SOMConstants map).
class AtomAttributes {
  const AtomAttributes({
    required this.radius,
    required this.mass,
    required this.color,
  });

  final double radius;
  final double mass;
  final Color color;

  static AtomAttributes forType(AtomType type) {
    final a = SomConstants.attributesFor(type);
    return AtomAttributes(radius: a.radius, mass: a.mass, color: a.color);
  }
}

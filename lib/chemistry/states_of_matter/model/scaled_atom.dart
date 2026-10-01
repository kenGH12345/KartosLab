import 'package:flutter/material.dart' show Color;

import 'atom_attributes.dart';
import 'atom_type.dart';
import 'som_vec2.dart';

/// Scaled (non-normalized) atom for view sync — PhET ScaledAtom.
class ScaledAtom {
  ScaledAtom(this.atomType, double initialX, double initialY)
      : position = SomVec2(initialX, initialY),
        radius = AtomAttributes.forType(atomType).radius,
        mass = AtomAttributes.forType(atomType).mass,
        color = AtomAttributes.forType(atomType).color;

  AtomType atomType;
  final SomVec2 position;
  final double radius;
  final double mass;
  final Color color;

  void setPosition(double x, double y) {
    position.setXY(x, y);
  }

  double getX() => position.x;
  double getY() => position.y;
  AtomType getType() => atomType;
}

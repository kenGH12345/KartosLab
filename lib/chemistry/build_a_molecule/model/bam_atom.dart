import 'dart:ui' show Offset, Rect;

import '../data/bam_element.dart';

int _nextAtomId = 0;

/// Atom with element identity. Ported from nitroglycerin Atom + Atom2 play fields.
class BamAtom {
  BamAtom(this.element) : id = _nextAtomId++;

  final BamElement element;
  final int id;

  String get symbol => element.symbol;

  double get atomicWeight => element.atomicWeight;

  double get covalentRadius => element.covalentRadius;

  bool isHydrogen() => element.isHydrogen();

  bool hasSameElement(BamAtom other) => element.isSameElement(other.element);

  @override
  String toString() => symbol;
}

/// Playable atom with position/destination for kit animation. Ported from Atom2.ts fields.
class BamPlayAtom extends BamAtom {
  BamPlayAtom(super.element);

  Offset position = Offset.zero;
  Offset destination = Offset.zero;
  bool dragging = false;
  bool visible = true;

  /// Axis-aligned bounds around [position] using covalent radius.
  Rect get positionBounds => Rect.fromCircle(
        center: position,
        radius: covalentRadius,
      );

  /// Axis-aligned bounds around [destination] using covalent radius.
  Rect get destinationBounds => Rect.fromCircle(
        center: destination,
        radius: covalentRadius,
      );

  void setPositionAndDestination(Offset point) {
    position = point;
    destination = point;
  }

  void translatePositionAndDestination(Offset delta) {
    position += delta;
    destination += delta;
  }

  void translate(double x, double y) {
    position = Offset(position.dx + x, position.dy + y);
  }

  void reset() {
    position = Offset.zero;
    destination = Offset.zero;
    dragging = false;
    visible = true;
  }
}

/// PubChem atom with 2d/3d coordinates. Ported from PubChemAtom in CompleteMolecule.ts.
enum BamPubChemAtomType { twoDimension, threeDimension, full }

class BamPubChemAtom extends BamAtom {
  BamPubChemAtom(
    super.element,
    this.type, {
    required this.x2d,
    required this.y2d,
    required this.x3d,
    required this.y3d,
    required this.z3d,
  });

  final BamPubChemAtomType type;
  final double x2d;
  final double y2d;
  final double x3d;
  final double y3d;
  final double z3d;

  static const double offset = 2.5;

  @override
  String toString() {
    switch (type) {
      case BamPubChemAtomType.twoDimension:
        return '${super.toString()} $x2d $y2d';
      case BamPubChemAtomType.threeDimension:
        return '${super.toString()} $x3d $y3d $z3d';
      case BamPubChemAtomType.full:
        return '${super.toString()} $x2d $y2d $x3d $y3d $z3d';
    }
  }
}

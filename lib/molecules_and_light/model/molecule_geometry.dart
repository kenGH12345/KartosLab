import 'dart:math' as math;
import 'dart:ui' show Color;

import '../molecules_and_light_constants.dart';

/// Atom visual data from PhET `Atom` factory methods (picometers, CSS colors).
class AtomSpec {
  const AtomSpec({
    required this.color,
    required this.radius,
    required this.offsetX,
    required this.offsetY,
    this.topLayer = false,
  });

  final Color color;
  final double radius;
  final double offsetX;
  final double offsetY;
  final bool topLayer;
}

class BondSpec {
  const BondSpec(this.a, this.b, {this.bondCount = 1});
  final int a;
  final int b;
  final int bondCount;
}

class MoleculeGeometry {
  const MoleculeGeometry(this.atoms, this.bonds);
  final List<AtomSpec> atoms;
  final List<BondSpec> bonds;
}

/// PhET oxygen uses PhetColorScheme.RED_COLORBLIND `#FF5500`.
const Color _oxygen = Color(0xFFFF5500);
const Color _carbon = Color(0xFF808080);
const Color _nitrogen = Color(0xFF0000FF);
const Color _hydrogen = Color(0xFFFFFFFF);

MoleculeGeometry geometryFor(MoleculeType type) {
  switch (type) {
    case MoleculeType.carbonMonoxide:
      return const MoleculeGeometry([
        AtomSpec(color: _carbon, radius: 77, offsetX: -85, offsetY: 0),
        AtomSpec(color: _oxygen, radius: 73, offsetX: 85, offsetY: 0),
      ], [
        BondSpec(0, 1, bondCount: 3),
      ]);
    case MoleculeType.nitrogen:
      return const MoleculeGeometry([
        AtomSpec(color: _nitrogen, radius: 75, offsetX: -85, offsetY: 0),
        AtomSpec(color: _nitrogen, radius: 75, offsetX: 85, offsetY: 0),
      ], [
        BondSpec(0, 1, bondCount: 3),
      ]);
    case MoleculeType.oxygen:
      return const MoleculeGeometry([
        AtomSpec(color: _oxygen, radius: 73, offsetX: -85, offsetY: 0),
        AtomSpec(color: _oxygen, radius: 73, offsetX: 85, offsetY: 0),
      ], [
        BondSpec(0, 1, bondCount: 2),
      ]);
    case MoleculeType.carbonDioxide:
      return const MoleculeGeometry([
        AtomSpec(color: _oxygen, radius: 73, offsetX: -170, offsetY: 0),
        AtomSpec(color: _carbon, radius: 77, offsetX: 0, offsetY: 0),
        AtomSpec(color: _oxygen, radius: 73, offsetX: 170, offsetY: 0),
      ], [
        BondSpec(0, 1, bondCount: 2),
        BondSpec(1, 2, bondCount: 2),
      ]);
    case MoleculeType.methane:
      const d = 155.0;
      const angle = math.pi * 0.9;
      final hx = d * math.cos(angle);
      final hy = d * math.sin(angle);
      const offset = 30.0;
      return MoleculeGeometry([
        AtomSpec(color: _carbon, radius: 77, offsetX: 0, offsetY: 0),
        AtomSpec(
          color: _hydrogen,
          radius: 37,
          offsetX: hx + offset,
          offsetY: hy,
          topLayer: true,
        ),
        AtomSpec(
          color: _hydrogen,
          radius: 37,
          offsetX: -hx - offset,
          offsetY: hy,
        ),
        AtomSpec(
          color: _hydrogen,
          radius: 37,
          offsetX: hx,
          offsetY: -hy + offset,
        ),
        AtomSpec(
          color: _hydrogen,
          radius: 37,
          offsetX: -hx,
          offsetY: -hy - offset,
        ),
      ], [
        const BondSpec(0, 1),
        const BondSpec(0, 2),
        const BondSpec(0, 3),
        const BondSpec(0, 4),
      ]);
    case MoleculeType.water:
      const bond = 130.0;
      const angle = 109 * math.pi / 180;
      final height = bond * math.cos(angle / 2);
      final hx = bond * math.sin(angle / 2);
      // Mass-weighted COG offsets from H2O.js
      const oMass = 12.011;
      const hMass = 1.0;
      const total = oMass + 2 * hMass;
      final oY = height * (2 * hMass / total);
      final hY = -(height - oY);
      return MoleculeGeometry([
        AtomSpec(color: _oxygen, radius: 73, offsetX: 0, offsetY: oY),
        AtomSpec(color: _hydrogen, radius: 37, offsetX: hx, offsetY: hY),
        AtomSpec(color: _hydrogen, radius: 37, offsetX: -hx, offsetY: hY),
      ], [
        const BondSpec(0, 1),
        const BondSpec(0, 2),
      ]);
    case MoleculeType.nitrogenDioxide:
    case MoleculeType.ozone:
      const bond = 180.0;
      const angle = 120 * math.pi / 180;
      final height = bond * math.cos(angle / 2);
      final width = 2 * bond * math.sin(angle / 2);
      final centerY = 2.0 / 3.0 * height;
      final wingY = -centerY / 2;
      final wingX = width / 2;
      final centerColor =
          type == MoleculeType.nitrogenDioxide ? _nitrogen : _oxygen;
      final centerRadius = type == MoleculeType.nitrogenDioxide ? 75.0 : 73.0;
      return MoleculeGeometry([
        AtomSpec(
          color: centerColor,
          radius: centerRadius,
          offsetX: 0,
          offsetY: centerY,
        ),
        AtomSpec(color: _oxygen, radius: 73, offsetX: wingX, offsetY: wingY),
        AtomSpec(color: _oxygen, radius: 73, offsetX: -wingX, offsetY: wingY),
      ], [
        BondSpec(0, 1, bondCount: type == MoleculeType.ozone ? 2 : 2),
        const BondSpec(0, 2),
      ]);
  }
}

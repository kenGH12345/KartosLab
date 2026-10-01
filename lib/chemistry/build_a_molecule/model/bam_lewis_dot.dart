import 'dart:ui' show Offset;

import 'bam_atom.dart';
import 'bam_direction.dart';

/// Lewis-dot directional connections for kit atoms. Ported from LewisDotModel.ts.
class BamLewisDotModel {
  BamLewisDotModel() {
    BamDirection.ensureOpposites();
  }

  final Map<int, BamLewisDotAtom> atomMap = {};

  void addAtom(BamAtom atom) {
    atomMap[atom.id] = BamLewisDotAtom(atom);
  }

  void breakBondsOfAtom(BamAtom atom) {
    final dotAtom = getLewisDotAtom(atom);
    for (final direction in BamDirection.values) {
      if (dotAtom.hasConnection(direction)) {
        final other = dotAtom.getLewisDotAtom(direction);
        if (other != null) {
          breakBond(dotAtom.atom, other.atom);
        }
      }
    }
  }

  void breakBond(BamAtom a, BamAtom b) {
    final dotA = getLewisDotAtom(a);
    final direction = getBondDirection(a, b);
    dotA.disconnect(direction);
    getLewisDotAtom(b).disconnect(direction.opposite);
  }

  void bond(BamAtom a, BamDirection dirAtoB, BamAtom b) {
    final dotA = getLewisDotAtom(a);
    final dotB = getLewisDotAtom(b);
    dotA.connect(dirAtoB, dotB);
    dotB.connect(dirAtoB.opposite, dotA);
  }

  List<BamDirection> getOpenDirections(BamAtom atom) {
    final result = <BamDirection>[];
    final dotAtom = getLewisDotAtom(atom);
    for (final direction in BamDirection.values) {
      if (!dotAtom.hasConnection(direction)) {
        result.add(direction);
      }
    }
    return result;
  }

  BamDirection getBondDirection(BamAtom a, BamAtom b) {
    final dotA = getLewisDotAtom(a);
    for (final test in BamDirection.values) {
      if (dotA.hasConnection(test) &&
          identical(dotA.getLewisDotAtom(test)!.atom, b)) {
        return test;
      }
    }
    return BamDirection.values.first;
  }

  bool willAllowBond(BamAtom a, BamDirection direction, BamAtom b) {
    final coordinateMap = <String, BamAtom>{};
    var success = _mapMolecule(Offset.zero, a, null, coordinateMap);
    success =
        success && _mapMolecule(direction.vector, b, null, coordinateMap);
    return success;
  }

  bool _mapMolecule(
    Offset coordinates,
    BamAtom atom,
    BamAtom? excludedAtom,
    Map<String, BamAtom> coordinateMap,
  ) {
    final dotAtom = getLewisDotAtom(atom);
    final point = Offset(
      coordinates.dx.roundToDouble(),
      coordinates.dy.roundToDouble(),
    );
    final idx = '${point.dx},${point.dy}';

    if (coordinateMap.containsKey(idx)) {
      if (!atom.isHydrogen() || !coordinateMap[idx]!.isHydrogen()) {
        return false;
      }
    } else {
      coordinateMap[idx] = atom;
    }

    for (final direction in BamDirection.values) {
      if (dotAtom.hasConnection(direction)) {
        final otherDot = dotAtom.getLewisDotAtom(direction)!;
        if (!identical(otherDot.atom, excludedAtom)) {
          final ok = _mapMolecule(
            coordinates + direction.vector,
            otherDot.atom,
            atom,
            coordinateMap,
          );
          if (!ok) return false;
        }
      }
    }
    return true;
  }

  BamLewisDotAtom getLewisDotAtom(BamAtom atom) {
    final result = atomMap[atom.id];
    if (result == null) {
      throw StateError('LewisDotAtom missing for atom ${atom.id}');
    }
    return result;
  }
}

class BamLewisDotAtom {
  BamLewisDotAtom(this.atom) {
    for (final direction in BamDirection.values) {
      connections[direction.id] = null;
    }
  }

  final BamAtom atom;
  final Map<String, BamLewisDotAtom?> connections = {};

  bool hasConnection(BamDirection direction) =>
      connections[direction.id] != null;

  BamLewisDotAtom? getLewisDotAtom(BamDirection direction) =>
      connections[direction.id];

  void connect(BamDirection direction, BamLewisDotAtom lewisDotAtom) {
    connections[direction.id] = lewisDotAtom;
  }

  void disconnect(BamDirection direction) {
    connections[direction.id] = null;
  }
}

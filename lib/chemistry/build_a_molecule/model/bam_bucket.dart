import 'dart:math' as math;
import 'dart:ui' show Offset, Size;

import '../data/bam_element.dart';
import 'bam_atom.dart';

/// Element bucket holding playable atoms. Ported from BAMBucket.ts (simplified packing).
class BamBucket {
  BamBucket({
    required this.size,
    required this.element,
    required this.capacity,
  }) : width = size.width * 0.95 {
    for (var i = 0; i < capacity; i++) {
      final atom = BamPlayAtom(element);
      atoms.add(atom);
      fullState.add(atom);
    }
    _layoutAtomsInBucket();
  }

  final Size size;
  final BamElement element;
  final int capacity;
  final double width;

  Offset position = Offset.zero;
  final List<BamPlayAtom> atoms = [];
  final List<BamPlayAtom> fullState = [];

  List<BamPlayAtom> get particleList => atoms;

  bool containsParticle(BamPlayAtom atom) => atoms.contains(atom);

  bool isFull() => fullState.length == atoms.length;

  void setPosition(Offset newPosition) {
    final delta = newPosition - position;
    position = newPosition;
    for (final atom in atoms) {
      atom.translatePositionAndDestination(delta);
    }
  }

  /// Instantly place atom into bucket packing. Port of placeAtom.
  void placeAtom(BamPlayAtom atom, {bool addFirstOpen = true}) {
    if (atoms.contains(atom)) {
      atoms.remove(atom);
    }
    if (addFirstOpen) {
      atoms.insert(0, atom);
    } else {
      atoms.add(atom);
    }
    _layoutAtomsInBucket();
  }

  void addParticleNearestOpen(BamPlayAtom atom, {bool animate = false}) {
    if (!atoms.contains(atom)) {
      atoms.add(atom);
    }
    _layoutAtomsInBucket();
  }

  void removeParticle(BamPlayAtom atom) {
    atoms.remove(atom);
    _layoutAtomsInBucket();
  }

  void setToFullState() {
    for (final atom in fullState) {
      if (!atoms.contains(atom)) {
        atoms.add(atom);
      }
    }
    _layoutAtomsInBucket();
  }

  /// Two-row packing centered on [position].
  void _layoutAtomsInBucket() {
    if (atoms.isEmpty) return;
    final r = element.covalentRadius;
    final n = atoms.length;
    final onBottom = n <= 2 ? n : (n / 2).floor() + 1;
    final onTop = n - onBottom;
    var idx = 0;

    void placeRow(int count, double yOffset) {
      if (count <= 0) return;
      final totalWidth = (count - 1) * (2 * r * 1.1);
      final startX = position.dx - totalWidth / 2;
      for (var i = 0; i < count; i++) {
        final atom = atoms[idx++];
        atom.setPositionAndDestination(
          Offset(startX + i * (2 * r * 1.1), position.dy + yOffset),
        );
      }
    }

    placeRow(onBottom, r * 0.3);
    placeRow(onTop, -r * 1.5);
  }

  static double calculateIdealBucketWidth(double radius, int quantity) {
    final numOnBottomRow =
        (quantity <= 2) ? quantity : (quantity / 2 + 1).floor();
    final width = 2 * radius * (numOnBottomRow + 1);
    return math.max(350, width + 1).floorToDouble();
  }

  static BamBucket createAutoSized(BamElement element, int quantity) {
    return BamBucket(
      size: Size(calculateIdealBucketWidth(element.covalentRadius, quantity), 200),
      element: element,
      capacity: quantity,
    );
  }
}

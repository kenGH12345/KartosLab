import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import '../data/bam_element.dart';
import '../data/bam_molecule_catalog.dart';
import 'bam_atom.dart';
import 'bam_bucket.dart';
import 'bam_collection_box.dart';
import 'bam_collection_layout.dart';
import 'bam_direction.dart';
import 'bam_lewis_dot.dart';
import 'bam_molecule.dart';
import 'bam_molecule_structure.dart';

int _kitIdCounter = 0;

/// Kit with buckets + play area bonding. Ported from Kit.ts.
class BamKit {
  BamKit(this.collectionLayout, this.buckets, {math.Random? random})
      : id = _kitIdCounter++,
        _random = random ?? math.Random() {
    BamDirection.ensureOpposites();
    reset();
    layoutBuckets(buckets);
  }

  final int id;
  final BamCollectionLayout collectionLayout;
  final List<BamBucket> buckets;
  final math.Random _random;

  final List<BamPlayAtom> atomsInPlayArea = [];
  final List<BamPlayAtom> atoms = [];
  final List<BamPlayAtom> atomsInCollectionBox = [];
  final List<BamMolecule> molecules = [];
  BamLewisDotModel? lewisDotModel;
  BamPlayAtom? selectedAtom;
  bool active = false;
  bool visible = false;

  /// Kit.addedMoleculeEmitter / removedMoleculeEmitter equivalents.
  void Function(BamMolecule molecule)? onMoleculeAdded;
  void Function(BamMolecule molecule)? onMoleculeRemoved;

  static const double bondDistanceThreshold = 100;
  static const double bucketPadding = 50;
  static const double interMoleculePadding = 100;

  void reset() {
    selectedAtom = null;
    for (final m in List<BamMolecule>.from(molecules)) {
      removeMolecule(m);
    }

    for (final atom in [...atoms, ...atomsInCollectionBox]) {
      atom.reset();
      getBucketForElement(atom.element).placeAtom(atom, addFirstOpen: true);
    }

    atoms.clear();
    atomsInCollectionBox.clear();
    atomsInPlayArea.clear();
    lewisDotModel = BamLewisDotModel();
    molecules.clear();

    for (final bucket in buckets) {
      atoms.addAll(bucket.particleList);
      for (final atom in bucket.particleList) {
        lewisDotModel!.addAtom(atom);
      }
      bucket.setToFullState();
    }
  }

  void layoutBuckets(List<BamBucket> buckets) {
    var usedWidth = 0.0;
    double? minY;
    double? maxY;

    for (var i = 0; i < buckets.length; i++) {
      final bucket = buckets[i];
      if (i != 0) usedWidth += bucketPadding;
      for (final atom in bucket.particleList) {
        final b = atom.positionBounds;
        minY = minY == null ? b.top : math.min(minY, b.top);
        maxY = maxY == null ? b.bottom : math.max(maxY, b.bottom);
      }
      bucket.setPosition(Offset(usedWidth, 0));
      usedWidth += bucket.width;
    }

    final centerY = (minY != null && maxY != null) ? (minY + maxY) / 2 : 0.0;
    for (final bucket in buckets) {
      bucket.setPosition(
        Offset(bucket.position.dx - usedWidth / 2 + bucket.width / 2, centerY),
      );
    }

    // Place kit into collection kit bounds (bottom center of kit area).
    final kitCenter = collectionLayout.availableKitBounds.center;
    for (final bucket in buckets) {
      bucket.setPosition(
        Offset(
          kitCenter.dx + bucket.position.dx,
          kitCenter.dy + bucket.position.dy * 0.2,
        ),
      );
    }
  }

  BamBucket getBucketForElement(BamElement element) {
    return buckets.firstWhere(
      (b) => b.element.isSameElement(element),
      orElse: () =>
          throw StateError('Element does not have an associated bucket.'),
    );
  }

  void atomDropped(BamAtom atom, {required bool droppedInKitArea}) {
    final molecule = getMolecule(atom);
    if (droppedInKitArea) {
      if (molecule != null) {
        recycleMoleculeIntoBuckets(molecule);
      }
    } else {
      if (molecule != null) {
        attemptToBondMolecule(molecule);
        separateMoleculeDestinations();
      }
    }
  }

  void moleculePutInCollectionBox(BamMolecule molecule, BamCollectionBox box) {
    removeMolecule(molecule);
    for (final atom in molecule.atoms) {
      final play = atom as BamPlayAtom;
      atoms.remove(play);
      atomsInCollectionBox.add(play);
      play.visible = false;
      atomsInPlayArea.remove(play);
    }
    box.addMolecule(molecule);
  }

  bool isAtomInPlay(BamAtom atom) => getMolecule(atom) != null;

  BamMolecule? getMolecule(BamAtom atom) {
    for (final molecule in molecules) {
      if (molecule.atoms.contains(atom)) return molecule;
    }
    return null;
  }

  void breakMolecule(BamMolecule molecule) {
    removeMolecule(molecule);
    for (final atom in molecule.atoms) {
      lewisDotModel!.breakBondsOfAtom(atom);
      final newMolecule = BamMolecule();
      newMolecule.addAtom(atom);
      addMolecule(newMolecule);
    }
    separateMoleculeDestinations();
  }

  void breakBond(BamAtom a, BamAtom b) {
    final oldMolecule = getMolecule(a);
    if (oldMolecule == null) return;
    final newMolecules = BamMoleculeStructure.getMoleculesFromBrokenBond(
      oldMolecule,
      oldMolecule.getBond(a, b),
      BamMolecule(),
      BamMolecule(),
    );
    lewisDotModel!.breakBond(a, b);
    removeMolecule(oldMolecule);
    for (final m in newMolecules) {
      addMolecule(m as BamMolecule);
    }
    separateMoleculeDestinations();
  }

  BamDirection getBondDirection(BamAtom a, BamAtom b) =>
      lewisDotModel!.getBondDirection(a, b);

  bool allBucketsFilled() => buckets.every((b) => b.isFull());

  void addMolecule(BamMolecule molecule) {
    molecules.add(molecule);
    onMoleculeAdded?.call(molecule);
  }

  void removeMolecule(BamMolecule molecule) {
    molecules.remove(molecule);
    onMoleculeRemoved?.call(molecule);
  }

  /// Pull atom from its bucket into play and try bonding.
  void addAtomToPlay(BamPlayAtom atom) {
    final bucket = getBucketForElement(atom.element);
    bucket.removeParticle(atom);
    if (!atomsInPlayArea.contains(atom)) {
      atomsInPlayArea.add(atom);
    }
    final molecule = BamMolecule();
    molecule.addAtom(atom);
    addMolecule(molecule);
    attemptToBondMolecule(molecule);
  }

  bool isContainedInBucket(BamAtom atom) {
    return buckets.any((b) => b.containsParticle(atom as BamPlayAtom));
  }

  void recycleAtomIntoBuckets(BamPlayAtom atom, {bool animate = true}) {
    lewisDotModel!.breakBondsOfAtom(atom);
    atomsInPlayArea.remove(atom);
    final bucket = getBucketForElement(atom.element);
    bucket.addParticleNearestOpen(atom, animate: animate);
  }

  void recycleMoleculeIntoBuckets(BamMolecule molecule) {
    for (final atom in molecule.atoms) {
      recycleAtomIntoBuckets(atom as BamPlayAtom);
    }
    removeMolecule(molecule);
  }

  Rect _padMoleculeBounds(Rect bounds) {
    const half = interMoleculePadding / 2;
    return Rect.fromLTRB(
      bounds.left - half,
      bounds.top - half,
      bounds.right + half,
      bounds.bottom + half,
    );
  }

  void separateMoleculeDestinations() {
    var maxIterations = 200;
    const pushAmount = 10.0;
    final available = collectionLayout.availablePlayAreaBounds;
    final numMolecules = molecules.length;
    var foundOverlap = true;

    while (foundOverlap && maxIterations-- >= 0) {
      foundOverlap = false;
      for (var i = 0; i < numMolecules; i++) {
        final a = molecules[i];
        var aBounds = _padMoleculeBounds(a.destinationBounds);

        if (aBounds.left < available.left) {
          a.shiftDestination(Offset(available.left - aBounds.left, 0));
          aBounds = _padMoleculeBounds(a.destinationBounds);
        }
        if (aBounds.right > available.right) {
          a.shiftDestination(Offset(available.right - aBounds.right, 0));
          aBounds = _padMoleculeBounds(a.destinationBounds);
        }
        if (aBounds.top < available.top) {
          a.shiftDestination(Offset(0, available.top - aBounds.top));
          aBounds = _padMoleculeBounds(a.destinationBounds);
        }
        if (aBounds.bottom > available.bottom) {
          a.shiftDestination(Offset(0, available.bottom - aBounds.bottom));
        }

        for (var k = 0; k < numMolecules; k++) {
          final b = molecules[k];
          if (a.moleculeId >= b.moleculeId) continue;
          final bBounds = _padMoleculeBounds(b.destinationBounds);
          if (aBounds.overlaps(bBounds)) {
            foundOverlap = true;
            final aCenter = aBounds.center +
                Offset(_random.nextDouble() - 0.5, _random.nextDouble() - 0.5);
            final bCenter = bBounds.center +
                Offset(_random.nextDouble() - 0.5, _random.nextDouble() - 0.5);
            var delta = bCenter - aCenter;
            final len = delta.distance;
            if (len < 1e-6) {
              delta = const Offset(1, 0);
            } else {
              delta = Offset(delta.dx / len, delta.dy / len) * pushAmount;
            }
            final aw = a.getApproximateMolecularWeight();
            final bw = b.getApproximateMolecularWeight();
            final pushRatio = aw / (aw + bw);
            b.shiftDestination(delta * pushRatio);
            a.shiftDestination(delta * (-1 * (1 - pushRatio)));
            aBounds = _padMoleculeBounds(a.destinationBounds);
          }
        }
      }
    }

    // Snap positions to destinations after separation.
    for (final m in molecules) {
      for (final atom in m.atoms) {
        final play = atom as BamPlayAtom;
        play.position = play.destination;
      }
    }
  }

  void bond(BamAtom a, BamDirection dirAtoB, BamAtom b) {
    lewisDotModel!.bond(a, dirAtoB, b);
    final molA = getMolecule(a);
    final molB = getMolecule(b);
    if (identical(molA, molB)) {
      throw StateError('loop or other invalid structure detected');
    }
    if (molA == null || molB == null) {
      throw StateError('Molecules not found for bonding');
    }
    final newMolecule = BamMoleculeStructure.getCombinedMoleculeFromBond(
      molA,
      molB,
      a,
      b,
      BamMolecule(),
    ) as BamMolecule;
    removeMolecule(molA);
    removeMolecule(molB);
    addMolecule(newMolecule);
  }

  BamMoleculeStructure getPossibleMoleculeStructureFromBond(
    BamAtom a,
    BamAtom b,
  ) {
    final molA = getMolecule(a);
    final molB = getMolecule(b);
    if (molA == null || molB == null) {
      throw StateError('Molecules not found');
    }
    return BamMoleculeStructure.getCombinedMoleculeFromBond(
      molA,
      molB,
      a,
      b,
      BamMolecule(),
    );
  }

  /// Attempt to bond [moleculeToAttempt] to another molecule.
  bool attemptToBondMolecule(BamMolecule moleculeToAttempt) {
    BamBondingOption? bestBondingOption;
    var bestDistanceFromIdealPosition = double.infinity;
    var atomsOverlap = false;

    for (final ourAtomRaw in moleculeToAttempt.atoms) {
      final ourAtom = ourAtomRaw as BamPlayAtom;
      for (final otherAtom in atoms) {
        if (identical(getMolecule(otherAtom), moleculeToAttempt)) continue;
        if (isContainedInBucket(otherAtom)) continue;
        if (identical(otherAtom, ourAtom) || !canBond(ourAtom, otherAtom)) {
          continue;
        }

        for (final otherDirection
            in lewisDotModel!.getOpenDirections(otherAtom)) {
          final direction = otherDirection.opposite;
          if (!lewisDotModel!.getOpenDirections(ourAtom).contains(direction)) {
            continue;
          }
          if (!lewisDotModel!.willAllowBond(ourAtom, direction, otherAtom)) {
            continue;
          }

          final option = BamBondingOption(otherAtom, otherDirection, ourAtom);
          final distance = ourAtom.position - option.idealPosition;
          final d = distance.distance;
          if (d < bestDistanceFromIdealPosition) {
            bestBondingOption = option;
            bestDistanceFromIdealPosition = d;
          }
          if (ourAtom.positionBounds.overlaps(otherAtom.positionBounds)) {
            atomsOverlap = true;
          }
        }
      }
    }

    final isBondingInvalid =
        (bestBondingOption == null ||
            bestDistanceFromIdealPosition > bondDistanceThreshold) &&
        !atomsOverlap;

    if (isBondingInvalid) {
      separateMoleculeDestinations();
      return false;
    }

    final bondingOption = bestBondingOption!;
    final delta = bondingOption.idealPosition - bondingOption.b.position;
    final moleculeWithAtom = getMolecule(bondingOption.b);
    if (moleculeWithAtom == null) return false;
    for (final atomInMolecule in moleculeWithAtom.atoms) {
      final play = atomInMolecule as BamPlayAtom;
      play.setPositionAndDestination(play.position + delta);
    }
    bond(bondingOption.a, bondingOption.direction, bondingOption.b);
    return true;
  }

  bool canBond(BamAtom a, BamAtom b) {
    return getMolecule(b) != null &&
        !identical(getMolecule(a), getMolecule(b)) &&
        isAllowedStructure(getPossibleMoleculeStructureFromBond(a, b)) &&
        collectionLayout.availablePlayAreaBounds
            .contains((a as BamPlayAtom).position) &&
        collectionLayout.availablePlayAreaBounds
            .contains((b as BamPlayAtom).position);
  }

  bool isAllowedStructure(BamMoleculeStructure moleculeStructure) {
    if (moleculeStructure.atoms.length < 2) return true;
    final catalog = BamMoleculeCatalog.mainInstance;
    if (catalog == null || !catalog.hasStructures) {
      // Without structures loaded, allow diatomic / small builds for tests that
      // only load collection molecules — still gate via equivalence when possible.
      return moleculeStructure.isValid();
    }
    return catalog.isAllowedStructure(moleculeStructure);
  }

  /// Refill buckets to full capacity (atoms not in collection boxes).
  void refill() {
    reset();
  }
}

/// Bond option from A to B. B moves near A. Ported from Kit.BondingOption.
class BamBondingOption {
  BamBondingOption(this.a, this.direction, this.b)
      : idealPosition = a.position +
            direction.vector *
                (a.covalentRadius + b.covalentRadius);

  final BamPlayAtom a;
  final BamDirection direction;
  final BamPlayAtom b;
  final Offset idealPosition;
}

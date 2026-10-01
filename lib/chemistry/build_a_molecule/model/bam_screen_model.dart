import 'dart:math' as math;
import 'dart:ui' show Size;

import '../data/bam_element.dart';
import '../data/bam_molecule_catalog.dart';
import 'bam_bucket.dart';
import 'bam_collection_box.dart';
import 'bam_collection_layout.dart';
import 'bam_complete_molecule.dart';
import 'bam_kit.dart';
import 'bam_kit_collection.dart';

/// Screen-level model: collections carousel + reset/generate.
/// Ported from BAMModel.ts.
class BamScreenModel {
  BamScreenModel({
    required BamKitCollection firstCollection,
    required this.collectionLayout,
    required this.isMultipleCollection,
    math.Random? random,
  })  : firstCollection = firstCollection,
        _random = random ?? math.Random() {
    collections.add(firstCollection);
    currentIndex = 0;
  }

  final BamCollectionLayout collectionLayout;
  final bool isMultipleCollection;
  final BamKitCollection firstCollection;
  final math.Random _random;

  final List<BamKitCollection> collections = [];
  int currentIndex = 0;
  BamCompleteMolecule? dialogMolecule;

  BamKitCollection get currentCollection => collections[currentIndex];

  BamKit? get currentKit => currentCollection.currentKit;

  void addCollection(BamKitCollection collection) {
    collections.add(collection);
    currentIndex = collections.indexOf(collection);
  }

  void reset() {
    switchTo(collections[0]);
    collections[0].reset();
    collections
      ..clear()
      ..add(firstCollection);
    currentIndex = 0;
  }

  bool hasPreviousCollection() => currentIndex > 0;

  bool hasNextCollection() => currentIndex < collections.length - 1;

  void switchToPreviousCollection() {
    if (hasPreviousCollection()) {
      switchTo(collections[currentIndex - 1]);
    }
  }

  void switchToNextCollection() {
    if (hasNextCollection()) {
      switchTo(collections[currentIndex + 1]);
    }
  }

  void switchTo(BamKitCollection collection) {
    currentIndex = collections.indexOf(collection);
  }

  BamCompleteMolecule pickRandomMoleculeNotIn(List<BamCompleteMolecule> used) {
    final pool = BamMoleculeCatalog.collectionBoxMolecules;
    while (true) {
      final molecule = pool[_random.nextInt(pool.length)];
      if (!used.contains(molecule)) return molecule;
    }
  }

  /// Generate a fillable kit collection. Ported from BAMModel.generateKitCollection.
  BamKitCollection generateKitCollection({
    required bool allowMultipleMolecules,
    required int numBoxes,
  }) {
    const maxInBox = 3;
    final usedMolecules = <BamCompleteMolecule>[];
    final kits = <BamKit>[];
    final boxes = <BamCollectionBox>[];
    var molecules = <BamCompleteMolecule>[];

    for (var i = 0; i < numBoxes; i++) {
      final molecule = pickRandomMoleculeNotIn(usedMolecules);
      usedMolecules.add(molecule);
      var numberInBox =
          allowMultipleMolecules ? 1 + _random.nextInt(maxInBox) : 1;
      final carbonCount = molecule.getHistogram().getQuantity(BamElement.C);
      if (carbonCount > 1) {
        numberInBox = math.min(2, numberInBox);
      }
      final box = BamCollectionBox(molecule, numberInBox);
      boxes.add(box);
      for (var j = 0; j < box.capacity; j++) {
        molecules.add(molecule);
      }
    }

    molecules = List<BamCompleteMolecule>.from(molecules)..shuffle(_random);

    while (molecules.isNotEmpty) {
      final buckets = <BamBucket>[];
      final molecule = molecules.first;
      final targetFormula = molecule.getHillSystemFormulaFragment();
      final equivalentRemaining = molecules
          .where((m) => m.getHillSystemFormulaFragment() == targetFormula)
          .length;
      final ableToIncrease =
          allowMultipleMolecules && equivalentRemaining > 1;
      var atomMultiple = 1 + (ableToIncrease ? equivalentRemaining : 0);

      final uniqueElements = <BamElement>[];
      for (final e in molecule.getElementList()) {
        if (!uniqueElements.any((u) => u.isSameElement(e))) {
          uniqueElements.add(e);
        }
      }
      for (final element in uniqueElements) {
        buckets.add(_createBucketForElement(element, molecule, atomMultiple));
      }
      kits.add(BamKit(collectionLayout, buckets, random: _random));

      molecules.removeAt(0);
      atomMultiple -= 1;
      while (atomMultiple > 0) {
        for (var k = 0; k < molecules.length; k++) {
          if (molecules[k].getHillSystemFormulaFragment() ==
              molecule.getHillSystemFormulaFragment()) {
            molecules.removeAt(k);
            break;
          }
        }
        atomMultiple -= 1;
      }
    }

    final collection = BamKitCollection(enableCues: true);
    for (final kit in kits) {
      collection.addKit(kit, triggerCue: true);
    }
    for (final box in boxes) {
      collection.addCollectionBox(box);
    }
    return collection;
  }

  BamBucket _createBucketForElement(
    BamElement element,
    BamCompleteMolecule molecule,
    int atomMultiple,
  ) {
    var requiredAtomCount = 0;
    for (final atom in molecule.atoms) {
      if (atom.element.isSameElement(element)) requiredAtomCount++;
    }
    var atomCount = requiredAtomCount * atomMultiple;
    if (!element.isCarbon() && (element.isHydrogen() || atomCount < 4)) {
      atomCount += _random.nextInt(2);
    }
    final bucketWidth =
        BamBucket.calculateIdealBucketWidth(element.covalentRadius, atomCount);
    return BamBucket(
      size: Size(bucketWidth, 200),
      element: element,
      capacity: atomCount,
    );
  }

  void regenerate() {
    addCollection(
      generateKitCollection(
        allowMultipleMolecules: isMultipleCollection,
        numBoxes: firstCollection.collectionBoxes.length == 5 ? 5 : 4,
      ),
    );
  }
}

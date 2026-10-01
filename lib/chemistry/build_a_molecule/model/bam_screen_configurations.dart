import 'dart:math' as math;
import 'dart:ui' show Size;

import '../data/bam_element.dart';
import '../data/bam_molecule_catalog.dart';
import 'bam_bucket.dart';
import 'bam_collection_box.dart';
import 'bam_collection_layout.dart';
import 'bam_kit.dart';
import 'bam_kit_collection.dart';
import 'bam_screen_model.dart';

/// Kit/box setups matching SingleModel / MultipleModel / PlaygroundModel.
class BamScreenConfigurations {
  BamScreenConfigurations._();

  static BamScreenModel createSingle({math.Random? random}) {
    final layout = BamCollectionLayout(hasCollectionPanel: true);
    final kitCollection = BamKitCollection(enableCues: true);
    final model = BamScreenModel(
      firstCollection: kitCollection,
      collectionLayout: layout,
      isMultipleCollection: false,
      random: random,
    );
    final common = BamMoleculeCatalog.commonMolecules;

    kitCollection.addKit(
      BamKit(layout, [
        BamBucket(size: const Size(400, 200), element: BamElement.H, capacity: 2),
        BamBucket(size: const Size(350, 200), element: BamElement.O, capacity: 1),
      ], random: random),
      triggerCue: true,
    );
    kitCollection.addKit(
      BamKit(layout, [
        BamBucket(size: const Size(400, 200), element: BamElement.H, capacity: 2),
        BamBucket(size: const Size(450, 200), element: BamElement.O, capacity: 2),
      ], random: random),
      triggerCue: true,
    );
    kitCollection.addKit(
      BamKit(layout, [
        BamBucket(size: const Size(350, 200), element: BamElement.C, capacity: 1),
        BamBucket(size: const Size(450, 200), element: BamElement.O, capacity: 2),
        BamBucket(size: const Size(500, 200), element: BamElement.N, capacity: 2),
      ], random: random),
      triggerCue: true,
    );

    kitCollection.addCollectionBox(BamCollectionBox(common['H2O']!, 1));
    kitCollection.addCollectionBox(BamCollectionBox(common['O2']!, 1));
    kitCollection.addCollectionBox(BamCollectionBox(common['H2']!, 1));
    kitCollection.addCollectionBox(BamCollectionBox(common['CO2']!, 1));
    kitCollection.addCollectionBox(BamCollectionBox(common['N2']!, 1));
    return model;
  }

  static BamScreenModel createMultiple({math.Random? random}) {
    final layout = BamCollectionLayout(hasCollectionPanel: true);
    final kitCollection = BamKitCollection(enableCues: true);
    final model = BamScreenModel(
      firstCollection: kitCollection,
      collectionLayout: layout,
      isMultipleCollection: true,
      random: random,
    );
    final common = BamMoleculeCatalog.commonMolecules;

    kitCollection.addKit(
      BamKit(layout, [
        BamBucket(size: const Size(400, 200), element: BamElement.H, capacity: 2),
        BamBucket(size: const Size(450, 200), element: BamElement.O, capacity: 2),
      ], random: random),
      triggerCue: true,
    );
    kitCollection.addKit(
      BamKit(layout, [
        BamBucket(size: const Size(500, 200), element: BamElement.C, capacity: 2),
        BamBucket(size: const Size(600, 200), element: BamElement.O, capacity: 4),
        BamBucket(size: const Size(500, 200), element: BamElement.N, capacity: 2),
      ], random: random),
      triggerCue: true,
    );
    kitCollection.addKit(
      BamKit(layout, [
        BamBucket(size: const Size(600, 200), element: BamElement.H, capacity: 12),
        BamBucket(size: const Size(600, 200), element: BamElement.O, capacity: 4),
        BamBucket(size: const Size(500, 200), element: BamElement.N, capacity: 2),
      ], random: random),
      triggerCue: true,
    );

    kitCollection.addCollectionBox(BamCollectionBox(common['CO2']!, 2));
    kitCollection.addCollectionBox(BamCollectionBox(common['O2']!, 2));
    kitCollection.addCollectionBox(BamCollectionBox(common['H2']!, 4));
    kitCollection.addCollectionBox(BamCollectionBox(common['NH3']!, 2));
    return model;
  }

  static BamScreenModel createPlayground({math.Random? random}) {
    final layout = BamCollectionLayout(hasCollectionPanel: false);
    final kitCollection = BamKitCollection();
    final model = BamScreenModel(
      firstCollection: kitCollection,
      collectionLayout: layout,
      isMultipleCollection: false,
      random: random,
    );
    const bucketDimensions = Size(670, 200);

    kitCollection.addKit(
      BamKit(layout, [
        BamBucket.createAutoSized(BamElement.H, 13),
        BamBucket.createAutoSized(BamElement.O, 3),
        BamBucket.createAutoSized(BamElement.C, 3),
        BamBucket.createAutoSized(BamElement.N, 3),
        BamBucket.createAutoSized(BamElement.Cl, 2),
      ], random: random),
    );
    kitCollection.addKit(
      BamKit(layout, [
        BamBucket(size: bucketDimensions, element: BamElement.H, capacity: 21),
        BamBucket.createAutoSized(BamElement.O, 4),
        BamBucket.createAutoSized(BamElement.C, 4),
        BamBucket.createAutoSized(BamElement.N, 4),
      ], random: random),
    );
    kitCollection.addKit(
      BamKit(layout, [
        BamBucket(size: bucketDimensions, element: BamElement.H, capacity: 21),
        BamBucket.createAutoSized(BamElement.C, 4),
        BamBucket.createAutoSized(BamElement.Cl, 4),
        BamBucket.createAutoSized(BamElement.F, 4),
      ], random: random),
    );
    kitCollection.addKit(
      BamKit(layout, [
        BamBucket(size: bucketDimensions, element: BamElement.H, capacity: 21),
        BamBucket.createAutoSized(BamElement.C, 3),
        BamBucket.createAutoSized(BamElement.B, 2),
        BamBucket.createAutoSized(BamElement.Si, 2),
      ], random: random),
    );
    kitCollection.addKit(
      BamKit(layout, [
        BamBucket(size: bucketDimensions, element: BamElement.H, capacity: 21),
        BamBucket.createAutoSized(BamElement.B, 1),
        BamBucket.createAutoSized(BamElement.S, 2),
        BamBucket.createAutoSized(BamElement.Si, 1),
        BamBucket.createAutoSized(BamElement.P, 1),
      ], random: random),
    );
    kitCollection.addKit(
      BamKit(layout, [
        BamBucket(size: bucketDimensions, element: BamElement.H, capacity: 21),
        BamBucket.createAutoSized(BamElement.C, 4),
        BamBucket.createAutoSized(BamElement.O, 2),
        BamBucket.createAutoSized(BamElement.P, 2),
      ], random: random),
    );
    kitCollection.addKit(
      BamKit(layout, [
        BamBucket(size: bucketDimensions, element: BamElement.H, capacity: 21),
        BamBucket.createAutoSized(BamElement.Br, 2),
        BamBucket.createAutoSized(BamElement.N, 3),
        BamBucket.createAutoSized(BamElement.C, 3),
      ], random: random),
    );
    return model;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_a_molecule/controller/bam_collection_feedback_driver.dart';
import 'package:kratos/chemistry/build_a_molecule/controller/bam_controller.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_element.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_molecule_catalog.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_atom.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_bond.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_box_feedback_state.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_bucket.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_collection_box.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_collection_layout.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_kit.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_kit_collection.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_molecule.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_screen_configurations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    BamMoleculeCatalog.initialList.completeMolecules.clear();
    BamMoleculeCatalog.initialList.moleculeNameMap.clear();
    BamMoleculeCatalog.mainInstance = null;
    BamMoleculeCatalog.initialized = false;
    await BamMoleculeCatalog.ensureInitialLoaded();
    await BamMoleculeCatalog.getMainInstance();
  });

  BamMolecule waterMolecule() {
    final m = BamMolecule();
    final o = BamPlayAtom(BamElement.O);
    final h1 = BamPlayAtom(BamElement.H);
    final h2 = BamPlayAtom(BamElement.H);
    m.addAtom(o);
    m.addAtom(h1);
    m.addAtom(h2);
    m.addBond(BamBond(o, h1));
    m.addBond(BamBond(o, h2));
    return m;
  }

  BamMolecule ohFragment() {
    final m = BamMolecule();
    final o = BamPlayAtom(BamElement.O);
    final h = BamPlayAtom(BamElement.H);
    m.addAtom(o);
    m.addAtom(h);
    m.addBond(BamBond(o, h));
    return m;
  }

  ({BamKitCollection collection, BamKit kit, BamCollectionBox waterBox,
      BamCollectionBox oxygenBox}) buildCueCollection() {
    final layout = BamCollectionLayout(hasCollectionPanel: true);
    final collection = BamKitCollection(enableCues: true);
    final kit = BamKit(layout, [
      BamBucket.createAutoSized(BamElement.H, 2),
      BamBucket.createAutoSized(BamElement.O, 1),
    ]);
    collection.addKit(kit, triggerCue: true);
    final water = BamMoleculeCatalog.commonMolecules['H2O']!;
    final oxygen = BamMoleculeCatalog.commonMolecules['O2']!;
    final waterBox = BamCollectionBox(water, 1);
    final oxygenBox = BamCollectionBox(oxygen, 1);
    collection.addCollectionBox(waterBox);
    collection.addCollectionBox(oxygenBox);
    return (
      collection: collection,
      kit: kit,
      waterBox: waterBox,
      oxygenBox: oxygenBox,
    );
  }

  test('source blink timing constants', () {
    expect(BamBoxFeedbackState.blinkLengthSeconds, 1.3);
    expect(BamBoxFeedbackState.blinkDelayMs, 100);
    expect(BamBoxFeedbackState.blinkTickCount, 13);
  });

  test('1. correct molecule triggers feedback', () {
    final built = buildCueCollection();
    var accepted = 0;
    BamMolecule? acceptedMol;
    BamCollectionBox? acceptedBox;
    built.collection.wireAcceptedCreationListeners((box, molecule) {
      accepted++;
      acceptedMol = molecule;
      acceptedBox = box;
      box.feedback.beginBlink();
    });

    final water = waterMolecule();
    built.kit.addMolecule(water);

    expect(accepted, 1);
    expect(identical(acceptedBox, built.waterBox), isTrue);
    expect(acceptedMol!.isEquivalent(built.waterBox.moleculeType), isTrue);
    expect(built.waterBox.feedback.cueVisible, isTrue);
    expect(built.waterBox.feedback.isBlinking, isTrue);
    expect(built.oxygenBox.feedback.cueVisible, isFalse);
    expect(built.collection.hasBlinkedOnce, isTrue);
  });

  test('2. incorrect molecule does not trigger feedback', () {
    final built = buildCueCollection();
    var accepted = 0;
    built.collection.wireAcceptedCreationListeners((box, molecule) {
      accepted++;
      box.feedback.beginBlink();
    });

    built.kit.addMolecule(ohFragment());

    expect(accepted, 0);
    expect(built.waterBox.feedback.cueVisible, isFalse);
    expect(built.oxygenBox.feedback.cueVisible, isFalse);
    expect(built.collection.hasBlinkedOnce, isFalse);
  });

  test('3. target collection item is correct (by moleculeType, not index)', () {
    final built = buildCueCollection();
    // Put oxygen box first in iteration by rebuilding with O2 first.
    final layout = BamCollectionLayout(hasCollectionPanel: true);
    final collection = BamKitCollection(enableCues: true);
    final kit = BamKit(layout, [
      BamBucket.createAutoSized(BamElement.H, 2),
      BamBucket.createAutoSized(BamElement.O, 2),
    ]);
    collection.addKit(kit, triggerCue: true);
    final water = BamMoleculeCatalog.commonMolecules['H2O']!;
    final oxygen = BamMoleculeCatalog.commonMolecules['O2']!;
    // Intentionally reverse list order vs Single screen.
    final oxygenBox = BamCollectionBox(oxygen, 1);
    final waterBox = BamCollectionBox(water, 1);
    collection.addCollectionBox(oxygenBox);
    collection.addCollectionBox(waterBox);

    BamCollectionBox? target;
    collection.wireAcceptedCreationListeners((box, molecule) {
      target = box;
      box.feedback.beginBlink();
    });

    kit.addMolecule(waterMolecule());
    expect(identical(target, waterBox), isTrue);
    expect(identical(target, oxygenBox), isFalse);
    expect(waterBox.moleculeType.formula, 'H2O');
    expect(waterBox.feedback.cueVisible, isTrue);
    expect(oxygenBox.feedback.cueVisible, isFalse);
  });

  test('4. feedback points to correct target (cue on matching box only)', () {
    final built = buildCueCollection();
    built.kit.addMolecule(waterMolecule());
    expect(built.waterBox.cueVisible, isTrue);
    expect(built.oxygenBox.cueVisible, isFalse);
  });

  test('5-6. target preview blinks then ends (13 ticks @ 100ms)', () {
    final state = BamBoxFeedbackState();
    state.beginBlink();
    expect(state.isBlinking, isTrue);
    expect(state.borderBlinkOn, isFalse);

    var blueFrames = 0;
    var scheduled = true;
    var ticks = 0;
    while (scheduled) {
      scheduled = state.advanceTick();
      ticks++;
      if (state.borderBlinkOn) blueFrames++;
    }

    expect(ticks, BamBoxFeedbackState.blinkTickCount);
    expect(state.isBlinking, isFalse);
    expect(state.borderBlinkOn, isFalse);
    expect(blueFrames, greaterThan(0));
  });

  test('7. repeated correct construction: blink once per collection', () {
    final built = buildCueCollection();
    var accepted = 0;
    built.collection.wireAcceptedCreationListeners((box, molecule) {
      accepted++;
      box.feedback.beginBlink();
    });

    built.kit.addMolecule(waterMolecule());
    expect(accepted, 1);

    built.kit.removeMolecule(built.kit.molecules.first);
    built.kit.addMolecule(waterMolecule());
    // Cue may show again; blink emitter only once.
    expect(accepted, 1);
    expect(built.waterBox.feedback.cueVisible, isTrue);
    expect(built.collection.hasBlinkedOnce, isTrue);
  });

  test('8. reset clears feedback', () {
    final built = buildCueCollection();
    built.collection.wireAcceptedCreationListeners((box, molecule) {
      box.feedback.beginBlink();
    });
    built.kit.addMolecule(waterMolecule());
    expect(built.waterBox.feedback.cueVisible, isTrue);
    expect(built.collection.hasBlinkedOnce, isTrue);

    built.collection.reset();
    expect(built.waterBox.feedback.cueVisible, isFalse);
    expect(built.waterBox.feedback.isBlinking, isFalse);
    expect(built.collection.hasBlinkedOnce, isFalse);
  });

  test('8b. resetKitsAndBoxes clears cue/blink but keeps hasBlinkedOnce', () {
    final built = buildCueCollection();
    built.collection.wireAcceptedCreationListeners((box, molecule) {
      box.feedback.beginBlink();
    });
    built.kit.addMolecule(waterMolecule());
    expect(built.collection.hasBlinkedOnce, isTrue);

    built.collection.resetKitsAndBoxes();
    expect(built.waterBox.feedback.cueVisible, isFalse);
    expect(built.waterBox.feedback.isBlinking, isFalse);
    expect(built.collection.hasBlinkedOnce, isTrue);
  });

  test('9. screen switch clears/disposes feedback via controller', () {
    final model = BamScreenConfigurations.createSingle();
    final controller = BamController(model);
    final waterBox = controller.collection.collectionBoxes
        .firstWhere((b) => b.moleculeType.formula == 'H2O');

    // Simulate accepted creation blink.
    controller.feedbackDriver.beginBlink(waterBox, schedule: false);
    expect(waterBox.feedback.isBlinking, isTrue);

    controller.reset();
    expect(waterBox.feedback.isBlinking, isFalse);

    controller.dispose();
  });

  test('driver steps match FeedbackState completion', () {
    final box = BamCollectionBox(
      BamMoleculeCatalog.commonMolecules['H2O']!,
      1,
    );
    var notifies = 0;
    final driver = BamCollectionFeedbackDriver(onChanged: () => notifies++);
    driver.beginBlink(box, schedule: false);
    expect(box.feedback.isBlinking, isTrue);

    for (var i = 0; i < BamBoxFeedbackState.blinkTickCount; i++) {
      driver.step();
    }
    expect(box.feedback.isBlinking, isFalse);
    expect(box.feedback.borderBlinkOn, isFalse);
    expect(notifies, greaterThan(BamBoxFeedbackState.blinkTickCount));
    driver.dispose();
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_element.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_molecule_catalog.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_atom.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_bucket.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_collection_layout.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_kit.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_molecule.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    BamMoleculeCatalog.initialList.completeMolecules.clear();
    BamMoleculeCatalog.initialList.moleculeNameMap.clear();
    BamMoleculeCatalog.mainInstance = null;
    BamMoleculeCatalog.initialized = false;
    await BamMoleculeCatalog.getMainInstance();
  });

  BamKit buildHoKit() {
    final layout = BamCollectionLayout(hasCollectionPanel: true);
    return BamKit(layout, [
      BamBucket.createAutoSized(BamElement.H, 2),
      BamBucket.createAutoSized(BamElement.O, 1),
    ]);
  }

  test('H+O bonding allowed toward water', () {
    final kit = buildHoKit();
    final playCenter = kit.collectionLayout.availablePlayAreaBounds.center;

    final o =
        kit.buckets.firstWhere((b) => b.element.isOxygen()).particleList.first;
    o.setPositionAndDestination(playCenter);
    kit.addAtomToPlay(o);

    final h1 = kit.buckets
        .firstWhere((b) => b.element.isHydrogen())
        .particleList
        .first;
    final bondDist = o.covalentRadius + h1.covalentRadius;
    h1.setPositionAndDestination(playCenter + Offset(bondDist * 0.5, 0));
    kit.addAtomToPlay(h1);

    final molO = kit.getMolecule(o);
    final molH = kit.getMolecule(h1);
    final bonded = identical(molO, molH) && (molO?.atoms.length ?? 0) >= 2;
    if (!bonded) {
      h1.setPositionAndDestination(playCenter + Offset(bondDist * 0.2, 0));
      o.setPositionAndDestination(playCenter);
      final hMol = kit.getMolecule(h1);
      if (hMol != null) {
        expect(kit.attemptToBondMolecule(hMol), isTrue);
      }
    }

    final waterish = kit.getMolecule(o);
    expect(waterish, isNotNull);
    expect(waterish!.atoms.length, greaterThanOrEqualTo(2));

    final hBucket = kit.buckets.firstWhere((b) => b.element.isHydrogen());
    if (hBucket.particleList.isNotEmpty) {
      final h2 = hBucket.particleList.first;
      h2.setPositionAndDestination(playCenter + Offset(-bondDist * 0.2, 0));
      kit.addAtomToPlay(h2);
    }

    final finalMol = kit.getMolecule(o);
    expect(finalMol, isNotNull);
    expect(finalMol!.atoms.length, anyOf(2, 3));
    expect(finalMol.isValid(), isTrue);
  });

  test('illegal merge rejected if catalog loaded', () {
    expect(BamMoleculeCatalog.mainInstance?.hasStructures, isTrue);

    final layout = BamCollectionLayout(hasCollectionPanel: true);
    final kit = BamKit(layout, [
      BamBucket.createAutoSized(BamElement.H, 4),
      BamBucket.createAutoSized(BamElement.O, 2),
    ]);
    final play = kit.collectionLayout.availablePlayAreaBounds.center;

    final o1 =
        kit.buckets.firstWhere((b) => b.element.isOxygen()).particleList[0];
    final o2 =
        kit.buckets.firstWhere((b) => b.element.isOxygen()).particleList[1];
    final hBucket = kit.buckets.firstWhere((b) => b.element.isHydrogen());
    final h1 = hBucket.particleList[0];
    final h2 = hBucket.particleList[1];

    o1.setPositionAndDestination(play);
    kit.addAtomToPlay(o1);
    h1.setPositionAndDestination(play + const Offset(40, 0));
    kit.addAtomToPlay(h1);
    expect(kit.getMolecule(o1), isNotNull);

    o2.setPositionAndDestination(play + const Offset(300, 0));
    kit.addAtomToPlay(o2);
    h2.setPositionAndDestination(play + const Offset(340, 0));
    kit.addAtomToPlay(h2);

    h1.setPositionAndDestination(h2.position);
    final molH1 = kit.getMolecule(h1)!;
    final beforeCount = kit.molecules.length;
    final bonded = kit.attemptToBondMolecule(molH1);
    if (bonded) {
      final merged = kit.getMolecule(h1);
      expect(
        BamMoleculeCatalog.mainInstance!.isAllowedStructure(merged!),
        isTrue,
      );
    } else {
      expect(kit.molecules.length, beforeCount);
    }

    final invalid = BamMolecule();
    invalid.addAtom(BamPlayAtom(BamElement.H));
    invalid.addAtom(BamPlayAtom(BamElement.H));
    invalid.addAtom(BamPlayAtom(BamElement.O));
    expect(invalid.isValid(), isFalse);
    expect(
      BamMoleculeCatalog.mainInstance!.isAllowedStructure(invalid),
      isFalse,
    );
  });
}

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_molecule_catalog.dart';
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
  });

  test('reset clears collections to first', () {
    final model = BamScreenConfigurations.createSingle(
      random: math.Random(42),
    );
    expect(model.collections.length, 1);

    final box = model.firstCollection.collectionBoxes.first;
    box.addMolecule(BamMolecule());
    expect(box.quantity, 1);

    final extra = model.generateKitCollection(
      allowMultipleMolecules: false,
      numBoxes: 4,
    );
    model.addCollection(extra);
    expect(model.collections.length, 2);
    expect(model.currentIndex, 1);

    model.reset();
    expect(model.collections.length, 1);
    expect(model.currentIndex, 0);
    expect(identical(model.collections.first, model.firstCollection), isTrue);
    expect(
      model.firstCollection.collectionBoxes.every((b) => b.quantity == 0),
      isTrue,
    );
  });
}

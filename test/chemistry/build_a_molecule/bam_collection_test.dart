import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_molecule_catalog.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_collection_box.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_molecule.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    BamMoleculeCatalog.initialList.completeMolecules.clear();
    BamMoleculeCatalog.initialList.moleculeNameMap.clear();
    await BamMoleculeCatalog.ensureInitialLoaded();
  });

  test('box accept water, reject wrong, capacity', () {
    final water = BamMoleculeCatalog.commonMolecules['H2O']!;
    final oxygen = BamMoleculeCatalog.commonMolecules['O2']!;
    final box = BamCollectionBox(water, 2);

    expect(box.willAllowMoleculeDrop(water), isTrue);
    expect(box.willAllowMoleculeDrop(oxygen), isFalse);

    box.addMolecule(BamMolecule());
    expect(box.quantity, 1);
    expect(box.willAllowMoleculeDrop(water), isTrue);

    box.addMolecule(BamMolecule());
    expect(box.isFull(), isTrue);
    expect(box.willAllowMoleculeDrop(water), isFalse);
  });
}

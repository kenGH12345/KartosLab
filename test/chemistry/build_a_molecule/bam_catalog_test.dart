import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_molecule_catalog.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('collection load count is 26', () async {
    final catalog = BamMoleculeCatalog();
    await catalog.loadInitialData();
    expect(catalog.completeMolecules.length, 26);
    expect(catalog.moleculeNameMap['Water'], isNotNull);
    expect(catalog.moleculeNameMap['Water']!.formula, 'H2O');
  });

  test('full load: completeMolecules > 9000, structures non-empty', () async {
    // Reset static state for isolation
    BamMoleculeCatalog.initialList.completeMolecules.clear();
    BamMoleculeCatalog.initialList.moleculeNameMap.clear();
    BamMoleculeCatalog.mainInstance = null;
    BamMoleculeCatalog.initialized = false;

    await BamMoleculeCatalog.initialList.loadInitialData();
    expect(BamMoleculeCatalog.initialList.completeMolecules.length, 26);

    final catalog = BamMoleculeCatalog();
    await catalog.loadAll();

    expect(catalog.completeMolecules.length, greaterThan(9000));
    expect(catalog.allowedStructureFormulaMap, isNotEmpty);
    expect(catalog.hasStructures, isTrue);
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('strings_en loads water key', () async {
    await BamStrings.load();
    expect(BamStrings.lookup('water'), isNotNull);
  });
}

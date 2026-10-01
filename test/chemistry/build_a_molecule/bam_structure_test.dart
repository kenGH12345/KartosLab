import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_element.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_molecule_catalog.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_atom.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_bond.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_complete_molecule.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_molecule_structure.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const waterSerial =
      'water|H2O|962|full|3|2|O 2.5369 -0.155 0 0 0|H 3.0739 0.155 0.2774 0.8929 0.2544,0-1|H 2.0 0.155 0.6068 -0.2383 -0.7169,0-1';

  test('parse water from collection line, formula H2O', () {
    final water = BamCompleteMolecule.fromSerial2(waterSerial);
    expect(water.formula, 'H2O');
    expect(water.commonName, 'water');
    expect(water.cid, 962);
    expect(water.atoms.length, 3);
    expect(water.bonds.length, 2);
  });

  test('manual H-O-H isEquivalent to water complete molecule', () {
    final water = BamCompleteMolecule.fromSerial2(waterSerial);

    final structure = BamMoleculeStructure();
    final o = BamAtom(BamElement.O);
    final h1 = BamAtom(BamElement.H);
    final h2 = BamAtom(BamElement.H);
    structure.addAtom(o);
    structure.addAtom(h1);
    structure.addAtom(h2);
    structure.addBond(BamBond(o, h1));
    structure.addBond(BamBond(o, h2));

    expect(structure.isEquivalent(water), isTrue);
    expect(water.isEquivalent(structure), isTrue);
  });

  test('wrong structure (only O-H) not equivalent to water', () {
    final water = BamCompleteMolecule.fromSerial2(waterSerial);

    final structure = BamMoleculeStructure();
    final o = BamAtom(BamElement.O);
    final h = BamAtom(BamElement.H);
    structure.addAtom(o);
    structure.addAtom(h);
    structure.addBond(BamBond(o, h));

    expect(structure.isEquivalent(water), isFalse);
  });

  test('after catalog.loadAll(), isAllowedStructure for water topology true',
      () async {
    final catalog = BamMoleculeCatalog();
    await catalog.loadAll();

    final structure = BamMoleculeStructure();
    final o = BamAtom(BamElement.O);
    final h1 = BamAtom(BamElement.H);
    final h2 = BamAtom(BamElement.H);
    structure.addAtom(o);
    structure.addAtom(h1);
    structure.addAtom(h2);
    structure.addBond(BamBond(o, h1));
    structure.addBond(BamBond(o, h2));

    expect(catalog.isAllowedStructure(structure), isTrue);
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('histogram hash stable', () {
    BamMoleculeStructure buildWater() {
      final structure = BamMoleculeStructure();
      final o = BamAtom(BamElement.O);
      final h1 = BamAtom(BamElement.H);
      final h2 = BamAtom(BamElement.H);
      structure.addAtom(o);
      structure.addAtom(h1);
      structure.addAtom(h2);
      structure.addBond(BamBond(o, h1));
      structure.addBond(BamBond(o, h2));
      return structure;
    }

    final a = buildWater().getHistogram().getHashString();
    final b = buildWater().getHistogram().getHashString();
    expect(a, b);
    // SUPPORTED_ELEMENTS order: B,Br,C,Cl,F,H,I,N,O,P,S,Si
    // water = 2 H, 1 O → _0_0_0_0_0_2_0_0_1_0_0_0
    expect(a, '_0_0_0_0_0_2_0_0_1_0_0_0');
  });

  test('ammonia general formula exception H3N → NH3', () {
    const ammoniaSerial =
        'ammonia|H3N|222|full|4|3|N 2.5369 0.155 0 0 0|H 3.0739 0.465 -0.4417 0.2906 0.8711,0-1|H 2.0 0.465 0.7256 0.6896 -0.1907,0-1|H 2.5369 -0.465 0.4875 -0.8701 0.2089,0-1';
    final ammonia = BamCompleteMolecule.fromSerial2(ammoniaSerial);
    expect(ammonia.formula, 'H3N');
    expect(ammonia.getGeneralFormula(), 'NH3');
    expect(ammonia.getGeneralFormulaFragment(), 'NH₃');
  });
}

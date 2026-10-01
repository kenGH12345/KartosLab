import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/bam_complete_molecule.dart';
import '../model/bam_molecule_structure.dart';
import '../model/bam_stripped_molecule.dart';

/// Molecule catalog / allow-list. Ported from MoleculeList.ts.
class BamMoleculeCatalog {
  BamMoleculeCatalog();

  final List<BamCompleteMolecule> completeMolecules = [];
  final Map<String, BamCompleteMolecule> moleculeNameMap = {};
  final Map<String, List<BamStrippedMolecule>> allowedStructureFormulaMap = {};

  static BamMoleculeCatalog? mainInstance;
  static bool initialized = false;
  static final BamMoleculeCatalog initialList = BamMoleculeCatalog();

  bool get hasStructures => allowedStructureFormulaMap.isNotEmpty;

  Future<void> loadInitialData({
    String assetPath =
        'assets/data/build_a_molecule/collection_molecules.json',
  }) async {
    final molecules = await _readCompleteMoleculesFromAsset(assetPath);
    for (final molecule in molecules) {
      addCompleteMolecule(molecule);
    }
  }

  Future<void> loadMainData({
    String otherPath = 'assets/data/build_a_molecule/other_molecules.json',
    String structuresPath = 'assets/data/build_a_molecule/structures.json',
  }) async {
    for (final molecule in initialList.getAllCompleteMolecules()) {
      addCompleteMolecule(molecule);
    }

    final mainMolecules = await _readCompleteMoleculesFromAsset(otherPath);
    for (var molecule in mainMolecules) {
      final initialLookup = initialList.moleculeNameMap[molecule.filterCommonName()];
      if (initialLookup != null && molecule.isEquivalent(initialLookup)) {
        molecule = initialLookup;
      }
      addCompleteMolecule(molecule);
    }

    final mainStructures = await _readMoleculeStructuresFromAsset(structuresPath);
    for (final structure in mainStructures) {
      addAllowedStructure(structure);
    }
  }

  /// Load collection, then other molecules + structures (full catalog).
  Future<void> loadAll() async {
    if (initialList.completeMolecules.isEmpty) {
      await initialList.loadInitialData();
    }
    await loadMainData();
    mainInstance = this;
    initialized = true;
  }

  /// Convenience: ensure [initialList] has collection molecules only.
  static Future<BamMoleculeCatalog> ensureInitialLoaded() async {
    if (initialList.completeMolecules.isEmpty) {
      await initialList.loadInitialData();
    }
    return initialList;
  }

  static Future<BamMoleculeCatalog> getMainInstance() async {
    if (!initialized || mainInstance == null) {
      final catalog = BamMoleculeCatalog();
      await catalog.loadAll();
      return catalog;
    }
    return mainInstance!;
  }

  bool isAllowedStructure(BamMoleculeStructure moleculeStructure) {
    final strippedMolecule = BamStrippedMolecule(moleculeStructure);
    final hashString = strippedMolecule.stripped.getHistogram().getHashString();

    if (strippedMolecule.stripped.atoms.isEmpty &&
        moleculeStructure.atoms.length <= 2) {
      return true;
    }

    if (!moleculeStructure.isValid()) {
      return false;
    }

    final moleculeStructures = allowedStructureFormulaMap[hashString];
    if (moleculeStructures != null) {
      for (final structure in moleculeStructures) {
        if (structure.isHydrogenSubmolecule(strippedMolecule)) {
          return true;
        }
      }
    }
    return false;
  }

  BamCompleteMolecule? findMatchingCompleteMolecule(
    BamMoleculeStructure moleculeStructure,
  ) {
    for (final completeMolecule in completeMolecules) {
      if (moleculeStructure.isEquivalent(completeMolecule)) {
        return completeMolecule;
      }
    }
    return null;
  }

  List<BamCompleteMolecule> getAllCompleteMolecules() =>
      List<BamCompleteMolecule>.from(completeMolecules);

  void addCompleteMolecule(BamCompleteMolecule completeMolecule) {
    completeMolecules.add(completeMolecule);
    moleculeNameMap[completeMolecule.filterCommonName()] = completeMolecule;
  }

  void addAllowedStructure(BamMoleculeStructure structure) {
    final strippedMolecule = BamStrippedMolecule(structure);
    final hashString = strippedMolecule.stripped.getHistogram().getHashString();
    final spot = allowedStructureFormulaMap[hashString];
    if (spot != null) {
      spot.add(strippedMolecule);
    } else {
      allowedStructureFormulaMap[hashString] = [strippedMolecule];
    }
  }

  BamCompleteMolecule? getMoleculeByName(String name) {
    return moleculeNameMap[name] ??
        initialList.moleculeNameMap[name];
  }

  /// Common molecule references (requires [initialList] loaded).
  /// Molecules only present in other_molecules (e.g. Acetic Acid) need [loadMainData].
  static Map<String, BamCompleteMolecule> get commonMolecules {
    BamCompleteMolecule? opt(String name) =>
        initialList.moleculeNameMap[name] ?? mainInstance?.moleculeNameMap[name];

    BamCompleteMolecule req(String name) {
      final m = opt(name);
      if (m == null) {
        throw StateError('Common molecule not loaded: $name');
      }
      return m;
    }

    final map = <String, BamCompleteMolecule>{
      'CO2': req('Carbon Dioxide'),
      'H2O': req('Water'),
      'N2': req('Nitrogen'),
      'CO': req('Carbon Monoxide'),
      'NO': req('Nitric Oxide'),
      'O2': req('Oxygen'),
      'H2': req('Hydrogen'),
      'Cl2': req('Chlorine'),
      'NH3': req('Ammonia'),
    };
    final acetic = opt('Acetic Acid');
    if (acetic != null) {
      map['C2H4O2'] = acetic;
    }
    return map;
  }

  /// Collection-box molecule list (requires catalog loaded).
  static List<BamCompleteMolecule> get collectionBoxMolecules {
    BamCompleteMolecule req(String name) {
      final m = initialList.getMoleculeByName(name) ??
          mainInstance?.getMoleculeByName(name);
      if (m == null) {
        throw StateError('Collection molecule not loaded: $name');
      }
      return m;
    }

    final common = commonMolecules;
    return [
      common['CO2']!,
      common['H2O']!,
      common['N2']!,
      common['CO']!,
      common['O2']!,
      common['H2']!,
      common['NH3']!,
      common['Cl2']!,
      common['NO']!,
      req('Acetylene'),
      req('Borane'),
      req('Trifluoroborane'),
      req('Chloromethane'),
      req('Ethylene'),
      req('Fluorine'),
      req('Fluoromethane'),
      req('Formaldehyde'),
      req('Hydrogen Cyanide'),
      req('Hydrogen Peroxide'),
      req('Hydrogen Sulfide'),
      req('Methane'),
      req('Nitrous Oxide'),
      req('Ozone'),
      req('Phosphine'),
      req('Silane'),
      req('Sulfur Dioxide'),
    ];
  }

  static Future<List<BamCompleteMolecule>> _readCompleteMoleculesFromAsset(
    String assetPath,
  ) async {
    final raw = await rootBundle.loadString(assetPath);
    final list = (jsonDecode(raw) as List<dynamic>).cast<String>();
    return list.map(BamCompleteMolecule.fromSerial2).toList();
  }

  static Future<List<BamMoleculeStructure>> _readMoleculeStructuresFromAsset(
    String assetPath,
  ) async {
    final raw = await rootBundle.loadString(assetPath);
    final list = (jsonDecode(raw) as List<dynamic>).cast<String>();
    return list.map(BamMoleculeStructure.fromSerial2Basic).toList();
  }
}

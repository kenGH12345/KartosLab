/// Lightweight count-based atom — shred `NumberAtom` domain subset.
///
/// Immutable value object. Derived quantities are getters (single source of
/// truth for charge / mass / atomic number).
library;

import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/data/atom_data_tables.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/data/atom_info_utils.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/data/element_data.dart';

/// Count-based atom configuration (protons / neutrons / electrons).
class NumberAtom {
  const NumberAtom(
    this.protons,
    this.neutrons,
    this.electrons,
  );

  const NumberAtom.counts({
    required int protonCount,
    required int neutronCount,
    required int electronCount,
  })  : protons = protonCount,
        neutrons = neutronCount,
        electrons = electronCount;

  final int protons;
  final int neutrons;
  final int electrons;

  /// Alias used by PhET call sites.
  int get protonCount => protons;
  int get neutronCount => neutrons;
  int get electronCount => electrons;

  /// Atomic number Z = proton count.
  int get atomicNumber => protons;

  /// Mass number A = protons + neutrons.
  int get massNumber => protons + neutrons;

  /// Net charge = protons − electrons.
  int get charge => protons - electrons;

  int get particleCount => protons + neutrons + electrons;

  /// shred: empty nucleus (`P+N == 0`) is treated as stable; else table lookup.
  bool get nucleusStable {
    if (protons + neutrons == 0) return true;
    return AtomInfoUtils.isStable(protons, neutrons);
  }

  bool get isUnstable => !nucleusStable;

  /// English lowercase name from shared table (`englishNameTable[Z]`).
  /// Z=0 → `''` (no element).
  String get elementNameEnglish {
    if (protons < 0 || protons >= kEnglishNameTable.length) return '';
    return kEnglishNameTable[protons];
  }

  /// Display name (capitalized). Z=0 → empty.
  String get elementDisplayName {
    final n = elementNameEnglish;
    if (n.isEmpty) return '';
    return n[0].toUpperCase() + n.substring(1);
  }

  /// Chemical symbol. Z=0 → `'-'` (PhET `symbolTable[0]`).
  String get symbol {
    if (protons < 0 || protons >= kSymbolTable.length) return '-';
    return kSymbolTable[protons];
  }

  /// Shared [ElementData] when Z ≥ 1; null for Z=0 / out of range.
  ElementData? get element => AtomDataFactory.elementOrNull(protons);

  /// Particle-count equality (shred `NumberAtom.equals`).
  bool countsEqual(NumberAtom other) =>
      protons == other.protons &&
      neutrons == other.neutrons &&
      electrons == other.electrons;

  NumberAtom copyWith({
    int? protons,
    int? neutrons,
    int? electrons,
  }) {
    return NumberAtom(
      protons ?? this.protons,
      neutrons ?? this.neutrons,
      electrons ?? this.electrons,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberAtom && countsEqual(other);

  @override
  int get hashCode => Object.hash(protons, neutrons, electrons);

  @override
  String toString() =>
      'NumberAtom(p=$protons, n=$neutrons, e=$electrons)';
}

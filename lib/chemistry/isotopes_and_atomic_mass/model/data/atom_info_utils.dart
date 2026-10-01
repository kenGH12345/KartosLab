/// Query utilities mirroring shred `AtomInfoUtils` methods used by IAAM.
///
/// Only the subset needed by Isotopes and Atomic Mass is ported.
library;

import 'atom_data_tables.dart';
import 'element_data.dart';
import 'isotope_data.dart';
import 'isotope_id.dart';
import 'phet_number_utils.dart';

/// Pure-Dart port of shred AtomInfoUtils (IAAM subset).
class AtomInfoUtils {
  AtomInfoUtils._();

  /// `AtomInfoUtils.isStable(numProtons, numNeutrons)`.
  static bool isStable(int numProtons, int numNeutrons) {
    if (numProtons < 0 || numProtons >= kStableNeutronsByZ.length) {
      return false;
    }
    return kStableNeutronsByZ[numProtons].contains(numNeutrons);
  }

  /// `AtomInfoUtils.getNumNeutronsInMostCommonIsotope(atomicNumber)`.
  static int getNumNeutronsInMostCommonIsotope(int atomicNumber) {
    if (atomicNumber < 0 ||
        atomicNumber >= kNumNeutronsInMostCommonIsotope.length) {
      return 0;
    }
    return kNumNeutronsInMostCommonIsotope[atomicNumber];
  }

  /// `AtomInfoUtils.getStandardAtomicMass(numProtons)`.
  ///
  /// Returns the table value; out-of-range Z throws [RangeError] (no silent
  /// Hydrogen fallback).
  static double getStandardAtomicMass(int numProtons) {
    if (numProtons < 0 || numProtons >= kStandardAtomicMassByZ.length) {
      throw RangeError.range(
        numProtons,
        0,
        kStandardAtomicMassByZ.length - 1,
        'numProtons',
      );
    }
    return kStandardAtomicMassByZ[numProtons];
  }

  /// `AtomInfoUtils.getIsotopeAtomicMass(protons, neutrons)`.
  ///
  /// Returns `-1` when the configuration is absent from ISOTOPE_INFO_TABLE
  /// (PhET behavior for unstable / unknown table entries).
  static double getIsotopeAtomicMass(int protons, int neutrons) {
    if (protons == 0) return -1;
    final massNumber = protons + neutrons;
    for (final entry in kIsotopeInfoTable) {
      if (entry.atomicNumber == protons && entry.massNumber == massNumber) {
        return entry.atomicMass;
      }
    }
    return -1;
  }

  /// `AtomInfoUtils.getNaturalAbundance(isotope, numDecimalPlaces)`.
  ///
  /// [abundance] is the raw table proportion; result is rounded with PhET
  /// `toFixedNumber`. Missing table entries → `0`.
  static double getNaturalAbundance({
    required int protonCount,
    required int massNumber,
    required int numDecimalPlaces,
  }) {
    for (final entry in kIsotopeInfoTable) {
      if (entry.atomicNumber == protonCount &&
          entry.massNumber == massNumber) {
        return toFixedNumber(entry.abundance, numDecimalPlaces);
      }
    }
    return 0;
  }

  /// `AtomInfoUtils.existsInTraceAmounts`.
  static bool existsInTraceAmounts({
    required int protonCount,
    required int massNumber,
  }) {
    if (protonCount <= 0) return false;
    for (final entry in kIsotopeInfoTable) {
      if (entry.atomicNumber == protonCount &&
          entry.massNumber == massNumber) {
        return entry.abundance == kTraceAbundance;
      }
    }
    return false;
  }

  /// `AtomInfoUtils.getAllIsotopesOfElement` → list of [IsotopeId]
  /// (neutral AtomConfig equivalents: electrons = protons).
  static List<IsotopeId> getAllIsotopeIdsOfElement(int atomicNumber) {
    final list = <IsotopeId>[];
    for (final entry in kIsotopeInfoTable) {
      if (entry.atomicNumber == atomicNumber) {
        list.add(IsotopeId(atomicNumber, entry.massNumber));
      }
    }
    return list;
  }

  /// `AtomInfoUtils.getStableIsotopesOfElement`.
  ///
  /// Order: table iteration order of ISOTOPE_INFO_TABLE filtered by stability
  /// (same as shred: iterate all isotopes of element, keep stable). Callers
  /// that need mass-sorted lists (Mixtures) must sort explicitly.
  static List<IsotopeId> getStableIsotopeIdsOfElement(int atomicNumber) {
    final all = getAllIsotopeIdsOfElement(atomicNumber);
    return [
      for (final id in all)
        if (isStable(id.atomicNumber, id.neutronCount)) id,
    ];
  }
}

/// Builds immutable [ElementData] / [IsotopeData] from the authoritative tables.
class AtomDataFactory {
  AtomDataFactory._();

  static ElementData? elementOrNull(int atomicNumber) {
    if (atomicNumber < 1 || atomicNumber > kIsotopeInfoMaxAtomicNumber) {
      return null;
    }
    return ElementData(
      atomicNumber: atomicNumber,
      symbol: kSymbolTable[atomicNumber],
      englishName: kEnglishNameTable[atomicNumber],
      standardAtomicMass: kStandardAtomicMassByZ[atomicNumber],
      mostCommonNeutronCount:
          kNumNeutronsInMostCommonIsotope[atomicNumber],
      stableNeutronCounts:
          List<int>.unmodifiable(kStableNeutronsByZ[atomicNumber]),
    );
  }

  static IsotopeData? isotopeOrNull(int atomicNumber, int massNumber) {
    for (final entry in kIsotopeInfoTable) {
      if (entry.atomicNumber == atomicNumber &&
          entry.massNumber == massNumber) {
        final neutrons = massNumber - atomicNumber;
        return IsotopeData(
          atomicNumber: atomicNumber,
          massNumber: massNumber,
          symbol: kSymbolTable[atomicNumber],
          atomicMass: entry.atomicMass,
          naturalAbundance: entry.abundance,
          stable: AtomInfoUtils.isStable(atomicNumber, neutrons),
        );
      }
    }
    return null;
  }

  static IsotopeData? isotopeFromProtonsNeutrons(
    int protons,
    int neutrons,
  ) {
    return isotopeOrNull(protons, protons + neutrons);
  }
}

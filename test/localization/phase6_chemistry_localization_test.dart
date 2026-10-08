import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_chemical_equations/bce_strings.dart';
import 'package:kratos/beers_law_lab/bll_strings.dart';
import 'package:kratos/chemistry/acid_base_solutions/abs_strings.dart';
import 'package:kratos/chemistry/build_an_atom/baa_strings.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/iaam_strings.dart';
import 'package:kratos/chemistry/molecule_polarity/mp_strings.dart';
import 'package:kratos/chemistry/ph_scale/phs_strings.dart';
import 'package:kratos/chemistry/states_of_matter/som_strings.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/l10n/legacy/migration_status.dart';
import 'package:kratos/l10n/scan/english_residue_classifier.dart';
import 'package:kratos/molecule_shapes/molecule_shapes_strings.dart';
import 'package:kratos/molecules_and_light/mal_strings.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_strings.dart';
import 'package:kratos/rutherford_scattering/rs_strings.dart';

void main() {
  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));

  test('PHASE 6 modules marked LOCALIZED or VERIFIED', () {
    for (final id in LocalizationMigrationRegistry.phase6ModuleIds) {
      final s = LocalizationMigrationRegistry.of(id);
      expect(
        s == LocalizationMigrationStatus.localized ||
            s == LocalizationMigrationStatus.verified,
        isTrue,
        reason: '$id=$s',
      );
    }
  });

  test('PHASE 6 string bags have no user-visible English titles', () {
    final c = EnglishResidueClassifier();
    final samples = <String>[
      BceStrings.title,
      BceStrings.reactants,
      BceStrings.balanced,
      BaaStrings.atom,
      BaaStrings.proton,
      BaaStrings.massNumber,
      PhsStrings.macro,
      PhsStrings.mySolution,
      PhsStrings.neutral,
      AbsStrings.acid,
      AbsStrings.base,
      IaamStrings.massNumber,
      MpStrings.electronegativity,
      MpStrings.partialCharges,
      MoleculeShapesStrings.moleculeGeometry,
      MalStrings.title,
      RpalStrings.reactants,
      RpalStrings.leftovers,
      RsStrings.nucleus,
      SomStrings.solid,
      SomStrings.pressure,
      BllStrings.concentration,
      loc.chemistry.atom,
      loc.chemistry.element,
      loc.chemistry.molecule,
      loc.chemistry.acid,
      loc.chemistry.base,
      loc.chemistry.concentration,
      loc.chemistry.ph,
      loc.physics.mass,
      loc.physics.pressure,
      loc.physics.wavelength,
      loc.quantum.photon,
      loc.common.resetAll,
    ];
    for (final s in samples) {
      expect(c.hasUserVisibleEnglish(s), isFalse, reason: s);
    }
  });

  test('glossary: atom≠element; pH kept; concentration≠density; massNumber≠mass', () {
    expect(loc.chemistry.atom, '原子');
    expect(loc.chemistry.element, '元素');
    expect(BaaStrings.atom, '原子');
    expect(loc.chemistry.ph, 'pH');
    expect(loc.chemistry.concentration, '浓度');
    expect(loc.chemistry.massNumber, '质量数');
    expect(loc.physics.mass, '质量');
    expect(loc.chemistry.base, '碱');
    expect(loc.chemistry.solution, '溶液');
    expect(SomStrings.pressure, '压强');
    expect(loc.physics.pressure, '压强');
  });
}

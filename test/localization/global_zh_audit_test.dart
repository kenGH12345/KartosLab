import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_chemical_equations/bce_strings.dart';
import 'package:kratos/bending_light/bl_strings.dart';
import 'package:kratos/chemistry/build_an_atom/baa_strings.dart';
import 'package:kratos/chemistry/ph_scale/phs_strings.dart';
import 'package:kratos/density/density_strings.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/l10n/legacy/migration_status.dart';
import 'package:kratos/l10n/namespaces/chemistry_l10n.dart';
import 'package:kratos/l10n/namespaces/common_l10n.dart';
import 'package:kratos/l10n/namespaces/electricity_l10n.dart';
import 'package:kratos/l10n/namespaces/fluids_l10n.dart';
import 'package:kratos/l10n/namespaces/mechanics_l10n.dart';
import 'package:kratos/l10n/namespaces/optics_waves_l10n.dart';
import 'package:kratos/l10n/namespaces/physics_l10n.dart';
import 'package:kratos/l10n/namespaces/quantum_l10n.dart';
import 'package:kratos/l10n/scan/english_residue_classifier.dart';
import 'package:kratos/ohms_law/ohms_law_strings.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

void main() {
  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));

  final classifier = EnglishResidueClassifier();

  test('Home / chrome / architecture marked localized-or-better', () {
    for (final id in ['home', 'shared-chrome', 'l10n-architecture']) {
      final s = LocalizationMigrationRegistry.of(id);
      expect(
        s == LocalizationMigrationStatus.localized ||
            s == LocalizationMigrationStatus.verified,
        isTrue,
        reason: id,
      );
    }
  });

  test('all domain-batch modules localized-or-better (not notStarted)', () {
    final all = {
      ...LocalizationMigrationRegistry.phase2ModuleIds,
      ...LocalizationMigrationRegistry.phase3ModuleIds,
      ...LocalizationMigrationRegistry.phase4ModuleIds,
      ...LocalizationMigrationRegistry.phase5ModuleIds,
      ...LocalizationMigrationRegistry.phase6ModuleIds,
    };
    for (final id in all) {
      final s = LocalizationMigrationRegistry.of(id);
      expect(s, isNot(LocalizationMigrationStatus.notStarted), reason: id);
      expect(
        s == LocalizationMigrationStatus.localized ||
            s == LocalizationMigrationStatus.verified ||
            s == LocalizationMigrationStatus.partial,
        isTrue,
        reason: '$id=$s',
      );
    }
  });

  test('no duplicate localization namespace keys', () {
    final keys = <String>{};
    for (final k in [
      ...CommonL10n.keys,
      ...PhysicsL10n.keys,
      ...MechanicsL10n.keys,
      ...FluidsL10n.keys,
      ...ElectricityL10n.keys,
      ...OpticsWavesL10n.keys,
      ...QuantumL10n.keys,
      ...ChemistryL10n.keys,
    ]) {
      expect(keys.add(k), isTrue, reason: 'duplicate $k');
    }
  });

  test('canonical glossary samples are Chinese (or approved symbols)', () {
    final samples = <String>[
      loc.common.resetAll,
      loc.home.appTitle,
      loc.physics.mass,
      loc.physics.force,
      loc.physics.density,
      loc.physics.pressure,
      loc.physics.wavelength,
      loc.mechanics.momentum,
      loc.fluids.fluidDensity,
      loc.electricity.resistor,
      loc.opticsWaves.ray,
      loc.quantum.photon,
      loc.chemistry.atom,
      loc.chemistry.element,
      loc.chemistry.ph,
      BlStrings.title,
      OhmsLawStrings.title,
      DensityStrings.title,
      QmStrings.title,
      BaaStrings.atom,
      BceStrings.balanced,
      PhsStrings.macro,
    ];
    for (final s in samples) {
      expect(classifier.hasUserVisibleEnglish(s), isFalse, reason: s);
    }
  });

  test('approved exceptions remain allowlisted', () {
    expect(
      classifier.classifyToken('pH', filePath: 'lib/ui.dart').name,
      'allowedTechnical',
    );
    expect(
      classifier.classifyToken('PhET', filePath: 'lib/ui.dart').name,
      'allowedTechnical',
    );
    expect(
      classifier.classifyToken('kg', filePath: 'lib/ui.dart').name,
      'allowedTechnical',
    );
  });

  test('verified granted only after ZH golden policy (phase 7C)', () {
    final verifiedCount = LocalizationMigrationRegistry.statusByModule.values
        .where((s) => s == LocalizationMigrationStatus.verified)
        .length;
    expect(verifiedCount, LocalizationMigrationRegistry.statusByModule.length);
    expect(
      LocalizationMigrationRegistry.of('circuit'),
      LocalizationMigrationStatus.verified,
    );
    expect(
      LocalizationMigrationRegistry.statusByModule.values
          .where((s) => s == LocalizationMigrationStatus.localized)
          .length,
      0,
    );
  });
}

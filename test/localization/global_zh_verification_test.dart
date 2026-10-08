import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/l10n/legacy/migration_status.dart';
import 'package:kratos/l10n/namespaces/accessibility_l10n.dart';
import 'package:kratos/l10n/namespaces/chemistry_l10n.dart';
import 'package:kratos/l10n/namespaces/common_l10n.dart';
import 'package:kratos/l10n/namespaces/electricity_l10n.dart';
import 'package:kratos/l10n/namespaces/fluids_l10n.dart';
import 'package:kratos/l10n/namespaces/mechanics_l10n.dart';
import 'package:kratos/l10n/namespaces/optics_waves_l10n.dart';
import 'package:kratos/l10n/namespaces/physics_l10n.dart';
import 'package:kratos/l10n/namespaces/quantum_l10n.dart';
import 'package:kratos/l10n/scan/english_residue_classifier.dart';
import 'package:kratos/screens/home_disciplines.dart';

void main() {
  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));
  final classifier = EnglishResidueClassifier();

  test('Home entries are registered in migration status', () {
    final alias = {'forces-and-motion-basics': 'forces'};
    for (final e in buildHomeDisciplines()
        .expand((d) => d.groups)
        .expand((g) => g.sims)) {
      final id = alias[e.id] ?? e.id;
      final s = LocalizationMigrationRegistry.of(id);
      expect(
        s == LocalizationMigrationStatus.localized ||
            s == LocalizationMigrationStatus.verified,
        isTrue,
        reason: '${e.id} → $id = $s',
      );
    }
  });

  test('Home / Shared Chrome / architecture localized-or-verified', () {
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

  test('no duplicate localization keys', () {
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
      ...AccessibilityL10n.keys,
    ]) {
      expect(keys.add(k), isTrue, reason: 'duplicate $k');
    }
  });

  test('Home titles and chrome samples are Chinese', () {
    for (final e in buildHomeDisciplines()
        .expand((d) => d.groups)
        .expand((g) => g.sims)
        .take(12)) {
      expect(classifier.hasUserVisibleEnglish(e.title), isFalse, reason: e.id);
    }
    expect(classifier.hasUserVisibleEnglish(loc.common.resetAll), isFalse);
    expect(classifier.hasUserVisibleEnglish(loc.home.appTitle), isFalse);
  });

  test('a11y samples are Chinese', () {
    expect(classifier.hasUserVisibleEnglish(loc.accessibility.resetAll), isFalse);
    expect(classifier.hasUserVisibleEnglish(loc.accessibility.play), isFalse);
    expect(classifier.hasUserVisibleEnglish(loc.accessibility.pause), isFalse);
  });

  test('verified modules require golden policy awareness', () {
    expect(
      LocalizationMigrationRegistry.of('home'),
      LocalizationMigrationStatus.verified,
    );
    expect(
      LocalizationMigrationRegistry.of('shared-chrome'),
      LocalizationMigrationStatus.verified,
    );
    // PHASE 7C remediations are VERIFIED (deterministic ZH goldens).
    for (final id in const [
      'circuit',
      'beers-law-lab',
      'collision-lab',
      'molarity',
      'friction',
      'cck-ac-virtual-lab',
      'resistance-in-a-wire',
      'fourier-making-waves',
      'quantum-coin-toss',
      'acid-base-solutions',
      'states-of-matter',
      'l10n-architecture',
    ]) {
      expect(
        LocalizationMigrationRegistry.of(id),
        LocalizationMigrationStatus.verified,
        reason: id,
      );
    }
    final verifiedCount = LocalizationMigrationRegistry.statusByModule.values
        .where((s) => s == LocalizationMigrationStatus.verified)
        .length;
    expect(verifiedCount, LocalizationMigrationRegistry.statusByModule.length);
    final localizedCount = LocalizationMigrationRegistry.statusByModule.values
        .where((s) => s == LocalizationMigrationStatus.localized)
        .length;
    expect(localizedCount, 0);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/gravity_and_orbits/gao_strings.dart';
import 'package:kratos/astronomy/keplers_laws/keplers_laws_strings.dart';
import 'package:kratos/astronomy/my_solar_system/my_solar_system_strings.dart';
import 'package:kratos/balancing_act/ba_strings.dart';
import 'package:kratos/collision_lab/collision_lab_strings.dart';
import 'package:kratos/forces/config/forces_strings.dart';
import 'package:kratos/friction/friction_strings.dart';
import 'package:kratos/gravity_force_lab/a11y/gfl_a11y_strings.dart';
import 'package:kratos/gravity_force_lab/gfl_strings.dart';
import 'package:kratos/gravity_force_lab_basics/gflb_strings.dart';
import 'package:kratos/hookes_law/hookes_law_strings.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/l10n/legacy/migration_status.dart';
import 'package:kratos/l10n/scan/english_residue_classifier.dart';
import 'package:kratos/masses_and_springs_basics/masb_strings.dart';
import 'package:kratos/pendulum_lab/pl_strings.dart';
import 'package:kratos/projectile_motion/pm_strings.dart';
import 'package:kratos/vector_addition/vector_addition_strings.dart';

void main() {
  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));

  test('PHASE 2 modules marked LOCALIZED or VERIFIED', () {
    for (final id in LocalizationMigrationRegistry.phase2ModuleIds) {
      final s = LocalizationMigrationRegistry.of(id);
      expect(
        s == LocalizationMigrationStatus.localized ||
            s == LocalizationMigrationStatus.verified,
        isTrue,
        reason: '$id=$s',
      );
    }
  });

  test('PHASE 2 string bags have no user-visible English titles', () {
    final c = EnglishResidueClassifier();
    final samples = <String>[
      CollisionLabStrings.title,
      CollisionLabStrings.mass,
      VectorAdditionStrings.title,
      VectorAdditionStrings.resetAll,
      PmStrings.title,
      PmStrings.gravity,
      PlStrings.title,
      PlStrings.mass,
      BaStrings.title,
      FrictionStrings.title,
      GflStrings.title,
      GflStrings.resetAll,
      GflbStrings.title,
      GaoStrings.title,
      GaoStrings.gravityForce,
      KeplersLawsStrings.title,
      MySolarSystemStrings.title,
      ForcesStrings.netForceGo,
      ForcesStrings.screenNetForce,
      HookesLawStrings.title,
      MasbStrings.title,
      GflA11yStrings.resetAll,
      GflA11yStrings.mass1,
      loc.mechanics.momentum,
      loc.mechanics.forceValues,
      loc.physics.mass,
      loc.physics.gravity,
      loc.physics.gravityForce,
    ];
    for (final s in samples) {
      expect(
        c.hasUserVisibleEnglish(s),
        isFalse,
        reason: s,
      );
    }
  });

  test('glossary: mass ≠ weight; gravity ≠ gravityForce', () {
    expect(loc.physics.mass, '质量');
    expect(loc.physics.weight, '重量');
    expect(loc.physics.gravity, '重力');
    expect(loc.physics.gravityForce, '引力');
    expect(GflStrings.forceValues, loc.mechanics.forceValues);
  });
}

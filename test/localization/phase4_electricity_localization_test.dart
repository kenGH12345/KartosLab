import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balloons_and_static_electricity/base_strings.dart';
import 'package:kratos/capacitor_lab_basics/clb_strings.dart';
import 'package:kratos/cck_ac_virtual_lab/cck_strings.dart';
import 'package:kratos/charges_and_fields/caf_strings.dart';
import 'package:kratos/faradays_law/faradays_law_strings.dart';
import 'package:kratos/john_travoltage/jt_strings.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/l10n/legacy/migration_status.dart';
import 'package:kratos/l10n/scan/english_residue_classifier.dart';
import 'package:kratos/magnetism/magnet_and_compass/mac_strings.dart';
import 'package:kratos/ohms_law/ohms_law_strings.dart';
import 'package:kratos/resistance_in_a_wire/riaw_strings.dart';

void main() {
  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));

  test('PHASE 4 modules marked LOCALIZED or VERIFIED', () {
    for (final id in LocalizationMigrationRegistry.phase4ModuleIds) {
      final s = LocalizationMigrationRegistry.of(id);
      expect(
        s == LocalizationMigrationStatus.localized ||
            s == LocalizationMigrationStatus.verified,
        isTrue,
        reason: '$id=$s',
      );
    }
  });

  test('PHASE 4 string bags have no user-visible English titles', () {
    final c = EnglishResidueClassifier();
    final samples = <String>[
      OhmsLawStrings.title,
      OhmsLawStrings.voltage,
      OhmsLawStrings.current,
      RiawStrings.resistivity,
      RiawStrings.area,
      CckStrings.title,
      CckStrings.resistor,
      CckStrings.voltmeter,
      ClbStrings.title,
      ClbStrings.electricField,
      ClbStrings.capacitance,
      CafStrings.title,
      CafStrings.electricField,
      CafStrings.equipotential,
      FaradaysLawStrings.title,
      FaradaysLawStrings.voltmeter,
      FaradaysLawStrings.fieldLines,
      JtStrings.title,
      BaseStrings.title,
      BaseStrings.showAllCharges,
      MacStrings.barMagnet,
      MacStrings.flipPolarity,
      loc.electricity.wire,
      loc.electricity.resistor,
      loc.physics.voltage,
      loc.physics.current,
      loc.physics.resistance,
      loc.mechanics.power,
    ];
    for (final s in samples) {
      expect(c.hasUserVisibleEnglish(s), isFalse, reason: s);
    }
  });

  test('glossary: current=电流; charge≠充电; power=功率; resistance≠resistor', () {
    expect(loc.physics.current, '电流');
    expect(loc.physics.voltage, '电压');
    expect(loc.physics.resistance, '电阻');
    expect(loc.electricity.resistor, '电阻器');
    expect(loc.electricity.capacitor, '电容器');
    expect(loc.electricity.capacitance, '电容');
    expect(loc.mechanics.power, '功率');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/bl_strings.dart';
import 'package:kratos/color_vision/color_vision_strings.dart';
import 'package:kratos/fourier_making_waves/fmw_strings.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/l10n/legacy/migration_status.dart';
import 'package:kratos/l10n/scan/english_residue_classifier.dart';
import 'package:kratos/normal_modes/normal_modes_strings.dart';
import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';
import 'package:kratos/quantum_coin_toss/common/quantum_measurement_strings.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';
import 'package:kratos/wave_on_a_string/woas_strings.dart';
import 'package:kratos/waves_intro/waves_intro_strings.dart';

void main() {
  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));

  test('PHASE 5 modules marked LOCALIZED or VERIFIED', () {
    for (final id in LocalizationMigrationRegistry.phase5ModuleIds) {
      final s = LocalizationMigrationRegistry.of(id);
      expect(
        s == LocalizationMigrationStatus.localized ||
            s == LocalizationMigrationStatus.verified,
        isTrue,
        reason: '$id=$s',
      );
    }
  });

  test('PHASE 5 string bags have no user-visible English titles', () {
    final c = EnglishResidueClassifier();
    final samples = <String>[
      BlStrings.title,
      BlStrings.ray,
      BlStrings.normal,
      BlStrings.indexOfRefraction,
      BlStrings.air,
      ColorVisionStrings.title,
      ColorVisionStrings.singleBulb,
      WoasStrings.title,
      WoasStrings.amplitude,
      WoasStrings.fixedEnd,
      WavesIntroStrings.title,
      WavesIntroStrings.frequency,
      WavesIntroStrings.electricField,
      NormalModesStrings.title,
      NormalModesStrings.phase,
      FmwStrings.title,
      FmwStrings.wavelength,
      QmStrings.title,
      QmStrings.photons,
      QmStrings.probability,
      QmStrings.classical,
      QwiStrings.title,
      QwiStrings.wavelength,
      QwiStrings.bothSlitsOpen,
      QuantumMeasurementStrings.observe,
      QuantumMeasurementStrings.superposition,
      loc.opticsWaves.ray,
      loc.opticsWaves.normal,
      loc.opticsWaves.phase,
      loc.quantum.photon,
      loc.quantum.probability,
      loc.physics.wavelength,
      loc.physics.frequency,
      loc.physics.amplitude,
      loc.common.resetAll,
      loc.common.normal,
    ];
    for (final s in samples) {
      expect(c.hasUserVisibleEnglish(s), isFalse, reason: s);
    }
  });

  test('glossary: normal≠正常 in optics; phase=相位; frequency=频率', () {
    expect(BlStrings.normal, '法线');
    expect(loc.opticsWaves.normal, '法线');
    expect(loc.common.normal, '正常');
    expect(WavesIntroStrings.normal, '正常');
    expect(NormalModesStrings.phase, '相位：');
    expect(loc.opticsWaves.phase, '相位');
    expect(loc.physics.frequency, '频率');
    expect(loc.physics.amplitude, '振幅');
    expect(loc.physics.wavelength, '波长');
    expect(QmStrings.observe, '观测');
    expect(QmStrings.probability, '概率');
    expect(QwiStrings.amplitude, '振幅');
  });
}

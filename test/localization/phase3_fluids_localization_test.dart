import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/buoyancy_strings.dart';
import 'package:kratos/density/density_strings.dart';
import 'package:kratos/diffusion/diffusion_strings.dart';
import 'package:kratos/gas_properties/gas_properties_strings.dart';
import 'package:kratos/gases_intro/gases_intro_strings.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/l10n/legacy/migration_status.dart';
import 'package:kratos/l10n/scan/english_residue_classifier.dart';
import 'package:kratos/membrane_transport/membrane_transport_strings.dart';
import 'package:kratos/under_pressure/under_pressure_strings.dart';

void main() {
  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));

  test('PHASE 3 modules marked LOCALIZED or VERIFIED', () {
    for (final id in LocalizationMigrationRegistry.phase3ModuleIds) {
      final s = LocalizationMigrationRegistry.of(id);
      expect(
        s == LocalizationMigrationStatus.localized ||
            s == LocalizationMigrationStatus.verified,
        isTrue,
        reason: '$id=$s',
      );
    }
  });

  test('PHASE 3 string bags have no user-visible English titles', () {
    final c = EnglishResidueClassifier();
    final samples = <String>[
      DensityStrings.title,
      DensityStrings.mass,
      DensityStrings.materialName('density.material.wood'),
      DensityStrings.materialName('density.material.gold'),
      BuoyancyStrings.title,
      BuoyancyStrings.fluidDensity,
      BuoyancyStrings.objectDensity,
      BuoyancyStrings.percentSubmerged,
      BuoyancyStrings.sameMass,
      UnderPressureStrings.title,
      UnderPressureStrings.fluidDensity,
      UnderPressureStrings.atmosphere,
      UnderPressureStrings.fluidA,
      GasesIntroStrings.title,
      GasesIntroStrings.holdConstant,
      GasesIntroStrings.returnLid,
      GasPropertiesStrings.title,
      GasPropertiesStrings.holdConstant,
      GasPropertiesStrings.removeDivider,
      GasPropertiesStrings.tempEmpty,
      DiffusionStrings.title,
      DiffusionStrings.removeDivider,
      MembraneTransportStrings.title,
      MembraneTransportStrings.solutes,
      MembraneTransportStrings.outside,
      loc.fluids.fluid,
      loc.fluids.liquid,
      loc.fluids.temperature,
      loc.fluids.fluidDensity,
      loc.physics.density,
      loc.physics.pressure,
      loc.physics.buoyancy,
      loc.physics.mass,
    ];
    for (final s in samples) {
      expect(c.hasUserVisibleEnglish(s), isFalse, reason: s);
    }
  });

  test('glossary: mass≠weight; fluid≠liquid; pressure=压强; wood=木材', () {
    expect(loc.physics.mass, '质量');
    expect(loc.physics.weight, '重量');
    expect(loc.fluids.fluid, '流体');
    expect(loc.fluids.liquid, '液体');
    expect(loc.physics.pressure, '压强');
    expect(loc.fluids.material('wood'), '木材');
    expect(DensityStrings.materialName('density.material.wood'), '木材');
  });
}

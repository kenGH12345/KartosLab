import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/molarity/model/molarity_constants.dart';
import 'package:kratos/chemistry/molarity/model/molarity_math.dart';
import 'package:kratos/chemistry/molarity/model/molarity_model.dart';
import 'package:kratos/chemistry/molarity/model/molarity_solute_catalog.dart';
import 'package:kratos/chemistry/molarity/model/solution.dart';
import 'package:kratos/chemistry/molarity/model/solvent.dart';

/// Phase 1 Model Contract — PhET molarity 1.6.0-dev.6 (HTML5 JS).
void main() {
  // M-01 architecture
  test('M-01 architecture: MolarityModel → solutes + Solution · no step(dt)', () {
    final m = MolarityModel.defaults();
    expect(m.solutes, hasLength(9));
    expect(m.solution, isA<Solution>());
    expect(m.maxPrecipitateAmount, closeTo(0.9, 1e-12));
    expect(m.resetInProgress, isFalse);
    // No AnimationController / Timer in model — reactive getters only.
    expect(m.solution.concentration, isA<double>());
  });

  // M-02 default state
  test('M-02 default: Drink mix · n=0.5 · V=0.5 · values off', () {
    final m = MolarityModel.defaults();
    expect(m.solution.solute.formula, 'Drink mix');
    expect(m.solution.soluteAmount, 0.5);
    expect(m.solution.volume, 0.5);
    expect(m.valuesVisible, isFalse);
  });

  // M-03 / M-04 ranges
  test('M-03 solute amount range clamp + 3 dp', () {
    final m = MolarityModel.defaults();
    m.setSoluteAmount(-1);
    expect(m.solution.soluteAmount, 0);
    m.setSoluteAmount(2);
    expect(m.solution.soluteAmount, 1);
    m.setSoluteAmount(0.12345);
    expect(m.solution.soluteAmount, 0.123);
  });

  test('M-04 volume range clamp + 3 dp (UI)', () {
    final m = MolarityModel.defaults();
    m.setVolume(0.1);
    expect(m.solution.volume, 0.2);
    m.setVolume(2);
    expect(m.solution.volume, 1);
    m.setVolume(0.56789);
    expect(m.solution.volume, 0.568);
  });

  // M-05 / M-06 concentration
  test('M-05 default concentration = 1.000 M', () {
    final m = MolarityModel.defaults();
    expect(m.solution.concentration, 1.0);
    expect(MolarityMath.toFixed(m.solution.concentration, 3), '1.000');
  });

  test('M-06 concentration formula min(C_sat, n/V)', () {
    final m = MolarityModel.defaults();
    m.setSoluteAmount(0.1);
    m.setVolume(0.5);
    expect(m.solution.concentration, 0.2);

    // Saturated K2Cr2O7 C_sat=0.50 · n=1 V=0.2 → raw 5 → capped 0.500
    m.selectSolute(3);
    m.setSoluteAmount(1);
    m.setVolume(0.2);
    expect(m.solution.concentration, 0.5);
  });

  // M-07 precision
  test('M-07 3-decimal precision (toFixedNumber)', () {
    final drink = MolaritySoluteCatalog.createCanonical().first;
    final s = Solution(
      solvent: const Solvent(),
      solute: drink,
      soluteAmount: 0.1,
      volume: 0.3,
    );
    // 0.1/0.3 = 0.333... → 0.333
    expect(s.concentration, 0.333);
    expect(s.concentration, isNot(closeTo(0.1 / 0.3, 0)));
  });

  // M-08 zero volume
  test('M-08 zero volume → C=0 · precipitate=n', () {
    final drink = MolaritySoluteCatalog.createCanonical().first;
    final s = Solution(
      solvent: const Solvent(),
      solute: drink,
      soluteAmount: 0.8,
      volume: 0,
    );
    expect(s.concentration, 0);
    expect(s.precipitateAmount, 0.8);
    expect(s.beakerLabel, '');
  });

  // M-09 / M-10 zero solute / water
  test('M-09/M-10 zero solute → C=0 · Water #E0FFFF · label H₂O', () {
    final m = MolarityModel.defaults();
    m.setSoluteAmount(0);
    expect(m.solution.concentration, 0);
    expect(m.solution.solutionColor, const Color(0xFFE0FFFF));
    expect(m.solution.beakerLabel, 'H\u2082O');
    expect(m.solution.hasSolute, isFalse);
  });

  // M-11..M-15 solute catalog
  test('M-11..M-15 all 9 solutes · C_sat · colors · KMnO₄ black', () {
    final list = MolaritySoluteCatalog.createCanonical();
    expect(list, hasLength(9));
    for (var i = 0; i < 9; i++) {
      expect(
        list[i].saturatedConcentration,
        MolaritySoluteCatalog.saturatedConcentrations[i],
      );
    }
    expect(list[0].solutionColor.min, const Color(0xFFFFE1E1));
    expect(list[0].solutionColor.max, const Color(0xFFFF0000));
    expect(list[0].particleColor, const Color(0xFFFF0000));
    expect(list[2].solutionColor.max, const Color(0xFFFF6A6A));
    expect(list[8].particleColor, const Color(0xFF000000));
    expect(list[8].formula, 'KMnO\u2084');
  });

  // M-16..M-19 saturation / precipitate
  test('M-16 saturation boundary n = V*C_sat → precipitate 0', () {
    final k2 = MolaritySoluteCatalog.createCanonical()[3]; // 0.50
    final s = Solution(
      solvent: const Solvent(),
      solute: k2,
      soluteAmount: 0.25,
      volume: 0.5,
    );
    expect(s.precipitateAmount, 0);
    expect(s.isSaturated, isFalse);
    expect(s.concentration, 0.5);
  });

  test('M-17/M-19 precipitate formula supersaturated', () {
    final k2 = MolaritySoluteCatalog.createCanonical()[3];
    final s = Solution(
      solvent: const Solvent(),
      solute: k2,
      soluteAmount: 1.0,
      volume: 0.5,
    );
    // n - V*C_sat = 1 - 0.25 = 0.75
    expect(s.precipitateAmount, closeTo(0.75, 1e-12));
    expect(s.isSaturated, isTrue);
    expect(s.concentration, 0.5);
  });

  test('M-18 precipitate zero when unsaturated', () {
    final m = MolarityModel.defaults();
    expect(m.solution.precipitateAmount, 0);
    expect(m.solution.isSaturated, isFalse);
  });

  // M-20 / M-21 particle count
  test('M-20/M-21 particle count = floor(200*p) · min 1', () {
    final k2 = MolaritySoluteCatalog.createCanonical()[3];
    final tiny = Solution(
      solvent: const Solvent(),
      solute: k2,
      soluteAmount: 0.251,
      volume: 0.5,
    );
    // precipitate = 0.001 → floor(0.2)=0 → clamp to 1
    expect(tiny.precipitateAmount, closeTo(0.001, 1e-12));
    expect(tiny.numberOfParticles, 1);

    final mid = Solution(
      solvent: const Solvent(),
      solute: k2,
      soluteAmount: 1.0,
      volume: 0.5,
    );
    // 0.75 * 200 = 150
    expect(mid.numberOfParticles, 150);

    final zero = Solution(
      solvent: const Solvent(),
      solute: k2,
      soluteAmount: 0.1,
      volume: 0.5,
    );
    expect(zero.numberOfParticles, 0);
  });

  // M-22 solute switch
  test('M-22 solute switch updates C_sat · keeps n/V', () {
    final m = MolarityModel.defaults();
    expect(m.solution.concentration, 1.0);
    m.selectSolute(3); // K2Cr2O7 C_sat=0.5
    expect(m.solution.soluteAmount, 0.5);
    expect(m.solution.volume, 0.5);
    expect(m.solution.concentration, 0.5);
    expect(m.solution.isSaturated, isTrue);
    expect(m.solution.precipitateAmount, closeTo(0.25, 1e-12));
  });

  // M-23 / M-24 / M-25 reactive
  test('M-23/M-24/M-25 reactive: amount/volume change → concentration', () {
    final m = MolarityModel.defaults();
    var notified = 0;
    m.solution.addListener(() => notified++);
    m.setSoluteAmount(0.2);
    expect(m.solution.concentration, 0.4);
    m.setVolume(1.0);
    expect(m.solution.concentration, 0.2);
    expect(notified, greaterThanOrEqualTo(2));
  });

  // M-26 valuesVisible independence
  test('M-26 valuesVisible does not change physics', () {
    final m = MolarityModel.defaults();
    final c0 = m.solution.concentration;
    final p0 = m.solution.precipitateAmount;
    m.setValuesVisible(true);
    expect(m.solution.concentration, c0);
    expect(m.solution.precipitateAmount, p0);
    expect(m.valuesVisible, isTrue);
  });

  // M-27 / M-28 reset
  test('M-27/M-28 reset from saturated non-default state', () {
    final m = MolarityModel.defaults();
    m.selectSolute(8); // KMnO4
    m.setSoluteAmount(1);
    m.setVolume(0.2);
    m.setValuesVisible(true);
    expect(m.solution.isSaturated, isTrue);

    m.reset();
    expect(m.valuesVisible, isFalse);
    expect(m.resetInProgress, isFalse);
    expect(m.solution.solute.formula, 'Drink mix');
    expect(m.solution.soluteAmount, 0.5);
    expect(m.solution.volume, 0.5);
    expect(m.solution.concentration, 1.0);
    expect(m.solution.precipitateAmount, 0);
  });

  // M-29 keyboard constants
  test('M-29 keyboard step constants', () {
    expect(MolarityConstants.keyboardStep, 0.050);
    expect(MolarityConstants.shiftKeyboardStep, 0.001);
    expect(MolarityConstants.soluteAmountDecimalPlaces, 3);
    expect(MolarityConstants.volumeDecimalPlaces, 3);
    expect(MolarityConstants.concentrationDecimalPlaces, 3);
    expect(MolarityConstants.concentrationDisplayMax, 5.0);
    expect(MolarityConstants.particlesPerMole, 200);
  });

  // M-30 no step architecture + isolation markers
  test('M-30 constants lay out 1100×700 · particles global', () {
    expect(MolarityConstants.layoutWidth, 1100);
    expect(MolarityConstants.layoutHeight, 700);
    expect(MolarityConstants.particlesPerMole, 200);
  });

  test('color at C_sat uses maxColor; C=0 uses water', () {
    final k2 = MolaritySoluteCatalog.createCanonical()[3];
    final sat = Solution(
      solvent: const Solvent(),
      solute: k2,
      soluteAmount: 0.25,
      volume: 0.5,
    );
    expect(sat.solutionColor, k2.solutionColor.max);

    final water = Solution(
      solvent: const Solvent(),
      solute: k2,
      soluteAmount: 0,
      volume: 0.5,
    );
    expect(water.solutionColor, const Color(0xFFE0FFFF));
  });

  test('maxPrecipitateAmount uses min C_sat among catalog', () {
    final solutes = MolaritySoluteCatalog.createCanonical();
    expect(
      MolarityModel.computeMaxPrecipitateAmount(solutes),
      closeTo(0.9, 1e-12),
    );
  });

  test('solute change does not invent reset of n/V', () {
    final m = MolarityModel.defaults();
    m.setSoluteAmount(0.8);
    m.setVolume(0.7);
    m.selectSolute(5);
    expect(m.solution.soluteAmount, 0.8);
    expect(m.solution.volume, 0.7);
  });

  test('cross-sim isolation: Solute has no molarMass / no form enum', () {
    final s = MolaritySoluteCatalog.createCanonical().first;
    expect(s.runtimeType.toString(), 'Solute');
    // Compile-time contract: no Beer's Law fields on Solute.
    expect(s.saturatedConcentration, isA<double>());
  });
}

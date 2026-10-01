import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_beaker.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_conductivity_tester.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_constants.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_particle_field.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_ph_paper.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_preferences.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_view_properties.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/intro_model.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/my_solution_model.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/particle_count.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/particle_key.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/solutions/strong_acid.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/solutions/water.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/solutions/weak_acid.dart';

void main() {
  group('Oracle F — Particle count', () {
    test('water [H3O+]=1e-7 → 2 particles', () {
      expect(absParticleCount(1e-7), 2);
    });

    test('C=0.01 → 54 particles', () {
      expect(absParticleCount(0.01), 54);
    });

    test('C=1 → 200 (max)', () {
      expect(absParticleCount(1), AbsConstants.particleMaxCount);
    });

    test('C=0 → 0', () {
      expect(absParticleCount(0), 0);
    });

    test('StrongAcid counts: HA=0, A and H3O from C', () {
      final a = StrongAcid()..concentration = 0.01;
      final field = AbsParticleField(random: Random(1));
      final counts = field.countsFor(a);
      expect(counts[ParticleKey.ha], 0);
      expect(counts[ParticleKey.a], 54);
      expect(counts[ParticleKey.h3o], 54);
      expect(counts.containsKey(ParticleKey.h2o), isFalse);
    });

    test('seeded layout is deterministic', () {
      final a = WeakAcid();
      final field1 = AbsParticleField(random: Random(42));
      final field2 = AbsParticleField(random: Random(42));
      final r = AbsParticleField.lensRadiusForBeakerHeight(270);
      final layout1 = field1.buildLayout(solution: a, lensRadius: r);
      final layout2 = field2.buildLayout(solution: a, lensRadius: r);
      expect(layout1.length, layout2.length);
      for (var i = 0; i < layout1.length; i++) {
        expect(layout1[i].key, layout2[i].key);
        expect(layout1[i].position, layout2[i].position);
      }
    });
  });

  group('Oracle G — Reset', () {
    test('IntroModel reset restores Water + tools + defaults', () {
      final model = IntroModel();
      final view = AbsViewProperties();

      model.selectedSolution = model.strongAcid;
      model.strongAcid.concentration = 1;
      model.pHMeter.position = Offset(
        model.pHMeter.position.dx,
        model.beaker.top + 30,
      );
      model.pHPaper.percentColored = 0.5;
      view.viewMode = AbsViewMode.graph;
      view.toolMode = AbsToolMode.pHPaper;

      model.reset();
      view.reset();

      expect(model.solution, same(model.water));
      expect(model.strongAcid.concentration, 1e-2);
      expect(model.pHMeter.isInSolution, isFalse);
      expect(model.pHPaper.percentColored, 0);
      expect(view.viewMode, AbsViewMode.particles);
      expect(view.toolMode, AbsToolMode.pHMeter);
    });

    test('MySolutionModel reset restores Acid+weak+0.01+1e-7', () {
      final model = MySolutionModel();
      model.isAcid = false;
      model.isWeak = false;
      model.concentration = 1;
      model.strength = 1e-3;
      model.pHMeter.position = Offset(
        model.pHMeter.position.dx,
        model.beaker.top + 40,
      );

      model.reset();

      expect(model.isAcid, isTrue);
      expect(model.isWeak, isTrue);
      expect(model.concentration, 1e-2);
      expect(model.strength, 1e-7);
      expect(model.solution, same(model.weakAcid));
      expect(model.pHMeter.isInSolution, isFalse);
    });

    test('AbsPreferences are NOT cleared by screen reset', () {
      final prefs = AbsPreferences(showSolvent: true);
      final model = IntroModel();
      model.reset();
      expect(prefs.showSolvent, isTrue);
    });
  });

  group('Conductivity — strict pH == 7', () {
    test('open circuit → 0', () {
      final beaker = AbsBeaker();
      final tester = AbsConductivityTester(
        beaker: beaker,
        pHOfSolution: () => 2,
      );
      // Default probes are above liquid.
      expect(tester.brightness, 0);
    });

    test('pH == 7 in solution → 0 (distilled water)', () {
      final beaker = AbsBeaker();
      final tester = AbsConductivityTester(
        beaker: beaker,
        pHOfSolution: () => 7,
      );
      _dipBothProbes(tester, beaker);
      expect(tester.brightness, 0);
    });

    test('pH < 7 closed circuit uses linear formula', () {
      final beaker = AbsBeaker();
      final tester = AbsConductivityTester(
        beaker: beaker,
        pHOfSolution: () => 0,
      );
      _dipBothProbes(tester, beaker);
      expect(tester.brightness, 1);
    });

    test('pH > 7 closed circuit', () {
      final beaker = AbsBeaker();
      final tester = AbsConductivityTester(
        beaker: beaker,
        pHOfSolution: () => 14,
      );
      _dipBothProbes(tester, beaker);
      expect(tester.brightness, 1);
    });

    test('pH 2 brightness matches formula', () {
      final beaker = AbsBeaker();
      const pH = 2.0;
      final tester = AbsConductivityTester(
        beaker: beaker,
        pHOfSolution: () => pH,
      );
      _dipBothProbes(tester, beaker);
      const expected = AbsConstants.neutralBrightness +
          (1 - AbsConstants.neutralBrightness) *
              (7 - pH) /
              (7 - 0);
      expect(tester.brightness, closeTo(expected, 1e-12));
    });

    test('Water via IntroModel → brightness 0 when dipped', () {
      final model = IntroModel();
      expect(model.pH, 7);
      _dipBothProbes(model.conductivityTester, model.beaker);
      expect(model.conductivityTester.brightness, 0);
    });
  });

  group('Tools — PHMeter / PHPaper', () {
    test('PHMeter blank when tip out of solution', () {
      final model = IntroModel();
      expect(model.pHMeter.isInSolution, isFalse);
      expect(model.pHMeter.displayedPH, isNull);
    });

    test('PHMeter shows pH when dipped', () {
      final model = IntroModel();
      model.pHMeter.position = Offset(
        model.pHMeter.position.dx,
        model.beaker.top + 10,
      );
      expect(model.pHMeter.isInSolution, isTrue);
      expect(model.pHMeter.displayedPH, 7);
    });

    test('PHPaper percentColored increases only while dipped', () {
      final beaker = AbsBeaker();
      final paper = AbsPhPaper(
        beaker: beaker,
        pHOfSolution: () => 2,
        solution: Water.new,
      );
      expect(paper.percentColored, 0);
      paper.position = Offset(beaker.position.dx, beaker.top + 40);
      expect(paper.percentColored, greaterThan(0));
      final colored = paper.percentColored;
      paper.position = Offset(beaker.position.dx, beaker.top - 10);
      expect(paper.percentColored, colored); // does not decrease
    });

    test('PHPaper float step moves up at 250 px/s', () {
      final beaker = AbsBeaker();
      final paper = AbsPhPaper(
        beaker: beaker,
        pHOfSolution: () => 2,
        solution: Water.new,
      );
      paper.position = Offset(beaker.position.dx, beaker.bottom - 10);
      final y0 = paper.position.dy;
      paper.step(0.1, isPressed: false);
      expect(paper.position.dy, lessThan(y0));
      expect(y0 - paper.position.dy, closeTo(25, 1e-9)); // 250 * 0.1
    });
  });

  group('Screen model isolation', () {
    test('Intro has Water; My Solution does not', () {
      final intro = IntroModel();
      final mine = MySolutionModel();
      expect(intro.solutions.whereType<Water>().length, 1);
      expect(mine.solutions.whereType<Water>(), isEmpty);
      expect(intro.solutions.length, 5);
      expect(mine.solutions.length, 4);
    });

    test('My Solution type matrix', () {
      final m = MySolutionModel();
      expect(m.solution, same(m.weakAcid));
      m.isWeak = false;
      expect(m.solution, same(m.strongAcid));
      m.isAcid = false;
      expect(m.solution, same(m.strongBase));
      m.isWeak = true;
      expect(m.solution, same(m.weakBase));
    });

    test('concentration syncs to all; strength only to weak', () {
      final m = MySolutionModel();
      m.concentration = 0.5;
      for (final s in m.solutions) {
        expect(s.concentration, 0.5);
      }
      m.strength = 1e-3;
      expect(m.weakAcid.strength, 1e-3);
      expect(m.weakBase.strength, 1e-3);
      expect(m.strongAcid.strength, AbsConstants.strongStrength);
      expect(m.strongBase.strength, AbsConstants.strongStrength);
    });

    test('models do not share solution instances', () {
      final a = IntroModel();
      final b = IntroModel();
      expect(identical(a.water, b.water), isFalse);
      a.strongAcid.concentration = 1;
      expect(b.strongAcid.concentration, 1e-2);
    });
  });

  group('View properties / preferences defaults', () {
    test('AbsViewProperties defaults', () {
      final v = AbsViewProperties();
      expect(v.viewMode, AbsViewMode.particles);
      expect(v.toolMode, AbsToolMode.pHMeter);
    });

    test('AbsPreferences default showSolvent=false', () {
      expect(AbsPreferences().showSolvent, isFalse);
    });

    test('concentration spinner delta is 0.001', () {
      expect(AbsConstants.deltaConcentration, 0.001);
      expect(AbsConstants.concentrationRange.min, 1e-3);
      expect(AbsConstants.concentrationRange.max, 1);
      expect(AbsConstants.concentrationRange.defaultValue, 1e-2);
    });
  });

  group('Beaker geometry', () {
    test('fixed size and 1:1 coordinates', () {
      final b = AbsBeaker();
      expect(b.size, AbsConstants.beakerSize);
      expect(b.position, AbsConstants.beakerPosition);
      expect(b.bounds.width, 360);
      expect(b.bounds.height, 270);
    });
  });
}

void _dipBothProbes(AbsConductivityTester tester, AbsBeaker beaker) {
  final y = beaker.top + 20;
  tester.positiveProbePosition = Offset(tester.positiveProbePosition.dx, y);
  tester.negativeProbePosition = Offset(tester.negativeProbePosition.dx, y);
}

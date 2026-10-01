import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/ph_scale/model/macro_model.dart';
import 'package:kratos/chemistry/ph_scale/model/micro_model.dart';
import 'package:kratos/chemistry/ph_scale/model/my_solution.dart';
import 'package:kratos/chemistry/ph_scale/model/ph_chemistry.dart';
import 'package:kratos/chemistry/ph_scale/model/ph_scale_constants.dart';
import 'package:kratos/chemistry/ph_scale/model/ratio_particle_counts.dart';
import 'package:kratos/chemistry/ph_scale/model/solute.dart';
import 'package:kratos/chemistry/ph_scale/model/solution_derived_properties.dart';
import 'package:kratos/chemistry/ph_scale/view/graph/graph_enums.dart';
import 'package:kratos/chemistry/ph_scale/view/graph/graph_math.dart';
import 'package:kratos/chemistry/ph_scale/view/ph_scale_view_properties.dart';
import 'package:kratos/chemistry/ph_scale/view/scientific_notation.dart';
import 'package:kratos/chemistry/ph_scale/view/screens/macro_screen_view.dart';
import 'package:kratos/chemistry/ph_scale/view/screens/ph_scale_screen.dart';
import 'package:kratos/chemistry/ph_scale/view/widgets/macro_ph_meter_node.dart';

void main() {
  group('Phase 6 — Cross-screen independence (SOURCE: separate createModel)', () {
    test('Macro / Micro / MySolution are separate instances', () {
      final macro = MacroModel()..completeAutofillNow();
      final micro = MicroModel()..completeAutofillNow();
      final mine = MySolutionModel();

      macro.selectSolute(Solute.coffee);
      macro.completeAutofillNow();

      expect(macro.solution.solute.id, 'coffee');
      expect(micro.solution.solute.id, isNot('coffee'));
      expect(mine.solution.pH, 7);
      expect(identical(macro.solution, micro.solution), isFalse);
    });
  });

  group('Phase 6 — Macro acceptance', () {
    test('autofill → 0.5 L water pH 7; solute change → stock pH', () {
      final m = MacroModel()..completeAutofillNow();
      expect(m.solution.totalVolume, closeTo(0.5, 1e-9));
      expect(m.solution.pH, closeTo(7, 1e-9));

      m.selectSolute(Solute.batteryAcid);
      m.completeAutofillNow();
      expect(m.solution.pH, closeTo(1, 1e-9));
      expect(m.solution.totalVolume, closeTo(0.5, 1e-9));
    });

    test('faucet rates: water 0.25 L/s; dropper 0.05 L/s', () {
      final m = MacroModel()..completeAutofillNow();
      expect(m.waterFaucet.maxFlowRate, 0.25);
      expect(m.drainFaucet.maxFlowRate, 0.25);
      expect(m.dropper.maxFlowRate, 0.05);
    });

    test('water faucet dilutes acid; drain reduces volume', () {
      final m = MacroModel();
      m.selectSolute(Solute.batteryAcid);
      m.completeAutofillNow();
      final pH0 = m.solution.pH!;
      m.waterFaucet.flowRate = 0.25;
      m.step(0.5);
      m.waterFaucet.flowRate = 0;
      expect(m.solution.totalVolume, greaterThan(0.5));
      expect(m.solution.pH!, greaterThan(pH0));

      final v = m.solution.totalVolume;
      m.drainFaucet.flowRate = 0.25;
      m.step(0.2);
      m.drainFaucet.flowRate = 0;
      expect(m.solution.totalVolume, lessThan(v));
    });

    test('probe out of fluid → null; in solution → solution pH', () {
      final m = MacroModel();
      m.selectSolute(Solute.coffee);
      m.completeAutofillNow();
      final tipIn = Offset(m.beaker.position.dx, m.beaker.position.dy - 50);
      expect(resolveProbePH(model: m, tip: tipIn), closeTo(5, 1e-9));
      expect(resolveProbePH(model: m, tip: const Offset(10, 10)), isNull);
      expect(m.formatDisplayedPH(null), isNull);
    });

    test('Reset All returns water autofill + probe home + null meter', () {
      final m = MacroModel()..completeAutofillNow();
      final probe0 = m.meter.probePosition;
      m.selectSolute(Solute.drainCleaner);
      m.completeAutofillNow();
      m.meter.probePosition = const Offset(400, 400);
      m.setProbeReading(13);
      m.waterFaucet.flowRate = 0.1;

      m.reset();
      m.completeAutofillNow();

      expect(m.solution.solute.id, 'water');
      expect(m.solution.totalVolume, closeTo(0.5, 1e-9));
      expect(m.solution.pH, closeTo(7, 1e-9));
      expect(m.meter.displayedPH, isNull);
      expect(m.meter.probePosition, probe0);
      expect(m.waterFaucet.flowRate, 0);
      expect(m.dropper.flowRate, 0);
    });
  });

  group('Phase 6 — Micro Ratio / Counts sync', () {
    test('acid / neutral / base Ratio + Counts from same derived', () {
      void check(
        double pH,
        void Function(({int h3o, int oh}) r, SolutionDerivedProperties d) fn,
      ) {
        final d = SolutionDerivedProperties(pH: pH, totalVolume: 0.5);
        final r = RatioParticleCounts.displayCounts(pH);
        fn(r, d);
      }

      check(7, (r, d) {
        expect(r.h3o, 50);
        expect(r.oh, 50);
        expect(d.particleCountH3O, closeTo(d.particleCountOH, 1e6));
        expect(d.concentrationH3O, closeTo(1e-7, 1e-20));
      });

      check(3, (r, d) {
        expect(r.h3o, greaterThan(r.oh));
        expect(d.concentrationH3O!, greaterThan(d.concentrationOH!));
      });

      check(11, (r, d) {
        expect(r.oh, greaterThan(r.h3o));
        expect(d.concentrationOH!, greaterThan(d.concentrationH3O!));
      });
    });

    test('viewProperties reset → toggles false', () {
      final v = PhScaleViewProperties()
        ..setRatioVisible(true)
        ..setParticleCountsVisible(true);
      v.reset();
      expect(v.ratioVisible, isFalse);
      expect(v.particleCountsVisible, isFalse);
    });

    test('Reset: model + view + graph', () {
      final micro = MicroModel()..completeAutofillNow();
      final view = PhScaleViewProperties()..setRatioVisible(true);
      final graph = GraphViewState(hasLinearFeature: true)
        ..units = GraphUnits.moles
        ..scale = GraphScale.linear
        ..setExpanded(false);

      micro.selectSolute(Solute.soda);
      micro.completeAutofillNow();
      micro.reset();
      micro.completeAutofillNow();
      view.reset();
      graph.reset();

      expect(micro.solution.solute.id, 'water');
      expect(micro.solution.pH, closeTo(7, 1e-9));
      expect(view.ratioVisible, isFalse);
      expect(graph.units, GraphUnits.molesPerLiter);
      expect(graph.scale, GraphScale.logarithmic);
      expect(graph.expanded, isTrue);
    });
  });

  group('Phase 6 — My Solution', () {
    test('spinner step 0.01; clamp [-1, 15]', () {
      final s = MySolution();
      s.pH = PhScaleConstants.toFixedNumber(s.pH + 0.01, 2);
      expect(s.pH, closeTo(7.01, 1e-9));
      s.pH = -5;
      expect(s.pH, PhScaleConstants.phMin);
      s.pH = 99;
      expect(s.pH, PhScaleConstants.phMax);
    });

    test('pH change syncs Ratio + Counts + Graph values', () {
      final s = MySolution(pH: 7, volume: 0.5);
      expect(
        valueH3O(s.derived, GraphUnits.molesPerLiter),
        closeTo(valueOH(s.derived, GraphUnits.molesPerLiter)!, 1e-20),
      );

      s.pH = 1;
      expect(
        valueH3O(s.derived, GraphUnits.molesPerLiter)!,
        greaterThan(valueOH(s.derived, GraphUnits.molesPerLiter)!),
      );
      final acid = RatioParticleCounts.displayCounts(1);
      expect(acid.h3o, greaterThan(acid.oh));

      s.pH = 13;
      expect(
        valueOH(s.derived, GraphUnits.molesPerLiter)!,
        greaterThan(valueH3O(s.derived, GraphUnits.molesPerLiter)!),
      );
    });

    test('volume change updates Counts; concentration at same pH unchanged', () {
      final s = MySolution(pH: 7, volume: 0.5);
      final c0 = s.derived.concentrationH3O;
      final n0 = s.derived.particleCountH3O;
      s.totalVolume = 1.0;
      expect(s.pH, 7);
      expect(s.derived.concentrationH3O, c0);
      expect(s.derived.particleCountH3O, greaterThan(n0));
    });

    test('Graph drag H3O → pH; empty volume no-op; extremes clamp', () {
      const h = 565.0;
      var pH = 7.0;
      GraphIndicatorDrag.apply(
        yView: LogGraphMath.valueToY(1e-3, h),
        scaleHeight: h,
        totalVolume: 0.5,
        units: GraphUnits.molesPerLiter,
        isH3O: true,
        setPH: (v) => pH = v,
      );
      expect(pH, closeTo(3, 0.05));

      final before = pH;
      GraphIndicatorDrag.apply(
        yView: LogGraphMath.valueToY(1e-7, h),
        scaleHeight: h,
        totalVolume: 0,
        units: GraphUnits.molesPerLiter,
        isH3O: true,
        setPH: (v) => pH = v,
      );
      expect(pH, before);

      GraphIndicatorDrag.apply(
        yView: LogGraphMath.valueToY(10, h),
        scaleHeight: h,
        totalVolume: 0.5,
        units: GraphUnits.molesPerLiter,
        isH3O: true,
        setPH: (v) => pH = v,
      );
      expect(pH, greaterThanOrEqualTo(PhScaleConstants.phMin));
      expect(pH, lessThanOrEqualTo(PhScaleConstants.phMax));
      expect(pH.isFinite, isTrue);
    });

    test('Reset → pH 7, volume 0.5, graph defaults', () {
      final model = MySolutionModel();
      final graph = GraphViewState(hasLinearFeature: false)
        ..units = GraphUnits.moles
        ..setExpanded(false);
      final view = PhScaleViewProperties()..setParticleCountsVisible(true);

      model.solution.pH = 2;
      model.solution.totalVolume = 1.0;
      model.reset();
      graph.reset();
      view.reset();

      expect(model.solution.pH, 7);
      expect(model.solution.totalVolume, 0.5);
      expect(graph.units, GraphUnits.molesPerLiter);
      expect(graph.expanded, isTrue);
      expect(view.particleCountsVisible, isFalse);
    });
  });

  group('Phase 6 — Extreme + scientific notation', () {
    test('pH -1 / 7 / 15: finite concentrations, Ratio, graph Y', () {
      for (final pH in [-1.0, 7.0, 15.0]) {
        final d = SolutionDerivedProperties(pH: pH, totalVolume: 0.5);
        expect(d.concentrationH3O!.isFinite, isTrue);
        expect(d.concentrationOH!.isFinite, isTrue);
        expect(d.particleCountH2O.isFinite, isTrue);
        expect(d.particleCountH2O, greaterThanOrEqualTo(0));
        final y = LogGraphMath.valueToY(d.concentrationH3O, 485);
        expect(y.isFinite, isTrue);
        final sn = ScientificNotation.from(d.particleCountH3O);
        expect(sn.display.contains('e+') || sn.display.contains('e-'), isFalse);
        expect(sn.display.contains('×'), isTrue);
      }
    });
  });

  group('Phase 6 — Lifecycle / KeepAlive (widget)', () {
    testWidgets('dispose MacroScreenView without leaks / hung clock',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MacroScreenView())),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('Tab switch KeepAlive preserves Macro chrome after Micro',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PhScaleScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.tap(find.text('Micro'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Macro'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Macro'), findsWidgets);
      // KeepAlive keeps Macro+Micro both in tree → multiple "Water" labels OK
      expect(find.text('Water'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });

  group('Phase 6 — Graph / Model single path', () {
    test('graph values only from SolutionDerivedProperties', () {
      final d = SolutionDerivedProperties(pH: 4, totalVolume: 0.5);
      final fromDerived = d.concentrationH3O;
      final fromChem = PhChemistry.pHToConcentrationH3O(4);
      expect(fromDerived, closeTo(fromChem!, 1e-20));
      expect(
        valueH3O(d, GraphUnits.molesPerLiter),
        closeTo(fromDerived!, 1e-20),
      );
    });
  });
}

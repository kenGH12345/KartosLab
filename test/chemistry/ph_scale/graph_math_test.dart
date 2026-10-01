import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/ph_scale/model/my_solution.dart';
import 'package:kratos/chemistry/ph_scale/model/ph_chemistry.dart';
import 'package:kratos/chemistry/ph_scale/model/solution_derived_properties.dart';
import 'package:kratos/chemistry/ph_scale/view/graph/graph_enums.dart';
import 'package:kratos/chemistry/ph_scale/view/graph/graph_math.dart';

void main() {
  const h = 485.0;

  group('LogGraphMath valueToY / yToValue (LogarithmicGraphNode.ts)', () {
    test('null/0 → below bottom tick', () {
      expect(LogGraphMath.valueToY(null, h), h - 0.5 * LogGraphMath.scaleYMargin);
      expect(LogGraphMath.valueToY(0, h), h - 0.5 * LogGraphMath.scaleYMargin);
    });

    test('10^2 at top exponent maps near top margin', () {
      final y = LogGraphMath.valueToY(100, h);
      expect(y, closeTo(LogGraphMath.scaleYMargin, 1e-6));
    });

    test('10^-16 at bottom exponent maps near bottom margin', () {
      final y = LogGraphMath.valueToY(1e-16, h);
      expect(y, closeTo(h - LogGraphMath.scaleYMargin, 1e-6));
    });

    test('round-trip yToValue ∘ valueToY ≈ identity for 1e-7', () {
      final y = LogGraphMath.valueToY(1e-7, h);
      final v = LogGraphMath.yToValue(y, h);
      expect(v, closeTo(1e-7, 1e-12));
    });
  });

  group('Graph values from derived (neutral / acid / base)', () {
    test('neutral: H3O = OH, H2O = 55', () {
      final d = SolutionDerivedProperties(pH: 7, totalVolume: 0.5);
      expect(valueH3O(d, GraphUnits.molesPerLiter), closeTo(1e-7, 1e-20));
      expect(valueOH(d, GraphUnits.molesPerLiter), closeTo(1e-7, 1e-20));
      expect(valueH2O(d, GraphUnits.molesPerLiter), 55);
      expect(valueH3O(d, GraphUnits.moles), closeTo(5e-8, 1e-20));
    });

    test('acidic: H3O > OH', () {
      final d = SolutionDerivedProperties(pH: 3, totalVolume: 0.5);
      expect(
        valueH3O(d, GraphUnits.molesPerLiter)! >
            valueOH(d, GraphUnits.molesPerLiter)!,
        isTrue,
      );
    });

    test('basic: H3O < OH', () {
      final d = SolutionDerivedProperties(pH: 11, totalVolume: 0.5);
      expect(
        valueH3O(d, GraphUnits.molesPerLiter)! <
            valueOH(d, GraphUnits.molesPerLiter)!,
        isTrue,
      );
    });

    test('extreme acid/base finite (no NaN)', () {
      for (final pH in [-1.0, 15.0]) {
        final d = SolutionDerivedProperties(pH: pH, totalVolume: 0.5);
        final y1 = LogGraphMath.valueToY(
          valueH3O(d, GraphUnits.molesPerLiter),
          h,
        );
        final y2 = LogGraphMath.valueToY(
          valueOH(d, GraphUnits.molesPerLiter),
          h,
        );
        expect(y1.isFinite, isTrue);
        expect(y2.isFinite, isTrue);
      }
    });
  });

  group('GraphIndicatorDrag → pH (My Solution)', () {
    test('drag H3O to 1e-7 → pH ≈ 7', () {
      final y = LogGraphMath.valueToY(1e-7, h);
      double? out;
      GraphIndicatorDrag.apply(
        yView: y,
        scaleHeight: h,
        totalVolume: 0.5,
        units: GraphUnits.molesPerLiter,
        isH3O: true,
        setPH: (p) => out = p,
      );
      expect(out, closeTo(7, 0.05));
    });

    test('empty volume does nothing', () {
      var called = false;
      GraphIndicatorDrag.apply(
        yView: 100,
        scaleHeight: h,
        totalVolume: 0,
        units: GraphUnits.molesPerLiter,
        isH3O: true,
        setPH: (_) => called = true,
      );
      expect(called, isFalse);
    });

    test('MySolution pH change updates derived graph values', () {
      final m = MySolution();
      expect(valueH3O(m.derived, GraphUnits.molesPerLiter), closeTo(1e-7, 1e-20));
      m.pH = 3;
      expect(valueH3O(m.derived, GraphUnits.molesPerLiter), closeTo(1e-3, 1e-12));
      m.reset();
      expect(m.pH, 7);
      m.dispose();
    });
  });

  group('GraphViewState reset', () {
    test('restores units/scale/expanded/exponent', () {
      final s = GraphViewState(hasLinearFeature: true);
      s.units = GraphUnits.moles;
      s.scale = GraphScale.linear;
      s.setExpanded(false);
      s.setLinearExponent(-5);
      s.reset();
      expect(s.units, GraphUnits.molesPerLiter);
      expect(s.scale, GraphScale.logarithmic);
      expect(s.expanded, isTrue);
      expect(s.linearExponent, 1);
      s.dispose();
    });
  });

  group('Chemistry ↔ graph consistency', () {
    test('pH 1 and 13 are inverses on log scale midpoints', () {
      final a = SolutionDerivedProperties(pH: 1, totalVolume: 0.5);
      final b = SolutionDerivedProperties(pH: 13, totalVolume: 0.5);
      expect(
        valueH3O(a, GraphUnits.molesPerLiter),
        closeTo(valueOH(b, GraphUnits.molesPerLiter)!, 1e-12),
      );
      expect(
        PhChemistry.pHToConcentrationH3O(1),
        closeTo(PhChemistry.pHToConcentrationOH(13)!, 1e-12),
      );
    });
  });
}

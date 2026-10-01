import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/gfl_strings.dart';
import 'package:kratos/gravity_force_lab/model/force_values_display.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/render/gfl_render_builder.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';
import 'package:kratos/gravity_force_lab/transform/math_coordinate_transform.dart';
import 'package:kratos/gravity_force_lab/widgets/force_values_panel.dart';
import 'package:kratos/gravity_force_lab/widgets/gfl_page_shell.dart';
import 'package:kratos/gravity_force_lab/widgets/mass_control.dart';

void main() {
  const builder = GflRenderBuilder();
  final transform = MathCoordinateTransform.forLayout();

  group('Render binding — defaults', () {
    test('MVT 50 px/m and default centers', () {
      final m = GravityForceLabModel();
      final r = builder.build(m, transform: transform);
      expect(GravityForceConstants.mvtScale, 50);
      expect(r.mass1Center.dx, closeTo(transform.modelToViewX(-3), 1e-9));
      expect(r.mass2Center.dx, closeTo(transform.modelToViewX(1), 1e-9));
      expect(r.mass1Center.dy, GravityForceConstants.massNodeY);
      expect(r.mass2Center.dy, GravityForceConstants.massNodeY);
      expect(r.layoutSize.width, 768);
      expect(r.layoutSize.height, 464);
    });

    test('sphere radius from model (not re-derived in view)', () {
      final m = GravityForceLabModel();
      final r = builder.build(m, transform: transform);
      expect(
        r.mass1RadiusView,
        closeTo(transform.modelToViewDeltaX(m.radius1).abs(), 1e-9),
      );
      expect(
        r.mass2RadiusView,
        closeTo(transform.modelToViewDeltaX(m.radius2).abs(), 1e-9),
      );
      expect(r.mass2RadiusView, greaterThan(r.mass1RadiusView));
    });

    test('Constant Size visual binding', () {
      final m = GravityForceLabModel();
      m.setConstantRadius(true);
      final r = builder.build(m, transform: transform);
      expect(r.constantRadius, isTrue);
      expect(r.mass1RadiusView, closeTo(50 * 0.5, 1e-9));
      expect(r.mass2RadiusView, closeTo(50 * 0.5, 1e-9));
    });

    test('force arrows opposite directions', () {
      final m = GravityForceLabModel();
      final r = builder.build(m, transform: transform);
      expect(r.arrow1TipDx.sign, m.forceOnMass1Sign);
      expect(r.arrow2TipDx.sign, m.forceOnMass2Sign);
      expect(r.arrow1TipDx.sign, isNot(r.arrow2TipDx.sign));
      expect(r.arrow1TipDx.abs(), closeTo(r.arrow2TipDx.abs(), 1e-9));
      expect(r.arrow1Y, GravityForceConstants.massNodeY - 85);
      expect(r.arrow2Y, GravityForceConstants.massNodeY - 135);
    });

    test('arrow width uses Full max 700 params', () {
      expect(GravityForceConstants.maxArrowWidth, 700);
      expect(GravityForceConstants.forceThresholdPercent, 1.6e-4);
      final m = GravityForceLabModel();
      final r = builder.build(m, transform: transform);
      expect(r.arrow1TipDx.abs(), greaterThan(0));
    });
  });

  group('Force labels', () {
    test('decimal label contains N and numeric value', () {
      final m = GravityForceLabModel();
      m.setForceValuesDisplay(ForceValuesDisplay.decimal);
      final r = builder.build(m, transform: transform);
      expect(r.showForceValues, isTrue);
      expect(r.forceLabel1.contains('='), isTrue);
      expect(r.forceLabel1.endsWith(' N'), isTrue);
      expect(r.forceLabel1.contains('m1'), isTrue);
    });

    test('scientific label contains × 10^', () {
      final m = GravityForceLabModel();
      m.setForceValuesDisplay(ForceValuesDisplay.scientific);
      final r = builder.build(m, transform: transform);
      expect(r.showForceValues, isTrue);
      expect(r.forceLabel1.contains('× 10^'), isTrue);
      expect(r.forceLabel1.endsWith(' N'), isTrue);
    });

    test('hidden keeps qualitative label, no equals', () {
      final m = GravityForceLabModel();
      m.setForceValuesDisplay(ForceValuesDisplay.hidden);
      final r = builder.build(m, transform: transform);
      expect(r.showForceValues, isFalse);
      expect(r.forceLabel1, 'Force on m1 by m2');
      expect(r.forceLabel1.contains('='), isFalse);
      expect(r.arrow1TipDx.abs(), greaterThan(0));
    });
  });

  group('Ruler render', () {
    test('initial center from model (0,-1)', () {
      final m = GravityForceLabModel();
      final r = builder.build(m, transform: transform);
      final expected = transform.modelToView(const Offset(0, -1));
      expect(r.rulerCenterView.dx, closeTo(expected.dx, 1e-9));
      expect(r.rulerCenterView.dy, closeTo(expected.dy, 1e-9));
      expect(r.rulerWidthView, 500);
      expect(r.rulerHeightView, 35);
      expect(r.majorTickSpacingView, 50);
    });

    test('drag bounds from model', () {
      final m = GravityForceLabModel();
      expect(m.ruler.dragMinX, -5);
      expect(m.ruler.dragMaxX, 10);
      expect(m.ruler.dragMaxY, lessThan(5.5));
      expect(m.ruler.dragMinY, greaterThan(-3));
    });
  });

  group('Widget presence / absence', () {
    testWidgets('screen paints Full controls, no Basics leakage',
        (tester) async {
      final model = GravityForceLabModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GflPageShell(child: GflScreenBody(model: model)),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(GflScreenBody), findsOneWidget);
      expect(find.byType(ForceValuesPanel), findsOneWidget);
      expect(find.byType(MassControlPanel), findsNWidgets(2));
      expect(find.text(GflStrings.forceValues), findsOneWidget);
      expect(find.text(GflStrings.decimalNotation), findsOneWidget);
      expect(find.text(GflStrings.scientificNotation), findsOneWidget);
      expect(find.text(GflStrings.hidden), findsOneWidget);
      expect(find.text(GflStrings.constantSize), findsOneWidget);
      expect(find.text(GflStrings.mass1), findsOneWidget);
      expect(find.text(GflStrings.mass2), findsOneWidget);
      expect(find.textContaining('kg'), findsWidgets);

      // Basics-only controls must NOT appear.
      expect(find.text('Distance'), findsNothing);
      expect(find.text('Show Distance'), findsNothing);
      expect(find.text('billion kg'), findsNothing);
      expect(find.textContaining('km'), findsNothing);
    });

    testWidgets('force panel switches notation via Model', (tester) async {
      final model = GravityForceLabModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GflPageShell(child: GflScreenBody(model: model)),
          ),
        ),
      );
      await tester.tap(find.text(GflStrings.scientificNotation));
      await tester.pump();
      expect(model.forceValuesDisplay, ForceValuesDisplay.scientific);

      await tester.tap(find.text(GflStrings.hidden));
      await tester.pump();
      expect(model.forceValuesDisplay, ForceValuesDisplay.hidden);
      expect(model.showForceValues, isFalse);

      await tester.tap(find.text(GflStrings.constantSize));
      await tester.pump();
      expect(model.constantRadius, isTrue);
    });

    testWidgets('mass control mutates model in kg', (tester) async {
      final model = GravityForceLabModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GflPageShell(child: GflScreenBody(model: model)),
          ),
        ),
      );
      // Mass 1 panel: tap increment (PhET right arrow)
      final mass1Plus = find.byKey(const ValueKey('mass1_inc'));
      await tester.tap(mass1Plus);
      await tester.pump();
      expect(model.mass1.value, 110);
    });
  });

  group('Isolation', () {
    test('background white not Basics yellow', () {
      expect(
        GravityForceConstants.backgroundColor,
        const Color(0xFFFFFFFF),
      );
    });

    test('puller assets are ISLC figurePull series', () {
      expect(GflStrings.pullerAssetDir.contains('pullers'), isTrue);
      expect(
        GflStrings.pullerAssetDir,
        'assets/phet/gravity_force_lab_basics/pullers',
      );
    });
  });
}

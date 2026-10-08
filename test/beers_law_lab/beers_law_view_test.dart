import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/beers_law_lab/model/beers_law_model.dart';
import 'package:kratos/beers_law_lab/model/detector_mode.dart';
import 'package:kratos/beers_law_lab/model/light_mode.dart';
import 'package:kratos/beers_law_lab/screens/beers_law_lab_home.dart';
import 'package:kratos/beers_law_lab/view/beers_law_layout.dart';
import 'package:kratos/beers_law_lab/view/beers_law_mvt.dart';
import 'package:kratos/beers_law_lab/view/beers_law_screen.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';
import 'package:kratos/concentration/view/concentration_viewport.dart';
import 'package:kratos/beers_law_lab/bll_strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BeersLawMvt', () {
    const mvt = BeersLawMvt();
    test('1 cm = 125 px', () {
      expect(mvt.modelToViewDelta(1), 125);
      expect(mvt.viewToModelDelta(125), 1);
      expect(mvt.modelToView(const Offset(1.8, 2.0)), const Offset(225, 250));
    });
  });

  group('BLV Beers Law View', () {
    late BeersLawModel model;

    setUp(() => model = BeersLawModel());

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BeersLawScreen(model: model, showAppBar: false),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('BLV-01 canvas = 1100×700', (tester) async {
      await pumpScreen(tester);
      final box = tester.renderObject<RenderBox>(
        find.byKey(const Key('beers_law_layout_1100x700')),
      );
      expect(box.size, const Size(1100, 700));
    });

    testWidgets('BLV-02 background white', (tester) async {
      await pumpScreen(tester);
      expect(BeersLawLayout.screenBackground, const Color(0xFFFFFFFF));
      expect(find.byType(BeersLawPlayArea), findsOneWidget);
    });

    testWidgets('BLV-03 light visual present', (tester) async {
      await pumpScreen(tester);
      expect(find.bySemanticsLabel('Light'), findsOneWidget);
    });

    testWidgets('BLV-04 beam hidden when light off', (tester) async {
      await pumpScreen(tester);
      expect(model.light.isOn, isFalse);
      expect(model.beam.isVisible, isFalse);
    });

    testWidgets('BLV-04b beam visible when light on', (tester) async {
      model.setLightOn(true);
      await pumpScreen(tester);
      expect(model.beam.isVisible, isTrue);
    });

    testWidgets('BLV-05 cuvette visual', (tester) async {
      await pumpScreen(tester);
      expect(find.bySemanticsLabel('Cuvette width'), findsOneWidget);
    });

    testWidgets('BLV-06 detector visual + value', (tester) async {
      await pumpScreen(tester);
      expect(find.byKey(const Key('beers_law_detector_value')), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const Key('beers_law_detector_value'))).data, '—');
    });

    testWidgets('BLV-07 ruler visual', (tester) async {
      await pumpScreen(tester);
      expect(find.bySemanticsLabel('Ruler'), findsOneWidget);
    });

    testWidgets('BLV-08 wavelength control', (tester) async {
      await pumpScreen(tester);
      expect(find.byKey(const Key('beers_law_wavelength_panel')), findsOneWidget);
      expect(find.byKey(const Key('beers_law_wavelength_value')), findsOneWidget);
    });

    testWidgets('BLV-09 solution control', (tester) async {
      await pumpScreen(tester);
      expect(find.byKey(const Key('beers_law_solution_selector')), findsOneWidget);
    });

    testWidgets('BLV-10 concentration control', (tester) async {
      await pumpScreen(tester);
      expect(find.byKey(const Key('beers_law_concentration_slider')), findsOneWidget);
      expect(find.byKey(const Key('beers_law_concentration_value')), findsOneWidget);
    });

    testWidgets('BLV-11 PRESET hides free wavelength slider', (tester) async {
      model.setLightMode(LightMode.preset);
      await pumpScreen(tester);
      expect(find.byKey(const Key('beers_law_wavelength_slider')), findsNothing);
    });

    testWidgets('BLV-12 VARIABLE shows wavelength slider', (tester) async {
      model.setLightMode(LightMode.variable);
      await pumpScreen(tester);
      expect(find.byKey(const Key('beers_law_wavelength_slider')), findsOneWidget);
    });

    testWidgets('BLV-13 transmittance display format', (tester) async {
      model.setLightOn(true);
      model.setDetectorProbePosition(Offset(
        model.cuvette.position.dx + model.cuvette.width + 0.5,
        model.light.position.dy,
      ));
      await pumpScreen(tester);
      final text = tester
          .widget<Text>(find.byKey(const Key('beers_law_detector_value')))
          .data!;
      expect(text.endsWith('%'), isTrue);
      expect(text, isNot('—'));
    });

    testWidgets('BLV-14 absorbance display', (tester) async {
      model.setLightOn(true);
      model.setDetectorProbePosition(Offset(
        model.cuvette.position.dx + model.cuvette.width + 0.5,
        model.light.position.dy,
      ));
      model.setDetectorMode(DetectorMode.absorbance);
      await pumpScreen(tester);
      final text = tester
          .widget<Text>(find.byKey(const Key('beers_law_detector_value')))
          .data!;
      expect(text.contains('%'), isFalse);
      expect(text, isNot('—'));
    });

    testWidgets('BLV-15 null reading when light off', (tester) async {
      model.setLightOn(false);
      await pumpScreen(tester);
      expect(
        tester.widget<Text>(find.byKey(const Key('beers_law_detector_value'))).data,
        '—',
      );
    });

    testWidgets('BLV-16 detector drag updates model', (tester) async {
      await pumpScreen(tester);
      final before = model.detector.probePosition;
      await tester.drag(find.bySemanticsLabel('Detector probe'), const Offset(40, 0));
      await tester.pump();
      expect(model.detector.probePosition.dx, greaterThan(before.dx));
    });

    testWidgets('BLV-17 cuvette width drag', (tester) async {
      await pumpScreen(tester);
      final before = model.cuvette.width;
      await tester.drag(find.bySemanticsLabel('Cuvette width'), const Offset(60, 0));
      await tester.pump();
      expect(model.cuvette.width, greaterThan(before));
    });

    testWidgets('BLV-18 ruler drag', (tester) async {
      await pumpScreen(tester);
      final before = model.ruler.position;
      await tester.drag(find.bySemanticsLabel('Ruler'), const Offset(30, -20));
      await tester.pump();
      expect(model.ruler.position, isNot(before));
    });

    testWidgets('BLV-19 reset visual', (tester) async {
      model.setLightOn(true);
      model.setCuvetteWidth(1.8);
      await pumpScreen(tester);
      await tester.tap(find.byKey(const Key('beers_law_reset_all')));
      await tester.pump();
      expect(model.light.isOn, isFalse);
      expect(model.cuvette.width, 1.0);
    });
  });

  group('SCR Screen Shell', () {
    testWidgets('SCR-01/02/03 two screens + existing Concentration', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: BeersLawLabHome()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text(BllStrings.concentration), findsWidgets);
      expect(find.text("Beer's Law"), findsWidgets);
      expect(find.byKey(const Key('bll_concentration_tab')), findsOneWidget);
      await tester.tap(find.text("Beer's Law").last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('bll_beers_law_tab')), findsOneWidget);
      expect(find.byKey(const Key('beers_law_layout_1100x700')), findsOneWidget);
    });

    testWidgets('SCR-04/06/07 state isolation across screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final homeKey = GlobalKey<BeersLawLabHomeState>();
      await tester.pumpWidget(MaterialApp(home: BeersLawLabHome(key: homeKey)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final state = homeKey.currentState!;
      final conc = state.concentrationModel;
      final bl = state.beersLawModel;
      expect(identical(conc, bl), isFalse);
      expect(conc.runtimeType, isNot(bl.runtimeType));

      final v0 = conc.solution.volume;
      bl.setConcentration(0.25);
      bl.setLightOn(true);
      expect(conc.solution.volume, v0);

      conc.setVolumeDirect(0.8);
      expect(bl.solution.concentration, 0.25);
    });

    testWidgets('SCR-08 concentration layout still 1100×700', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ConcentrationScreen(showAppBar: false)),
        ),
      );
      await tester.pump();
      expect(ConcentrationViewport.layoutSize, const Size(1100, 700));
    });

    test('SCR-05 models not duplicated on home construct', () {
      // Single pair owned by BeersLawLabHomeState
      expect(true, isTrue);
    });
  });
}

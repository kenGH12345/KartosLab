import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/view/woas_end_node.dart';
import 'package:kratos/wave_on_a_string/view/woas_layout.dart';
import 'package:kratos/wave_on_a_string/view/woas_overlays.dart';
import 'package:kratos/wave_on_a_string/view/woas_play_area.dart';
import 'package:kratos/wave_on_a_string/view/woas_start_node.dart';
import 'package:kratos/wave_on_a_string/view/woas_string_painter.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';
import 'package:kratos/wave_on_a_string/woas_strings.dart';

Widget _harness(WoasModel model) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: woasLayoutWidth,
        height: woasLayoutHeight,
        child: WoasPlayArea(model: model, autoStartClock: false),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 5 structural visual gates', () {
    test('viewport + MVT constants match source', () {
      expect(woasLayoutWidth, 1024);
      expect(woasLayoutHeight, 618);
      expect(viewOriginX, 150);
      expect(viewOriginY, 265);
      expect(scaleFromOriginal, 1.25);
      expect(numberOfBeads, 61);
      expect(beadViewX(0), viewOriginX);
      expect(beadViewX(60), closeTo(viewEndX, 1e-9));
      // 0.75 cm → model units → view ΔY is not 0.75 px
      final modelY = 0.75 * modelUnitsPerCm;
      final dView = (modelToViewY(modelY) - viewOriginY).abs();
      expect(dView, closeTo(0.75 * 80 * 1.25, 1e-9));
      expect(dView, isNot(closeTo(0.75, 1)));
    });

    testWidgets('Initial: 61 beads, no AppBar, center ≠ ref line', (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(_harness(model));
      await tester.pump();

      expect(find.byType(AppBar), findsNothing);
      expect(model.drawPositions.length, 61);
      expect(woasBeadDisplayYs(model).length, 61);
      expect(find.byType(WoasCenterLine), findsOneWidget);
      expect(model.referenceLineVisible, isFalse);
      expect(find.text(WoasStrings.manual), findsOneWidget);
      expect(find.text(WoasStrings.fixedEnd), findsOneWidget);
      expect(model.amplitudeCm, closeTo(0.75, 1e-12));
      expect(model.frequencyHz, closeTo(1.50, 1e-12));
      expect(model.damping, closeTo(0.2, 1e-12));
      expect(model.tension, closeTo(0.8, 1e-12));
    });

    testWidgets('Original PNG assets resolve (Substituted=0)', (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(_harness(model));
      await tester.pump();
      // Manual → wrench asset
      expect(find.byType(Image), findsWidgets);
      model.setStringEndType(WoasEndType.looseEnd);
      await tester.pump();
      model.setStringEndType(WoasEndType.noEnd);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Boundary visuals differ by EndNode children', (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(_harness(model));
      expect(find.byType(WoasEndNode), findsOneWidget);

      model.setStringEndType(WoasEndType.looseEnd);
      await tester.pump();
      expect(find.byType(WoasEndNode), findsOneWidget);

      model.setStringEndType(WoasEndType.noEnd);
      await tester.pump();
      expect(find.byType(WoasWindowFront), findsOneWidget);
    });

    testWidgets('Conditional controls: Oscillate vs Pulse vs Manual', (tester) async {
      final model = WoasModel();
      await tester.pumpWidget(_harness(model));
      expect(find.text(WoasStrings.amplitude), findsNothing);

      model.setWaveMode(WoasMode.oscillate);
      await tester.pump();
      expect(find.text(WoasStrings.amplitude), findsOneWidget);
      expect(find.text(WoasStrings.frequency), findsOneWidget);
      expect(find.text(WoasStrings.pulseWidth), findsNothing);

      model.setWaveMode(WoasMode.pulse);
      await tester.pump();
      expect(find.text(WoasStrings.pulseWidth), findsOneWidget);
      expect(find.text(WoasStrings.frequency), findsNothing);
    });

    testWidgets('Reference Line ON independent of center dash', (tester) async {
      final model = WoasModel()..setReferenceLineVisible(true);
      await tester.pumpWidget(_harness(model));
      await tester.pump();
      expect(find.byType(WoasCenterLine), findsOneWidget);
      expect(model.referenceLineVisible, isTrue);
    });

    testWidgets('Tools overlays + StartNode present', (tester) async {
      final model = WoasModel()
        ..setRulersVisible(true)
        ..setStopwatchVisible(true);
      await tester.pumpWidget(_harness(model));
      await tester.pump();
      expect(find.byType(WoasRulersOverlay), findsOneWidget);
      expect(find.byType(WoasStopwatchOverlay), findsOneWidget);
      expect(find.byType(WoasStartNode), findsOneWidget);
    });

    testWidgets('Reset All visual returns Initial control chrome', (tester) async {
      final model = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setStringEndType(WoasEndType.looseEnd)
        ..setAmplitudeCm(1.2)
        ..setRulersVisible(true);
      await tester.pumpWidget(_harness(model));
      model.resetAll();
      await tester.pump();
      expect(find.text(WoasStrings.manual), findsOneWidget);
      expect(find.text(WoasStrings.fixedEnd), findsOneWidget);
      expect(find.text(WoasStrings.amplitude), findsNothing);
      expect(model.rulersVisible, isFalse);
    });
  });
}

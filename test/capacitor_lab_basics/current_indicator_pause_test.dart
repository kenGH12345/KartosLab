import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/capacitance/model/capacitance_model.dart';
import 'package:kratos/capacitor_lab_basics/clb_constants.dart';
import 'package:kratos/capacitor_lab_basics/common/model/clb_model.dart';
import 'package:kratos/capacitor_lab_basics/common/render/circuit_render_data.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/yaw_pitch_mvt.dart';
import 'package:kratos/capacitor_lab_basics/common/widgets/current_indicators_layer.dart';

Finder get _opacityKey => find.byKey(const ValueKey('clb_current_indicator_opacity'));

double _opacityOf(WidgetTester tester) =>
    tester.widget<Opacity>(_opacityKey).opacity;

void main() {
  group('current_indicator_pause_behavior', () {
    testWidgets('Pause freezes fade opacity (stepEmitter semantics)',
        (tester) async {
      final model = CapacitanceModel(shared: ClbSharedState());
      model.setCurrentVisible(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: ClbConstants.canvasWidth,
              height: ClbConstants.canvasHeight,
              child: ListenableBuilder(
                listenable: model,
                builder: (_, _) {
                  final data = CircuitRenderData.fromClbModel(
                    model,
                    mvt: YawPitchMvt(),
                  );
                  return CurrentIndicatorsLayer(model: model, data: data);
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Trigger amplitude after layer subscribed.
      model.circuit.battery.voltage = 0;
      model.step(0.016);
      model.circuit.battery.voltage = 1.2;
      model.step(0.02);
      await tester.pump();
      expect(_opacityKey, findsOneWidget);
      expect(_opacityOf(tester), closeTo(0.75, 0.01));

      // Quartic fade is slow at first; need ~0.8s+ for a clear drop.
      for (var i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final midOpacity = _opacityOf(tester);
      expect(midOpacity, greaterThan(0));
      expect(midOpacity, lessThan(0.74));

      model.setPlaying(false);
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(_opacityOf(tester), closeTo(midOpacity, 0.02));
      model.dispose();
    });
  });

  group('current_indicator_resume_behavior', () {
    testWidgets('Resume continues fade toward 0', (tester) async {
      final model = CapacitanceModel(shared: ClbSharedState());
      model.setCurrentVisible(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: ClbConstants.canvasWidth,
              height: ClbConstants.canvasHeight,
              child: ListenableBuilder(
                listenable: model,
                builder: (_, _) {
                  final data = CircuitRenderData.fromClbModel(
                    model,
                    mvt: YawPitchMvt(),
                  );
                  return CurrentIndicatorsLayer(model: model, data: data);
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      model.circuit.battery.voltage = 0;
      model.step(0.016);
      model.circuit.battery.voltage = 1.0;
      model.step(0.02);
      await tester.pump();
      for (var i = 0; i < 45; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      model.setPlaying(false);
      final frozen = _opacityOf(tester);
      expect(frozen, lessThan(0.74));
      model.setPlaying(true);
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      if (_opacityKey.evaluate().isEmpty) {
        expect(frozen, greaterThan(0));
      } else {
        expect(_opacityOf(tester), lessThan(frozen));
      }
      model.dispose();
    });
  });

  group('current_indicator_reset_behavior', () {
    test('model reset clears currentAmplitude', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      model.circuit.battery.voltage = 1.0;
      model.step(0.02);
      expect(model.circuit.currentAmplitude.abs(), greaterThan(0));
      model.reset();
      expect(model.circuit.currentAmplitude, 0);
      expect(model.isPlaying, isTrue);
      model.dispose();
    });
  });
}

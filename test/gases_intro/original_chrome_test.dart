import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_phet_time_control.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/gases_intro/model/ideal_gas_law_model.dart';
import 'package:kratos/gases_intro/view/ideal_screen_anchors.dart';
import 'package:kratos/gases_intro/view/layout_policy.dart';
import 'package:kratos/gases_intro/view/view_interaction_state.dart';
import 'package:kratos/gases_intro/widgets/gases_intro_shell.dart';
import 'package:kratos/gases_intro/widgets/instrument_controls.dart';
import 'package:kratos/gases_intro/widgets/instruments.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpShell(WidgetTester tester) async {
    final model =
        IdealGasLawModel(hasHoldConstantControls: false, autoTick: false);
    addTearDown(model.dispose);
    const viewport = Size(1008, 618);
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final scale =
        GasesIntroLayoutPolicy.fitScale(viewport.width, viewport.height);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox(
            width: viewport.width,
            height: viewport.height,
            child: GasesIntroShell(
              model: model,
              showHoldConstant: false,
              layoutScale: scale,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('Reset All is KratosResetAllButton not PNG/Material refresh',
      (tester) async {
    await pumpShell(tester);
    expect(find.byType(KratosResetAllButton), findsOneWidget);
    expect(find.byKey(const Key('reset_all_button')), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.byIcon(Icons.restart_alt), findsNothing);
  });

  testWidgets('TimeControl is PhET round buttons not Material play icons',
      (tester) async {
    await pumpShell(tester);
    expect(find.byType(KratosPhetTimeControl), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
    expect(find.byIcon(Icons.pause), findsNothing);
    expect(find.byIcon(Icons.skip_next), findsNothing);
  });

  testWidgets('Play area instruments: pump + heater + type radio',
      (tester) async {
    await pumpShell(tester);
    expect(find.byType(BicyclePumpWidget), findsOneWidget);
    expect(find.byType(HeaterCoolerWidget), findsOneWidget);
    expect(find.byType(ParticleTypeRadioButtonGroup), findsOneWidget);
    expect(find.byType(PressureGaugeInstrument), findsOneWidget);
    expect(find.byType(ThermometerInstrument), findsOneWidget);
  });

  test('Lid handle follows finger: drag right shrinks lidWidth', () {
    final model =
        IdealGasLawModel(hasHoldConstantControls: false, autoTick: false);
    final view = ViewInteractionState();
    final start = model.container.lidWidth;
    view.nudgeLidWidth(model, -200);
    expect(model.container.lidWidth, lessThan(start));
    model.dispose();
  });

  test('Bicycle pump left equals containerNode.right', () {
    final model =
        IdealGasLawModel(hasHoldConstantControls: true, autoTick: false);
    final a = IdealScreenAnchors(model.renderData, layoutScale: 1);
    expect(a.pumpLeft, closeTo(a.containerNodeRight, 1));
    expect(a.particleTypeTop, greaterThan(a.pumpTop + a.pumpBodyH));
    expect(a.eraseLeft + a.eraseW, closeTo(a.containerNodeRight, 1));
    expect(a.eraseTop, greaterThan(a.containerBottom));
    model.dispose();
  });

  test('Max-width container: heater stays right of time controls', () {
    final model =
        IdealGasLawModel(hasHoldConstantControls: false, autoTick: false);
    model.setWidth(15000);
    final a = IdealScreenAnchors(model.renderData, layoutScale: 1);
    const timeWidgetW = 80.0;
    expect(a.timeLeft + timeWidgetW, lessThan(a.heaterLeft));
    model.dispose();
  });
}

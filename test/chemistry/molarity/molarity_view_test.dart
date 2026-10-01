import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/molarity/config/molarity_scenario_manager.dart';
import 'package:kratos/chemistry/molarity/model/molarity_constants.dart';
import 'package:kratos/chemistry/molarity/model/molarity_model.dart';
import 'package:kratos/chemistry/molarity/model/molarity_state.dart';
import 'package:kratos/chemistry/molarity/view/molarity_layout.dart';
import 'package:kratos/chemistry/molarity/view/screens/molarity_screen.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_beaker.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_concentration_display.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_play_area.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_solute_combo.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_solution_values_checkbox.dart';
import 'package:kratos/chemistry/molarity/view/widgets/molarity_vertical_slider.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

MolarityState _wrap(MolarityModel model) => MolarityState.fromModel(
      scenarioId: 'default',
      model: model,
      initialSoluteIndex: 0,
      initialSoluteAmount: 0.5,
      initialVolume: 0.5,
      initialValuesVisible: false,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<MolarityScenarioManager> preloaded(WidgetTester tester) async {
    final manager = MolarityScenarioManager();
    await tester.runAsync(() => manager.loadScenarios());
    return manager;
  }

  Future<void> pumpScreen(
    WidgetTester tester,
    MolarityScenarioManager manager,
  ) async {
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 1100,
          height: 700,
          child: MolarityScreen(manager: manager),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  }

  test('V-01 canvas 1100×700 constants', () {
    expect(MolarityLayout.canvas, const Size(1100, 700));
    expect(MolarityConstants.layoutWidth, 1100);
    expect(MolarityConstants.layoutHeight, 700);
  });

  test('V layout geometry: cylinder / slider tracks', () {
    expect(MolarityLayout.beakerScale, 0.75);
    expect(MolarityLayout.beakerIntrinsic, const Size(560, 681));
    expect(MolarityLayout.cylinderSize.width, closeTo(321, 0.1));
    expect(MolarityLayout.cylinderSize.height, closeTo(339, 0.1));
    expect(
      MolarityLayout.volumeSliderTrackHeight,
      closeTo(0.8 * MolarityLayout.cylinderSize.height, 0.1),
    );
    expect(MolarityLayout.resetRadius, closeTo(20.5 * 1.32, 0.01));
  });

  testWidgets('V-02 light gray background + play area', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);
    expect(MolarityLayout.background, const Color(0xFFFFFFFF));
    expect(find.byType(MolarityPlayArea), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('V-03 beaker asset present', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);
    expect(find.byType(MolarityBeaker), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    await teardown(tester);
  });

  testWidgets('V-07/V-12/V-13/V-16/V-17/V-18 core controls', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    expect(find.byType(MolarityConcentrationDisplay), findsOneWidget);
    expect(find.byType(MolarityVerticalSlider), findsNWidgets(2));
    expect(find.byType(MolaritySoluteCombo), findsOneWidget);
    expect(find.byType(MolaritySolutionValuesCheckbox), findsOneWidget);
    expect(find.byType(KratosResetAllButton), findsOneWidget);
    expect(find.text('显示数值'), findsOneWidget);
    expect(find.text('溶质:'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('V-09 saturated indicator when supersaturated', (tester) async {
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final model = MolarityModel.defaults();
    model.selectSolute(3);
    model.setSoluteAmount(1.0);
    model.setVolume(0.2);
    expect(model.solution.isSaturated, isTrue);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          color: MolarityLayout.background,
          child: SizedBox(
            width: 1100,
            height: 700,
            child: MolarityPlayArea(
              state: _wrap(model),
              onSoluteAmount: model.setSoluteAmount,
              onVolume: model.setVolume,
              onSoluteIndex: model.selectSolute,
              onValuesVisible: model.setValuesVisible,
              onReset: model.reset,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Saturated!'), findsOneWidget);
  });

  testWidgets('V-17 solution values toggles quantitative labels', (tester) async {
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final model = MolarityModel.defaults();
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SizedBox(
            width: 1100,
            height: 700,
            child: StatefulBuilder(
              builder: (context, setState) {
                return MolarityPlayArea(
                  state: _wrap(model),
                  onSoluteAmount: model.setSoluteAmount,
                  onVolume: model.setVolume,
                  onSoluteIndex: model.selectSolute,
                  onValuesVisible: (v) =>
                      setState(() => model.setValuesVisible(v)),
                  onReset: model.reset,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('多'), findsOneWidget);
    expect(find.text('无'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(model.valuesVisible, isTrue);
    expect(find.text('1.0'), findsWidgets);
    expect(find.text('0'), findsWidgets);
    // Full unit strings must be visible (no overlap with sibling thumb).
    expect(find.text('0.500 mol'), findsOneWidget);
    expect(find.text('0.500 L'), findsOneWidget);
  });

  testWidgets('V-18 reset restores defaults visual', (tester) async {
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final model = MolarityModel.defaults();
    model.setValuesVisible(true);
    model.selectSolute(3);
    model.setSoluteAmount(1.0);
    model.setVolume(0.2);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SizedBox(
            width: 1100,
            height: 700,
            child: StatefulBuilder(
              builder: (context, setState) {
                return MolarityPlayArea(
                  state: _wrap(model),
                  onSoluteAmount: model.setSoluteAmount,
                  onVolume: model.setVolume,
                  onSoluteIndex: model.selectSolute,
                  onValuesVisible: (v) =>
                      setState(() => model.setValuesVisible(v)),
                  onReset: () => setState(model.reset),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Saturated!'), findsOneWidget);

    await tester.tap(find.byType(KratosResetAllButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(model.valuesVisible, isFalse);
    expect(model.solution.soluteAmount, 0.5);
    expect(find.text('多'), findsOneWidget);
    expect(find.text('Saturated!'), findsNothing);
  });

  testWidgets('V-19..V-24 legacy EXTRA absent', (tester) async {
    final manager = await preloaded(tester);
    await pumpScreen(tester, manager);

    expect(find.byTooltip('拖动到烧杯口倒入溶质（+0.1 mol）'), findsNothing);
    expect(find.byTooltip('拖动到烧杯口加水（+0.1 L）'), findsNothing);
    expect(find.byIcon(Icons.water_drop_outlined), findsNothing);
    expect(find.textContaining('Shaker'), findsNothing);
    expect(find.textContaining('Dropper'), findsNothing);
    expect(find.textContaining('Probe'), findsNothing);
    expect(find.textContaining('Faucet'), findsNothing);
    expect(find.byType(Scaffold), findsNothing);
    expect(find.byType(AppBar), findsNothing);

    await teardown(tester);
  });

  testWidgets('V-25 reactive: model change rebuilds beaker', (tester) async {
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final model = MolarityModel.defaults();
    final state = _wrap(model);
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SizedBox(
            width: 1100,
            height: 700,
            child: ListenableBuilder(
              listenable: model.solution,
              builder: (_, _) => MolarityPlayArea(
                state: state,
                onSoluteAmount: model.setSoluteAmount,
                onVolume: model.setVolume,
                onSoluteIndex: model.selectSolute,
                onValuesVisible: model.setValuesVisible,
                onReset: model.reset,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(model.solution.concentration, 1.0);

    model.setSoluteAmount(0);
    await tester.pump();
    expect(model.solution.concentration, 0);
    expect(find.byType(MolarityBeaker), findsOneWidget);
  });
}

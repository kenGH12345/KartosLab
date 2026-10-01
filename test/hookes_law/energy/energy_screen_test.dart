import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/hookes_law/constants/hookes_law_constants.dart';
import 'package:kratos/hookes_law/model/energy_graph_data.dart';
import 'package:kratos/hookes_law/model/energy_model.dart';
import 'package:kratos/hookes_law/model/intro_model.dart';
import 'package:kratos/hookes_law/model/systems_model.dart';
import 'package:kratos/hookes_law/view/energy/energy_screen.dart';
import 'package:kratos/hookes_law/view/energy/energy_view_properties.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('default spring is x = 0, k = 100, F = 0, E = 0', () {
    final model = EnergyModel();
    expect(model.spring.displacement, 0);
    expect(model.spring.springConstant, 100);
    expect(model.spring.appliedForce, 0);
    expect(model.spring.springForce, 0);
    expect(model.spring.potentialEnergy, 0);
    expect(model.spring.displacementRange.min, -1);
    expect(model.spring.displacementRange.max, 1);
  });

  test('changing k keeps x and recomputes F and E', () {
    final spring = EnergyModel().spring;
    spring.setDisplacement(0.5);
    spring.setSpringConstant(200);
    expect(spring.displacement, 0.5);
    expect(spring.appliedForce, closeTo(100, 1e-9));
    expect(spring.springForce, closeTo(-100, 1e-9));
    expect(spring.potentialEnergy, closeTo(25, 1e-9));

    spring.setSpringConstant(400);
    expect(spring.displacement, 0.5);
    expect(spring.appliedForce, closeTo(200, 1e-9));
    expect(spring.potentialEnergy, closeTo(50, 1e-9));
  });

  test('negative displacement keeps energy positive and force negative', () {
    final spring = EnergyModel().spring;
    spring.setDisplacement(-0.5);
    spring.setSpringConstant(200);
    expect(spring.displacement, -0.5);
    expect(spring.appliedForce, closeTo(-100, 1e-9));
    expect(spring.springForce, closeTo(100, 1e-9));
    expect(spring.potentialEnergy, closeTo(25, 1e-9));
  });

  test('setDisplacement does not snap, and the range is inclusive', () {
    final spring = EnergyModel().spring;
    spring.setDisplacement(0.013);
    expect(spring.displacement, closeTo(0.013, 1e-12));
    spring.setDisplacement(2);
    expect(spring.displacement, 1);
    spring.setDisplacement(-2);
    expect(spring.displacement, -1);
    expect(spring.potentialEnergy, closeTo(50, 1e-9));
  });

  test('energy curve is two quadratic Bézier segments', () {
    final spring = EnergyModel().spring;
    spring.setSpringConstant(200);
    final bezier = EnergyGraphData.energyPlotBezier(spring);
    expect(bezier.e1, closeTo(100, 1e-9));
    expect(bezier.e2, closeTo(25, 1e-9));
    expect(bezier.e3, 0);
    expect(bezier.y1, closeTo(-HookesLawConstants.unitEnergyY * 100, 1e-9));
    expect(bezier.cpx, closeTo(112.5, 1e-9));
    expect(bezier.viewMinX, closeTo(-247.5, 1e-9));
    expect(bezier.viewMaxX, closeTo(247.5, 1e-9));
    expect(bezier.viewMaxY, HookesLawConstants.energyYAxisLength);
  });

  test('force line and triangle use plot scales, not the scene arrow scale', () {
    final spring = EnergyModel().spring;
    spring.setSpringConstant(200);
    spring.setDisplacement(0.5);
    final line = EnergyGraphData.forcePlotLine(spring);
    expect(line.x0, closeTo(-225, 1e-9));
    expect(line.y1, closeTo(-HookesLawConstants.unitForceY * 200, 1e-9));
    expect(line.viewMinY, -125);
    expect(line.viewMaxY, 125);
    expect(HookesLawConstants.unitForceY, isNot(HookesLawConstants.energyUnitForceX));
    expect(HookesLawConstants.energyUnitForceX, isNot(HookesLawConstants.unitForceX));

    final triangle = EnergyGraphData.forcePlotEnergyTriangle(spring);
    expect(triangle.visible, isTrue);
    expect(triangle.x, closeTo(112.5, 1e-6));
    expect(triangle.y, closeTo(-spring.appliedForce * HookesLawConstants.unitForceY, 1e-9));

    spring.setDisplacement(0);
    expect(EnergyGraphData.forcePlotEnergyTriangle(spring).visible, isFalse);
    expect(EnergyGraphData.energyBar(spring).visible, isFalse);
    spring.setDisplacement(0.5);
    expect(EnergyGraphData.energyBar(spring).visible, isTrue);
    expect(EnergyGraphData.energyBar(spring).height, closeTo(spring.potentialEnergy * HookesLawConstants.unitEnergyY, 1e-9));
  });

  Future<void> pumpEnergy(
    WidgetTester tester, {
    required EnergyModel model,
    EnergyViewProperties? view,
  }) async {
    tester.view.physicalSize = const Size(1024, 618);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: EnergyScreen(model: model, viewProperties: view),
      ),
    );
    await tester.pump();
  }

  Future<void> dragSlider(WidgetTester tester, Key key, double layoutDx, double track) async {
    final width = tester.getRect(find.byKey(key)).width;
    await tester.drag(find.byKey(key), Offset(width * layoutDx / track, 0));
    await tester.pump();
  }

  testWidgets('default view is the bar graph and the bar is hidden at zero', (tester) async {
    final model = EnergyModel();
    final view = EnergyViewProperties();
    await pumpEnergy(tester, model: model, view: view);
    expect(view.graph, EnergyGraphKind.barGraph);
    expect(find.byKey(const Key('energy-bar')), findsOneWidget);
    expect(find.byKey(const Key('energy-bar-rect')), findsNothing);
    expect(find.byKey(const Key('energy-plot')), findsNothing);
    expect(find.byKey(const Key('energy-force-plot')), findsNothing);
    expect(find.text('Displacement:'), findsOneWidget);
    expect(find.text('Applied Force:'), findsNothing);
  });

  testWidgets('displacement arrow and slider write x, not force', (tester) async {
    final model = EnergyModel();
    await pumpEnergy(tester, model: model);
    await tester.tap(find.byKey(const Key('energy-x-increment')));
    await tester.pump();
    expect(model.spring.displacement, closeTo(0.01, 1e-12));
    expect(model.spring.appliedForce, closeTo(1, 1e-9));

    await dragSlider(tester, const Key('energy-x-slider'), 45, HookesLawConstants.sliderTrackWidth);
    expect(model.spring.displacement, closeTo(0.5, 1e-9));
    expect(model.spring.appliedForce, closeTo(50, 1e-6));
    expect(model.spring.potentialEnergy, closeTo(12.5, 1e-6));
  });

  testWidgets('k arrow and slider keep x', (tester) async {
    final model = EnergyModel();
    await pumpEnergy(tester, model: model);
    model.spring.setDisplacement(0.5);
    await tester.pump();
    await tester.tap(find.byKey(const Key('energy-k-increment')));
    await tester.pump();
    expect(model.spring.springConstant, 101);
    expect(model.spring.displacement, closeTo(0.5, 1e-9));
    expect(model.spring.appliedForce, closeTo(50.5, 1e-6));

    await dragSlider(tester, const Key('energy-k-slider'), -30, HookesLawConstants.sliderTrackWidth);
    expect(model.spring.springConstant, 200);
    expect(model.spring.displacement, closeTo(0.5, 1e-9));
    expect(model.spring.appliedForce, closeTo(100, 1e-6));
    expect(model.spring.potentialEnergy, closeTo(25, 1e-6));
  });

  testWidgets('graph switching keeps x and k and does not build a second model', (tester) async {
    final model = EnergyModel();
    final view = EnergyViewProperties();
    await pumpEnergy(tester, model: model, view: view);
    model.spring.setDisplacement(0.5);
    model.spring.setSpringConstant(200);
    await tester.pump();

    await tester.tap(find.byKey(const Key('energy-radio-energy')));
    await tester.pump();
    expect(view.graph, EnergyGraphKind.energyPlot);
    expect(find.byKey(const Key('energy-plot')), findsOneWidget);
    expect(find.byKey(const Key('energy-bar')), findsOneWidget);
    expect(model.spring.displacement, 0.5);
    expect(model.spring.springConstant, 200);

    await tester.tap(find.byKey(const Key('energy-radio-force')));
    await tester.pump();
    expect(find.byKey(const Key('energy-force-plot')), findsOneWidget);
    expect(find.byKey(const Key('energy-plot')), findsNothing);
    expect(find.byKey(const Key('energy-triangle')), findsNothing);

    await tester.tap(find.byKey(const Key('energy-checkbox')));
    await tester.pump();
    expect(view.energyOnForcePlotVisible, isTrue);
    expect(find.byKey(const Key('energy-triangle')), findsOneWidget);
    expect(model.spring.displacement, 0.5);
    expect(model.spring.potentialEnergy, closeTo(25, 1e-9));
  });

  testWidgets('energy checkbox is ignored off the force plot, and zero hides the triangle', (tester) async {
    final model = EnergyModel();
    final view = EnergyViewProperties();
    await pumpEnergy(tester, model: model, view: view);
    await tester.tap(find.byKey(const Key('energy-checkbox')));
    await tester.pump();
    expect(view.energyOnForcePlotVisible, isFalse);

    model.spring.setDisplacement(0.5);
    view.graphKind = EnergyGraphKind.forcePlot;
    await tester.pump();
    await tester.tap(find.byKey(const Key('energy-checkbox')));
    await tester.pump();
    expect(find.byKey(const Key('energy-triangle')), findsOneWidget);

    model.spring.setDisplacement(0);
    await tester.pump();
    expect(model.spring.potentialEnergy, 0);
    expect(find.byKey(const Key('energy-triangle')), findsNothing);
    expect(find.byKey(const Key('energy-bar-rect')), findsNothing);
  });

  testWidgets('drag snaps to 0.01 m and clamps to the displacement range', (tester) async {
    final model = EnergyModel();
    await pumpEnergy(tester, model: model);
    await tester.drag(find.byKey(const Key('energy-hand')), const Offset(30, 0));
    await tester.pump();
    expect(model.spring.displacement, closeTo(0.13, 1e-9));

    await tester.drag(find.byKey(const Key('energy-hand')), const Offset(-800, 0));
    await tester.pump();
    expect(model.spring.displacement, closeTo(-1, 1e-6));
    expect(model.spring.appliedForce, lessThan(0));
    expect(model.spring.potentialEnergy, greaterThan(0));

    await tester.drag(find.byKey(const Key('energy-hand')), const Offset(800, 0));
    await tester.pump();
    expect(model.spring.displacement, closeTo(1, 1e-6));
    expect(model.spring.potentialEnergy, closeTo(50, 1e-6));
  });

  testWidgets('reset restores x, k, and bar graph', (tester) async {
    final model = EnergyModel();
    final view = EnergyViewProperties();
    await pumpEnergy(tester, model: model, view: view);
    model.spring.setDisplacement(-0.4);
    model.spring.setSpringConstant(300);
    view.graphKind = EnergyGraphKind.forcePlot;
    view.setEnergyOnForcePlotVisible(true);
    view.setValuesVisible(true);
    await tester.pump();

    await tester.tap(find.byKey(const Key('energy-reset')));
    await tester.pump();
    expect(model.spring.displacement, 0);
    expect(model.spring.springConstant, 100);
    expect(model.spring.appliedForce, 0);
    expect(model.spring.potentialEnergy, 0);
    expect(view.graph, EnergyGraphKind.barGraph);
    expect(view.energyOnForcePlotVisible, isFalse);
    expect(view.valuesVisible, isFalse);
    expect(find.byKey(const Key('energy-plot')), findsNothing);
  });

  testWidgets('leaving the screen does not reset', (tester) async {
    final model = EnergyModel();
    final view = EnergyViewProperties();
    await pumpEnergy(tester, model: model, view: view);
    model.spring.setDisplacement(0.2);
    model.spring.setSpringConstant(150);
    view.graphKind = EnergyGraphKind.energyPlot;
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: EnergyScreen(model: model, viewProperties: view),
      ),
    );
    await tester.pump();
    expect(model.spring.displacement, closeTo(0.2, 1e-12));
    expect(model.spring.springConstant, 150);
    expect(view.graph, EnergyGraphKind.energyPlot);
    expect(find.byKey(const Key('energy-plot')), findsOneWidget);
  });

  test('energy state is independent of intro and systems', () {
    final intro = IntroModel();
    final systems = SystemsModel();
    final energy = EnergyModel();
    intro.system1.spring.setAppliedForce(40);
    systems.parallelSystem.topSpring.setSpringConstant(250);
    energy.spring.setDisplacement(0.25);
    energy.spring.setSpringConstant(300);

    expect(intro.system1.spring.appliedForce, 40);
    expect(intro.system1.spring.springConstant, 200);
    expect(systems.parallelSystem.topSpring.springConstant, 250);
    expect(systems.seriesSystem.leftSpring.displacement, 0);
    expect(energy.spring.displacement, 0.25);
    expect(energy.spring.springConstant, 300);
    expect(energy.spring.appliedForce, closeTo(75, 1e-9));

    energy.spring.setDisplacement(-0.2);
    expect(intro.system1.spring.appliedForce, 40);
    expect(systems.parallelSystem.equivalentSpring.displacement, 0);
  });
}

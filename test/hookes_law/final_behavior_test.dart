import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/hookes_law/constants/hookes_law_constants.dart';
import 'package:kratos/hookes_law/model/energy_graph_data.dart';
import 'package:kratos/hookes_law/model/energy_model.dart';
import 'package:kratos/hookes_law/model/intro_model.dart';
import 'package:kratos/hookes_law/model/robotic_arm_drag.dart';
import 'package:kratos/hookes_law/model/systems_model.dart';
import 'package:kratos/hookes_law/view/energy/energy_screen.dart';
import 'package:kratos/hookes_law/view/energy/energy_view_properties.dart';
import 'package:kratos/hookes_law/view/intro/intro_screen.dart';
import 'package:kratos/hookes_law/view/intro/intro_view_properties.dart';
import 'package:kratos/hookes_law/view/systems/systems_screen.dart';
import 'package:kratos/hookes_law/view/systems/systems_view_properties.dart';

/// Closed loops that the per-screen suites do not host together:
/// screen swaps on the same model instances, pointer-up with no settle
/// motion, and the exact source numbers driven through the controls.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> show(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1024, 618);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: screen,
      ),
    );
    await tester.pump();
  }

  Future<void> dragTrack(
    WidgetTester tester,
    Key key,
    double layoutDx,
    double track,
  ) async {
    final width = tester.getRect(find.byKey(key)).width;
    await tester.drag(find.byKey(key), Offset(width * layoutDx / track, 0));
    await tester.pump();
  }

  test('drag snap is 0.01 m and setDisplacement is not', () {
    final system = IntroModel().system1;
    final spring = system.spring;
    const expected = [0.01, 0.03, 0.04];
    for (var i = 0; i < expected.length; i++) {
      final raw = [0.013, 0.027, 0.044][i];
      final proposed = spring.equilibriumX + raw;
      applyRoboticArmPointerLeft(
        arm: system.roboticArm,
        springRightRange: spring.rightRange,
        proposedLeft: proposed,
      );
      expect(spring.displacement, closeTo(expected[i], 1e-12));
    }

    final fresh = IntroModel().system1.spring;
    fresh.setDisplacement(0.013);
    expect(fresh.displacement, closeTo(0.013, 1e-12));
    fresh.setDisplacement(0.027);
    expect(fresh.displacement, closeTo(0.027, 1e-12));
    fresh.setDisplacement(0.044);
    expect(fresh.displacement, closeTo(0.044, 1e-12));
  });

  test('repeated F and x writes do not drift', () {
    final spring = IntroModel().system1.spring;
    spring.setAppliedForce(50);
    for (var i = 0; i < 30; i++) {
      spring.setSpringConstant(200 + (i.isEven ? 0 : 1));
      spring.setAppliedForce(50);
    }
    expect(spring.appliedForce, 50);
    expect(spring.displacement, closeTo(50 / 201, 1e-12));
    expect(spring.springForce, closeTo(-50, 1e-12));

    final energy = EnergyModel().spring;
    energy.setDisplacement(0.5);
    for (var i = 0; i < 30; i++) {
      energy.setSpringConstant(i.isEven ? 200 : 400);
      energy.setDisplacement(0.5);
    }
    expect(energy.displacement, 0.5);
    expect(energy.appliedForce, closeTo(200, 1e-9));
    expect(energy.springForce, closeTo(-200, 1e-9));
    expect(energy.potentialEnergy, closeTo(50, 1e-9));
  });

  testWidgets('intro controls keep F when k changes, and the other system does not follow', (tester) async {
    final model = IntroModel();
    final view = IntroViewProperties();
    await show(tester, IntroScreen(model: model, viewProperties: view));
    await tester.pumpAndSettle();

    await dragTrack(tester, const Key('intro-f-slider-1'), 45, HookesLawConstants.sliderTrackWidth);
    expect(model.system1.spring.appliedForce, 50);
    expect(model.system1.spring.displacement, closeTo(0.25, 1e-12));
    expect(model.system2.spring.appliedForce, 0);

    await dragTrack(tester, const Key('intro-k-slider-1'), -30, HookesLawConstants.sliderTrackWidth);
    expect(model.system1.spring.springConstant, 400);
    expect(model.system1.spring.appliedForce, 50);
    expect(model.system1.spring.displacement, closeTo(0.125, 1e-12));
    expect(model.system1.spring.springForce, closeTo(-50, 1e-12));
    expect(model.system2.spring.springConstant, 200);
    expect(model.system2.spring.displacement, 0);

    await tester.tap(find.byKey(const Key('intro-radio-2')));
    await tester.pumpAndSettle();
    await tester.drag(find.byKey(const Key('intro-hand-2')), const Offset(30, 0));
    await tester.pump();
    expect(model.system2.spring.displacement, closeTo(0.13, 1e-9));
    expect(model.system1.spring.appliedForce, 50);
    expect(model.system1.spring.displacement, closeTo(0.125, 1e-12));

    await tester.tap(find.text('Applied Force'));
    await tester.tap(find.text('Values'));
    await tester.pump();
    expect(find.text('50.0 N'), findsWidgets);
    expect(find.text('26.0 N'), findsOneWidget);
  });

  testWidgets('pointer up leaves the spring where the snap wrote it', (tester) async {
    final model = IntroModel();
    await show(tester, IntroScreen(model: model));
    await tester.pumpAndSettle();

    final hand = tester.getCenter(find.byKey(const Key('intro-hand-1')));
    final gesture = await tester.startGesture(hand);
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump();
    final x = model.system1.spring.displacement;
    final force = model.system1.spring.appliedForce;
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(model.system1.spring.displacement, x);
    expect(model.system1.spring.appliedForce, force);
    expect(x, closeTo(0.13, 1e-9));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reset during the 1 to 2 animation restores the default and can run again', (tester) async {
    final model = IntroModel();
    final view = IntroViewProperties();
    await show(tester, IntroScreen(model: model, viewProperties: view));
    await tester.pumpAndSettle();

    model.system1.spring.setAppliedForce(20);
    model.system2.spring.setSpringConstant(300);
    await tester.tap(find.byKey(const Key('intro-radio-2')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('intro-reset')));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(view.numberOfSystems, 1);
    expect(model.system1.spring.appliedForce, 0);
    expect(model.system1.spring.displacement, 0);
    expect(model.system2.spring.springConstant, 200);
    expect(find.byKey(const Key('intro-hand-2')), findsNothing);

    await tester.tap(find.byKey(const Key('intro-radio-2')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('intro-radio-1')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('intro-radio-2')));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(view.numberOfSystems, 2);
    expect(find.byKey(const Key('intro-hand-2')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opening and closing a screen does not keep a disposed listener', (tester) async {
    final intro = IntroModel();
    final view = IntroViewProperties();
    var updates = 0;
    intro.system1.spring.appliedForceProperty.addListener((_) => updates++);

    for (var i = 0; i < 3; i++) {
      await show(tester, IntroScreen(model: intro, viewProperties: view));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }

    final before = updates;
    intro.system1.spring.setAppliedForce(15);
    expect(updates, before + 1);
    expect(intro.system1.spring.appliedForce, 15);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving a screen and coming back keeps that screen and ignores the others', (tester) async {
    final intro = IntroModel();
    final introView = IntroViewProperties();
    final systems = SystemsModel();
    final systemsView = SystemsViewProperties();
    final energy = EnergyModel();
    final energyView = EnergyViewProperties();

    await show(tester, IntroScreen(model: intro, viewProperties: introView));
    await tester.pumpAndSettle();
    await dragTrack(tester, const Key('intro-f-slider-1'), 45, HookesLawConstants.sliderTrackWidth);
    expect(intro.system1.spring.appliedForce, 50);

    await show(tester, SystemsScreen(model: systems, viewProperties: systemsView));
    expect(systems.parallelSystem.equivalentSpring.appliedForce, 0);
    expect(systems.seriesSystem.equivalentSpring.appliedForce, 0);
    expect(intro.system1.spring.appliedForce, 50);
    await tester.tap(find.byKey(const Key('systems-k-top-increment')));
    await tester.pump();
    expect(systems.parallelSystem.topSpring.springConstant, 201);

    await show(tester, EnergyScreen(model: energy, viewProperties: energyView));
    expect(energy.spring.displacement, 0);
    expect(energy.spring.springConstant, 100);
    expect(intro.system1.spring.appliedForce, 50);
    expect(systems.parallelSystem.topSpring.springConstant, 201);
    await tester.tap(find.byKey(const Key('energy-x-increment')));
    await tester.pump();
    expect(energy.spring.displacement, closeTo(0.01, 1e-12));

    await show(tester, IntroScreen(model: intro, viewProperties: introView));
    await tester.pumpAndSettle();
    expect(intro.system1.spring.appliedForce, 50);
    expect(intro.system1.spring.displacement, closeTo(0.25, 1e-12));
    expect(systems.parallelSystem.topSpring.springConstant, 201);
    expect(energy.spring.displacement, closeTo(0.01, 1e-12));

    await show(tester, SystemsScreen(model: systems, viewProperties: systemsView));
    expect(systems.parallelSystem.topSpring.springConstant, 201);
    expect(systemsView.systemType, SystemsKind.parallel);
    expect(energy.spring.displacement, closeTo(0.01, 1e-12));
    expect(intro.system1.spring.appliedForce, 50);

    await show(tester, EnergyScreen(model: energy, viewProperties: energyView));
    expect(energy.spring.displacement, closeTo(0.01, 1e-12));
    expect(energyView.graph, EnergyGraphKind.barGraph);
    expect(intro.system1.spring.springConstant, 200);
    expect(systems.parallelSystem.equivalentSpring.appliedForce, 0);
  });

  testWidgets('unequal series springs share F, unequal parallel springs do not share F', (tester) async {
    final model = SystemsModel();
    final view = SystemsViewProperties();
    await show(tester, SystemsScreen(model: model, viewProperties: view));

    await dragTrack(
      tester,
      const Key('systems-k-bottom-slider'),
      1,
      HookesLawConstants.systemsSpringConstantTrackWidth,
    );
    expect(model.parallelSystem.bottomSpring.springConstant, 400);
    expect(model.parallelSystem.topSpring.springConstant, 200);
    model.parallelSystem.equivalentSpring.setDisplacement(0.1);
    await tester.pump();
    expect(model.parallelSystem.topSpring.displacement, closeTo(0.1, 1e-12));
    expect(model.parallelSystem.bottomSpring.displacement, closeTo(0.1, 1e-12));
    expect(model.parallelSystem.topSpring.appliedForce, closeTo(20, 1e-9));
    expect(model.parallelSystem.bottomSpring.appliedForce, closeTo(40, 1e-9));
    expect(model.parallelSystem.equivalentSpring.appliedForce, closeTo(60, 1e-9));

    final before = (
      model.parallelSystem.equivalentSpring.appliedForce,
      model.parallelSystem.equivalentSpring.displacement,
      model.parallelSystem.equivalentSpring.springConstant,
    );
    await tester.tap(find.text('Spring Force'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('systems-components')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('systems-total')));
    await tester.pump();
    expect(model.parallelSystem.equivalentSpring.appliedForce, before.$1);
    expect(model.parallelSystem.equivalentSpring.displacement, before.$2);
    expect(model.parallelSystem.equivalentSpring.springConstant, before.$3);

    await tester.tap(find.byKey(const Key('systems-radio-series')));
    await tester.pump();
    await dragTrack(
      tester,
      const Key('systems-k-left-slider'),
      1,
      HookesLawConstants.systemsSpringConstantTrackWidth,
    );
    expect(model.seriesSystem.leftSpring.springConstant, 400);
    expect(model.seriesSystem.rightSpring.springConstant, 200);
    await dragTrack(tester, const Key('systems-f-series-slider'), 45, HookesLawConstants.sliderTrackWidth);
    expect(model.seriesSystem.equivalentSpring.appliedForce, 50);
    expect(model.seriesSystem.leftSpring.appliedForce, closeTo(50, 1e-9));
    expect(model.seriesSystem.rightSpring.appliedForce, closeTo(50, 1e-9));
    expect(
      model.seriesSystem.leftSpring.displacement + model.seriesSystem.rightSpring.displacement,
      closeTo(model.seriesSystem.equivalentSpring.displacement, 1e-9),
    );
    expect(model.parallelSystem.topSpring.appliedForce, closeTo(20, 1e-9));
    expect(model.parallelSystem.bottomSpring.springConstant, 400);
  });

  testWidgets('series drag keeps equal forces and parallel drag keeps equal x', (tester) async {
    final model = SystemsModel();
    final view = SystemsViewProperties();
    await show(tester, SystemsScreen(model: model, viewProperties: view));
    model.parallelSystem.bottomSpring.setSpringConstant(400);
    await tester.pump();

    await tester.drag(find.byKey(const Key('systems-hand-parallel')), const Offset(20, 0));
    await tester.pump();
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('systems-hand-parallel'))),
    );
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      model.parallelSystem.topSpring.displacement,
      closeTo(model.parallelSystem.bottomSpring.displacement, 1e-12),
    );
    expect(
      model.parallelSystem.topSpring.appliedForce + model.parallelSystem.bottomSpring.appliedForce,
      closeTo(model.parallelSystem.equivalentSpring.appliedForce, 1e-6),
    );

    view.systemType = SystemsKind.series;
    await tester.pump();
    model.seriesSystem.leftSpring.setSpringConstant(400);
    await tester.pump();
    await tester.drag(find.byKey(const Key('systems-hand-series')), const Offset(-25, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      model.seriesSystem.leftSpring.appliedForce,
      closeTo(model.seriesSystem.rightSpring.appliedForce, 1e-9),
    );
    expect(
      model.seriesSystem.leftSpring.displacement + model.seriesSystem.rightSpring.displacement,
      closeTo(model.seriesSystem.equivalentSpring.displacement, 1e-9),
    );
  });

  testWidgets('energy slider reaches k = 400 without moving x, including the negative side', (tester) async {
    final model = EnergyModel();
    final view = EnergyViewProperties();
    await show(tester, EnergyScreen(model: model, viewProperties: view));

    await dragTrack(tester, const Key('energy-x-slider'), 45, HookesLawConstants.sliderTrackWidth);
    expect(model.spring.displacement, closeTo(0.5, 1e-9));
    await dragTrack(tester, const Key('energy-k-slider'), 90, HookesLawConstants.sliderTrackWidth);
    expect(model.spring.springConstant, 400);
    expect(model.spring.displacement, closeTo(0.5, 1e-9));
    expect(model.spring.appliedForce, closeTo(200, 1e-6));
    expect(model.spring.springForce, closeTo(-200, 1e-6));
    expect(model.spring.potentialEnergy, closeTo(50, 1e-6));
    expect(find.byKey(const Key('energy-bar-rect')), findsOneWidget);

    model.spring.setDisplacement(-0.5);
    await tester.pump();
    expect(model.spring.appliedForce, closeTo(-200, 1e-6));
    expect(model.spring.springForce, closeTo(200, 1e-6));
    expect(model.spring.potentialEnergy, closeTo(50, 1e-6));
    expect(EnergyGraphData.energyBar(model.spring).visible, isTrue);
    expect(EnergyGraphData.energyBar(model.spring).energy, closeTo(50, 1e-9));
    final triangle = EnergyGraphData.forcePlotEnergyTriangle(model.spring);
    expect(triangle.visible, isTrue);
    expect(triangle.y, closeTo(-model.spring.appliedForce * HookesLawConstants.unitForceY, 1e-9));
    expect(triangle.y, greaterThan(0));

    model.spring.setSpringConstant(200);
    model.spring.setDisplacement(-0.5);
    await tester.pump();
    expect(model.spring.appliedForce, closeTo(-100, 1e-9));
    expect(model.spring.springForce, closeTo(100, 1e-9));
    expect(model.spring.potentialEnergy, closeTo(25, 1e-9));

    model.spring.setDisplacement(0);
    await tester.pump();
    expect(model.spring.appliedForce, 0);
    expect(model.spring.springForce, 0);
    expect(model.spring.potentialEnergy, 0);
    expect(find.byKey(const Key('energy-bar-rect')), findsNothing);
    expect(EnergyGraphData.forcePlotEnergyTriangle(model.spring).visible, isFalse);
  });

  testWidgets('graph radios move the same bar and the energy triangle follows only the checkbox', (tester) async {
    final model = EnergyModel();
    final view = EnergyViewProperties();
    await show(tester, EnergyScreen(model: model, viewProperties: view));
    model.spring.setDisplacement(0.5);
    model.spring.setSpringConstant(200);
    await tester.pump();

    final barAtOrigin = tester.getTopLeft(find.byKey(const Key('energy-bar'))).dx;
    final x = model.spring.displacement;
    final k = model.spring.springConstant;
    final force = model.spring.appliedForce;
    final energy = model.spring.potentialEnergy;

    await tester.tap(find.byKey(const Key('energy-radio-energy')));
    await tester.pump();
    final barAside = tester.getTopLeft(find.byKey(const Key('energy-bar'))).dx;
    final plotX = tester.getTopLeft(find.byKey(const Key('energy-plot'))).dx;
    expect(barAside, lessThan(barAtOrigin));
    expect(plotX, greaterThan(barAside));
    expect(find.byKey(const Key('energy-bar')), findsOneWidget);
    expect(model.spring.displacement, x);
    expect(model.spring.springConstant, k);

    await tester.tap(find.byKey(const Key('energy-radio-force')));
    await tester.pump();
    expect(find.byKey(const Key('energy-triangle')), findsNothing);
    final forceTop = tester.getTopLeft(find.byKey(const Key('energy-force-plot'))).dy;
    final barTop = tester.getTopLeft(find.byKey(const Key('energy-bar'))).dy;
    expect(forceTop, lessThan(barTop));
    expect(find.byKey(const Key('energy-bar')), findsOneWidget);

    await tester.tap(find.byKey(const Key('energy-checkbox')));
    await tester.pump();
    expect(find.byKey(const Key('energy-triangle')), findsOneWidget);
    expect(model.spring.appliedForce, force);
    expect(model.spring.potentialEnergy, energy);

    await tester.tap(find.byKey(const Key('energy-checkbox')));
    await tester.pump();
    expect(find.byKey(const Key('energy-triangle')), findsNothing);
    expect(model.spring.displacement, x);
    expect(model.spring.potentialEnergy, energy);

    await tester.tap(find.byKey(const Key('energy-radio-bar')));
    await tester.pump();
    expect(tester.getTopLeft(find.byKey(const Key('energy-bar'))).dx, closeTo(barAtOrigin, 0.5));
    expect(find.byKey(const Key('energy-plot')), findsNothing);
    expect(find.byKey(const Key('energy-force-plot')), findsNothing);
    expect(view.graph, EnergyGraphKind.barGraph);
    expect(model.spring.appliedForce, force);

    await tester.tap(find.byKey(const Key('energy-radio-energy')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('energy-radio-force')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('energy-radio-bar')));
    await tester.pump();
    expect(model.spring.displacement, x);
    expect(model.spring.springConstant, k);
    expect(tester.takeException(), isNull);
  });

  testWidgets('energy reset clears x, k, the graph, and the checkbox', (tester) async {
    final model = EnergyModel();
    final view = EnergyViewProperties();
    await show(tester, EnergyScreen(model: model, viewProperties: view));
    model.spring.setDisplacement(-0.5);
    model.spring.setSpringConstant(400);
    view.graphKind = EnergyGraphKind.forcePlot;
    await tester.pump();
    await tester.tap(find.byKey(const Key('energy-checkbox')));
    await tester.pump();
    expect(view.energyOnForcePlotVisible, isTrue);

    await tester.tap(find.byKey(const Key('energy-reset')));
    await tester.pump();
    expect(model.spring.displacement, 0);
    expect(model.spring.springConstant, 100);
    expect(model.spring.appliedForce, 0);
    expect(model.spring.potentialEnergy, 0);
    expect(view.graph, EnergyGraphKind.barGraph);
    expect(view.energyOnForcePlotVisible, isFalse);
    expect(find.byKey(const Key('energy-triangle')), findsNothing);
    expect(find.byKey(const Key('energy-bar')), findsOneWidget);
  });
}

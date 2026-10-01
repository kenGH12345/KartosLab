import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/hookes_law/constants/hookes_law_constants.dart';
import 'package:kratos/hookes_law/model/systems_model.dart';
import 'package:kratos/hookes_law/view/parametric_spring_geometry.dart';
import 'package:kratos/hookes_law/view/systems/systems_screen.dart';
import 'package:kratos/hookes_law/view/systems/systems_view_properties.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('8-loop systems spring still ends at length * 225 px', () {
    const length = 1.5;
    final geometry = ParametricSpringGeometry.sample(
      loops: HookesLawConstants.parallelSpringLoops,
      pointsPerLoop: HookesLawConstants.springPointsPerLoop,
      radius: HookesLawConstants.springRadius,
      aspectRatio: HookesLawConstants.springAspectRatio,
      leftEndLength: HookesLawConstants.springLeftEndLength,
      rightEndLength: HookesLawConstants.springRightEndLength,
      xScale: ParametricSpringGeometry.xScaleForLength(
        length,
        loops: HookesLawConstants.parallelSpringLoops,
      ),
      lineWidth: ParametricSpringGeometry.lineWidthFor(200, minK: 200),
    );
    expect(geometry.rightTipX, closeTo(length * HookesLawConstants.unitDisplacementX, 1e-9));
    expect(geometry.lineWidth, 3);
    var folded = false;
    for (var i = 1; i < geometry.points.length; i++) {
      if (geometry.points[i].x < geometry.points[i - 1].x) {
        folded = true;
        break;
      }
    }
    expect(folded, isTrue);
  });

  Future<void> pumpSystems(
    WidgetTester tester, {
    required SystemsModel model,
    SystemsViewProperties? view,
  }) async {
    tester.view.physicalSize = const Size(1024, 618);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SystemsScreen(model: model, viewProperties: view),
      ),
    );
  }

  Future<void> dragForceSlider(WidgetTester tester, Key key) async {
    final width = tester.getRect(find.byKey(key)).width;
    await tester.drag(
      find.byKey(key),
      Offset(width * 36 / HookesLawConstants.sliderTrackWidth, 0),
    );
  }

  testWidgets('default is parallel and series already exists at defaults', (tester) async {
    final model = SystemsModel();
    final view = SystemsViewProperties();
    await pumpSystems(tester, model: model, view: view);

    expect(view.systemType, SystemsKind.parallel);
    expect(view.springForceRepresentation, SpringForceRepresentation.total);
    expect(view.springForceVectorVisible, isFalse);
    expect(model.parallelSystem.topSpring.springConstant, 200);
    expect(model.parallelSystem.bottomSpring.springConstant, 200);
    expect(model.parallelSystem.equivalentSpring.springConstant, 400);
    expect(model.parallelSystem.equivalentSpring.appliedForce, 0);
    expect(model.seriesSystem.leftSpring.springConstant, 200);
    expect(model.seriesSystem.equivalentSpring.springConstant, 100);
    expect(find.byKey(const Key('systems-hand-parallel')), findsOneWidget);
    expect(find.byKey(const Key('systems-hand-series')), findsNothing);
    expect(find.text('Top Spring:'), findsOneWidget);
    expect(find.text('Left Spring:'), findsNothing);
  });

  testWidgets('k and force controls write the parallel model and keep component relations', (tester) async {
    final model = SystemsModel();
    await pumpSystems(tester, model: model);
    final parallel = model.parallelSystem;

    await tester.tap(find.byKey(const Key('systems-k-top-increment')));
    await tester.pump();
    expect(parallel.topSpring.springConstant, 201);
    expect(parallel.bottomSpring.springConstant, 200);
    expect(parallel.equivalentSpring.springConstant, 401);
    expect(parallel.equivalentSpring.appliedForce, 0);
    expect(model.seriesSystem.leftSpring.springConstant, 200);

    await dragForceSlider(tester, const Key('systems-f-parallel-slider'));
    await tester.pump();
    final force = parallel.equivalentSpring.appliedForce;
    expect(force, 40);
    expect(parallel.topSpring.displacement, closeTo(parallel.bottomSpring.displacement, 1e-9));
    expect(parallel.topSpring.displacement, closeTo(parallel.equivalentSpring.displacement, 1e-9));
    expect(
      parallel.topSpring.appliedForce + parallel.bottomSpring.appliedForce,
      closeTo(force, 1e-6),
    );
    expect(parallel.topSpring.appliedForce, isNot(closeTo(parallel.bottomSpring.appliedForce, 1e-6)));

    await tester.tap(find.byKey(const Key('systems-k-bottom-increment')));
    await tester.pump();
    expect(parallel.bottomSpring.springConstant, 201);
    expect(parallel.equivalentSpring.appliedForce, 40);
  });

  testWidgets('series keeps equal forces and additive displacement', (tester) async {
    final model = SystemsModel();
    final view = SystemsViewProperties();
    await pumpSystems(tester, model: model, view: view);
    await tester.tap(find.byKey(const Key('systems-radio-series')));
    await tester.pump();

    final series = model.seriesSystem;
    await tester.tap(find.byKey(const Key('systems-k-left-increment')));
    await tester.pump();
    expect(series.leftSpring.springConstant, 201);
    expect(series.rightSpring.springConstant, 200);
    final keq = 1 / (1 / 201 + 1 / 200);
    expect(series.equivalentSpring.springConstant, closeTo(keq, 1e-9));
    expect(series.leftSpring.appliedForce, series.rightSpring.appliedForce);

    await dragForceSlider(tester, const Key('systems-f-series-slider'));
    await tester.pump();
    expect(series.equivalentSpring.appliedForce, 40);
    expect(series.leftSpring.appliedForce, closeTo(series.rightSpring.appliedForce, 1e-9));
    expect(series.leftSpring.appliedForce, closeTo(40, 1e-6));
    expect(
      series.leftSpring.displacement + series.rightSpring.displacement,
      closeTo(series.equivalentSpring.displacement, 1e-6),
    );
    expect(series.leftSpring.displacement, isNot(closeTo(series.rightSpring.displacement, 1e-6)));
    expect(model.parallelSystem.equivalentSpring.appliedForce, 0);
  });

  testWidgets('Total and Components only change arrow visibility', (tester) async {
    final model = SystemsModel();
    final view = SystemsViewProperties();
    await pumpSystems(tester, model: model, view: view);
    await dragForceSlider(tester, const Key('systems-f-parallel-slider'));
    await tester.pump();
    final before = _snapshot(model);

    await tester.tap(find.byKey(const Key('systems-components')));
    await tester.pump();
    expect(view.springForceRepresentation, SpringForceRepresentation.total);
    expect(_snapshot(model), before);

    await tester.tap(find.text('Spring Force'));
    await tester.pump();
    expect(find.byKey(const Key('systems-total-arrow-parallel')), findsOneWidget);
    expect(find.byKey(const Key('systems-top-component-arrow')), findsNothing);

    await tester.tap(find.byKey(const Key('systems-components')));
    await tester.pump();
    expect(view.springForceRepresentation, SpringForceRepresentation.components);
    expect(find.byKey(const Key('systems-total-arrow-parallel')), findsNothing);
    expect(find.byKey(const Key('systems-top-component-arrow')), findsOneWidget);
    expect(find.byKey(const Key('systems-bottom-component-arrow')), findsOneWidget);
    expect(_snapshot(model), before);

    await tester.tap(find.byKey(const Key('systems-total')));
    await tester.pump();
    expect(view.springForceRepresentation, SpringForceRepresentation.total);
    expect(find.byKey(const Key('systems-top-component-arrow')), findsNothing);
    expect(_snapshot(model), before);
  });

  testWidgets('drag snaps to 0.01 m and clamps without splitting the systems', (tester) async {
    final model = SystemsModel();
    final view = SystemsViewProperties();
    await pumpSystems(tester, model: model, view: view);
    final parallel = model.parallelSystem;

    await tester.drag(find.byKey(const Key('systems-hand-parallel')), const Offset(30, 0));
    await tester.pump();
    expect(parallel.equivalentSpring.displacement, closeTo(0.13, 1e-9));
    expect(parallel.topSpring.displacement, closeTo(0.13, 1e-9));
    expect(parallel.bottomSpring.displacement, closeTo(0.13, 1e-9));

    await tester.drag(find.byKey(const Key('systems-hand-parallel')), const Offset(-800, 0));
    await tester.pump();
    expect(parallel.equivalentSpring.displacement, closeTo(-0.25, 1e-6));
    expect(parallel.equivalentSpring.appliedForce, closeTo(-100, 1e-6));
    expect(parallel.topSpring.displacement, closeTo(parallel.bottomSpring.displacement, 1e-9));

    await tester.drag(find.byKey(const Key('systems-hand-parallel')), const Offset(800, 0));
    await tester.pump();
    expect(parallel.equivalentSpring.displacement, closeTo(0.25, 1e-6));
    expect(parallel.equivalentSpring.appliedForce, closeTo(100, 1e-6));
    expect(
      parallel.topSpring.appliedForce + parallel.bottomSpring.appliedForce,
      closeTo(100, 1e-4),
    );

    view.systemType = SystemsKind.series;
    await tester.pump();
    final series = model.seriesSystem;
    await tester.drag(find.byKey(const Key('systems-hand-series')), const Offset(-30, 0));
    await tester.pump();
    expect(series.equivalentSpring.displacement, closeTo(-0.13, 1e-9));
    expect(series.leftSpring.appliedForce, closeTo(series.rightSpring.appliedForce, 1e-9));
    expect(
      series.leftSpring.displacement + series.rightSpring.displacement,
      closeTo(series.equivalentSpring.displacement, 1e-6),
    );
    expect(parallel.equivalentSpring.displacement, closeTo(0.25, 1e-6));

    await tester.drag(find.byKey(const Key('systems-hand-series')), const Offset(800, 0));
    await tester.pump();
    expect(series.equivalentSpring.displacement, closeTo(1, 1e-6));
    expect(series.equivalentSpring.appliedForce, closeTo(100, 1e-6));
    expect(series.leftSpring.appliedForce, closeTo(series.rightSpring.appliedForce, 1e-6));
  });

  testWidgets('reset restores the hidden system and the controls', (tester) async {
    final model = SystemsModel();
    final view = SystemsViewProperties();
    await pumpSystems(tester, model: model, view: view);

    await tester.tap(find.byKey(const Key('systems-k-top-increment')));
    await tester.pump();
    await tester.tap(find.text('Spring Force'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('systems-components')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('systems-radio-series')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('systems-k-right-increment')));
    await tester.pump();
    expect(model.parallelSystem.topSpring.springConstant, 201);
    expect(model.seriesSystem.rightSpring.springConstant, 201);

    await tester.tap(find.byKey(const Key('systems-reset')));
    await tester.pump();

    expect(view.systemType, SystemsKind.parallel);
    expect(view.springForceRepresentation, SpringForceRepresentation.total);
    expect(view.springForceVectorVisible, isFalse);
    expect(model.parallelSystem.topSpring.springConstant, 200);
    expect(model.parallelSystem.bottomSpring.springConstant, 200);
    expect(model.parallelSystem.equivalentSpring.appliedForce, 0);
    expect(model.parallelSystem.equivalentSpring.displacement, 0);
    expect(model.seriesSystem.rightSpring.springConstant, 200);
    expect(model.seriesSystem.leftSpring.springConstant, 200);
    expect(model.seriesSystem.equivalentSpring.appliedForce, 0);
    expect(model.seriesSystem.equivalentSpring.displacement, 0);
    expect(find.byKey(const Key('systems-hand-series')), findsNothing);
    expect(find.text('Top Spring:'), findsOneWidget);
  });

  testWidgets('leaving the screen does not reset or copy state', (tester) async {
    final model = SystemsModel();
    final view = SystemsViewProperties();
    await pumpSystems(tester, model: model, view: view);
    await tester.tap(find.byKey(const Key('systems-k-bottom-increment')));
    await tester.pump();
    view.systemType = SystemsKind.series;
    view.setSpringForceVectorVisible(true);
    view.springForceRepresentation = SpringForceRepresentation.components;
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SystemsScreen(model: model, viewProperties: view),
      ),
    );
    await tester.pump();

    expect(model.parallelSystem.bottomSpring.springConstant, 201);
    expect(model.seriesSystem.equivalentSpring.springConstant, 100);
    expect(view.systemType, SystemsKind.series);
    expect(view.springForceRepresentation, SpringForceRepresentation.components);
    expect(find.text('Left Spring:'), findsOneWidget);
    expect(find.byKey(const Key('systems-hand-parallel')), findsNothing);
  });
}

String _snapshot(SystemsModel model) {
  final parallel = model.parallelSystem;
  final series = model.seriesSystem;
  return [
    parallel.topSpring.springConstant,
    parallel.bottomSpring.springConstant,
    parallel.topSpring.appliedForce,
    parallel.bottomSpring.appliedForce,
    parallel.equivalentSpring.appliedForce,
    parallel.equivalentSpring.displacement,
    series.leftSpring.appliedForce,
    series.equivalentSpring.appliedForce,
    series.equivalentSpring.displacement,
  ].join(',');
}

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/my_solar_system/config/mss_scenario.dart';
import 'package:kratos/astronomy/my_solar_system/controller/my_solar_system_controller.dart';
import 'package:kratos/astronomy/my_solar_system/painters/velocity_vectors_painter.dart';
import 'package:kratos/astronomy/my_solar_system/render/mss_mvt.dart';
import 'package:kratos/astronomy/my_solar_system/screens/my_solar_system_home.dart';
import 'package:kratos/astronomy/my_solar_system/screens/my_solar_system_screen.dart';
import 'package:kratos/astronomy/my_solar_system/widgets/mss_time_controls.dart';
import 'package:kratos/common/widgets/nine_grid_layout.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  testWidgets('Home lists My Solar System under 天体力学', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    expect(find.text('My Solar System'), findsOneWidget);
  });

  testWidgets('Intro screen play pause step restart', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = MySolarSystemController(isLab: false);
    await tester.pumpWidget(
      MaterialApp(
        home: MySolarSystemScreen(
          isLab: false,
          controller: c,
        ),
      ),
    );
    await tester.pump();
    expect(c.isPlaying, isFalse);
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    expect(c.isPlaying, isTrue);
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(c.isPlaying, isFalse);
    final x = c.bodies[1].position.x;
    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pump();
    expect(c.bodies[1].position.x, isNot(x));
  });

  testWidgets('TimePanel is upper-right and footer Time is gone', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MySolarSystemScreen(
          isLab: false,
          controller: MySolarSystemController(isLab: false),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('mss-time-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('mss-footer-time')), findsNothing);
    expect(find.byType(MssTimePanel), findsOneWidget);
    final grid = tester.getRect(find.byType(NineGridLayout));
    final panel = tester.getRect(find.byKey(const ValueKey('mss-time-panel')));
    expect(panel.top, closeTo(grid.top + 10, 1));
    expect(panel.right, closeTo(grid.right - 10, 1));
    expect(panel.left, greaterThan(grid.center.dx));
  });

  testWidgets('velocity vector painter is present', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MySolarSystemScreen(
          isLab: false,
          controller: MySolarSystemController(isLab: false),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is VelocityVectorsPainter,
      ),
      findsOneWidget,
    );
  });

  testWidgets('dragging a body pauses and writes model position', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = MySolarSystemController(isLab: false);
    await tester.pumpWidget(
      MaterialApp(
        home: MySolarSystemScreen(isLab: false, controller: c),
      ),
    );
    await tester.pump();
    final play = tester.getRect(find.byKey(const ValueKey('mss-play-area')));
    final mvt = MssMvt(
      center: Offset(play.width / 2, play.height / 2),
      scale: c.zoomScale,
    );
    final local = mvt.toView(c.bodies[1].position);
    final global = play.topLeft + local;
    c.play();
    await tester.pump();
    expect(c.isPlaying, isTrue);
    final startX = c.bodies[1].position.x;
    await tester.dragFrom(global, const Offset(50, 0));
    await tester.pump();
    expect(c.isPlaying, isFalse);
    expect(c.bodies[1].position.x, isNot(closeTo(startX, 1e-6)));
    expect(c.draggingBodyIndex, isNull);
  });

  testWidgets('Lab also hosts TimePanel top-right', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MySolarSystemScreen(
          isLab: true,
          controller: MySolarSystemController(isLab: true),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('mss-time-panel')), findsOneWidget);
    expect(find.text('Fast'), findsOneWidget);
  });

  testWidgets('More Data / Mass / CoM / Gravity / Grid / Zoom / Tape',
      (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = MySolarSystemController(isLab: true);
    await tester.pumpWidget(
      MaterialApp(home: MySolarSystemScreen(isLab: true, controller: c)),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('mss-values-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('mss-mass-slider-1')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('mss-more-data')));
    await tester.pump();
    expect(c.moreDataVisible, isTrue);
    expect(find.byKey(const ValueKey('mss-pos-x-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('mss-mass-slider-1')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('mss-toggle-com')));
    await tester.pump();
    expect(c.centerOfMassVisible, isTrue);

    await tester.tap(find.byKey(const ValueKey('mss-toggle-gravity')));
    await tester.pump();
    expect(c.gravityVisible, isTrue);

    await tester.tap(find.byKey(const ValueKey('mss-toggle-grid')));
    await tester.pump();
    expect(c.gridVisible, isTrue);

    await tester.tap(find.byKey(const ValueKey('mss-toggle-tape')));
    await tester.pump();
    expect(c.measuringTapeVisible, isTrue);
    expect(find.byKey(const ValueKey('mss-measuring-tape')), findsOneWidget);

    final z = c.zoomLevel;
    await tester.tap(find.byKey(const ValueKey('mss-zoom-in')));
    await tester.pump();
    expect(c.zoomLevel, z + 1);
  });

  testWidgets('Lab has Intro/Lab tabs via home', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MySolarSystemHome()));
    await tester.pump();
    expect(find.text('Intro'), findsWidgets);
    expect(find.text('Lab'), findsWidgets);
  });

  testWidgets('capture intro default 1024x768', (tester) async {
    await _capture(
      tester,
      size: const Size(1024, 768),
      isLab: false,
      name: 'loop3-intro-1024x768.png',
      enableOverlays: true,
    );
  });

  testWidgets('capture intro 375x667', (tester) async {
    await _capture(
      tester,
      size: const Size(375, 667),
      isLab: false,
      name: 'loop3-intro-375x667.png',
      enableOverlays: true,
    );
  });

  testWidgets('capture intro 1920x1080', (tester) async {
    await _capture(
      tester,
      size: const Size(1920, 1080),
      isLab: false,
      name: 'loop3-intro-1920x1080.png',
      enableOverlays: true,
    );
  });

  testWidgets('capture lab 1024x768', (tester) async {
    await _capture(
      tester,
      size: const Size(1024, 768),
      isLab: true,
      name: 'loop3-lab-1024x768.png',
      enableOverlays: true,
    );
  });

  testWidgets('capture lab 375x667', (tester) async {
    await _capture(
      tester,
      size: const Size(375, 667),
      isLab: true,
      name: 'loop3-lab-375x667.png',
      enableOverlays: true,
    );
  });

  testWidgets('Lab bodies / return / offscale / custom', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = MySolarSystemController(isLab: true);
    await tester.pumpWidget(
      MaterialApp(home: MySolarSystemScreen(isLab: true, controller: c)),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('mss-bodies-control')), findsOneWidget);
    expect(c.numberOfActiveBodies, 2);
    c.setNumberOfActiveBodies(3);
    await tester.pump();
    expect(c.numberOfActiveBodies, 3);
    expect(c.currentScenarioId, 'custom');
    c.isAnyBodyCollided = true;
    c.notifyListeners();
    await tester.pump();
    expect(find.byKey(const ValueKey('mss-return-bodies')), findsOneWidget);
    c.setGravityVisible(true);
    c.setBodyMass(0, 0.1);
    c.setBodyMass(1, 0.1);
    c.setBodyPositionComponent(1, x: 14, y: 0);
    await tester.pump();
    expect(find.byKey(const ValueKey('mss-offscale')), findsOneWidget);
  });

  testWidgets('capture lab loop4 1024x768', (tester) async {
    await _capture(
      tester,
      size: const Size(1024, 768),
      isLab: true,
      name: 'loop4-lab-1024x768.png',
      enableOverlays: true,
      loop4State: true,
    );
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('375 intro no layout overflow', (tester) async {
    await _pumpNoOverflow(
      tester,
      size: const Size(375, 667),
      isLab: false,
    );
  });

  testWidgets('375 lab no layout overflow', (tester) async {
    await _pumpNoOverflow(
      tester,
      size: const Size(375, 667),
      isLab: true,
    );
  });

  testWidgets('1024 intro no layout overflow', (tester) async {
    await _pumpNoOverflow(
      tester,
      size: const Size(1024, 768),
      isLab: false,
    );
  });

  testWidgets('1920 lab no layout overflow', (tester) async {
    await _pumpNoOverflow(
      tester,
      size: const Size(1920, 1080),
      isLab: true,
    );
  });

  testWidgets('capture loop5 intro default 375x667', (tester) async {
    await _capture(
      tester,
      size: const Size(375, 667),
      isLab: false,
      name: 'loop5-intro-default-375x667.png',
      enableOverlays: true,
    );
  });

  testWidgets('capture loop5 intro default 1024x768', (tester) async {
    await _capture(
      tester,
      size: const Size(1024, 768),
      isLab: false,
      name: 'loop5-intro-default-1024x768.png',
      enableOverlays: true,
    );
  });

  testWidgets('capture loop5 intro default 1920x1080', (tester) async {
    await _capture(
      tester,
      size: const Size(1920, 1080),
      isLab: false,
      name: 'loop5-intro-default-1920x1080.png',
      enableOverlays: true,
    );
  });

  testWidgets('capture loop5 intro moredata 1024x768', (tester) async {
    await _capture(
      tester,
      size: const Size(1024, 768),
      isLab: false,
      name: 'loop5-intro-moredata-1024x768.png',
      enableOverlays: true,
      moreData: true,
    );
  });

  testWidgets('capture loop5 lab sun-planet 375x667', (tester) async {
    await _capture(
      tester,
      size: const Size(375, 667),
      isLab: true,
      name: 'loop5-lab-sun-planet-375x667.png',
      scenarioId: 'sun_planet',
      loadCatalog: true,
    );
  });

  testWidgets('capture loop5 lab sun-planet 1024x768', (tester) async {
    await _capture(
      tester,
      size: const Size(1024, 768),
      isLab: true,
      name: 'loop5-lab-sun-planet-1024x768.png',
      scenarioId: 'sun_planet',
      loadCatalog: true,
      enableOverlays: true,
    );
  });

  testWidgets('capture loop5 lab four-star-ballet 1024x768', (tester) async {
    await _capture(
      tester,
      size: const Size(1024, 768),
      isLab: true,
      name: 'loop5-lab-four-star-ballet-1024x768.png',
      scenarioId: 'four_star_ballet',
      loadCatalog: true,
      enableOverlays: true,
    );
  });

  testWidgets('capture loop5 lab custom 1024x768', (tester) async {
    await _capture(
      tester,
      size: const Size(1024, 768),
      isLab: true,
      name: 'loop5-lab-custom-1024x768.png',
      loadCatalog: true,
      enableOverlays: true,
      customState: true,
    );
  });

  testWidgets('capture loop5 lab moredata 1920x1080', (tester) async {
    await _capture(
      tester,
      size: const Size(1920, 1080),
      isLab: true,
      name: 'loop5-lab-moredata-1920x1080.png',
      loadCatalog: true,
      enableOverlays: true,
      moreData: true,
    );
  });
}

Future<void> _pumpNoOverflow(
  WidgetTester tester, {
  required Size size,
  required bool isLab,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final c = MySolarSystemController(isLab: isLab);
  if (isLab) {
    c.setMoreDataVisible(true);
    c.setGridVisible(true);
    c.setGravityVisible(true);
    c.setCenterOfMassVisible(true);
    c.setMeasuringTapeVisible(true);
  }
  await tester.pumpWidget(
    MaterialApp(home: MySolarSystemScreen(isLab: isLab, controller: c)),
  );
  await tester.pump();
  expect(tester.takeException(), isNull);
}

Future<void> _capture(
  WidgetTester tester, {
  required Size size,
  required bool isLab,
  required String name,
  bool enableOverlays = false,
  bool loop4State = false,
  bool loadCatalog = false,
  String? scenarioId,
  bool moreData = false,
  bool customState = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final key = GlobalKey();
  List<MssScenario> catalog = const [];
  if (loadCatalog || loop4State) {
    final dir = Directory('assets/scenarios/my-solar-system');
    catalog = [
      for (final f in dir.listSync().whereType<File>())
        if (f.path.endsWith('.json') && !f.path.endsWith('manifest.json'))
          MssScenario.fromJson(
            jsonDecode(f.readAsStringSync()) as Map<String, dynamic>,
          ),
    ];
  }
  MssScenario? initial;
  if (scenarioId != null) {
    for (final s in catalog) {
      if (s.scenarioId == scenarioId) {
        initial = s;
        break;
      }
    }
  }
  final c = MySolarSystemController(
    isLab: isLab,
    catalog: catalog,
    initialScenario: initial,
  );
  if (enableOverlays || moreData) {
    c.setGridVisible(true);
    c.setGravityVisible(true);
    c.setCenterOfMassVisible(true);
    c.setMeasuringTapeVisible(true);
    if (isLab) c.setMoreDataVisible(moreData || enableOverlays);
  }
  if (loop4State && isLab) {
    c.setNumberOfActiveBodies(3);
    c.isAnyBodyCollided = true;
    c.setBodyMass(0, 0.1);
    c.setBodyMass(1, 0.1);
    c.setBodyPositionComponent(1, x: 14, y: 0);
  }
  if (customState && isLab) {
    c.setNumberOfActiveBodies(3);
    c.setBodyMass(1, 40);
  }
  await tester.pumpWidget(
    MaterialApp(
      home: RepaintBoundary(
        key: key,
        child: MySolarSystemScreen(isLab: isLab, controller: c),
      ),
    ),
  );
  await tester.pump();
  c.stepOnce(1 / 8);
  await tester.pump();
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory(
      '${Directory.current.path}/requirements/req-my-solar-system/screenshots',
    );
    dir.createSync(recursive: true);
    final out = File('${dir.path}/$name');
    out.writeAsBytesSync(bytes!.buffer.asUint8List());
    expect(out.existsSync(), isTrue);
  });
}

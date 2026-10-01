import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_skate_park/controller/graphs_controller.dart';
import 'package:kratos/energy_skate_park/screens/graphs_screen.dart';
import 'package:kratos/energy_skate_park/widgets/control_panel.dart';
import 'package:kratos/energy_skate_park/widgets/energy_graph_panel.dart';
import 'package:kratos/energy_skate_park/widgets/play_area.dart';
import 'package:kratos/energy_skate_park/widgets/time_control.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Graphs page layout: graph above play area, not overlay',
      (tester) async {
    final controller = GraphsController();
    addTearDown(controller.dispose);

    final view = tester.view;
    view.physicalSize = const Size(1024, 618);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          child: SizedBox(
            width: 1024,
            height: 618,
            child: GraphsScreen(controller: controller, embedded: true),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(EnergyGraphPanel), findsOneWidget);
    expect(find.byType(PlayArea), findsOneWidget);
    expect(find.byType(ControlPanel), findsOneWidget);

    final graphBox =
        tester.renderObject<RenderBox>(find.byType(EnergyGraphPanel));
    final playBox = tester.renderObject<RenderBox>(find.byType(PlayArea));
    final controlBox =
        tester.renderObject<RenderBox>(find.byType(ControlPanel));

    final graphOrigin = graphBox.localToGlobal(Offset.zero);
    final playOrigin = playBox.localToGlobal(Offset.zero);
    final controlOrigin = controlBox.localToGlobal(Offset.zero);

    expect(
      graphOrigin.dy + graphBox.size.height,
      lessThanOrEqualTo(playOrigin.dy + 2.0),
      reason: 'EnergyGraphPanel bottom must be at/above PlayArea top',
    );
    expect(graphBox.size.height, lessThan(280),
        reason: 'Graph panel must not dominate vertical space');
    expect(graphBox.size.height, greaterThan(160));
    expect(playBox.size.height, greaterThan(200),
        reason: 'Simulation viewport must remain usable below graph');
    // Control panel lives in the right column (screen-local x > mid).
    expect(controlOrigin.dx, greaterThan(500),
        reason: 'Control column must remain on the right side');
    // Graph must not overlap control horizontally at the top band.
    expect(
      graphOrigin.dx + graphBox.size.width,
      lessThanOrEqualTo(controlOrigin.dx + 4),
      reason: 'Graph must not invade control column',
    );

    final rects = <String, dynamic>{
      'viewport': {'w': 1024.0, 'h': 618.0},
      'graph': _normRect(graphOrigin, graphBox.size, 1024, 618),
      'simulation': _normRect(playOrigin, playBox.size, 1024, 618),
      'control': _normRect(controlOrigin, controlBox.size, 1024, 618),
    };
    if (find.byType(TimeControl).evaluate().isNotEmpty) {
      final bottomBox =
          tester.renderObject<RenderBox>(find.byType(TimeControl));
      final bottomOrigin = bottomBox.localToGlobal(Offset.zero);
      rects['bottomControls'] =
          _normRect(bottomOrigin, bottomBox.size, 1024, 618);
    }

    final outDir = Directory(
      'requirements/req-energy-skate-park/visual-qa',
    );
    if (!outDir.existsSync()) outDir.createSync(recursive: true);
    File('${outDir.path}/graphs-layout-rects.json')
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(rects));

    final rb = tester.renderObject<RenderRepaintBoundary>(
      find.byType(RepaintBoundary).first,
    );
    await tester.runAsync(() async {
      final img = await rb.toImage(pixelRatio: 1.0);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      if (bd != null) {
        File('${outDir.path}/graphs-current.png')
            .writeAsBytesSync(bd.buffer.asUint8List());
      }
      img.dispose();
    });
  });
}

Map<String, double> _normRect(Offset o, Size s, double vw, double vh) => {
      'x': o.dx / vw,
      'y': o.dy / vh,
      'w': s.width / vw,
      'h': s.height / vh,
      'px': o.dx,
      'py': o.dy,
      'pw': s.width,
      'ph': s.height,
    };

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/collision_lab/collision_lab_colors.dart';
import 'package:kratos/collision_lab/controller/collision_lab_controller.dart';
import 'package:kratos/collision_lab/controller/explore1d_controller.dart';
import 'package:kratos/collision_lab/controller/explore2d_controller.dart';
import 'package:kratos/collision_lab/controller/inelastic_controller.dart';
import 'package:kratos/collision_lab/controller/intro_controller.dart';
import 'package:kratos/collision_lab/model/cl_vec.dart';
import 'package:kratos/collision_lab/widgets/play_area_widget.dart';

/// Visual QA captures including edge-clipping and grid-drag states.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final outDir = Directory(
    'requirements/req-collision-lab/visual-qa/flutter',
  );

  setUpAll(() {
    if (!outDir.existsSync()) outDir.createSync(recursive: true);
  });

  Future<void> capture(
    WidgetTester tester,
    String file,
    CollisionLabController controller,
  ) async {
    controller.model.isPlaying = false;
    await tester.binding.setSurfaceSize(const Size(900, 500));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: CollisionLabColors.screenBackground,
          body: Center(
            child: SizedBox(
              width: 800,
              height: 420,
              child: RepaintBoundary(
                key: ValueKey('capture_$file'),
                child: PlayAreaWidget(controller: controller),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final boundary = tester.renderObject(
      find.byKey(ValueKey('capture_$file')),
    ) as RenderRepaintBoundary;
    final image =
        await tester.runAsync(() => boundary.toImage(pixelRatio: 1.25));
    expect(image, isNotNull);
    final bytes = await tester
        .runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
    File('${outDir.path}/$file.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
    controller.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  }

  testWidgets('intro playarea', (tester) async {
    await capture(tester, 'flutter_intro_playarea', IntroController());
  });

  testWidgets('explore1d playarea', (tester) async {
    await capture(tester, 'flutter_explore1d_playarea', Explore1dController());
  });

  testWidgets('explore2d playarea vectors grid', (tester) async {
    final c = Explore2dController();
    c.setVelocityVectors(true);
    c.setGridVisible(true);
    await capture(tester, 'flutter_explore2d_playarea', c);
  });

  testWidgets('inelastic playarea', (tester) async {
    await capture(tester, 'flutter_inelastic_playarea', InelasticController());
  });

  // A/B — ball near / partially past play-area edge (clipping)
  testWidgets('A ball near edge', (tester) async {
    final c = Explore2dController();
    c.model.playArea.gridVisible = false;
    final b = c.model.ballSystem.balls[0];
    b.position = ClVec(
      c.model.playArea.right - b.radius - 0.02,
      0,
    );
    await capture(tester, 'flutter_qa_A_near_edge', c);
  });

  testWidgets('B ball center outside — partial clip', (tester) async {
    final c = IntroController();
    // Intro has no reflecting border; center outside → partial geometry clipped
    c.model.ballSystem.balls[0].position = const ClVec(2.05, 0);
    c.model.ballSystem.balls[1].position = const ClVec(-0.5, 0);
    await capture(tester, 'flutter_qa_B_partial_outside', c);
  });

  testWidgets('C grid ON drag snap pose', (tester) async {
    final c = Explore2dController();
    c.setGridVisible(true);
    c.dragBall(0, const ClVec(0.26, -0.14));
    c.dragBall(1, const ClVec(-0.54, 0.36));
    await capture(tester, 'flutter_qa_C_grid_on', c);
  });

  testWidgets('D grid OFF drag pose', (tester) async {
    final c = Explore2dController();
    c.model.playArea.gridVisible = false;
    c.dragBall(0, const ClVec(0.26, -0.14));
    await capture(tester, 'flutter_qa_D_grid_off', c);
  });
}

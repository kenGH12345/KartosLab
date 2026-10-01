import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/solute_form.dart';
import 'package:kratos/concentration/view/concentration_layout.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';

/// Captures Phase 3 visual states into `test/concentration/FLUTTER/`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> capture(
    WidgetTester tester,
    ConcentrationModel model,
    String name,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1100, 700));

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox(
                width: ConcentrationLayout.layoutBounds.width,
                height: ConcentrationLayout.layoutBounds.height,
                child: ConcentrationPlayArea(
                  model: model,
                  dispenserLabel: model.solute.displayName,
                  stockColor: stockSolutionColor(model.solute),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 1));
    final bytes =
        await tester.runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));

    final outDir = Directory('test/concentration/FLUTTER');
    outDir.createSync(recursive: true);
    File('${outDir.path}/$name.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
  }

  testWidgets('capture shaker / dropper visual states', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final idle = ConcentrationModel(random: math.Random(1));
    await capture(tester, idle, 'CT_shaker_idle');

    final dispensing = ConcentrationModel(random: math.Random(2));
    dispensing.setShakerPosition(const Offset(370, 165));
    dispensing.step(0.05);
    dispensing.setShakerPosition(const Offset(390, 160));
    dispensing.step(0.05);
    await capture(tester, dispensing, 'CT_shaker_dispensing');

    final particles = ConcentrationModel(random: math.Random(3));
    for (var i = 0; i < 12; i++) {
      particles.setShakerPosition(Offset(340 + i * 4.0, 160));
      particles.step(0.05);
    }
    expect(particles.shakerParticles.count, greaterThan(0));
    await capture(tester, particles, 'CT_shaker_particles');

    final dropIdle = ConcentrationModel(random: math.Random(4));
    dropIdle.setSoluteForm(SoluteForm.solution);
    await capture(tester, dropIdle, 'CT_dropper_idle');

    final dropDisp = ConcentrationModel(random: math.Random(5));
    dropDisp.setSoluteForm(SoluteForm.solution);
    dropDisp.setDropperDispensing(true);
    dropDisp.step(0.1);
    await capture(tester, dropDisp, 'CT_dropper_dispensing');

    final files = Directory('test/concentration/FLUTTER')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .toSet();
    expect(files.contains('CT_shaker_idle.png'), isTrue);
    expect(files.contains('CT_shaker_dispensing.png'), isTrue);
    expect(files.contains('CT_shaker_particles.png'), isTrue);
    expect(files.contains('CT_dropper_idle.png'), isTrue);
    expect(files.contains('CT_dropper_dispensing.png'), isTrue);
  }, timeout: const Timeout(Duration(minutes: 2)));
}

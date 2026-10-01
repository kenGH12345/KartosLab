import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/solute_definitions.dart';
import 'package:kratos/concentration/view/concentration_layout.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';

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
    final bytes = await tester
        .runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
    final outDir = Directory('test/concentration/FLUTTER');
    outDir.createSync(recursive: true);
    File('${outDir.path}/$name.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
  }

  testWidgets('capture saturation / precipitate visual states', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final unsat = ConcentrationModel(random: math.Random(30));
    unsat.setSolute(SoluteDefinitions.copperSulfate);
    unsat.addSoluteAmount(0.4);
    expect(unsat.isSaturated, isFalse);
    await capture(tester, unsat, 'CT_unsaturated');

    final near = ConcentrationModel(random: math.Random(31));
    near.setSolute(SoluteDefinitions.copperSulfate);
    near.addSoluteAmount(0.68);
    expect(near.isSaturated, isFalse);
    expect(near.concentration, closeTo(1.36, 1e-9));
    await capture(tester, near, 'CT_near_saturation');

    final sat = ConcentrationModel(random: math.Random(32));
    sat.setSolute(SoluteDefinitions.copperSulfate);
    sat.addSoluteAmount(0.85);
    expect(sat.isSaturated, isTrue);
    expect(sat.precipitateParticles.count, greaterThan(0));
    await capture(tester, sat, 'CT_saturated');

    final high = ConcentrationModel(random: math.Random(33));
    high.setSolute(SoluteDefinitions.copperSulfate);
    high.addSoluteAmount(4.0);
    expect(high.precipitateParticles.count, greaterThan(100));
    await capture(tester, high, 'CT_precipitate_high');

    final shaker = ConcentrationModel(random: math.Random(34));
    for (var i = 0; i < 15; i++) {
      shaker.setShakerPosition(Offset(340 + i * 4.0, 160));
      shaker.step(0.05);
    }
    expect(shaker.shakerParticles.count, greaterThan(0));
    await capture(tester, shaker, 'CT_shaker_particles');

    final satShake = ConcentrationModel(random: math.Random(35));
    satShake.setSolute(SoluteDefinitions.copperSulfate);
    satShake.addSoluteAmount(1.2);
    for (var i = 0; i < 12; i++) {
      satShake.setShakerPosition(Offset(340 + i * 3.0, 160));
      satShake.step(0.05);
    }
    expect(satShake.isSaturated, isTrue);
    await capture(tester, satShake, 'CT_saturated_shaker');

    final diluted = ConcentrationModel(random: math.Random(36));
    diluted.setSolute(SoluteDefinitions.copperSulfate);
    diluted.addSoluteAmount(0.85);
    expect(diluted.isSaturated, isTrue);
    diluted.setSolventFlowRate(0.25);
    diluted.step(1.6);
    diluted.setSolventFlowRate(0);
    expect(diluted.isSaturated, isFalse);
    await capture(tester, diluted, 'CT_diluted_after_saturation');

    final removed = ConcentrationModel(random: math.Random(37));
    removed.setSolute(SoluteDefinitions.copperSulfate);
    removed.addSoluteAmount(2.0);
    removed.removeSolute();
    expect(removed.precipitateParticles.count, 0);
    await capture(tester, removed, 'CT_removed');

    final files = Directory('test/concentration/FLUTTER')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .toSet();
    for (final name in [
      'CT_unsaturated.png',
      'CT_near_saturation.png',
      'CT_saturated.png',
      'CT_precipitate_high.png',
      'CT_shaker_particles.png',
      'CT_saturated_shaker.png',
      'CT_diluted_after_saturation.png',
      'CT_removed.png',
    ]) {
      expect(files.contains(name), isTrue, reason: name);
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}

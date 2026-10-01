import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/solute_definitions.dart';
import 'package:kratos/concentration/model/solute_form.dart';
import 'package:kratos/concentration/view/concentration_layout.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';

/// Captures Phase 4 water / drain / evaporation visual states.
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

  testWidgets('capture water / drain / evaporation visual states', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final waterLow = ConcentrationModel(random: math.Random(10));
    waterLow.setVolumeDirect(0.35);
    waterLow.setSolventFlowRate(0.08);
    await capture(tester, waterLow, 'CT_water_low');

    final waterHigh = ConcentrationModel(random: math.Random(11));
    waterHigh.setVolumeDirect(0.85);
    waterHigh.setSolventFlowRate(0.25);
    await capture(tester, waterHigh, 'CT_water_high');

    final drain = ConcentrationModel(random: math.Random(12));
    drain.addSoluteAmount(0.4);
    drain.setDrainFlowRate(0.2);
    await capture(tester, drain, 'CT_drain');

    final evap = ConcentrationModel(random: math.Random(13));
    evap.setSolute(SoluteDefinitions.drinkMix);
    evap.addSoluteAmount(0.35);
    evap.setEvaporationRate(0.2);
    await capture(tester, evap, 'CT_evaporation');

    final sat = ConcentrationModel(random: math.Random(14));
    sat.setSolute(SoluteDefinitions.copperSulfate);
    sat.addSoluteAmount(0.6);
    sat.setEvaporationRate(0.25);
    sat.step(0.5);
    sat.releaseEvaporation();
    expect(sat.isSaturated, isTrue);
    expect(sat.precipitateParticles.count, greaterThan(0));
    await capture(tester, sat, 'CT_evaporation_saturated');

    final empty = ConcentrationModel(random: math.Random(15));
    empty.setVolumeDirect(0);
    empty.step(0);
    await capture(tester, empty, 'CT_empty');

    // Keep Phase 3 assets present when this suite runs alone.
    final shaker = ConcentrationModel(random: math.Random(1));
    await capture(tester, shaker, 'CT_shaker_idle');
    shaker.setSoluteForm(SoluteForm.solution);
    await capture(tester, shaker, 'CT_dropper_idle');

    final files = Directory('test/concentration/FLUTTER')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .toSet();
    for (final name in [
      'CT_water_low.png',
      'CT_water_high.png',
      'CT_drain.png',
      'CT_evaporation.png',
      'CT_evaporation_saturated.png',
      'CT_empty.png',
    ]) {
      expect(files.contains(name), isTrue, reason: name);
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}

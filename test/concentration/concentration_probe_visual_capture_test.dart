import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/model/concentration_constants.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/solute_definitions.dart';
import 'package:kratos/concentration/model/solute_form.dart';
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

  testWidgets('capture probe / meter visual states', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final outside = ConcentrationModel(random: math.Random(20));
    await capture(tester, outside, 'CT_probe_outside');

    final solution = ConcentrationModel(random: math.Random(21));
    solution.addSoluteAmount(0.5);
    solution.setProbePosition(
      Offset(solution.beaker.position.dx, solution.beaker.position.dy - 40),
    );
    expect(solution.meter.value, isNotNull);
    await capture(tester, solution, 'CT_probe_solution');

    final water = ConcentrationModel(random: math.Random(22));
    water.setSolventFlowRate(0.25);
    water.setProbePosition(
      water.solventFaucet.position + const Offset(0, 40),
    );
    expect(water.meter.value, 0);
    await capture(tester, water, 'CT_probe_water');

    final stock = ConcentrationModel(random: math.Random(23));
    stock.setSoluteForm(SoluteForm.solution);
    stock.setDropperDispensing(true);
    stock.setProbePosition(stock.dropper.position + const Offset(0, 30));
    expect(stock.meter.value, isNotNull);
    await capture(tester, stock, 'CT_probe_stock');

    final drain = ConcentrationModel(random: math.Random(24));
    drain.addSoluteAmount(0.4);
    drain.setDrainFlowRate(0.2);
    drain.setProbePosition(drain.drainFaucet.position + const Offset(0, 40));
    expect(drain.meter.value, isNotNull);
    await capture(tester, drain, 'CT_probe_drain');

    final sat = ConcentrationModel(random: math.Random(25));
    sat.setSolute(SoluteDefinitions.copperSulfate);
    sat.addSoluteAmount(1.0);
    sat.setProbePosition(
      Offset(sat.beaker.position.dx, sat.beaker.position.dy - 30),
    );
    expect(sat.meter.value, closeTo(1.38, 1e-9));
    await capture(tester, sat, 'CT_probe_saturated');

    final files = Directory('test/concentration/FLUTTER')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .toSet();
    for (final name in [
      'CT_probe_outside.png',
      'CT_probe_solution.png',
      'CT_probe_water.png',
      'CT_probe_stock.png',
      'CT_probe_drain.png',
      'CT_probe_saturated.png',
    ]) {
      expect(files.contains(name), isTrue, reason: name);
    }

    // Sanity: initial outside uses drag bounds constant
    expect(
      outside.meter.probePosition,
      ConcentrationConstants.probeInitialPosition,
    );
  }, timeout: const Timeout(Duration(minutes: 2)));
}

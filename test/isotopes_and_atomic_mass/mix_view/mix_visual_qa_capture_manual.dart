/// Manual visual QA capture (not part of default suite).
/// Run:
///   flutter test test/isotopes_and_atomic_mass/mix_view/mix_visual_qa_capture_manual.dart --timeout 300s
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/controller/mixtures_controller.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/iaam_constants.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/interactivity_mode.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/screens/mix_isotopes_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final boundaryKey = GlobalKey();

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pump();
    final boundary =
        boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory(
      'requirements/req-isotopes-and-atomic-mass/visual-qa/V2',
    );
    if (!dir.existsSync()) dir.createSync(recursive: true);
    await File('${dir.path}/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
  }

  testWidgets('capture mix visual QA matrix (no Nature toImage)', (tester) async {
    final c = MixturesController();
    await tester.binding.setSurfaceSize(
      const Size(IaamConstants.layoutWidth, IaamConstants.layoutHeight),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            key: boundaryKey,
            child: SizedBox(
              width: IaamConstants.layoutWidth,
              height: IaamConstants.layoutHeight,
              child: ListenableBuilder(
                listenable: c,
                builder: (context, child) => MixIsotopesScreen(
                  controller: c,
                  embedded: true,
                  tickOnClock: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await shot(tester, 'mix_initial');
    c.selectElement(6);
    await shot(tester, 'mix_element_selected');
    await shot(tester, 'mix_bucket_mode');
    c.moveBucketToChamber(12);
    await shot(tester, 'mix_single_isotope');
    c.moveBucketToChamber(12);
    c.moveBucketToChamber(13);
    await shot(tester, 'mix_two_isotopes');
    c.setInteractivityMode(InteractivityMode.slidersAndSmallAtoms);
    await shot(tester, 'mix_slider_mode');
    c.setIsotopeQuantity(12, 30);
    c.setIsotopeQuantity(13, 20);
    await shot(tester, 'mix_multiple_isotopes');
    // Nature: set state for restore path but skip expensive toImage of ~1000 arcs
    c.setShowingNaturesMix(true);
    await tester.pump();
    expect(c.model.chamberParticles.length, greaterThan(900));
    // Lightweight stub marker file for Nature (device QA owns full frame)
    await File(
      'requirements/req-isotopes-and-atomic-mass/visual-qa/V2/mix_nature.txt',
    ).writeAsString(
      'Nature mix particles=${c.model.chamberParticles.length}; capture on device APK',
    );
    c.setShowingNaturesMix(false);
    await shot(tester, 'mix_my_mix_restore');
    c.clear();
    await shot(tester, 'mix_clear');
    c.reset();
    await shot(tester, 'mix_reset');
  });
}

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/keplers_laws/controller/keplers_laws_controller.dart';
import 'package:kratos/astronomy/keplers_laws/model/law_mode.dart';
import 'package:kratos/astronomy/keplers_laws/screens/keplers_laws_screen.dart';

/// Captures actual Flutter frames to visual-qa/flutter/.
/// Not goldens; not layout constants derived from pixels.
/// Text is Ahem (white bars) in widget tests; geometry is still valid.
void main() {
  Future<void> capture(
    WidgetTester tester, {
    required String name,
    required Widget child,
  }) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(key: key, child: child),
      ),
    );
    await tester.pump();

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('requirements/req-keplers-laws/visual-qa/flutter');
      dir.createSync(recursive: true);
      File('${dir.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  testWidgets('capture first-law default 1024x768', (tester) async {
    await capture(
      tester,
      name: 'first-law-default-1024x768',
      child: const KeplersLawsScreen(initialLaw: LawMode.first),
    );
  });

  testWidgets('capture first-law composition foci/string/e', (tester) async {
    final c = KeplersLawsController(initialLaw: LawMode.first);
    c.visible.fociVisible = true;
    c.visible.stringChecked = true;
    c.visible.eccentricityVisible = true;
    c.visible.axesVisible = true;
    c.visible.semiaxesChecked = true;
    await capture(
      tester,
      name: 'first-law-composition-1024x768',
      child: KeplersLawsScreen(
        initialLaw: LawMode.first,
        controller: c,
      ),
    );
  });

  testWidgets('capture second-law default 1024x768', (tester) async {
    await capture(
      tester,
      name: 'second-law-default-1024x768',
      child: const KeplersLawsScreen(initialLaw: LawMode.second),
    );
  });

  testWidgets('capture third-law default 1024x768', (tester) async {
    await capture(
      tester,
      name: 'third-law-default-1024x768',
      child: const KeplersLawsScreen(initialLaw: LawMode.third),
    );
  });
}

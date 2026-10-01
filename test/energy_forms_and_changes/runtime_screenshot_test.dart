import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';
import 'package:kratos/energy_forms_and_changes/intro/screens/intro_screen_body.dart';
import 'package:kratos/energy_forms_and_changes/screens/energy_forms_and_changes_home.dart';
import 'package:kratos/energy_forms_and_changes/systems/screens/systems_screen_body.dart';
import 'package:kratos/energy_forms_and_changes/widgets/efac_simulation_shell.dart';

import 'efac_runtime_fixtures.dart';

/// Dual QA paths for EFAC coordinate shell.
///
/// 1) Design-space: body at 1024×618 (object / Scene Graph geometry)
/// 2) Live-shell: Home → AppBar/TabBar → EfacSimulationShell → scene
///
/// Note: widget tests use Ahem font → Latin text as black rectangles.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final designDir = Directory(
    'requirements/req-energy-forms-and-changes/visual-qa/runtime/flutter',
  );
  final liveDir = Directory(
    'requirements/req-energy-forms-and-changes/visual-qa/runtime/flutter/live_shell',
  );

  setUpAll(() {
    if (!designDir.existsSync()) designDir.createSync(recursive: true);
    if (!liveDir.existsSync()) liveDir.createSync(recursive: true);
  });

  Future<void> warmImageCache(List<String> paths) async {
    await Future.wait(paths.map((path) async {
      final provider = AssetImage(path);
      final stream = provider.resolve(ImageConfiguration.empty);
      final done = Completer<void>();
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          if (!done.isCompleted) done.complete();
          stream.removeListener(listener);
        },
        onError: (error, stack) {
          if (!done.isCompleted) done.completeError(error, stack);
          stream.removeListener(listener);
        },
      );
      stream.addListener(listener);
      await done.future.timeout(const Duration(seconds: 10));
    }));
  }

  final criticalAssets = <String>[
    EfacAssets.shelf,
    EfacAssets.gasPipeIntro,
    EfacAssets.ironTextureFront,
    EfacAssets.ironTextureRight,
    EfacAssets.ironTextureTop,
    EfacAssets.brickTextureFront,
    EfacAssets.brickTextureRight,
    EfacAssets.brickTextureTop,
    EfacAssets.flame,
    EfacAssets.iceCubeStack,
    EfacAssets.energyThermal,
    EfacAssets.png('bicycleFrame'),
    EfacAssets.png('bicycleGear'),
    EfacAssets.png('bicycleSpokes'),
    EfacAssets.png('cyclistTorso'),
    EfacAssets.png('cyclistLegFront01'),
    EfacAssets.png('cyclistLegBack01'),
    EfacAssets.png('generator'),
    EfacAssets.png('generatorWheelSpokes'),
    EfacAssets.png('generatorWheelHub'),
    EfacAssets.png('wireBottomLeft'),
    EfacAssets.png('connector'),
    EfacAssets.png('wireStraight'),
    EfacAssets.png('wireBottomRightShort'),
    EfacAssets.png('elementBaseBack'),
    EfacAssets.png('elementBaseFront'),
    EfacAssets.png('heaterElement'),
    EfacAssets.png('heaterElementDark'),
    EfacAssets.bicycleIcon,
    EfacAssets.faucetIcon,
    EfacAssets.sunIcon,
    EfacAssets.teaKettleIcon,
    EfacAssets.generatorIcon,
    EfacAssets.solarPanelIcon,
    EfacAssets.waterIcon,
    EfacAssets.incandescentIcon,
    EfacAssets.fluorescentIcon,
    EfacAssets.fanIcon,
    EfacAssets.png('incandescent'),
    EfacAssets.png('incandescentOn'),
    EfacAssets.png('fluorescentFront'),
    EfacAssets.png('fluorescentBack'),
    EfacAssets.png('fluorescentOnFront'),
    EfacAssets.png('fluorescentOnBack'),
    for (var i = 1; i <= 6; i++) ...[
      EfacAssets.png('cyclistLegFront${i.toString().padLeft(2, '0')}'),
      EfacAssets.png('cyclistLegBack${i.toString().padLeft(2, '0')}'),
    ],
  ];

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> writeBoundary(
    WidgetTester tester,
    GlobalKey key,
    File file,
  ) async {
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(8000));
    });
  }

  /// Path A — design-space: direct body @ 1024×618 (no Home / shell).
  Future<void> captureDesign(
    WidgetTester tester,
    Widget body,
    String name,
  ) async {
    final key = GlobalKey();
    await tester.binding.setSurfaceSize(
      const Size(EfacConstants.layoutWidth, EfacConstants.layoutHeight),
    );
    await tester.runAsync(() => warmImageCache(criticalAssets));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: EfacConstants.layoutWidth,
              height: EfacConstants.layoutHeight,
              child: body,
            ),
          ),
        ),
      ),
    );
    await settle(tester);
    await writeBoundary(tester, key, File('${designDir.path}/$name.png'));
  }

  /// Path B — live-shell: Home → chrome → EfacSimulationShell.
  Future<void> captureLiveShell(
    WidgetTester tester, {
    required String name,
    required bool systemsTab,
  }) async {
    final homeKey = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.runAsync(() => warmImageCache(criticalAssets));

    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: homeKey,
          child: const EnergyFormsAndChangesHome(),
        ),
      ),
    );
    await settle(tester);

    if (systemsTab) {
      await tester.tap(find.text(EfacStrings.systems));
      await settle(tester);
    }

    expect(find.byType(EfacSimulationShell), findsWidgets);

    // Full Home (AppBar + TabBar + shell viewport).
    await writeBoundary(
      tester,
      homeKey,
      File('${liveDir.path}/$name.png'),
    );

    // Visible shell viewport (PhET layout() region). TabBarView may keep
    // both tabs mounted; pick the boundary with non-zero paint size.
    final boundaries = find.byKey(
      const ValueKey<String>('efac_simulation_shell_boundary'),
    );
    expect(boundaries, findsWidgets);
    RenderRepaintBoundary? shellRb;
    for (final element in boundaries.evaluate()) {
      final ro = element.renderObject! as RenderRepaintBoundary;
      if (ro.size.width > 1 && ro.size.height > 1) {
        shellRb = ro;
        break;
      }
    }
    expect(shellRb, isNotNull);

    await tester.runAsync(() async {
      final image = await shellRb!.toImage(pixelRatio: 1.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('${liveDir.path}/${name}_viewport.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(8000));
      // Live viewport must not be forced to exact design size.
      expect(image.width, isNot(equals(EfacConstants.layoutWidth.toInt())));
    });
  }

  // ——— Design-space (fixed fixtures — see efac_runtime_fixtures.dart) ———

  testWidgets('design-space: Intro initial', (tester) async {
    await captureDesign(
      tester,
      IntroScreenBody(controller: EfacRuntimeFixtures.introInitial()),
      'intro_initial',
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('design-space: Intro heater active', (tester) async {
    final c = EfacRuntimeFixtures.introHeaterActive();
    expect(c.model.linkedHeaters, isTrue);
    expect(c.model.rightBurner.heatCoolLevel, closeTo(1.0, 1e-9));
    expect(c.model.thermometers[0].isFollowing, isTrue);
    await captureDesign(
      tester,
      IntroScreenBody(controller: c),
      'intro_heater_active',
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('design-space: Intro thermometer attached', (tester) async {
    await captureDesign(
      tester,
      IntroScreenBody(
        controller: EfacRuntimeFixtures.introThermometerAttached(),
      ),
      'intro_thermometer_attached',
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('design-space: Intro linked heaters', (tester) async {
    await captureDesign(
      tester,
      IntroScreenBody(controller: EfacRuntimeFixtures.introLinkedHeaters()),
      'intro_linked_heaters',
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('design-space: Intro after reset', (tester) async {
    await captureDesign(
      tester,
      IntroScreenBody(controller: EfacRuntimeFixtures.introAfterReset()),
      'intro_after_reset',
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('design-space: Systems initial', (tester) async {
    await captureDesign(
      tester,
      SystemsScreenBody(controller: EfacRuntimeFixtures.systemsBikeReset()),
      'systems_initial',
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('design-space: Systems bike active', (tester) async {
    await captureDesign(
      tester,
      SystemsScreenBody(controller: EfacRuntimeFixtures.systemsBikeActive()),
      'systems_bike_active',
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('design-space: Systems selector faucet', (tester) async {
    await captureDesign(
      tester,
      SystemsScreenBody(
        controller: EfacRuntimeFixtures.systemsSelectorFaucet(),
      ),
      'systems_selector_faucet',
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('design-space: Systems after reset', (tester) async {
    await captureDesign(
      tester,
      SystemsScreenBody(controller: EfacRuntimeFixtures.systemsAfterReset()),
      'systems_after_reset',
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  // ——— Live-shell ———

  testWidgets('live-shell: Intro Home @ 1280×800', (tester) async {
    await captureLiveShell(
      tester,
      name: 'intro_home_1280x800',
      systemsTab: false,
    );
  }, timeout: const Timeout(Duration(seconds: 90)));

  testWidgets('live-shell: Systems Home @ 1280×800', (tester) async {
    await captureLiveShell(
      tester,
      name: 'systems_home_1280x800',
      systemsTab: true,
    );
  }, timeout: const Timeout(Duration(seconds: 90)));
}

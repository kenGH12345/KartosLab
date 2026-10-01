import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/diffusion/diffusion_constants.dart';
import 'package:kratos/diffusion/model/diffusion_model.dart';
import 'package:kratos/diffusion/widgets/diffusion_shell.dart';

import '../controller/gas_simulation_controller.dart';
import '../gas_properties_colors.dart';
import '../model/hold_constant.dart';
import '../model/ideal_gas_law_model.dart';
import '../model/random_source.dart';
import '../transform/gas_coordinate_transform.dart';
import '../widgets/gas_ideal_family_shell.dart';

/// Desktop capture entry:
/// `flutter run -d windows -t lib/gas_properties/screens/gas_properties_capture_main.dart`
///
/// Writes PNGs to:
/// `requirements/req-gas-properties/screenshots/*/flutter/`
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _CaptureApp(),
  ));
}

class _CaptureApp extends StatefulWidget {
  const _CaptureApp();

  @override
  State<_CaptureApp> createState() => _CaptureAppState();
}

class _CaptureAppState extends State<_CaptureApp> {
  final _keys = List.generate(8, (_) => GlobalKey());
  String _status = 'preparing…';

  late final GasSimulationController ideal;
  late final GasSimulationController idealHold;
  late final GasSimulationController explore;
  late final GasSimulationController exploreWall;
  late final GasSimulationController energy;
  late final GasSimulationController energyHist;
  late final DiffusionModel diffusion;
  late final DiffusionModel diffusionOpen;

  @override
  void initState() {
    super.initState();
    ideal = GasSimulationController(
      profile: IdealGasProfile.ideal,
      random: RandomSource(1),
      autoTick: false,
    );
    idealHold = GasSimulationController(
      profile: IdealGasProfile.ideal,
      random: RandomSource(1),
      autoTick: false,
    )..setNumberHeavy(80)
      ..setNumberLight(40)
      ..setHoldConstant(HoldConstant.temperature);
    idealHold.model.advance(0.2);
    idealHold.setStopwatchVisible(false);

    explore = GasSimulationController(
      profile: IdealGasProfile.explore,
      random: RandomSource(2),
      autoTick: false,
    );
    exploreWall = GasSimulationController(
      profile: IdealGasProfile.explore,
      random: RandomSource(2),
      autoTick: false,
    )..setNumberHeavy(60)
      ..setWallVelocityVisible(true);
    exploreWall.beginWidthAdjust();
    exploreWall.setWidthDuringAdjust(7500);

    energy = GasSimulationController(
      profile: IdealGasProfile.energy,
      random: RandomSource(3),
      autoTick: false,
    );
    energyHist = GasSimulationController(
      profile: IdealGasProfile.energy,
      random: RandomSource(3),
      autoTick: false,
    )..setNumberHeavy(100)
      ..setNumberLight(80);
    for (var i = 0; i < 20; i++) {
      energyHist.model.advance(0.2);
    }
    energyHist.setStopwatchVisible(false);

    diffusion = DiffusionModel(autoTick: false)
      ..setLeftCount(40)
      ..setRightCount(40)
      ..setCenterOfMassVisible(true);

    diffusionOpen = DiffusionModel(autoTick: false)
      ..setLeftCount(40)
      ..setRightCount(40)
      ..setHasDivider(false)
      ..setParticleFlowRateVisible(true)
      ..setCenterOfMassVisible(true);
    for (var i = 0; i < 30; i++) {
      diffusionOpen.stepModelTime(0.2);
    }
    diffusionOpen.setCenterOfMassVisible(true);

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      await _captureAll();
    });
  }

  @override
  void dispose() {
    ideal.dispose();
    idealHold.dispose();
    explore.dispose();
    exploreWall.endWidthAdjust();
    exploreWall.dispose();
    energy.dispose();
    energyHist.dispose();
    diffusion.dispose();
    diffusionOpen.dispose();
    super.dispose();
  }

  Future<void> _captureAll() async {
    final pairs = <(GlobalKey, String, String)>[
      (_keys[0], 'ideal', 'initial'),
      (_keys[1], 'ideal', 'hold_temperature'),
      (_keys[2], 'explore', 'initial'),
      (_keys[3], 'explore', 'moving_wall'),
      (_keys[4], 'energy', 'initial'),
      (_keys[5], 'energy', 'histogram_populated'),
      (_keys[6], 'diffusion', 'initial'),
      (_keys[7], 'diffusion', 'partition_removed'),
    ];
    for (final (key, screen, name) in pairs) {
      await _save(key, screen, name);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    setState(() => _status = 'DONE — check screenshots/*/flutter');
  }

  Future<void> _save(GlobalKey key, String screen, String name) async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final root = Directory(
      'requirements/req-gas-properties/screenshots/$screen/flutter',
    );
    // When running from build/, resolve repo root via script location heuristic.
    Directory out = root;
    if (!out.existsSync()) {
      out = Directory(
        '${Directory.current.path}/requirements/req-gas-properties/screenshots/$screen/flutter',
      );
    }
    // Prefer absolute project path
    final abs = Directory(
      r'D:\OneDrive\Desktop\KartosLab\KartosLab\requirements\req-gas-properties\screenshots\'
      '$screen\\flutter',
    );
    abs.createSync(recursive: true);
    final file = File('${abs.path}\\$name.png');
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    // ignore: avoid_print
    print('CAPTURED ${file.path} (${file.lengthSync()})');
    setState(() => _status = 'wrote $screen/$name');
  }

  Widget _box(GlobalKey key, Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: RepaintBoundary(
        key: key,
        child: SizedBox(
          width: GasLayoutPolicy.logicalWidth,
          height: GasLayoutPolicy.logicalHeight,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_status),
        backgroundColor: const Color(GasPropertiesColors.accent),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _box(keys0, GasIdealFamilyShell(controller: ideal, layoutScale: 1)),
            _box(keys1, GasIdealFamilyShell(controller: idealHold, layoutScale: 1)),
            _box(keys2, GasIdealFamilyShell(controller: explore, layoutScale: 1)),
            _box(
              keys3,
              GasIdealFamilyShell(controller: exploreWall, layoutScale: 1),
            ),
            _box(keys4, GasIdealFamilyShell(controller: energy, layoutScale: 1)),
            _box(
              keys5,
              GasIdealFamilyShell(controller: energyHist, layoutScale: 1),
            ),
            _box(
              keys6,
              SizedBox(
                width: DiffusionConstants.layoutWidth,
                height: DiffusionConstants.layoutHeight,
                child: DiffusionShell(model: diffusion),
              ),
            ),
            _box(
              keys7,
              SizedBox(
                width: DiffusionConstants.layoutWidth,
                height: DiffusionConstants.layoutHeight,
                child: DiffusionShell(model: diffusionOpen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GlobalKey get keys0 => _keys[0];
  GlobalKey get keys1 => _keys[1];
  GlobalKey get keys2 => _keys[2];
  GlobalKey get keys3 => _keys[3];
  GlobalKey get keys4 => _keys[4];
  GlobalKey get keys5 => _keys[5];
  GlobalKey get keys6 => _keys[6];
  GlobalKey get keys7 => _keys[7];
}

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import '../controller/atomic_interactions_controller.dart';
import '../controller/phase_changes_controller.dart';
import '../controller/states_of_matter_controller.dart';
import '../model/dual_atom_model.dart';
import '../model/force_display_mode.dart';
import '../model/multiple_particle_model.dart';
import '../model/phase_changes_model.dart';
import '../model/phase_state.dart';
import '../model/som_random.dart';
import '../model/substance_type.dart';
import '../som_constants.dart';
import '../transform/som_coordinate_transform.dart';
import 'atomic_interactions_screen.dart';
import 'phase_changes_screen.dart';
import 'states_screen.dart';

/// Desktop / headless-friendly Visual QA capture entry.
///
/// ```
/// flutter run -d windows -t lib/chemistry/states_of_matter/screens/states_of_matter_capture_main.dart
/// ```
///
/// Prefer the widget-test harness when `flutter run` is flaky:
/// `tool/run_som_capture.bat`
///
/// Critical: every shot pauses the simulation before PNG write — particles move.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _SomCaptureApp(),
  ));
}

const _outAbs = r'D:\OneDrive\Desktop\KartosLab\KartosLab\requirements\req-states-of-matter\visual-qa\FLUTTER';
const _viewport = Size(1280, 800);
const _dpr = 1.0;

class _SomCaptureApp extends StatefulWidget {
  const _SomCaptureApp();

  @override
  State<_SomCaptureApp> createState() => _SomCaptureAppState();
}

class _SomCaptureAppState extends State<_SomCaptureApp>
    with TickerProviderStateMixin {
  final _key = GlobalKey();
  String _status = 'preparing…';
  Widget? _current;
  String? _currentName;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await _captureAll();
    });
  }

  StatesOfMatterController _states({int seed = 42}) {
    final c = StatesOfMatterController(
      model: MultipleParticleModel(
        random: SomRandom(seed),
        validSubstances: const {
          SubstanceType.neon,
          SubstanceType.argon,
          SubstanceType.diatomicOxygen,
          SubstanceType.water,
        },
      ),
    );
    c.attach(this);
    return c;
  }

  PhaseChangesController _phase({int seed = 42}) {
    final c = PhaseChangesController(
      model: PhaseChangesModel(random: SomRandom(seed)),
    );
    c.attach(this);
    return c;
  }

  AtomicInteractionsController _interaction() {
    final c = AtomicInteractionsController(model: DualAtomModel());
    c.attach(this);
    return c;
  }

  void _step(MultipleParticleModel m, int frames) {
    for (var i = 0; i < frames; i++) {
      m.step(SomConstants.nominalTimeStep);
    }
  }

  Future<void> _showAndCapture(
    String name,
    Widget Function() buildScreen,
  ) async {
    setState(() {
      _status = 'capturing $name';
      _currentName = name;
      _current = buildScreen();
    });
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _save(name);
  }

  Future<void> _captureAll() async {
    Directory(_outAbs).createSync(recursive: true);

    // 01 neon solid initial (default substance/temp = solid)
    {
      final c = _states();
      c.setPlaying(false);
      await _showAndCapture(
        '01_States_neon_solid_initial',
        () => StatesScreen(controller: c),
      );
      c.dispose();
    }

    // 02 neon liquid
    {
      final c = _states();
      c.setPhase(PhaseState.liquid);
      c.setPlaying(false);
      await _showAndCapture(
        '02_States_neon_liquid',
        () => StatesScreen(controller: c),
      );
      c.dispose();
    }

    // 03 neon gas
    {
      final c = _states();
      c.setPhase(PhaseState.gas);
      c.setPlaying(false);
      await _showAndCapture(
        '03_States_neon_gas',
        () => StatesScreen(controller: c),
      );
      c.dispose();
    }

    // 04 argon solid
    {
      final c = _states(seed: 43);
      c.setSubstance(SubstanceType.argon);
      c.setPhase(PhaseState.solid);
      c.setPlaying(false);
      await _showAndCapture(
        '04_States_argon_solid',
        () => StatesScreen(controller: c),
      );
      c.dispose();
    }

    // 05 oxygen solid
    {
      final c = _states(seed: 44);
      c.setSubstance(SubstanceType.diatomicOxygen);
      c.setPhase(PhaseState.solid);
      c.setPlaying(false);
      await _showAndCapture(
        '05_States_oxygen_solid',
        () => StatesScreen(controller: c),
      );
      c.dispose();
    }

    // 06 water solid
    {
      final c = _states(seed: 45);
      c.setSubstance(SubstanceType.water);
      c.setPhase(PhaseState.solid);
      c.setPlaying(false);
      await _showAndCapture(
        '06_States_water_solid',
        () => StatesScreen(controller: c),
      );
      c.dispose();
    }

    // 07 heated then paused (heater cleared on pause; T / particles remain hot)
    {
      final c = _states();
      c.setPlaying(true);
      c.setHeatingCoolingAmount(1.0);
      _step(c.model, 90);
      c.setPlaying(false);
      await _showAndCapture(
        '07_States_heated',
        () => StatesScreen(controller: c),
      );
      c.dispose();
    }

    // 08 paused after short run
    {
      final c = _states();
      c.setPlaying(true);
      _step(c.model, 30);
      c.setPlaying(false);
      await _showAndCapture(
        '08_States_paused',
        () => StatesScreen(controller: c),
      );
      c.dispose();
    }

    // 09 reset
    {
      final c = _states();
      c.setSubstance(SubstanceType.argon);
      c.setPhase(PhaseState.gas);
      _step(c.model, 10);
      c.resetAll();
      c.setPlaying(false);
      await _showAndCapture(
        '09_States_reset',
        () => StatesScreen(controller: c),
      );
      c.dispose();
    }

    // 10 Phase Changes initial
    {
      final c = _phase();
      c.setPlaying(false);
      await _showAndCapture(
        '10_PhaseChanges_initial',
        () => PhaseChangesScreen(controller: c),
      );
      c.dispose();
    }

    // 11 compressed
    {
      final c = _phase(seed: 50);
      c.setPlaying(true);
      c.setTargetContainerHeight(5000);
      _step(c.model, 240);
      c.setPlaying(false);
      await _showAndCapture(
        '11_PhaseChanges_compressed',
        () => PhaseChangesScreen(controller: c),
      );
      c.dispose();
    }

    // 12 adjustable atom
    {
      final c = _phase(seed: 51);
      c.setSubstance(SubstanceType.adjustableAtom);
      c.setEpsilon(200);
      c.setPlaying(false);
      await _showAndCapture(
        '12_PhaseChanges_adjustable',
        () => PhaseChangesScreen(controller: c),
      );
      c.dispose();
    }

    // 13 Interaction neon initial
    {
      final c = _interaction();
      c.setPlaying(false);
      await _showAndCapture(
        '13_Interaction_neon_initial',
        () => AtomicInteractionsScreen(controller: c),
      );
      c.dispose();
    }

    // 14 forces total (drag so force arrows are visible)
    {
      final c = _interaction();
      c.setForcesDisplayMode(ForceDisplayMode.total);
      c.dragTo(400);
      c.endDrag();
      c.setPlaying(false);
      await _showAndCapture(
        '14_Interaction_forces_total',
        () => AtomicInteractionsScreen(controller: c),
      );
      c.dispose();
    }

    // 15 Interaction reset
    {
      final c = _interaction();
      c.setForcesDisplayMode(ForceDisplayMode.components);
      c.dragTo(350);
      c.endDrag();
      c.resetAll();
      c.setPlaying(false);
      await _showAndCapture(
        '15_Interaction_reset',
        () => AtomicInteractionsScreen(controller: c),
      );
      c.dispose();
    }

    setState(() {
      _status = 'DONE — $_outAbs';
      _current = null;
      _currentName = null;
    });
    // ignore: avoid_print
    print('SOM CAPTURE COMPLETE → $_outAbs');
  }

  Future<void> _save(String name) async {
    final ctx = _key.currentContext;
    if (ctx == null) {
      // ignore: avoid_print
      print('SKIP $name — no context');
      return;
    }
    final boundary = ctx.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: _dpr);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final dir = Directory(_outAbs)..createSync(recursive: true);
    final file = File('${dir.path}\\$name.png');
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    File('${dir.path}\\$name.meta.txt').writeAsStringSync(
      [
        'state: $name',
        'viewport: ${_viewport.width.toInt()}x${_viewport.height.toInt()}',
        'DPR: $_dpr',
        'design: ${SomCoordinateTransform.layoutBoundsWidth}x'
            '${SomCoordinateTransform.layoutBoundsHeight}',
        'paused: true',
        'source: states_of_matter_capture_main',
        'captured_at: ${DateTime.now().toIso8601String()}',
      ].join('\n'),
    );
    // ignore: avoid_print
    print('CAPTURED ${file.path} (${file.lengthSync()})');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_status),
        backgroundColor: const Color(0xFF1177AA),
      ),
      body: Center(
        child: SizedBox(
          width: _viewport.width,
          height: _viewport.height,
          child: RepaintBoundary(
            key: _key,
            child: _current ??
                ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      _currentName == null ? _status : '…',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

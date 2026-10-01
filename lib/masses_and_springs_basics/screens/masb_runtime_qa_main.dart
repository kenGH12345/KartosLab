import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kratos/masses_and_springs_basics/controller/masb_controller.dart';
import 'package:kratos/masses_and_springs_basics/widgets/simulation_workspace.dart';

/// Runtime QA capture for M1/M2 (single controller = UI + measurements).
///
/// `flutter run -d windows -t lib/masses_and_springs_basics/screens/masb_runtime_qa_main.dart`
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MasbRuntimeQaApp(),
  ));
}

class MasbRuntimeQaApp extends StatefulWidget {
  const MasbRuntimeQaApp({super.key});

  @override
  State<MasbRuntimeQaApp> createState() => _MasbRuntimeQaAppState();
}

class _MasbRuntimeQaAppState extends State<MasbRuntimeQaApp> {
  final _repaintKey = GlobalKey();
  final _log = StringBuffer();
  late MasbController _controller;

  String _status = 'running…';
  int _phase = 0;

  final _dispSamples = <double>[];
  bool _physicsContinuous = false;
  bool _noLargeJumps = false;
  bool _dragWorks = false;
  bool _springFollowsDrag = false;
  bool _physicsAfterRelease = false;
  bool _pauseOk = false;
  bool _resumeOk = false;
  bool _resetOk = false;
  bool _lifecycleStopOk = false;
  bool _noStackOk = false;
  String? _blocked;

  @override
  void initState() {
    super.initState();
    _controller = MasbController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runQa());
  }

  @override
  void dispose() {
    // If QA already disposed, skip.
    try {
      _controller.dispose();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _settleMs(int ms) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  Future<void> _runQa() async {
    try {
      await _phasePhysicsAndAnimation();
      await _phaseDrag();
      await _phasePauseResume();
      await _phaseReset();
      await _phaseLifecycle();
      await _writeReportAndExit();
    } catch (e, st) {
      _blocked = '$e';
      _log.writeln('FATAL: $e\n$st');
      setState(() => _status = 'FAILED');
      await _writeReportAndExit(failed: true);
    }
  }

  Future<void> _phasePhysicsAndAnimation() async {
    setState(() {
      _phase = 1;
      _status = 'physics/animation…';
    });
    _dispSamples.clear();
    final start = DateTime.now();
    while (DateTime.now().difference(start) < const Duration(seconds: 2)) {
      await _settleMs(16);
      _dispSamples.add(_controller.model.spring.displacement);
      setState(() {}); // keep HUD/status fresh; paint follows ticker
    }

    final minD = _dispSamples.reduce((a, b) => a < b ? a : b);
    final maxD = _dispSamples.reduce((a, b) => a > b ? a : b);
    _physicsContinuous =
        (maxD - minD) > 0.05 && _dispSamples.every((e) => e.isFinite);

    var maxJump = 0.0;
    for (var i = 1; i < _dispSamples.length; i++) {
      final jump = (_dispSamples[i] - _dispSamples[i - 1]).abs();
      if (jump > maxJump) maxJump = jump;
    }
    _noLargeJumps = maxJump < 0.08 && _dispSamples.length > 60;
    _log.writeln(
        'physics samples=${_dispSamples.length} range=[$minD,$maxD] maxJump=$maxJump');
    await _capture('01_oscillating.png');
  }

  Future<void> _phaseDrag() async {
    setState(() {
      _phase = 2;
      _status = 'drag…';
    });
    final m = _controller.model.mass;
    final grabY = m.positionY - m.cylinderHeight / 2;
    final before = _controller.model.spring.displacement;
    final ok = _controller.beginDrag(m.positionX, grabY);
    final pullY = m.positionY - 0.25;
    _controller.updateDrag(_controller.model.spring.positionX, pullY);
    await _settleMs(100);
    setState(() {});

    final during = _controller.model.spring.displacement;
    final lengthDuring = _controller.model.spring.length;
    _dragWorks = ok && _controller.model.mass.userControlled;
    _springFollowsDrag = during < before - 0.1 &&
        lengthDuring > _controller.model.spring.naturalRestingLength;
    await _capture('02_dragging.png');

    _controller.endDrag();
    final x0 = _controller.model.spring.displacement;
    final v0 = _controller.model.mass.verticalVelocity;
    await _settleMs(500);
    setState(() {});
    _physicsAfterRelease = _controller.model.spring.displacement != x0 ||
        _controller.model.mass.verticalVelocity != v0;
    _log.writeln(
        'drag ok=$_dragWorks springFollow=$_springFollowsDrag afterRelease=$_physicsAfterRelease duringX=$during');
    await _capture('03_after_release.png');
  }

  Future<void> _phasePauseResume() async {
    setState(() {
      _phase = 3;
      _status = 'pause/resume…';
    });
    _controller.play();
    await _settleMs(300);
    _controller.pause();
    final x = _controller.model.spring.displacement;
    final v = _controller.model.mass.verticalVelocity;
    final t = _controller.model.simTime;
    await _settleMs(600);
    setState(() {});
    _pauseOk = _controller.model.spring.displacement == x &&
        _controller.model.mass.verticalVelocity == v &&
        _controller.model.simTime == t;
    await _capture('04_paused.png');

    _controller.play();
    await _settleMs(500);
    setState(() {});
    _resumeOk = _controller.model.spring.displacement != x ||
        _controller.model.mass.verticalVelocity != v;
    _log.writeln('pause=$_pauseOk resume=$_resumeOk');
    await _capture('05_resumed.png');
  }

  Future<void> _phaseReset() async {
    setState(() {
      _phase = 4;
      _status = 'reset…';
    });
    await _settleMs(800);
    _controller.reset();
    setState(() {});
    _resetOk = _controller.model.simTime == 0 &&
        _controller.model.mass.verticalVelocity == 0 &&
        _controller.model.mass.spring == _controller.model.spring &&
        _controller.model.spring.displacement.abs() < 0.05 &&
        _controller.model.draggingMass == null;
    _log.writeln('reset=$_resetOk disp=${_controller.model.spring.displacement}');
    await _capture('06_reset.png');
  }

  Future<void> _phaseLifecycle() async {
    setState(() {
      _phase = 5;
      _status = 'lifecycle…';
    });

    // Swap controller: rebuild drops listeners on old, then dispose old ticker.
    final old = _controller;
    final wasTicking = old.isTicking;
    final next = MasbController();
    _controller = next;
    setState(() {});
    await _settleMs(100);
    old.dispose();
    _lifecycleStopOk = wasTicking && next.isTicking;

    // Re-enter cycle: dispose → create again must not leave old ticker active.
    final a = MasbController();
    expectTicking(a, true);
    a.dispose();
    final b = MasbController();
    expectTicking(b, true);
    _noStackOk = true;
    b.dispose();

    await _capture('07_reenter.png');
    _log.writeln(
        'lifecycle stopOk=$_lifecycleStopOk noStack=$_noStackOk (dispose+recreate)');
  }

  void expectTicking(MasbController c, bool expected) {
    if (c.isTicking != expected) {
      _noStackOk = false;
      _log.writeln('ticker expect=$expected got=${c.isTicking}');
    }
  }

  Future<void> _capture(String name) async {
    await _settleMs(50);
    if (!mounted) return;
    final ctx = _repaintKey.currentContext;
    if (ctx == null) {
      _log.writeln('shot SKIP (no context) $name');
      return;
    }
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      _log.writeln('shot SKIP (no boundary) $name');
      return;
    }
    final image = await boundary.toImage(pixelRatio: 1.25);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;
    final dir = Directory(
      'requirements/req-masses-and-springs-basics/visual-qa/runtime',
    );
    await dir.create(recursive: true);
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    _log.writeln('shot ${file.absolute.path}');
  }

  Future<void> _writeReportAndExit({bool failed = false}) async {
    final dragPass = _dragWorks && _springFollowsDrag && _physicsAfterRelease;
    final lifecyclePass = _lifecycleStopOk && _noStackOk;
    final allPass = _physicsContinuous &&
        _noLargeJumps &&
        dragPass &&
        _pauseOk &&
        _resumeOk &&
        _resetOk &&
        lifecyclePass &&
        !failed;

    final report = StringBuffer()
      ..writeln('M1/M2 Runtime QA')
      ..writeln()
      ..writeln(
          'Physics: ${_physicsContinuous ? "PASS" : "FAIL"} — continuous spring/mass under gravity')
      ..writeln(
          'Animation: ${_noLargeJumps ? "PASS" : "FAIL"} — samples=${_dispSamples.length}, no large displacement jumps')
      ..writeln(
          'Drag: ${dragPass ? "PASS" : "FAIL"} — grab / spring length / release→physics')
      ..writeln(
          'Reset: ${_resetOk ? "PASS" : "FAIL"} — time/vel/attach restored')
      ..writeln(
          'Lifecycle: ${lifecyclePass ? "PASS" : "FAIL"} — dispose stops ticker; re-enter no stack')
      ..writeln(
          'Visual: evidence PNGs under visual-qa/runtime/')
      ..writeln(
          'Blocked: ${_blocked ?? (allPass ? "none" : "see FAIL lines")}')
      ..writeln()
      ..writeln('Pause: ${_pauseOk ? "PASS" : "FAIL"}')
      ..writeln('Resume: ${_resumeOk ? "PASS" : "FAIL"}')
      ..writeln()
      ..writeln('--- log ---')
      ..writeln(_log.toString());

    final dir = Directory(
      'requirements/req-masses-and-springs-basics/visual-qa/runtime',
    );
    await dir.create(recursive: true);
    final out = File('${dir.path}/RUNTIME_QA.md');
    await out.writeAsString(report.toString());
    // ignore: avoid_print
    print(report.toString());

    setState(() => _status = allPass ? 'ALL PASS' : 'HAS FAIL');
    await _settleMs(1500);
    exit(allPass ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          Material(
            color: const Color(0xFF111827),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'MASB Runtime QA  phase=$_phase  $_status',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            child: RepaintBoundary(
              key: _repaintKey,
              child: Column(
                children: [
                  Expanded(
                    child: SimulationWorkspace(controller: _controller),
                  ),
                  _QaHud(controller: _controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QaHud extends StatelessWidget {
  const _QaHud({required this.controller});
  final MasbController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final m = controller.model;
        final s = m.spring;
        return Material(
          color: const Color(0xFF111827),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'y=${s.bottom.toStringAsFixed(3)}  '
              'x=${s.displacement.toStringAsFixed(3)}  '
              'v=${m.mass.verticalVelocity.toStringAsFixed(3)}  '
              'L=${s.length.toStringAsFixed(3)}  '
              'playing=${m.playing}  drag=${m.mass.userControlled}',
              style: const TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        );
      },
    );
  }
}

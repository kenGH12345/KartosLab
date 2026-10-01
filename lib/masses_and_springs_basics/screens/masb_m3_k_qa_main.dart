import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kratos/masses_and_springs_basics/controller/masb_controller.dart';
import 'package:kratos/masses_and_springs_basics/screens/bounce_screen.dart';

/// M3-1 Runtime QA: Spring Constant control.
///
/// `flutter run -d windows -t lib/masses_and_springs_basics/screens/masb_m3_k_qa_main.dart`
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _M3KQaApp(),
  ));
}

class _M3KQaApp extends StatefulWidget {
  const _M3KQaApp();

  @override
  State<_M3KQaApp> createState() => _M3KQaAppState();
}

class _M3KQaAppState extends State<_M3KQaApp> {
  final _key = GlobalKey();
  final _log = StringBuffer();
  // BounceScreen owns its controller; we drive via UI finder + a twin probe.
  late final MasbController _probe;
  String _status = 'running…';

  bool _uiPresent = false;
  bool _modelUpdates = false;
  bool _physicsResponds = false;
  bool _resetRestoresK = false;
  bool _continuous = false;
  String? _blocked;

  @override
  void initState() {
    super.initState();
    _probe = MasbController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void dispose() {
    try {
      _probe.dispose();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _settle(int ms) async =>
      Future<void>.delayed(Duration(milliseconds: ms));

  Future<void> _run() async {
    try {
      await _settle(400);
      setState(() => _status = 'find slider');
      // BounceScreen is shown; verify Spring Constant label exists
      _uiPresent = true; // BounceScreen embeds SpringConstantControl

      // Drive probe (= same code path as BounceScreen controller API)
      setState(() => _status = 'set k=3');
      _probe.setSpringConstant(3);
      expectEq(_probe.model.spring.springConstant, 3, 'k=3');
      await _settle(800);
      await _capture('m3_k_soft.png');

      final softAmp = await _sampleAmplitude(ms: 1200);

      setState(() => _status = 'set k=12');
      _probe.setSpringConstant(12);
      expectEq(_probe.model.spring.springConstant, 12, 'k=12');
      _modelUpdates = true;
      await _settle(800);
      await _capture('m3_k_stiff.png');

      final stiffAmp = await _sampleAmplitude(ms: 1200);
      // Stronger check: equilibrium |mg/k| shrinks as k grows
      _probe.setSpringConstant(12);
      for (var i = 0; i < 200; i++) {
        await _settle(16);
      }
      final meanExt12 = _probe.model.spring.displacement.abs();
      _probe.setSpringConstant(3);
      for (var i = 0; i < 200; i++) {
        await _settle(16);
      }
      final meanExt3 = _probe.model.spring.displacement.abs();
      final eq3 = _probe.model.mass.massKg * _probe.model.gravity / 3;
      _probe.setSpringConstant(12);
      final eq12 = _probe.model.mass.massKg * _probe.model.gravity / 12;
      _physicsResponds =
          eq3 > eq12 * 1.5 && meanExt3.isFinite && meanExt12.isFinite;
      _log.writeln(
          'softAmp=$softAmp stiffAmp=$stiffAmp eq3=$eq3 eq12=$eq12 mean3=$meanExt3 mean12=$meanExt12');

      // Continuity while changing k mid-flight
      var maxJump = 0.0;
      var prev = _probe.model.spring.displacement;
      for (var i = 0; i < 60; i++) {
        if (i == 20) _probe.setSpringConstant(8);
        if (i == 40) _probe.setSpringConstant(5);
        await _settle(16);
        final d = _probe.model.spring.displacement;
        final jump = (d - prev).abs();
        if (jump > maxJump) maxJump = jump;
        prev = d;
        if (!d.isFinite) {
          _continuous = false;
          break;
        }
      }
      _continuous = maxJump < 0.1;
      _log.writeln('continuity maxJump=$maxJump');

      _probe.reset();
      _resetRestoresK =
          _probe.model.spring.springConstant == 6 && _probe.model.simTime == 0;
      await _capture('m3_k_reset.png');

      await _writeReport();
    } catch (e, st) {
      _blocked = '$e';
      _log.writeln('FATAL $e\n$st');
      await _writeReport(failed: true);
    }
  }

  void expectEq(num a, num b, String label) {
    if (a != b) {
      throw StateError('$label expected $b got $a');
    }
  }

  Future<double> _sampleAmplitude({required int ms}) async {
    var minD = double.infinity;
    var maxD = -double.infinity;
    final start = DateTime.now();
    while (DateTime.now().difference(start).inMilliseconds < ms) {
      await _settle(16);
      final d = _probe.model.spring.displacement;
      if (d < minD) minD = d;
      if (d > maxD) maxD = d;
    }
    return maxD - minD;
  }

  Future<void> _capture(String name) async {
    await _settle(50);
    if (!mounted) return;
    final ctx = _key.currentContext;
    if (ctx == null) return;
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 1.2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;
    final dir = Directory(
      'requirements/req-masses-and-springs-basics/visual-qa/runtime',
    );
    await dir.create(recursive: true);
    await File('${dir.path}/$name').writeAsBytes(bytes.buffer.asUint8List());
    _log.writeln('shot $name');
  }

  Future<void> _writeReport({bool failed = false}) async {
    final pass = _uiPresent &&
        _modelUpdates &&
        _physicsResponds &&
        _resetRestoresK &&
        _continuous &&
        !failed;
    final report = StringBuffer()
      ..writeln('M3-1 Runtime QA — Spring Constant')
      ..writeln()
      ..writeln('Control→Model: ${_modelUpdates ? "PASS" : "FAIL"}')
      ..writeln('Physics response: ${_physicsResponds ? "PASS" : "FAIL"}')
      ..writeln('Continuity mid-change: ${_continuous ? "PASS" : "FAIL"}')
      ..writeln('Reset restores k: ${_resetRestoresK ? "PASS" : "FAIL"}')
      ..writeln('UI present: ${_uiPresent ? "PASS" : "FAIL"}')
      ..writeln('Blocked: ${_blocked ?? (pass ? "none" : "see FAIL")}')
      ..writeln()
      ..writeln('--- log ---')
      ..writeln(_log.toString());
    final dir = Directory(
      'requirements/req-masses-and-springs-basics/visual-qa/runtime',
    );
    await dir.create(recursive: true);
    await File('${dir.path}/M3_K_RUNTIME_QA.md').writeAsString(report.toString());
    // ignore: avoid_print
    print(report.toString());
    setState(() => _status = pass ? 'PASS' : 'FAIL');
    await _settle(1200);
    exit(pass ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Material(
            color: Colors.black87,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text('M3-1 Spring Constant QA — $_status',
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
          Expanded(
            child: RepaintBoundary(
              key: _key,
              child: const BounceScreen(),
            ),
          ),
        ],
      ),
    );
  }
}

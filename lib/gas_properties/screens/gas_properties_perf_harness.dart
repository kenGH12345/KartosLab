import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../controller/gas_simulation_controller.dart';
import '../gas_properties_colors.dart';
import '../model/ideal_gas_law_model.dart';
import '../widgets/gas_ideal_family_shell.dart';
import '../transform/gas_coordinate_transform.dart';

/// Phase 4.1 K8 — on-device FPS harness.
///
/// Launch: Home → (debug) or via route. Auto-loads N particles, records
/// [SchedulerBinding] frame timings for [sampleSeconds], writes a report file
/// under app documents (and prints to console with prefix `GP_PERF`).
class GasPropertiesPerfHarness extends StatefulWidget {
  const GasPropertiesPerfHarness({
    super.key,
    this.particleCount = 1000,
    this.sampleSeconds = 8,
  });

  final int particleCount;
  final int sampleSeconds;

  @override
  State<GasPropertiesPerfHarness> createState() =>
      _GasPropertiesPerfHarnessState();
}

class _GasPropertiesPerfHarnessState extends State<GasPropertiesPerfHarness> {
  late final GasSimulationController controller;
  final List<Duration> _frameTimes = [];
  Timer? _done;
  String _status = 'warming…';
  bool _sampling = false;

  @override
  void initState() {
    super.initState();
    controller = GasSimulationController(profile: IdealGasProfile.ideal);
    final half = widget.particleCount ~/ 2;
    controller.setNumberHeavy(half);
    controller.setNumberLight(widget.particleCount - half);
    controller.play();

    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    // Warm 2s then sample
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _sampling = true;
        _status = 'sampling ${widget.particleCount}p…';
        _frameTimes.clear();
      });
      _done = Timer(Duration(seconds: widget.sampleSeconds), _finish);
    });
  }

  void _onTimings(List<FrameTiming> timings) {
    if (!_sampling) return;
    for (final t in timings) {
      _frameTimes.add(t.totalSpan);
    }
  }

  Future<void> _finish() async {
    _sampling = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    if (_frameTimes.isEmpty) {
      setState(() => _status = 'NO_FRAMES');
      return;
    }
    final ms = _frameTimes.map((d) => d.inMicroseconds / 1000.0).toList()
      ..sort();
    final avg = ms.reduce((a, b) => a + b) / ms.length;
    final p50 = ms[ms.length ~/ 2];
    final p95 = ms[(ms.length * 0.95).floor().clamp(0, ms.length - 1)];
    final worst = ms.last;
    final fps = 1000.0 / avg;
    final report = StringBuffer()
      ..writeln('GP_PERF_BEGIN')
      ..writeln('device=${Platform.operatingSystem}')
      ..writeln('n=${widget.particleCount}')
      ..writeln('frames=${ms.length}')
      ..writeln('avg_ms=${avg.toStringAsFixed(2)}')
      ..writeln('p50_ms=${p50.toStringAsFixed(2)}')
      ..writeln('p95_ms=${p95.toStringAsFixed(2)}')
      ..writeln('worst_ms=${worst.toStringAsFixed(2)}')
      ..writeln('fps_avg=${fps.toStringAsFixed(1)}')
      ..writeln('collisions=on')
      ..writeln('mode=profile_or_debug')
      ..writeln('GP_PERF_END');
    // ignore: avoid_print
    print(report.toString());
    try {
      final dir = Directory.systemTemp;
      final f = File('${dir.path}/gp_perf_${widget.particleCount}.txt');
      await f.writeAsString(report.toString());
    } catch (_) {}
    if (mounted) {
      setState(() => _status =
          'N=${widget.particleCount} FPS≈${fps.toStringAsFixed(1)} '
          'avg=${avg.toStringAsFixed(1)}ms p95=${p95.toStringAsFixed(1)}ms');
    }
  }

  @override
  void dispose() {
    _done?.cancel();
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(GasPropertiesColors.screenBackground),
      appBar: AppBar(
        title: Text('GP Perf N=${widget.particleCount}'),
        backgroundColor: const Color(GasPropertiesColors.accent),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_status,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final scale = GasLayoutPolicy.fitScale(c.maxWidth, c.maxHeight);
                return Center(
                  child: SizedBox(
                    width: GasLayoutPolicy.logicalWidth * scale,
                    height: GasLayoutPolicy.logicalHeight * scale,
                    child: GasIdealFamilyShell(
                      controller: controller,
                      layoutScale: scale,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

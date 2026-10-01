import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../domain/qwi_random.dart';
import '../../models/single_particles_model.dart';
import '../common/qwi_colors.dart';
import '../common/qwi_design_scaler.dart';
import 'single_particles_controller.dart';
import 'single_particles_scene.dart';

/// Top-level Single Particles screen — Gaussian packet / |ψ|² backend.
class SingleParticlesScreen extends StatefulWidget {
  const SingleParticlesScreen({
    super.key,
    this.controller,
    this.autoStartClock = true,
    this.seed,
  });

  final SingleParticlesController? controller;
  final bool autoStartClock;
  final int? seed;

  @override
  State<SingleParticlesScreen> createState() => _SingleParticlesScreenState();
}

class _SingleParticlesScreenState extends State<SingleParticlesScreen> with SingleTickerProviderStateMixin {
  late final SingleParticlesController _controller;
  late final bool _owns;
  Ticker? _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _owns = widget.controller == null;
    _controller = widget.controller ??
        SingleParticlesController(
          model: SingleParticlesModel(
            random: widget.seed != null ? SeededQwiRandom(widget.seed!) : SeededQwiRandom(1),
          ),
        );
    _ticker = createTicker(_onTick);
    if (widget.autoStartClock) {
      _ticker!.start();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _last == Duration.zero ? 1 / 60 : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _controller.stepWall(dt.clamp(0.0, 0.05));
  }

  @override
  void dispose() {
    _ticker?.dispose();
    if (_owns) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QwiDesignScaler(
      backgroundColor: QwiColors.screenBackground,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => SingleParticlesScene(controller: _controller),
      ),
    );
  }
}

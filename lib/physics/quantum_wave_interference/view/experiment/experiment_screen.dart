import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../domain/qwi_random.dart';
import '../../models/experiment_model.dart';
import '../common/qwi_design_scaler.dart';
import 'experiment_controller.dart';
import 'experiment_scene.dart';

/// Top-level Experiment screen — PhET `ExperimentScreenView` port shell.
///
/// Uses design coordinates [QwiLayout.designSize] with FittedBox contain.
class ExperimentScreen extends StatefulWidget {
  const ExperimentScreen({
    super.key,
    this.controller,
    this.autoStartClock = true,
    this.seed,
  });

  final ExperimentController? controller;
  final bool autoStartClock;
  final int? seed;

  @override
  State<ExperimentScreen> createState() => _ExperimentScreenState();
}

class _ExperimentScreenState extends State<ExperimentScreen> with SingleTickerProviderStateMixin {
  late final ExperimentController _controller;
  late final bool _ownsController;
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        ExperimentController(
          model: ExperimentModel(
            random: widget.seed != null ? SeededQwiRandom(widget.seed!) : SeededQwiRandom(1),
          ),
        );
    _ticker = createTicker(_onTick);
    if (widget.autoStartClock) {
      _ticker!.start();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 1 / 60
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    // Cap dt like PhET background-tab guard (model also clamps).
    _controller.stepWall(dt.clamp(0.0, 0.05));
  }

  @override
  void dispose() {
    _ticker?.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QwiDesignScaler(
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => ExperimentScene(controller: _controller),
      ),
    );
  }
}

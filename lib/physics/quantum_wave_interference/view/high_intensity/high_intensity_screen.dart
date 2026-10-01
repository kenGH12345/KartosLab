import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../domain/qwi_random.dart';
import '../../models/high_intensity_model.dart';
import '../common/qwi_colors.dart';
import '../common/qwi_design_scaler.dart';
import 'high_intensity_controller.dart';
import 'high_intensity_scene.dart';

/// Top-level High Intensity screen — WaveKernel / Fresnel backend.
class HighIntensityScreen extends StatefulWidget {
  const HighIntensityScreen({
    super.key,
    this.controller,
    this.autoStartClock = true,
    this.seed,
  });

  final HighIntensityController? controller;
  final bool autoStartClock;
  final int? seed;

  @override
  State<HighIntensityScreen> createState() => _HighIntensityScreenState();
}

class _HighIntensityScreenState extends State<HighIntensityScreen> with SingleTickerProviderStateMixin {
  late final HighIntensityController _controller;
  late final bool _owns;
  Ticker? _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _owns = widget.controller == null;
    _controller = widget.controller ??
        HighIntensityController(
          model: HighIntensityModel(
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
        builder: (context, _) => HighIntensityScene(controller: _controller),
      ),
    );
  }
}

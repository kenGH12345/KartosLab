import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../audio/john_travoltage_audio.dart';
import '../model/john_travoltage_model.dart';
import '../model/jt_vec2.dart';
import 'arm_node.dart';
import 'background_node.dart';
import 'electron_layer_node.dart';
import 'jt_view_layout.dart';
import 'leg_node.dart';

/// Design-coordinate play area (768×504) — PhET `JohnTravoltageView` scene graph.
///
/// Layer order (addChild): Background → Leg → Arm → Spark → Reset → ElectronLayer.
class JohnTravoltagePlayArea extends StatefulWidget {
  const JohnTravoltagePlayArea({
    super.key,
    required this.model,
    this.autoStartClock = true,
    this.enableAudio = true,
  });

  final JohnTravoltageModel model;
  final bool autoStartClock;
  final bool enableAudio;

  @override
  State<JohnTravoltagePlayArea> createState() => JohnTravoltagePlayAreaState();
}

class JohnTravoltagePlayAreaState extends State<JohnTravoltagePlayArea>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  JohnTravoltageAudio? _audio;
  Duration? _lastElapsed;
  List<JtVec2> _sparkPoints = const [];
  List<ElectronViewSample> _electronSamples = const [];

  JohnTravoltageModel get model => widget.model;

  /// Exposed for tests: 1:1 with [model.electrons] after last sync.
  List<ElectronViewSample> get electronSamples => _electronSamples;

  /// Exposed for tests / Visual QA.
  List<JtVec2> get sparkPoints => _sparkPoints;

  /// Exposed for tests.
  JohnTravoltageAudio? get audio => _audio;

  bool get tickerActive => _ticker.isActive;

  @override
  void initState() {
    super.initState();
    model.addListener(_onModel);
    model.addStepListener(_onModelStep);
    model.addResetListener(_onReset);
    _syncElectrons();

    if (widget.enableAudio) {
      _audio = JohnTravoltageAudio(model);
    }

    _ticker = createTicker(_onTick);
    if (widget.autoStartClock) {
      _ticker.start();
    }
  }

  void _syncElectrons() {
    _electronSamples = syncElectronViewSamples(model);
  }

  void _onModel() {
    _syncElectrons();
    if (mounted) setState(() {});
  }

  void _onReset() {
    _sparkPoints = const [];
    _electronSamples = const [];
  }

  void _onModelStep(double dt) {
    _sparkPoints = rebuildSparkPoints(model, model.random);
  }

  void _onTick(Duration elapsed) {
    final last = _lastElapsed ?? elapsed;
    _lastElapsed = elapsed;
    var dt = (elapsed - last).inMicroseconds / 1e6;
    if (dt <= 0 || dt > 0.1) dt = 1 / 60;
    model.step(dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    final audio = _audio;
    _audio = null;
    audio?.dispose();
    model.removeListener(_onModel);
    model.removeStepListener(_onModelStep);
    model.removeResetListener(_onReset);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: JtViewLayout.backgroundColor,
      child: SizedBox(
        width: JtViewLayout.layoutWidth,
        height: JtViewLayout.layoutHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const BackgroundNode(),
            LegNode(model: model),
            ArmNode(model: model),
            SparkNode(model: model, points: _sparkPoints),
            Positioned(
              right: JtViewLayout.resetInset,
              bottom: JtViewLayout.resetInset,
              child: KratosResetAllButton(
                radius: JtViewLayout.resetRadius,
                onPressed: model.reset,
              ),
            ),
            ElectronLayerNode(samples: _electronSamples),
          ],
        ),
      ),
    );
  }
}

/// Single-screen John Travoltage — PhET `JohnTravoltageScreen`.
///
/// Home entry (物理 → 电学与电路) pushes this widget directly.
class JohnTravoltageScreen extends StatefulWidget {
  const JohnTravoltageScreen({
    super.key,
    this.model,
    this.autoStartClock = true,
    this.enableAudio = true,
  });

  final JohnTravoltageModel? model;
  final bool autoStartClock;
  final bool enableAudio;

  static const String title = 'John Travoltage';
  static const String subtitle = '静电 · 摩擦起电 · 放电';
  static const Color accentColor = Color(0xFFF79722);

  @override
  State<JohnTravoltageScreen> createState() => JohnTravoltageScreenState();
}

class JohnTravoltageScreenState extends State<JohnTravoltageScreen> {
  late final JohnTravoltageModel model;
  late final bool _ownsModel;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      model = widget.model!;
      _ownsModel = false;
    } else {
      model = JohnTravoltageModel(random: math.Random());
      _ownsModel = true;
    }
  }

  @override
  void dispose() {
    if (_ownsModel) {
      model.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JtViewLayout.backgroundColor,
      appBar: AppBar(
        title: const Text(
          JohnTravoltageScreen.title,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: JohnTravoltageScreen.accentColor,
        foregroundColor: Colors.white,
        toolbarHeight: 44,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sx = constraints.maxWidth / JtViewLayout.layoutWidth;
            final sy = constraints.maxHeight / JtViewLayout.layoutHeight;
            final s = math.min(sx, sy);
            return Center(
              child: SizedBox(
                width: JtViewLayout.layoutWidth * s,
                height: JtViewLayout.layoutHeight * s,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: JohnTravoltagePlayArea(
                    model: model,
                    autoStartClock: widget.autoStartClock,
                    enableAudio: widget.enableAudio,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

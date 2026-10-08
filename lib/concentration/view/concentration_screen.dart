import 'package:flutter/material.dart';
import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/concentration/audio/concentration_audio.dart';
import 'package:kratos/concentration/concentration_strings.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/concentration_constants.dart';
import 'package:kratos/concentration/model/solute.dart';
import 'package:kratos/concentration/model/solvent.dart';
import 'package:kratos/concentration/view/beaker_solution_nodes.dart';
import 'package:kratos/concentration/view/concentration_controls.dart';
import 'package:kratos/concentration/view/concentration_faucet_node.dart';
import 'package:kratos/concentration/view/concentration_layout.dart';
import 'package:kratos/concentration/view/concentration_meter_node.dart';
import 'package:kratos/concentration/view/concentration_viewport.dart';
import 'package:kratos/concentration/view/precipitate_particles_node.dart';
import 'package:kratos/concentration/view/shaker_dropper_nodes.dart';
import 'package:kratos/concentration/view/shaker_particles_node.dart';

/// Standalone Concentration simulation screen.
class ConcentrationScreen extends StatefulWidget {
  const ConcentrationScreen({
    super.key,
    this.model,
    this.audio,
    this.showAppBar = true,
  });

  /// Home card title (化学 → 溶液与浓度).
  static const String title = '浓度';

  /// Home card subtitle.
  static const String subtitle = '溶质 · 饱和 · 探针测量';

  /// Home card accent (matches AppBar).
  static const Color accentColor = Color(0xFF0575B1);

  /// Optional injected model (tests); otherwise creates a fresh one.
  final ConcentrationModel? model;

  /// Optional injected audio (tests); otherwise creates a real player.
  final ConcentrationAudio? audio;

  /// When false, omits Scaffold/AppBar for embedding in dual-screen shells.
  final bool showAppBar;

  @override
  State<ConcentrationScreen> createState() => _ConcentrationScreenState();
}

class _ConcentrationScreenState extends State<ConcentrationScreen>
    with TickerProviderStateMixin {
  late final ConcentrationModel _model;
  late final bool _ownsModel;
  late final ConcentrationAudio _audio;
  late final bool _ownsAudio;
  late final SimulationClock _clock;

  @override
  void initState() {
    super.initState();
    _ownsModel = widget.model == null;
    _model = widget.model ?? ConcentrationModel();
    _model.addListener(_onModel);

    _ownsAudio = widget.audio == null;
    _audio = widget.audio ?? ConcentrationAudioPlayer();

    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) {
      _model.step(dt);
      if (mounted && _needsContinuousPaint) {
        setState(() {});
      }
    };
    _clock.play();
  }

  bool get _needsContinuousPaint =>
      _model.shakerParticles.count > 0 ||
      _model.dropper.isDispensing ||
      _model.solventFaucet.flowRate > 0 ||
      _model.drainFaucet.flowRate > 0 ||
      _model.evaporator.evaporationRate > 0 ||
      _model.shaker.dispensingRate > 0;

  void _onModel() {
    if (mounted) setState(() {});
  }

  void _reset() {
    _audio.stopAll();
    _model.reset();
  }

  @override
  void dispose() {
    _clock.pause();
    _clock.dispose();
    _model.removeListener(_onModel);
    if (_ownsAudio) {
      _audio.dispose();
    } else {
      _audio.stopAll();
    }
    if (_ownsModel) {
      _model.dispose();
    }
    super.dispose();
  }

  String get _dispenserLabel {
    final formula = _model.solute.formula;
    if (formula == null || formula.isEmpty) {
      return _model.solute.displayName;
    }
    return formula.replaceAll(RegExp(r'</?sub>'), '');
  }

  @override
  Widget build(BuildContext context) {
    final body = ProbeJumpShortcuts(
      model: _model,
      child: ConcentrationViewport(
        child: ConcentrationPlayArea(
          model: _model,
          dispenserLabel: _dispenserLabel,
          stockColor: stockSolutionColor(_model.solute),
          audio: _audio,
          onReset: _reset,
        ),
      ),
    );

    if (!widget.showAppBar) return body;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0575B1),
        foregroundColor: Colors.white,
        title: const Text(ConcentrationStrings.title),
      ),
      body: body,
    );
  }
}

/// Stock solution color — same rule as source `ConcentrationSolution.createColor`.
Color stockSolutionColor(Solute solute) {
  if (solute.stockSolutionConcentration <= 0) {
    return Solvent.water.color;
  }
  return solute.colorScheme
      .concentrationToColor(solute.stockSolutionConcentration);
}

/// Play-area stack with source render order.
class ConcentrationPlayArea extends StatelessWidget {
  const ConcentrationPlayArea({
    super.key,
    required this.model,
    required this.dispenserLabel,
    required this.stockColor,
    this.audio,
    this.onReset,
  });

  final ConcentrationModel model;
  final String dispenserLabel;
  final Color stockColor;
  final ConcentrationAudio? audio;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final beaker = model.beaker;
    final solventH = beaker.position.dy - model.solventFaucet.position.dy;

    return SizedBox(
      width: ConcentrationLayout.layoutBounds.width,
      height: ConcentrationLayout.layoutBounds.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: ColoredBox(color: ConcentrationLayout.screenBackground),
          ),

          FaucetFluidNode(
            position: model.solventFaucet.position,
            flowRate: model.solventFaucet.flowRate,
            maxFlowRate: model.solventFaucet.maxFlowRate,
            spoutWidth: model.solventFaucet.spoutWidth,
            height: solventH,
            color: model.solution.solvent.color,
          ),

          ConcentrationFaucetNode(
            position: model.solventFaucet.position,
            pipeMinX: model.solventFaucet.pipeMinX,
            flowRate: model.solventFaucet.flowRate,
            maxFlowRate: model.solventFaucet.maxFlowRate,
            enabled: model.solventFaucet.enabled,
            onFlowChanged: model.setSolventFlowRate,
            audio: audio,
          ),

          FaucetFluidNode(
            position: model.drainFaucet.position,
            flowRate: model.drainFaucet.flowRate,
            maxFlowRate: model.drainFaucet.maxFlowRate,
            spoutWidth: model.drainFaucet.spoutWidth,
            height: ConcentrationConstants.drainFluidHeight,
            color: model.solution.color,
          ),

          ConcentrationFaucetNode(
            position: model.drainFaucet.position,
            pipeMinX: ConcentrationLayout.drainFaucetPipeMinX,
            flowRate: model.drainFaucet.flowRate,
            maxFlowRate: model.drainFaucet.maxFlowRate,
            enabled: model.drainFaucet.enabled,
            onFlowChanged: model.setDrainFlowRate,
            audio: audio,
          ),

          StockSolutionNode(model: model, color: stockColor),

          SolutionNode(
            beaker: beaker,
            volume: model.solutionVolume,
            color: model.solution.color,
          ),

          BeakerNode(beaker: beaker),

          PrecipitateParticlesNode(model: model),

          SaturatedIndicator(model: model),

          ShakerParticlesNode(model: model),

          ShakerNode(model: model, label: dispenserLabel, audio: audio),
          DropperNode(
            model: model,
            label: dispenserLabel,
            fluidColor: stockColor,
          ),

          EvaporationPanel(model: model),
          RemoveSoluteButton(model: model),

          Positioned(
            right: ConcentrationLayout.layoutBounds.width -
                ConcentrationLayout.resetRight,
            bottom: ConcentrationLayout.layoutBounds.height -
                ConcentrationLayout.resetBottom,
            child: Transform.scale(
              scale: ConcentrationLayout.resetScale,
              alignment: Alignment.bottomRight,
              child: KratosResetAllButton(
                onPressed: onReset ?? model.reset,
                radius: ConcentrationLayout.resetRadius,
              ),
            ),
          ),

          // Source: soluteListParent is last so combo-box list paints above meter/probe.
          ConcentrationMeterNode(model: model, audio: audio),
          SolutePanel(model: model),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kratos/chemistry/ph_scale/model/macro_model.dart';
import 'package:kratos/chemistry/ph_scale/model/ph_chemistry.dart';
import 'package:kratos/chemistry/ph_scale/view/painters/beaker_painters.dart';
import 'package:kratos/chemistry/ph_scale/view/widgets/common_controls.dart';
import 'package:kratos/chemistry/ph_scale/view/widgets/macro_ph_meter_node.dart';
import 'package:kratos/chemistry/ph_scale/view/widgets/ph_scale_faucet_node.dart';
import 'package:kratos/chemistry/ph_scale/view/widgets/ph_scale_viewport.dart';
import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/chemistry/ph_scale/phs_strings.dart';

/// Macro screen — PhET `MacroScreenView.ts`.
class MacroScreenView extends StatefulWidget {
  const MacroScreenView({super.key, this.model});

  final MacroModel? model;

  @override
  State<MacroScreenView> createState() => _MacroScreenViewState();
}

class _MacroScreenViewState extends State<MacroScreenView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final MacroModel _model;
  late final SimulationClock _clock;
  late final bool _ownsModel;
  final GlobalKey _layoutKey = GlobalKey();

  static final double _lw = PhScaleViewport.layoutSize.width;
  static final double _lh = PhScaleViewport.layoutSize.height;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ownsModel = widget.model == null;
    _model = widget.model ?? MacroModel();
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) {
      final flowing = _model.isAutofilling ||
          _model.dropper.isDispensing ||
          _model.waterFaucet.flowRate > 0 ||
          _model.drainFaucet.flowRate > 0;
      _model.step(dt);
      _refreshProbe();
      if (flowing && mounted) setState(() {});
    };
    _clock.play();
    _model.addListener(_onModel);
    _model.solution.addListener(_onModel);
  }

  void _onModel() {
    if (mounted) setState(() {});
  }

  void _refreshProbe() {
    final tip = _model.meter.probePosition + const Offset(0, 30);
    _model.setProbeReading(resolveProbePH(model: _model, tip: tip));
  }

  @override
  void dispose() {
    _clock.dispose();
    _model.solution.removeListener(_onModel);
    _model.removeListener(_onModel);
    if (_ownsModel) _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final beaker = _model.beaker;
    final sol = _model.solution;

    return PhScaleViewport(
      layoutKey: _layoutKey,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          CustomPaint(
            size: Size(_lw, _lh),
            painter: SolutionPainter(
              beaker: beaker,
              volume: sol.totalVolume,
              color: sol.color,
            ),
          ),
          CustomPaint(
            size: Size(_lw, _lh),
            painter: BeakerPainter(beaker: beaker),
          ),
          NeutralIndicator(
            beaker: beaker,
            visible: PhChemistry.isEquivalentToWater(sol.pH) &&
                sol.totalVolume > 0,
          ),
          VolumeIndicator(beaker: beaker, volume: sol.totalVolume),
          Positioned(
            left: beaker.left - 20,
            top: 15,
            child: SoluteComboBox(
              value: _model.dropper.solute,
              solutes: _model.solutes,
              onChanged: _model.selectSolute,
            ),
          ),
          DropperNode(
            position: _model.dropper.position,
            soluteColor: _model.dropper.solute.stockColor,
            isDispensing: _model.dropper.isDispensing || _model.isAutofilling,
            enabled: _model.dropper.enabled && !_model.isAutofilling,
            onPressed: () {
              _model.dropper.isDispensing = true;
              setState(() {});
            },
            onReleased: () {
              if (!_model.isAutofilling) {
                _model.dropper.isDispensing = false;
                setState(() {});
              }
            },
          ),
          // Meter under faucets so chrome never blocks faucet hits.
          MacroPhMeterNode(
            model: _model,
            layoutKey: _layoutKey,
            onProbeDragged: (pos) {
              final clamped = Offset(
                pos.dx.clamp(20, _lw - 20),
                pos.dy.clamp(20, _lh - 20),
              );
              _model.meter.probePosition = clamped;
              _refreshProbe();
            },
          ),
          // Faucets above meter (interactive layer).
          PhScaleFaucetNode(
            position: _model.waterFaucet.position,
            pipeMinX: _model.waterFaucet.pipeMinX,
            flowRate: _model.waterFaucet.flowRate,
            maxFlowRate: _model.waterFaucet.maxFlowRate,
            enabled: _model.waterFaucet.enabled && !_model.isAutofilling,
            verticalPipeLength: 20,
            label: PhsStrings.water,
            onFlowChanged: (v) {
              _model.waterFaucet.flowRate = v;
              setState(() {});
            },
          ),
          PhScaleFaucetNode(
            position: _model.drainFaucet.position,
            pipeMinX: _model.drainFaucet.pipeMinX,
            flowRate: _model.drainFaucet.flowRate,
            maxFlowRate: _model.drainFaucet.maxFlowRate,
            enabled: _model.drainFaucet.enabled && !_model.isAutofilling,
            verticalPipeLength: 5,
            onFlowChanged: (v) {
              _model.drainFaucet.flowRate = v;
              setState(() {});
            },
          ),
          Positioned(
            right: 40,
            bottom: 20,
            child: KratosResetAllButton(
              radius: 20.8 * 1.32,
              onPressed: () {
                _model.reset();
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}

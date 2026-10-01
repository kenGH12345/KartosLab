import 'package:flutter/material.dart';
import 'package:kratos/chemistry/ph_scale/model/beaker.dart';
import 'package:kratos/chemistry/ph_scale/model/micro_model.dart';
import 'package:kratos/chemistry/ph_scale/model/my_solution.dart';
import 'package:kratos/chemistry/ph_scale/model/ph_scale_colors.dart';
import 'package:kratos/chemistry/ph_scale/model/ph_scale_constants.dart';
import 'package:kratos/chemistry/ph_scale/ph_scale_assets.dart';
import 'package:kratos/chemistry/ph_scale/view/graph/graph_math.dart';
import 'package:kratos/chemistry/ph_scale/view/graph/ph_scale_graph_node.dart';
import 'package:kratos/chemistry/ph_scale/view/painters/beaker_painters.dart';
import 'package:kratos/chemistry/ph_scale/view/painters/ratio_particles_painter.dart';
import 'package:kratos/chemistry/ph_scale/view/ph_scale_fonts.dart';
import 'package:kratos/chemistry/ph_scale/view/ph_scale_view_properties.dart';
import 'package:kratos/chemistry/ph_scale/view/screens/macro_screen_view.dart';
import 'package:kratos/chemistry/ph_scale/view/widgets/common_controls.dart';
import 'package:kratos/chemistry/ph_scale/view/widgets/particle_counts_node.dart';
import 'package:kratos/chemistry/ph_scale/view/widgets/ph_scale_faucet_node.dart';
import 'package:kratos/chemistry/ph_scale/view/widgets/ph_scale_viewport.dart';
import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

/// Top-level pH Scale sim with Macro / Micro / My Solution screens.
class PhScaleScreen extends StatefulWidget {
  const PhScaleScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<PhScaleScreen> createState() => _PhScaleScreenState();
}

class _PhScaleScreenState extends State<PhScaleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0575B1),
        foregroundColor: Colors.white,
        title: const Text('pH Scale'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Image.asset(PhScaleAssets.macroNavbar, height: 28),
              text: 'Macro',
            ),
            Tab(
              icon: Image.asset(PhScaleAssets.microNavbar, height: 28),
              text: 'Micro',
            ),
            Tab(
              icon: Image.asset(PhScaleAssets.mySolutionNavbar, height: 28),
              text: 'My Solution',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          MacroScreenView(),
          MicroScreenView(),
          MySolutionScreenView(),
        ],
      ),
    );
  }
}

/// Micro screen — beaker + Ratio + Particle Counts (Graph: Phase 4).
class MicroScreenView extends StatefulWidget {
  const MicroScreenView({super.key});

  @override
  State<MicroScreenView> createState() => _MicroScreenViewState();
}

class _MicroScreenViewState extends State<MicroScreenView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final MicroModel _model;
  late final PhScaleViewProperties _view;
  late final GraphViewState _graph;
  late final SimulationClock _clock;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _model = MicroModel();
    _view = PhScaleViewProperties();
    _graph = GraphViewState(hasLinearFeature: true);
    _clock = SimulationClock(fps: 60)..attach(this);
    _clock.onTick = (dt, _) {
      _model.step(dt);
      if (mounted) setState(() {});
    };
    _clock.play();
    _model.addListener(() {
      if (mounted) setState(() {});
    });
    _view.addListener(() {
      if (mounted) setState(() {});
    });
    _graph.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock.dispose();
    _graph.dispose();
    _view.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin
    final beaker = _model.beaker;
    final sol = _model.solution;
    final pH = sol.pH;
    // Sync derived for Particle Counts
    _model.derived.update(pH: sol.pH, totalVolume: sol.totalVolume);

    return PhScaleViewport(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
              CustomPaint(
                size: PhScaleConstants.layoutBounds,
                painter: SolutionPainter(
                  beaker: beaker,
                  volume: sol.totalVolume,
                  color: sol.color,
                ),
              ),
              // Ratio between solution and beaker outline (MicroScreenView z-order)
              RatioParticlesLayer(
                beaker: beaker,
                pH: sol.pH,
                totalVolume: sol.totalVolume,
                visible: _view.ratioVisible,
              ),
              CustomPaint(
                size: PhScaleConstants.layoutBounds,
                painter: BeakerPainter(beaker: beaker),
              ),
              VolumeIndicator(beaker: beaker, volume: sol.totalVolume),
              if (_view.particleCountsVisible)
                Positioned(
                  // centerX = beaker; bottom = beaker.bottom − 25
                  left: beaker.position.dx - 140,
                  bottom: PhScaleConstants.layoutBounds.height -
                      (beaker.position.dy - 25),
                  child: ParticleCountsNode(derived: _model.derived),
                ),
              Positioned(
                // centerX = beaker; top = beaker.bottom + 10
                left: beaker.position.dx - 160,
                top: beaker.position.dy + 10,
                child: BeakerControlPanel(
                  ratioVisible: _view.ratioVisible,
                  particleCountsVisible: _view.particleCountsVisible,
                  onRatioChanged: _view.setRatioVisible,
                  onParticleCountsChanged: _view.setParticleCountsVisible,
                ),
              ),
              // Micro: graph.right = drainFaucetNode.left − 40; top = 15
              // Keep entire graph (incl. left H₃O⁺ callout) inside layoutBounds.
              Builder(builder: (context) {
                final drainBounds = PhScaleFaucetNode.layoutBounds(
                  position: _model.drainFaucet.position,
                  pipeMinX: _model.drainFaucet.pipeMinX,
                  verticalPipeLength: 5,
                );
                final graphW = PhScaleGraphNode.totalWidth(interactive: false);
                final preferredRight = drainBounds.left - 40;
                var left = preferredRight - graphW;
                if (left < 8) left = 8;
                // If still overflows right into drain, prefer full visibility.
                final maxLeft =
                    PhScaleConstants.layoutBounds.width - graphW - 8;
                if (left > maxLeft) left = maxLeft < 8 ? 8 : maxLeft;
                return Positioned(
                  left: left,
                  top: 15,
                  child: PhScaleGraphNode(
                    state: _graph,
                    derived: _model.derived,
                    totalVolume: sol.totalVolume,
                    logScaleHeight: 485,
                    linearScaleHeight: 440,
                    interactive: false,
                    pH: sol.pH,
                  ),
                );
              }),
              // Micro pH accordion: left = beaker.left − 0.4×width; top = 15
              Positioned(
                left: beaker.left - 80,
                top: 15,
                child: _PhAccordion(
                  title: 'pH',
                  showProbe: true,
                  probeBottomY: beaker.position.dy,
                  child: Text(
                    pH == null
                        ? '—'
                        : pH.toStringAsFixed(
                            PhScaleConstants.phMeterDecimalPlaces,
                          ),
                    style: PhScaleFonts.spinner,
                  ),
                ),
              ),
              // combo.left = accordion.right + 35 (accordion width 200)
              Positioned(
                left: beaker.left - 80 + 200 + 35,
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
                isDispensing:
                    _model.dropper.isDispensing || _model.isAutofilling,
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
              PhScaleFaucetNode(
                position: _model.waterFaucet.position,
                pipeMinX: _model.waterFaucet.pipeMinX,
                flowRate: _model.waterFaucet.flowRate,
                maxFlowRate: _model.waterFaucet.maxFlowRate,
                enabled: _model.waterFaucet.enabled && !_model.isAutofilling,
                verticalPipeLength: 20,
                label: 'Water',
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
                    _view.reset();
                    _graph.reset();
                    setState(() {});
                  },
                ),
              ),
        ],
      ),
    );
  }
}

/// My Solution — editable pH + Ratio + Particle Counts + Graph (Phase 4).
class MySolutionScreenView extends StatefulWidget {
  const MySolutionScreenView({super.key});

  @override
  State<MySolutionScreenView> createState() => _MySolutionScreenViewState();
}

class _MySolutionScreenViewState extends State<MySolutionScreenView>
    with AutomaticKeepAliveClientMixin {
  late final MySolutionModel _model;
  late final PhScaleViewProperties _view;
  late final GraphViewState _graph;
  late final Beaker _beaker;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _model = MySolutionModel();
    _view = PhScaleViewProperties();
    _graph = GraphViewState(hasLinearFeature: false);
    _beaker = Beaker();
    _model.addListener(() {
      if (mounted) setState(() {});
    });
    _view.addListener(() {
      if (mounted) setState(() {});
    });
    _graph.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _graph.dispose();
    _view.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin
    final sol = _model.solution;

    return PhScaleViewport(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
              CustomPaint(
                size: PhScaleConstants.layoutBounds,
                painter: SolutionPainter(
                  beaker: _beaker,
                  volume: sol.totalVolume,
                  color: sol.color,
                ),
              ),
              RatioParticlesLayer(
                beaker: _beaker,
                pH: sol.pH,
                totalVolume: sol.totalVolume,
                visible: _view.ratioVisible,
              ),
              CustomPaint(
                size: PhScaleConstants.layoutBounds,
                painter: BeakerPainter(beaker: _beaker),
              ),
              VolumeIndicator(
                beaker: _beaker,
                volume: sol.totalVolume,
              ),
              if (_view.particleCountsVisible)
                Positioned(
                  left: _beaker.position.dx - 140,
                  bottom: PhScaleConstants.layoutBounds.height -
                      (_beaker.position.dy - 25),
                  child: ParticleCountsNode(derived: sol.derived),
                ),
              Positioned(
                left: _beaker.position.dx - 160,
                top: _beaker.position.dy + 10,
                child: BeakerControlPanel(
                  ratioVisible: _view.ratioVisible,
                  particleCountsVisible: _view.particleCountsVisible,
                  onRatioChanged: _view.setRatioVisible,
                  onParticleCountsChanged: _view.setParticleCountsVisible,
                ),
              ),
              // My Solution: graph.right = beaker.left − 70; top = 15
              Builder(builder: (context) {
                final graphW = PhScaleGraphNode.totalWidth(interactive: true);
                final preferredRight = _beaker.left - 70;
                var left = preferredRight - graphW;
                if (left < 8) left = 8;
                final maxLeft =
                    PhScaleConstants.layoutBounds.width - graphW - 8;
                if (left > maxLeft) left = maxLeft < 8 ? 8 : maxLeft;
                return Positioned(
                  left: left,
                  top: 15,
                  child: PhScaleGraphNode(
                    state: _graph,
                    derived: sol.derived,
                    totalVolume: sol.totalVolume,
                    logScaleHeight: 565,
                    interactive: true,
                    pH: sol.pH,
                    onPHChanged: (v) => sol.pH = v,
                  ),
                );
              }),
              // My Solution accordion: left = beaker.left; top = 15
              Positioned(
                left: _beaker.left,
                top: 15,
                child: _PhAccordion(
                  title: 'pH',
                  showProbe: true,
                  probeBottomY: _beaker.position.dy,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SpinnerButton(
                        up: true,
                        onPressed: () {
                          sol.pH = PhScaleConstants.toFixedNumber(
                            sol.pH + 0.01,
                            2,
                          );
                        },
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          sol.pH.toStringAsFixed(2),
                          textAlign: TextAlign.center,
                          style: PhScaleFonts.spinner,
                        ),
                      ),
                      _SpinnerButton(
                        up: false,
                        onPressed: () {
                          sol.pH = PhScaleConstants.toFixedNumber(
                            sol.pH - 0.01,
                            2,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: 20,
                child: KratosResetAllButton(
                  radius: 20.8 * 1.32,
                  onPressed: () {
                    _model.reset();
                    _view.reset();
                    _graph.reset();
                    setState(() {});
                  },
                ),
              ),
        ],
      ),
    );
  }
}

class _PhAccordion extends StatelessWidget {
  const _PhAccordion({
    required this.title,
    required this.child,
    this.showProbe = false,
    this.probeBottomY,
  });

  final String title;
  final Widget child;
  final bool showProbe;
  /// Absolute Y (layout coords) for probe tip; used with [showProbe].
  final double? probeBottomY;

  @override
  Widget build(BuildContext context) {
    // Accordion box alone; probe drawn as overflow below when requested.
    const boxH = 88.0;
    final probeLen = showProbe && probeBottomY != null
        ? (probeBottomY! - 15 - boxH).clamp(40.0, 600.0)
        : 0.0;

    return SizedBox(
      width: 200,
      height: boxH + probeLen,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          if (probeLen > 0)
            Positioned(
              top: boxH - 4,
              child: CustomPaint(
                size: Size(14, probeLen),
                painter: _ProbeStickPainter(),
              ),
            ),
          Container(
            width: 200,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: PhScaleColors.panelFill,
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: PhScaleFonts.accordionTitle),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProbeStickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shaft = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width / 2 - 4, 0, 8, size.height - 12),
      const Radius.circular(2),
    );
    canvas.drawRRect(shaft, Paint()..color = const Color(0xFF9E9E9E));
    canvas.drawRRect(
      shaft,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final tip = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 - 6, size.height - 14)
      ..lineTo(size.width / 2 + 6, size.height - 14)
      ..close();
    canvas.drawPath(tip, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SpinnerButton extends StatelessWidget {
  const _SpinnerButton({required this.up, required this.onPressed});

  final bool up;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        color: const Color(0xFFCCCCCC),
        child: CustomPaint(painter: _TrianglePainter(up: up)),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.up});

  final bool up;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (up) {
      path
        ..moveTo(size.width / 2, 6)
        ..lineTo(size.width - 6, size.height - 6)
        ..lineTo(6, size.height - 6)
        ..close();
    } else {
      path
        ..moveTo(6, 6)
        ..lineTo(size.width - 6, 6)
        ..lineTo(size.width / 2, size.height - 6)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.up != up;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/atomic_interactions_controller.dart';
import '../layout/interaction_scene_layout.dart';
import '../model/atom_pair.dart';
import '../model/dual_atom_model.dart';
import '../model/force_display_mode.dart';
import '../painters/lj_potential_graph_painter.dart';
import '../som_assets.dart';
import '../som_colors.dart';
import '../som_constants.dart';
import '../som_strings.dart';
import '../transform/som_interaction_transform.dart';
import '../widgets/som_reset_button.dart';
import '../widgets/som_scene_shell.dart';
import '../widgets/som_time_control.dart';

/// Atomic Interactions — PhET MVT (145,360)×0.25 via [SomInteractionTransform].
class AtomicInteractionsScreen extends StatefulWidget {
  const AtomicInteractionsScreen({super.key, required this.controller});

  final AtomicInteractionsController controller;

  @override
  State<AtomicInteractionsScreen> createState() =>
      _AtomicInteractionsScreenState();
}

class _AtomicInteractionsScreenState extends State<AtomicInteractionsScreen> {
  AtomicInteractionsController get _c => widget.controller;
  static const _mvt = SomInteractionTransform();

  @override
  void initState() {
    super.initState();
    _c.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _c.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SomSceneShell(child: _buildLayout());
  }

  Widget _buildLayout() {
    final m = _c.model;
    final fixedView = _mvt.modelToView(0, 0);
    final movableView =
        _mvt.modelToView(m.movableAtom.getX(), m.movableAtom.getY());
    // PhET ParticleNode: modelRadius × MVT × OVERLAP_ENLARGEMENT_FACTOR
    final fixedR = _mvt.modelToViewScale(m.fixedAtom.radius) *
        InteractionSceneLayout.particleOverlapFactor;
    final movableR = _mvt.modelToViewScale(m.movableAtom.radius) *
        InteractionSceneLayout.particleOverlapFactor;

    final graphLeft = InteractionSceneLayout.graphLeft();

    final pinRight = _mvt.modelToViewX(-m.fixedAtom.radius * 0.5);
    final pinBottom = _mvt.modelToViewY(-m.fixedAtom.radius * 0.5);
    const pinH = InteractionSceneLayout.pushPinWidth * (366 / 327);
    const pinW = InteractionSceneLayout.pushPinWidth;

    const handW = InteractionSceneLayout.handWidth;
    const handH = handW * (179 / 186);

    final showReturn = m.isMovableAtomOffCanvas;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: graphLeft,
          top: InteractionSceneLayout.inset +
              InteractionSceneLayout.graphTopExtra,
          child: LjPotentialGraphPanel(
            width: InteractionSceneLayout.graphWidth,
            height: InteractionSceneLayout.graphHeight,
            calculator: m.ljPotentialCalculator,
            markerDistance: m.movableAtom.getX(),
            expanded: true,
            showHeader: false,
          ),
        ),
        Positioned(
          left: fixedView.dx - fixedR,
          top: fixedView.dy - fixedR,
          child: _AtomDisc(color: m.fixedAtom.color, radius: fixedR),
        ),
        if (m.forcesDisplayMode != ForceDisplayMode.hidden)
          Positioned.fill(
            child: CustomPaint(
              painter: _ForceArrowsPainter(
                fixedCenter: fixedView,
                movableCenter: movableView,
                attractive: m.attractiveForce,
                repulsive: m.repulsiveForce,
                mode: m.forcesDisplayMode,
              ),
            ),
          ),
        // Movable atom (may be off-canvas → Return Atom)
        Positioned(
          left: movableView.dx - movableR,
          top: movableView.dy - movableR,
          child: GestureDetector(
            onHorizontalDragStart: (_) => _c.dragTo(m.movableAtom.getX()),
            onHorizontalDragUpdate: (d) {
              final newViewX = movableView.dx + d.delta.dx;
              _c.dragTo(_mvt.viewToModelX(newViewX));
            },
            onHorizontalDragEnd: (_) => _c.endDrag(),
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: _AtomDisc(color: m.movableAtom.color, radius: movableR),
            ),
          ),
        ),
        Positioned(
          left: pinRight - pinW,
          top: pinBottom - pinH,
          child: Image.asset(
            SomAssets.pushPin,
            width: pinW,
            height: pinH,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
          ),
        ),
        if (m.movementHintVisible && !showReturn)
          Positioned(
            left: movableView.dx,
            top: movableView.dy,
            child: GestureDetector(
              onHorizontalDragStart: (_) => _c.dragTo(m.movableAtom.getX()),
              onHorizontalDragUpdate: (d) {
                final newViewX = movableView.dx + d.delta.dx;
                _c.dragTo(_mvt.viewToModelX(newViewX));
              },
              onHorizontalDragEnd: (_) => _c.endDrag(),
              child: Image.asset(
                SomAssets.hand,
                width: handW,
                height: handH,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        if (showReturn)
          Positioned(
            left: InteractionSceneLayout.returnAtomLeft,
            bottom: InteractionSceneLayout.returnAtomBottomInset,
            child: _ReturnAtomButton(onPressed: _c.returnAtom),
          ),
        // Right column: Atoms panel + Forces accordion (PhET stack)
        Positioned(
          right: InteractionSceneLayout.resetSideInset +
              InteractionSceneLayout.resetRadius * 2 +
              20,
          top: InteractionSceneLayout.inset,
          child: SizedBox(
            width: InteractionSceneLayout.panelWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AtomsControlPanel(
                  model: m,
                  width: InteractionSceneLayout.panelWidth,
                  onAtomPair: _c.setAtomPair,
                  onEpsilon: _c.setEpsilon,
                  onSigma: _c.setAdjustableAtomSigma,
                ),
                const SizedBox(height: 8),
                _ForcesAccordion(
                  model: m,
                  width: InteractionSceneLayout.panelWidth,
                  onForceMode: _c.setForcesDisplayMode,
                  onToggle: _c.toggleForcesExpanded,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: InteractionSceneLayout.layoutWidth / 2 +
              InteractionSceneLayout.timeControlCenterXOffset -
              120,
          bottom: InteractionSceneLayout.timeControlBottomInset,
          child: Row(
            children: [
              SomTimeControl(
                isPlaying: m.isPlaying,
                onPlayPause: _c.togglePlaying,
                onStep: _c.stepOnce,
              ),
              const SizedBox(width: 16),
              _SpeedRadio(
                label: SomStrings.normal,
                selected: m.timeSpeed == InteractionTimeSpeed.normal,
                onTap: () => _c.setTimeSpeed(InteractionTimeSpeed.normal),
              ),
              const SizedBox(width: 12),
              _SpeedRadio(
                label: SomStrings.slowMotion,
                selected: m.timeSpeed == InteractionTimeSpeed.slow,
                onTap: () => _c.setTimeSpeed(InteractionTimeSpeed.slow),
              ),
            ],
          ),
        ),
        Positioned(
          right: InteractionSceneLayout.resetSideInset,
          bottom: InteractionSceneLayout.resetBottomInset,
          child: SomResetButton(
            radius: InteractionSceneLayout.resetRadius,
            onPressed: _c.resetAll,
          ),
        ),
      ],
    );
  }
}

class _ReturnAtomButton extends StatelessWidget {
  const _ReturnAtomButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF61BEE3),
      borderRadius: BorderRadius.circular(5),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(5),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            SomStrings.returnAtom,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _AtomDisc extends StatelessWidget {
  const _AtomDisc({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [
            Color.lerp(color, Colors.white, 0.55)!,
            color,
            Color.lerp(color, Colors.black, 0.35)!,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
    );
  }
}

/// PhET force colors: attractive `#FC9732`, repulsive `#FD17FF`, total `#49B649`.
class _ForceArrowsPainter extends CustomPainter {
  _ForceArrowsPainter({
    required this.fixedCenter,
    required this.movableCenter,
    required this.attractive,
    required this.repulsive,
    required this.mode,
  });

  final Offset fixedCenter;
  final Offset movableCenter;
  final double attractive;
  final double repulsive;
  final ForceDisplayMode mode;

  static const _attractive = Color(0xFFFC9732);
  static const _repulsive = Color(0xFFFD17FF);
  static const _total = Color(0xFF49B649);

  @override
  void paint(Canvas canvas, Size size) {
    double len(double f) {
      final mag = f.abs();
      if (mag < 1e-40) return 0;
      return (14 + math.log(mag + 1e-35) * 3.5).clamp(10.0, 90.0);
    }

    void arrow(Offset from, double dx, Color color) {
      if (dx.abs() < 1) return;
      final to = Offset(from.dx + dx, from.dy);
      final paint = Paint()
        ..color = color
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(from, to, paint);
      final dir = dx.sign;
      final tip = Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(to.dx - dir * 12, to.dy - 7)
        ..lineTo(to.dx - dir * 12, to.dy + 7)
        ..close();
      canvas.drawPath(tip, Paint()..color = color);
    }

    if (mode == ForceDisplayMode.components) {
      // Attractive pulls movable left (−); repulsive pushes right (+)
      arrow(movableCenter.translate(0, -14), -len(attractive), _attractive);
      arrow(movableCenter.translate(0, 14), len(repulsive), _repulsive);
      arrow(fixedCenter.translate(0, -14), len(attractive), _attractive);
      arrow(fixedCenter.translate(0, 14), -len(repulsive), _repulsive);
    } else if (mode == ForceDisplayMode.total) {
      final net = repulsive - attractive;
      arrow(
        movableCenter,
        net >= 0 ? len(net.abs()) : -len(net.abs()),
        _total,
      );
      arrow(
        fixedCenter,
        net >= 0 ? -len(net.abs()) : len(net.abs()),
        _total,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ForceArrowsPainter oldDelegate) =>
      oldDelegate.attractive != attractive ||
      oldDelegate.repulsive != repulsive ||
      oldDelegate.movableCenter != movableCenter ||
      oldDelegate.mode != mode;
}

class _AtomsControlPanel extends StatelessWidget {
  const _AtomsControlPanel({
    required this.model,
    required this.width,
    required this.onAtomPair,
    required this.onEpsilon,
    required this.onSigma,
  });

  final DualAtomModel model;
  final double width;
  final ValueChanged<AtomPair> onAtomPair;
  final ValueChanged<double> onEpsilon;
  final ValueChanged<double> onSigma;

  Color _swatch(AtomPair pair) {
    switch (pair) {
      case AtomPair.neonNeon:
        return SomConstants.neonColor;
      case AtomPair.argonArgon:
        return SomConstants.argonColor;
      case AtomPair.adjustable:
        return SomConstants.adjustableAttractionColor;
      default:
        return Colors.grey;
    }
  }

  String _label(AtomPair pair) {
    switch (pair) {
      case AtomPair.neonNeon:
        return SomStrings.neon;
      case AtomPair.argonArgon:
        return SomStrings.argon;
      case AtomPair.adjustable:
        return SomStrings.adjustableAttraction;
      default:
        return pair.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      decoration: BoxDecoration(
        color: SomColors.controlPanelBackground,
        border: Border.all(color: SomColors.controlPanelStroke),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            SomStrings.atoms,
            style: TextStyle(
              color: SomColors.controlPanelText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          for (final pair in model.validAtomPairs)
            _atomRow(
              label: _label(pair),
              color: _swatch(pair),
              selected: model.atomPair == pair,
              onTap: () => onAtomPair(pair),
            ),
          if (model.atomPair == AtomPair.adjustable) ...[
            const SizedBox(height: 6),
            const Text(
              SomStrings.interactionStrength,
              style: TextStyle(color: SomColors.controlPanelText, fontSize: 11),
            ),
            _slider(
              context,
              value: model.adjustableAtomInteractionStrength.clamp(
                SomConstants.minEpsilon,
                SomConstants.maxEpsilon,
              ),
              min: SomConstants.minEpsilon,
              max: SomConstants.maxEpsilon,
              onChanged: onEpsilon,
            ),
            const Text(
              SomStrings.atomDiameter,
              style: TextStyle(color: SomColors.controlPanelText, fontSize: 11),
            ),
            _slider(
              context,
              value: model.adjustableAtomDiameter.clamp(
                SomConstants.minSigma,
                SomConstants.maxSigma,
              ),
              min: SomConstants.minSigma,
              max: SomConstants.maxSigma,
              onChanged: onSigma,
            ),
          ],
        ],
      ),
    );
  }

  Widget _slider(
    BuildContext context, {
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        activeTrackColor: const Color(0xFF71EDFF),
        inactiveTrackColor: Colors.white24,
        thumbColor: const Color(0xFF71EDFF),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }

  Widget _atomRow({
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? const Color(0xFF3A3A5A) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: selected
                  ? Border.all(color: Colors.white70, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.35, -0.35),
                      colors: [
                        Color.lerp(color, Colors.white, 0.55)!,
                        color,
                        Color.lerp(color, Colors.black, 0.35)!,
                      ],
                    ),
                    border: Border.all(color: Colors.white24, width: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForcesAccordion extends StatelessWidget {
  const _ForcesAccordion({
    required this.model,
    required this.width,
    required this.onForceMode,
    required this.onToggle,
  });

  final DualAtomModel model;
  final double width;
  final ValueChanged<ForceDisplayMode> onForceMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: SomColors.controlPanelBackground,
        border: Border.all(color: SomColors.controlPanelStroke),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Text(
                    model.forcesExpanded ? '−' : '+',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      SomStrings.forces,
                      style: TextStyle(
                        color: SomColors.controlPanelText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (model.forcesExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _forceOption(
                    selected: model.forcesDisplayMode == ForceDisplayMode.hidden,
                    onTap: () => onForceMode(ForceDisplayMode.hidden),
                    child: const Text(
                      SomStrings.hideForces,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  _forceOption(
                    selected: model.forcesDisplayMode == ForceDisplayMode.total,
                    onTap: () => onForceMode(ForceDisplayMode.total),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            SomStrings.totalForce,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        _miniArrow(const Color(0xFF49B649), left: true),
                      ],
                    ),
                  ),
                  _forceOption(
                    selected:
                        model.forcesDisplayMode == ForceDisplayMode.components,
                    onTap: () => onForceMode(ForceDisplayMode.components),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2, right: 4),
                          child: CustomPaint(
                            size: const Size(8, 52),
                            painter: _BracketPainter(),
                          ),
                        ),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ComponentLine(
                                SomStrings.attractive,
                                Color(0xFFFC9732),
                                left: true,
                              ),
                              Text(
                                SomStrings.vanderwaals,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                              _ComponentLine(
                                SomStrings.repulsive,
                                Color(0xFFFD17FF),
                                left: false,
                              ),
                              Text(
                                SomStrings.electronOverlap,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _forceOption({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: CustomPaint(
                size: const Size(12, 12),
                painter: _MiniRadioPainter(selected: selected),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _ComponentLine extends StatelessWidget {
  const _ComponentLine(this.label, this.color, {required this.left});

  final String label;
  final Color color;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        _miniArrow(color, left: left),
      ],
    );
  }
}

Widget _miniArrow(Color color, {required bool left}) {
  return CustomPaint(
    size: const Size(22, 10),
    painter: _MiniForceArrowPainter(color: color, pointLeft: left),
  );
}

class _MiniForceArrowPainter extends CustomPainter {
  _MiniForceArrowPainter({required this.color, required this.pointLeft});

  final Color color;
  final bool pointLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    if (pointLeft) {
      canvas.drawLine(Offset(size.width, y), Offset(6, y), paint);
      final tip = Path()
        ..moveTo(0, y)
        ..lineTo(7, y - 4.5)
        ..lineTo(7, y + 4.5)
        ..close();
      canvas.drawPath(tip, Paint()..color = color);
    } else {
      canvas.drawLine(Offset(0, y), Offset(size.width - 6, y), paint);
      final tip = Path()
        ..moveTo(size.width, y)
        ..lineTo(size.width - 7, y - 4.5)
        ..lineTo(size.width - 7, y + 4.5)
        ..close();
      canvas.drawPath(tip, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniForceArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointLeft != pointLeft;
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(2, 0)
      ..lineTo(2, size.height / 2 - 3)
      ..lineTo(0, size.height / 2)
      ..lineTo(2, size.height / 2 + 3)
      ..lineTo(2, size.height)
      ..lineTo(size.width, size.height);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniRadioPainter extends CustomPainter {
  _MiniRadioPainter({required this.selected});
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      size.shortestSide / 2 - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white70,
    );
    if (selected) {
      canvas.drawCircle(
        c,
        size.shortestSide * 0.28,
        Paint()..color = const Color(0xFF71EDFF),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniRadioPainter oldDelegate) =>
      oldDelegate.selected != selected;
}

class _SpeedRadio extends StatelessWidget {
  const _SpeedRadio({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(14, 14),
            painter: _MiniRadioPainter(selected: selected),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

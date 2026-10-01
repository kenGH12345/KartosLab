import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../layout/membrane_transport_layout.dart';
import '../layout/membrane_transport_layout_composer.dart';
import '../membrane_transport_constants.dart';
import '../membrane_transport_feature_set.dart';
import '../model/membrane_transport_model.dart';
import '../model/mt_random.dart';
import '../model/particle_mode.dart';
import '../model/slot.dart';
import '../model/solute_type.dart';
import '../model/transport_protein_type.dart';
import '../view/observation_window_painter.dart';
import '../view/particle_image_cache.dart';
import '../view/protein_drag_session.dart';
import '../view/protein_image_cache.dart';
import '../view/transport_protein_panel.dart';

/// Shared screen body — featureSet gates proteins / voltage / ligands / ATP.
class MembraneTransportScreenBody extends StatefulWidget {
  const MembraneTransportScreenBody({
    super.key,
    required this.featureSet,
    this.seed = 1,
    this.pausedForGolden = false,
  });

  final MembraneTransportFeatureSet featureSet;
  final int seed;

  /// When true, model starts paused (deterministic Golden / layout tests).
  final bool pausedForGolden;

  @override
  State<MembraneTransportScreenBody> createState() =>
      _MembraneTransportScreenBodyState();
}

class _MembraneTransportScreenBodyState
    extends State<MembraneTransportScreenBody>
    with SingleTickerProviderStateMixin {
  late final MembraneTransportModel model;
  late final List<Phospholipid> phospholipids;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  bool _imagesReady = false;

  /// Exposed for Golden / layout tests (paused screens).
  MembraneTransportModel get testModel => model;

  @override
  void initState() {
    super.initState();
    model = MembraneTransportModel(
      featureSet: widget.featureSet,
      random: SeededMtRandom(widget.seed),
    );
    if (widget.pausedForGolden) {
      model.isPlaying = false;
    }
    phospholipids = Phospholipid.createAll(model.random);
    _ticker = createTicker(_onTick)..start();
    Future.wait([
      ParticleImageCache.ensureLoaded(),
      if (featureSetHasProteins(widget.featureSet))
        ProteinImageCache.ensureLoaded(),
    ]).then((_) {
      if (mounted) setState(() => _imagesReady = true);
    });
  }

  void _onTick(Duration elapsed) {
    if (widget.pausedForGolden) return;
    final dt = _last == Duration.zero
        ? 0.0
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt <= 0 || dt > 0.25) return;

    model.step(dt);
    if (model.isPlaying) {
      final scaled = dt * model.getTimeSpeedFactor();
      for (final p in phospholipids) {
        p.step(scaled, model.random);
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MembraneTransportLayoutPrimitives.fitScale(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final phys = MembraneTransportLayoutPrimitives.physicalSize(scale);
        return ColoredBox(
          color: MembraneTransportColors.outsideCell,
          child: Center(
            child: SizedBox(
              width: phys.width,
              height: phys.height,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: MembraneTransportLayoutPrimitives.designWidth,
                  height: MembraneTransportLayoutPrimitives.designHeight,
                  child: ListenableBuilder(
                    listenable: model,
                    builder: (context, _) => _DesignSpace(
                      model: model,
                      phospholipids: phospholipids,
                      imagesReady: _imagesReady,
                      onResetRequested: () {
                        model.reset();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Thin alias kept for Phase 3 tests / imports.
class SimpleDiffusionScreenBody extends MembraneTransportScreenBody {
  const SimpleDiffusionScreenBody({super.key, super.seed})
      : super(featureSet: MembraneTransportFeatureSet.simpleDiffusion);
}

class _DesignSpace extends StatefulWidget {
  const _DesignSpace({
    required this.model,
    required this.phospholipids,
    required this.imagesReady,
    required this.onResetRequested,
  });

  final MembraneTransportModel model;
  final List<Phospholipid> phospholipids;
  final bool imagesReady;
  final VoidCallback onResetRequested;

  @override
  State<_DesignSpace> createState() => _DesignSpaceState();
}

class _DesignSpaceState extends State<_DesignSpace> {
  final GlobalKey _designKey = GlobalKey();
  ProteinDragSession? _drag;
  int? _highlightIndex;

  MembraneTransportModel get model => widget.model;

  Offset? _globalToDesign(Offset global) {
    final box = _designKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.globalToLocal(global);
  }

  void _startToolboxDrag(TransportProteinType type, Offset global) {
    final design = _globalToDesign(global);
    if (design == null) return;
    setState(() {
      _drag = ProteinDragSession(
        type: type,
        originSlot: null,
        initialModelPosition: ProteinDragSession.designToModel(design),
      );
      _updateHighlight();
    });
  }

  void _startMembraneDrag(Slot slot, Offset global) {
    final type = slot.transportProteinType;
    if (type == null) return;
    final design = _globalToDesign(global);
    if (design == null) return;
    // Source clears slot immediately on pickup
    slot.setTransportProteinType(null);
    model.notifyAfterSlotMutation();
    setState(() {
      _drag = ProteinDragSession(
        type: type,
        originSlot: slot,
        initialModelPosition: ProteinDragSession.designToModel(design),
      );
      _updateHighlight();
    });
  }

  void _updateDrag(Offset global) {
    if (_drag == null) return;
    final design = _globalToDesign(global);
    if (design == null) return;
    setState(() {
      _drag!.modelPosition = ProteinDragSession.designToModel(design);
      _updateHighlight();
    });
  }

  void _updateHighlight() {
    if (_drag == null) {
      _highlightIndex = null;
      return;
    }
    final closest = ProteinDragSession.closestOverlappingSlot(
      dragBounds: _drag!.designBounds,
      slots: model.membraneSlots,
    );
    _highlightIndex = closest == null
        ? null
        : model.membraneSlots.indexOf(closest);
  }

  void _endDrag() {
    final session = _drag;
    if (session == null) return;
    final target = ProteinDragSession.closestOverlappingSlot(
      dragBounds: session.designBounds,
      slots: model.membraneSlots,
    );
    if (target != null) {
      model.dropProteinFromDrag(
        session.type,
        target,
        originSlot: session.originSlot,
      );
    }
    // Invalid drop: protein returns to toolbox (already cleared if from slot)
    setState(() {
      _drag = null;
      _highlightIndex = null;
    });
  }

  void _cancelDrag() {
    final session = _drag;
    if (session == null) return;
    // Return to origin slot if dragged from membrane
    if (session.originSlot != null) {
      session.originSlot!.setTransportProteinType(session.type);
      model.notifyAfterSlotMutation();
    }
    setState(() {
      _drag = null;
      _highlightIndex = null;
    });
  }

  void _onReset() {
    _cancelDrag();
    widget.onResetRequested();
  }

  Slot? _hitFilledSlot(Offset observationLocal) {
    final modelPt =
        MembraneTransportLayoutSpec.observationViewToModel(observationLocal);
    const hitR = MembraneTransportConstants.transportProteinWidth / 2;
    for (final slot in model.membraneSlots) {
      if (!slot.isFilled) continue;
      if ((slot.position - modelPt.dx).abs() <= hitR &&
          modelPt.dy.abs() <= 20) {
        return slot;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final slots = MembraneTransportLayoutSpec.resolve(
      featureSet: model.featureSet,
    );
    final obs = slots.observation;

    return Listener(
      onPointerMove: (e) {
        if (_drag != null) _updateDrag(e.position);
      },
      onPointerUp: (_) => _endDrag(),
      onPointerCancel: (_) => _cancelDrag(),
      child: SizedBox(
        key: _designKey,
        width: MembraneTransportLayoutPrimitives.designWidth,
        height: MembraneTransportLayoutPrimitives.designHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            MembraneTransportLayoutComposer(
              slots: slots,
              selectedSolute: model.selectedSolute,
              onReset: _onReset,
              observation: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (d) {
                  if (_drag != null) return;
                  final hit = _hitFilledSlot(d.localPosition);
                  if (hit != null) {
                    _startMembraneDrag(hit, d.globalPosition);
                  }
                },
                // PhET ObservationWindow clipArea — particles must not paint outside
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    MembraneTransportLayoutPrimitives.observationCornerRadius,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CustomPaint(
                    painter: ObservationWindowPainter(
                      model: model,
                      phospholipids: widget.phospholipids,
                      particleImages: widget.imagesReady
                          ? ParticleImageCache.images
                          : const {},
                      showSlotIndicators: _drag != null,
                      highlightedSlotIndex: _highlightIndex,
                    ),
                    size: Size(obs.width, obs.height),
                  ),
                ),
              ),
              solutesPanel: _SolutesPanel(model: model),
              outsideControl: _SideSoluteControl(
                model: model,
                side: MembraneSide.outside,
              ),
              insideControl: _SideSoluteControl(
                model: model,
                side: MembraneSide.inside,
              ),
              cell: SizedBox(
                width: MembraneTransportLayoutPrimitives.cellMaxWidth,
                height: MembraneTransportLayoutPrimitives.cellMaxWidth *
                    (305.63 / 332.58),
                child: SvgPicture.asset(
                  MembraneTransportAssets.cell,
                  fit: BoxFit.contain,
                ),
              ),
              eraser: _EraserButton(model: model),
              timeControls: _TimeControls(model: model),
              crossingOptions: _CrossingOptions(model: model),
              concentrationsGraph: _ConcentrationsPanel(model: model),
              proteinPanel: slots.showProteinPanel
                  ? TransportProteinPanel(
                      model: model,
                      onDragStart: _startToolboxDrag,
                    )
                  : null,
            ),
            if (_drag != null)
              Positioned(
                left: _drag!.designBounds.left,
                top: _drag!.designBounds.top,
                width: _drag!.designBounds.width,
                height: _drag!.designBounds.height,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.92,
                    child: SvgPicture.asset(
                      MembraneTransportAssets.forProteinToolbox(_drag!.type),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SolutesPanel extends StatelessWidget {
  const _SolutesPanel({required this.model});
  final MembraneTransportModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MembraneTransportLayoutPrimitives.solutesPanelWidth,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FC),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Solutes',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          for (final t in model.selectableSolutes)
            _SoluteRadio(model: model, type: t),
        ],
      ),
    );
  }
}

class _SoluteRadio extends StatelessWidget {
  const _SoluteRadio({required this.model, required this.type});
  final MembraneTransportModel model;
  final SoluteType type;

  @override
  Widget build(BuildContext context) {
    final selected = model.selectedSolute == type;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => model.setSelectedSolute(type),
        child: Container(
          width: 68,
          padding: const EdgeInsets.fromLTRB(2, 3, 2, 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected ? const Color(0xFF1565C0) : Colors.black26,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 22,
                child: SvgPicture.asset(
                  MembraneTransportAssets.forParticleType(type.name),
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                type.panelLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, height: 1.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideSoluteControl extends StatelessWidget {
  const _SideSoluteControl({required this.model, required this.side});
  final MembraneTransportModel model;
  final MembraneSide side;

  @override
  Widget build(BuildContext context) {
    final fill = side == MembraneSide.outside
        ? MembraneTransportColors.observationOutside
        : MembraneTransportColors.observationInside;
    final label = side == MembraneSide.outside ? 'Outside' : 'Inside';
    final count = model.countSolutes(model.selectedSolute, side);
    final total =
        model.countSolutes(model.selectedSolute, MembraneSide.outside) +
            model.countSolutes(model.selectedSolute, MembraneSide.inside);

    return Container(
      width: MembraneTransportLayoutPrimitives.soluteControlWidth,
      padding: const EdgeInsets.fromLTRB(4, 3, 4, 4),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black45),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 22,
            width: 40,
            child: SvgPicture.asset(
              MembraneTransportAssets.forParticleType(
                model.selectedSolute.name,
              ),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ArrowBtn(
                icon: Icons.keyboard_double_arrow_left,
                enabled: count > 0,
                onPressed: () => model.removeSolutes(
                  model.selectedSolute,
                  side,
                  count < 50 ? count : 50,
                ),
              ),
              _ArrowBtn(
                icon: Icons.chevron_left,
                enabled: count > 0,
                onPressed: () => model.removeSolutes(
                  model.selectedSolute,
                  side,
                  count < 10 ? count : 10,
                ),
              ),
              _ArrowBtn(
                icon: Icons.chevron_right,
                enabled: total < MembraneTransportConstants.maxSoluteCount,
                onPressed: () {
                  final room =
                      MembraneTransportConstants.maxSoluteCount - total;
                  model.addSolutes(
                    model.selectedSolute,
                    side,
                    room < 10 ? room : 10,
                  );
                },
              ),
              _ArrowBtn(
                icon: Icons.keyboard_double_arrow_right,
                enabled: total < MembraneTransportConstants.maxSoluteCount,
                onPressed: () {
                  final room =
                      MembraneTransportConstants.maxSoluteCount - total;
                  model.addSolutes(
                    model.selectedSolute,
                    side,
                    room < 50 ? room : 50,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  const _ArrowBtn({
    required this.icon,
    required this.onPressed,
    required this.enabled,
  });
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: SizedBox(
        width: 18,
        height: 18,
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.black87 : Colors.black26,
        ),
      ),
    );
  }
}

class _EraserButton extends StatelessWidget {
  const _EraserButton({required this.model});
  final MembraneTransportModel model;

  /// PhET EraserButton — yellow RectangularPushButton + scenery-phet eraser glyph
  /// (MembraneTransportScreenView scale 1.2, iconWidth 20).
  static const Color _baseYellow = Color(0xFFEEF422);

  @override
  Widget build(BuildContext context) {
    final enabled = model.hasAnySolutes;
    const iconW = MembraneTransportAssets.eraserIconWidth;
    const iconH = iconW * (55.96 / 69.44);
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Material(
        color: _baseYellow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(color: Color(0xFF505050), width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: enabled ? model.clearSolutes : null,
          child: SizedBox(
            width: MembraneTransportLayoutPrimitives.eraserWidth,
            height: MembraneTransportLayoutPrimitives.eraserHeight,
            child: Center(
              child: CustomPaint(
                size: const Size(iconW, iconH),
                painter: const _PhEraserGlyphPainter(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// scenery-phet `eraser.svg` geometry (viewBox 69.44×55.96), solid fills.
class _PhEraserGlyphPainter extends CustomPainter {
  const _PhEraserGlyphPainter();

  static Path _scaled(Path src, Size size) {
    final m = Matrix4.diagonal3Values(
      size.width / 69.44,
      size.height / 55.96,
      1,
    );
    return src.transform(m.storage);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Tip (bottom-left worn rubber)
    final tip = Path()
      ..moveTo(5.86, 31.78)
      ..cubicTo(3.72, 37.24, 1.64, 42.77, 0.82, 48.57)
      ..cubicTo(0.23, 52.69, 2.24, 54.14, 6.21, 54.60)
      ..cubicTo(11.92, 55.26, 17.91, 55.44, 23.64, 55.01)
      ..cubicTo(30.36, 54.51, 34.18, 54.68, 36.44, 47.83)
      ..cubicTo(37.84, 43.59, 38.20, 42.33, 38.76, 39.36)
      ..cubicTo(39.41, 35.91, 39.36, 34.00, 40.38, 31.78)
      ..lineTo(5.86, 31.78)
      ..close();

    // Left body face
    final left = Path()
      ..moveTo(36.82, 1.44)
      ..quadraticBezierTo(35.57, 1.92, 33.82, 3.40)
      ..cubicTo(31.18, 5.63, 28.31, 8.93, 25.91, 11.43)
      ..cubicTo(20.54, 17.05, 14.98, 22.50, 9.52, 28.04)
      ..cubicTo(9.03, 28.54, 8.27, 29.25, 5.86, 31.78)
      ..lineTo(40.38, 31.78)
      ..lineTo(68.72, 0.73)
      ..cubicTo(64.01, 0.73, 59.31, 0.72, 54.60, 0.73)
      ..cubicTo(51.07, 0.73, 47.54, 0.77, 44.01, 0.73)
      ..cubicTo(41.10, 0.71, 38.86, 0.65, 36.82, 1.44)
      ..close();

    // Right body face
    final right = Path()
      ..moveTo(68.72, 0.73)
      ..lineTo(40.38, 31.78)
      ..cubicTo(40.12, 32.18, 39.74, 34.00, 39.47, 34.96)
      ..cubicTo(39.00, 36.64, 38.43, 38.83, 37.97, 40.53)
      ..cubicTo(36.73, 45.07, 36.44, 46.38, 35.06, 50.89)
      ..cubicTo(43.64, 41.54, 50.57, 34.85, 59.16, 25.50)
      ..cubicTo(63.21, 21.10, 65.50, 17.81, 66.58, 12.02)
      ..cubicTo(67.28, 8.26, 67.98, 4.50, 68.71, 0.74)
      ..close();

    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.44 * (size.width / 69.44)
      ..strokeJoin = StrokeJoin.round;

    void fillStroke(Path p, Color c) {
      final sp = _scaled(p, size);
      canvas.drawPath(sp, Paint()..color = c);
      canvas.drawPath(sp, stroke);
    }

    fillStroke(tip, const Color(0xFFD7D7D7));
    fillStroke(left, const Color(0xFFC9C9C9));
    fillStroke(right, const Color(0xFFA9A9A9));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TimeControls extends StatelessWidget {
  const _TimeControls({required this.model});
  final MembraneTransportModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: const Color(0xFF1976D2),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => model.setPlaying(!model.isPlaying),
            child: SizedBox(
              width: MembraneTransportLayoutPrimitives.timeControlHeight,
              height: MembraneTransportLayoutPrimitives.timeControlHeight,
              child: Icon(
                model.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SpeedRadio(
              label: 'Normal',
              selected: model.timeSpeed == MtTimeSpeed.normal,
              onTap: () => model.setTimeSpeed(MtTimeSpeed.normal),
            ),
            _SpeedRadio(
              label: 'Slow',
              selected: model.timeSpeed == MtTimeSpeed.slow,
              onTap: () => model.setTimeSpeed(MtTimeSpeed.slow),
            ),
          ],
        ),
      ],
    );
  }
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
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _CrossingOptions extends StatelessWidget {
  const _CrossingOptions({required this.model});
  final MembraneTransportModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Check(
          label: 'Crossing Highlights',
          value: model.crossingHighlightsEnabled,
          onChanged: model.setCrossingHighlights,
        ),
        _Check(
          label: 'Crossing Sounds',
          value: model.crossingSoundsEnabled,
          onChanged: model.setCrossingSounds,
        ),
      ],
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: value,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: (v) => onChanged(v ?? false),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

/// PhET `SoluteConcentrationsAccordionBox` — title fixed at top; content
/// expands **downward**. Height always reserved (`useExpandedBoundsWhenCollapsed`).
class _ConcentrationsPanel extends StatefulWidget {
  const _ConcentrationsPanel({required this.model});
  final MembraneTransportModel model;

  @override
  State<_ConcentrationsPanel> createState() => _ConcentrationsPanelState();
}

class _ConcentrationsPanelState extends State<_ConcentrationsPanel> {
  /// PhET `expandedDefaultValue: true`
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    const w = MembraneTransportLayoutPrimitives.graphWidth;
    const h = MembraneTransportLayoutPrimitives.graphExpandedHeight;
    const contentH = MembraneTransportLayoutPrimitives.graphContentHeight;

    return SizedBox(
      width: w,
      height: h,
      child: Align(
        alignment: Alignment.topLeft,
        child: Material(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: const BorderSide(color: Colors.black87, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => setState(() => expanded = !expanded),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      // PhET AccordionBox expand button (green ± square)
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF58A700),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: Colors.black54, width: 0.8),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          expanded ? Icons.remove : Icons.add,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Solute Concentrations',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (expanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 4),
                  child: SizedBox(
                    width: w - 10,
                    height: contentH,
                    child: _SoluteConcentrationsContent(model: widget.model),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared Outside/Inside background + 5× [SoluteBarChartNode] (124×92).
class _SoluteConcentrationsContent extends StatelessWidget {
  const _SoluteConcentrationsContent({required this.model});
  final MembraneTransportModel model;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cw = constraints.maxWidth;
        final ch = constraints.maxHeight;
        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            children: [
              // Extracellular / intracellular halves
              Positioned(
                left: 0,
                top: 0,
                width: cw,
                height: ch / 2,
                child: const ColoredBox(
                  color: MembraneTransportColors.observationOutside,
                ),
              ),
              Positioned(
                left: 0,
                top: ch / 2,
                width: cw,
                height: ch / 2,
                child: const ColoredBox(
                  color: MembraneTransportColors.observationInside,
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _ContentBorderPainter(),
                ),
              ),
              // Outside / Inside labels — PhET TEXT_MARGIN=27, scale 0.85
              const Positioned(
                left: 4,
                top: 22,
                child: Text(
                  'Outside',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
              const Positioned(
                left: 4,
                bottom: 22,
                child: Text(
                  'Inside',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
              // Charts: left=50, top=5, spacing=10 — SoluteConcentrationsAccordionBox
              Positioned(
                left: 50,
                top: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < plottableSoluteTypes.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      _SoluteBarChartNode(
                        model: model,
                        type: plottableSoluteTypes[i],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContentBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(5),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// PhET `SoluteBarChartNode` — BOX 124×92; bars grow horizontally from origin.
class _SoluteBarChartNode extends StatelessWidget {
  const _SoluteBarChartNode({required this.model, required this.type});
  final MembraneTransportModel model;
  final SoluteType type;

  static const double boxW = MembraneTransportLayoutPrimitives.barChartBoxWidth;
  static const double boxH = MembraneTransportLayoutPrimitives.barChartBoxHeight;

  @override
  Widget build(BuildContext context) {
    final outside = model.countSolutes(type, MembraneSide.outside);
    final inside = model.countSolutes(type, MembraneSide.inside);
    final iconScale = type == SoluteType.glucose
        ? 0.55
        : type == SoluteType.potassiumIon
            ? 0.7
            : 0.85;

    return SizedBox(
      width: boxW,
      height: boxH,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          CustomPaint(
            size: const Size(boxW, boxH),
            painter: _SoluteBarChartPainter(
              outsideCount: outside,
              insideCount: inside,
              barColor: _barColor(type),
            ),
          ),
          Positioned(
            left: type == SoluteType.glucose ? 28 : 40,
            bottom: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22 * iconScale + 4,
                  height: 18,
                  child: SvgPicture.asset(
                    MembraneTransportAssets.forParticleType(type.name),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  type.panelLabel,
                  style: TextStyle(
                    fontSize: type == SoluteType.glucose ? 11 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _barColor(SoluteType t) {
    switch (t) {
      case SoluteType.oxygen:
        return const Color(0xFFFF0000);
      case SoluteType.carbonDioxide:
        return const Color(0xFF737373);
      case SoluteType.sodiumIon:
        return const Color(0xFFFF5500);
      case SoluteType.potassiumIon:
        return const Color(0xFF009BC2);
      case SoluteType.glucose:
        return const Color.fromRGBO(106, 42, 211, 1);
      default:
        return Colors.grey;
    }
  }
}

class _SoluteBarChartPainter extends CustomPainter {
  _SoluteBarChartPainter({
    required this.outsideCount,
    required this.insideCount,
    required this.barColor,
  });

  final int outsideCount;
  final int insideCount;
  final Color barColor;

  static const double boxW = MembraneTransportLayoutPrimitives.barChartBoxWidth;
  static const double boxH = MembraneTransportLayoutPrimitives.barChartBoxHeight;
  static const double barThickness = 15;
  static const double barMultiplier = 2;
  static const double paddingFactor = 0.95;
  static const double originX = 20;
  static const double originExtent = 54;

  double _countToWidth(int count) =>
      barMultiplier *
      count /
      MembraneTransportConstants.maxSoluteCount *
      (boxH / 2) *
      paddingFactor;

  @override
  void paint(Canvas canvas, Size size) {
    // Faint layout box — PhET layoutBox opacity 0.2
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, boxW, boxH),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, boxW, boxH),
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final midY = boxH / 2;

    // Membrane: phospholipid heads (orange) + tails (pink) — not a red line
    canvas.drawLine(
      Offset(0, midY),
      Offset(boxW, midY),
      Paint()
        ..color = MembraneTransportColors.phospholipidHead
        ..strokeWidth = 13 * 0.5
        ..strokeCap = StrokeCap.butt,
    );
    canvas.drawLine(
      Offset(0, midY),
      Offset(boxW, midY),
      Paint()
        ..color = MembraneTransportColors.phospholipidTail
        ..strokeWidth = 4 * 0.5
        ..strokeCap = StrokeCap.butt,
    );

    // Vertical origin axis
    canvas.drawLine(
      Offset(originX, midY + originExtent / 2),
      Offset(originX, midY - originExtent / 2),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );

    final outW = _countToWidth(outsideCount);
    final inW = _countToWidth(insideCount);
    final outCy = midY - (barThickness / 2 + 7);
    final inCy = midY + (barThickness / 2 + 7);

    void drawBar(double width, double centerY) {
      if (width <= 0) return;
      final rect = Rect.fromLTWH(
        originX,
        centerY - barThickness / 2,
        width,
        barThickness,
      );
      canvas.drawRect(rect, Paint()..color = barColor);
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    drawBar(outW, outCy);
    drawBar(inW, inCy);
  }

  @override
  bool shouldRepaint(covariant _SoluteBarChartPainter old) =>
      old.outsideCount != outsideCount ||
      old.insideCount != insideCount ||
      old.barColor != barColor;
}

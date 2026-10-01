import 'package:flutter/material.dart';

import '../../common/simulation_clock.dart';
import '../faradays_law_constants.dart';
import '../model/faradays_law_model.dart';
import 'components/bulb_widget.dart';
import 'components/coil_image_layer.dart';
import 'components/voltmeter_widget.dart';
import 'controls/control_panel.dart';
import 'painters/coils_wires_painter.dart';
import 'painters/field_lines_painter.dart';
import 'painters/magnet_arrows_painter.dart';
import 'painters/magnet_painter.dart';

/// Play area in source layout coordinates (834×504) — `FaradaysLawScreenView`.
///
/// Z-order (source):
/// wires → bulb → coil backs → voltmeter → field+magnet → coil fronts
class FaradaysLawPlayArea extends StatefulWidget {
  const FaradaysLawPlayArea({
    super.key,
    required this.model,
    this.autoStartClock = true,
  });

  final FaradaysLawModel model;

  /// Widget tests should set false — perpetual ticker hangs settle.
  final bool autoStartClock;

  @override
  State<FaradaysLawPlayArea> createState() => FaradaysLawPlayAreaState();
}

class FaradaysLawPlayAreaState extends State<FaradaysLawPlayArea>
    with TickerProviderStateMixin {
  late final SimulationClock clock;
  final GlobalKey layoutKey = GlobalKey(debugLabel: 'faradaysLawLayout');

  Offset? _grabOffset;

  FaradaysLawModel get model => widget.model;

  @override
  void initState() {
    super.initState();
    model.addListener(_onModel);
    clock = SimulationClock(fps: 60);
    clock.attach(this);
    clock.onTick = (dt, _) {
      model.step(dt);
    };
    if (widget.autoStartClock) {
      clock.play();
    }
  }

  void _onModel() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    clock.dispose();
    model.removeListener(_onModel);
    super.dispose();
  }

  Offset? globalToLayout(Offset global) {
    final box = layoutKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return box.globalToLocal(global);
  }

  void onDragStart(Offset global) {
    final local = globalToLayout(global);
    if (local == null) return;
    model.magnet.isDragging = true;
    _grabOffset = local - model.magnet.position;
  }

  void onDragUpdate(Offset global) {
    final local = globalToLayout(global);
    if (local == null || _grabOffset == null) return;
    model.moveMagnetToPosition(local - _grabOffset!);
  }

  void onDragEnd() {
    model.magnet.isDragging = false;
    _grabOffset = null;
  }

  @override
  Widget build(BuildContext context) {
    final layout = FaradaysLawConstants.layoutSize;

    return ColoredBox(
      color: const Color(FaradaysLawConstants.backgroundColorValue),
      // Force fill viewport so FittedBox scales 834×504 to cover available space
      // (otherwise FittedBox shrink-wraps to layout size → left cluster + empty blue).
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
            key: layoutKey,
            width: layout.width,
            height: layout.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: CoilsWiresPainter(
                      topCoilVisible: model.topCoilVisible,
                    ),
                  ),
                ),
                BulbWidget(bulb: model.bulb),
                CoilImageLayer(
                  kind: CoilKind.fourLoop,
                  front: false,
                  coilCenter: FaradaysLawConstants.bottomCoilPosition,
                ),
                CoilImageLayer(
                  kind: CoilKind.twoLoop,
                  front: false,
                  coilCenter: FaradaysLawConstants.topCoilPosition,
                  visible: model.topCoilVisible,
                ),
                VoltmeterWidget(
                  visible: model.voltmeterVisible,
                  needleAngle: model.voltmeter.clampedNeedleAngle,
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: FieldLinesPainter(
                        geometry: model.fieldLines.geometry,
                      ),
                    ),
                  ),
                ),
                _buildMagnetHitTarget(),
                CoilImageLayer(
                  kind: CoilKind.fourLoop,
                  front: true,
                  coilCenter: FaradaysLawConstants.bottomCoilPosition,
                ),
                CoilImageLayer(
                  kind: CoilKind.twoLoop,
                  front: true,
                  coilCenter: FaradaysLawConstants.topCoilPosition,
                  visible: model.topCoilVisible,
                ),
                FaradaysLawControlPanel(model: model),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const Size _hitPad = Size(180, 90);

  Widget _buildMagnetHitTarget() {
    final pos = model.magnet.position;
    return Positioned(
      left: pos.dx - _hitPad.width / 2,
      top: pos.dy - _hitPad.height / 2,
      width: _hitPad.width,
      height: _hitPad.height,
      child: GestureDetector(
        key: const Key('faradays_law_magnet_gesture'),
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => onDragStart(d.globalPosition),
        onPanUpdate: (d) => onDragUpdate(d.globalPosition),
        onPanEnd: (_) => onDragEnd(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (model.magnetArrowsVisible)
              CustomPaint(
                size: _hitPad,
                painter: MagnetArrowsPainter(
                  magnetSize: const Size(
                    FaradaysLawConstants.magnetWidth,
                    FaradaysLawConstants.magnetHeight,
                  ),
                ),
              ),
            SizedBox(
              key: const Key('faradays_law_magnet'),
              width: FaradaysLawConstants.magnetWidth + 8,
              height: FaradaysLawConstants.magnetHeight + 16,
              child: CustomPaint(
                painter: MagnetPainter(orientation: model.magnet.orientation),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

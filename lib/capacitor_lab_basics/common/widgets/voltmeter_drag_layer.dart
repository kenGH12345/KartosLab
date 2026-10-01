import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../clb_colors.dart';
import '../../clb_constants.dart';
import '../../clb_strings.dart';
import '../model/clb_model.dart';
import '../model/voltmeter.dart';
import '../render/circuit_render_data.dart';
import '../transform/yaw_pitch_mvt.dart';

/// Play-area voltmeter — `VoltmeterNode.js` + `Voltmeter.js`.
///
/// Interaction baseline (PhET `ToolboxPanel.js` / `VoltmeterBodyNode.js`):
/// - Toolbox drag-out: body center under pointer; probes keep absolute positions.
/// - Body drag moves **body only**; probes independent tip drag.
/// - Reading = tip hit → `computeValue`; `null` → "?".
/// - Return: `body.eroded(40) ∩ toolbox` → hide (no model reset).
class VoltmeterDragLayer extends StatelessWidget {
  const VoltmeterDragLayer({
    super.key,
    required this.model,
    required this.data,
    required this.toolboxBounds,
    this.toolboxBoundsOf,
    this.mvt,
  });

  final ClbModel model;
  final CircuitRenderData data;
  final Rect toolboxBounds;
  /// Live canvas-space toolbox rect (preferred on pan-end return).
  final Rect Function()? toolboxBoundsOf;
  final YawPitchMvt? mvt;

  static const double bodyW = 405 * ClbConstants.voltmeterBodyScale;
  static const double bodyH = 502 * ClbConstants.voltmeterBodyScale;
  static const double probeW = 62 * ClbConstants.voltmeterProbeScale;
  static const double probeH = 501 * ClbConstants.voltmeterProbeScale;

  @override
  Widget build(BuildContext context) {
    if (!model.voltmeterVisible) {
      return const SizedBox.shrink();
    }

    final transform = mvt ?? YawPitchMvt();
    final vm = model.voltmeter;
    final bodyTL = data.voltmeterBodyTopLeft;
    final posTip = data.positiveProbeTopCenter;
    final negTip = data.negativeProbeTopCenter;
    final yaw = data.probeRotationRad;

    final posConnBody = Offset(
      bodyTL.dx + (0.5 - 0.056) * bodyW,
      bodyTL.dy + 0.875 * bodyH,
    );
    final negConnBody = Offset(
      bodyTL.dx + (0.5 + 0.056) * bodyW,
      bodyTL.dy + 0.875 * bodyH,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Wires must not steal hits (full-canvas paint would block toolbox/reset).
        IgnorePointer(
          child: CustomPaint(
            size: const Size(
              ClbConstants.canvasWidth,
              ClbConstants.canvasHeight,
            ),
            painter: _ProbeWiresPainter(
              positiveBody: posConnBody,
              positiveProbe: _probeConnectionBottom(posTip, yaw),
              negativeBody: negConnBody,
              negativeProbe: _probeConnectionBottom(negTip, yaw),
            ),
          ),
        ),
        // Body — independent of probes
        Positioned(
          left: bodyTL.dx,
          top: bodyTL.dy,
          width: bodyW,
          height: bodyH,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) => vm.isDragged = true,
            onPanUpdate: (d) {
              final delta =
                  transform.viewToModelDeltaXY(d.delta.dx, d.delta.dy);
              vm.bodyX += delta.dx;
              vm.bodyY += delta.dy;
              // Reading does not depend on body; still refresh for UI.
              model.notifyViewChanged();
            },
            onPanEnd: (_) {
              vm.isDragged = false;
              maybeReturnVoltmeterToToolbox(
                model: model,
                mvt: transform,
                toolboxBounds: toolboxBoundsOf?.call() ?? toolboxBounds,
              );
              model.notifyViewChanged();
            },
            onPanCancel: () {
              vm.isDragged = false;
              maybeReturnVoltmeterToToolbox(
                model: model,
                mvt: transform,
                toolboxBounds: toolboxBoundsOf?.call() ?? toolboxBounds,
              );
              model.notifyViewChanged();
            },
            child: _VoltmeterBodyWidget(
              voltageText: vm.measuredVoltage == null
                  ? ClbStrings.voltsUnknown
                  : ClbStrings.voltsPattern(vm.measuredVoltage!),
            ),
          ),
        ),
        // Probes on top — free tip drag; reading updates every frame
        _probe(
          asset: ClbConstants.assetProbeRed,
          tip: posTip,
          yaw: yaw,
          onDelta: (dx, dy) {
            final delta = transform.viewToModelDeltaXY(dx, dy);
            vm.positiveProbeX += delta.dx;
            vm.positiveProbeY += delta.dy;
            model.notifyViewChanged(); // tip → hit → computeValue
          },
        ),
        _probe(
          asset: ClbConstants.assetProbeBlack,
          tip: negTip,
          yaw: yaw,
          onDelta: (dx, dy) {
            final delta = transform.viewToModelDeltaXY(dx, dy);
            vm.negativeProbeX += delta.dx;
            vm.negativeProbeY += delta.dy;
            model.notifyViewChanged();
          },
        ),
      ],
    );
  }

  static Offset _probeConnectionBottom(Offset tip, double yaw) {
    final local = Offset(0, probeH);
    final c = math.cos(yaw);
    final s = math.sin(yaw);
    return tip +
        Offset(local.dx * c - local.dy * s, local.dx * s + local.dy * c);
  }

  Widget _probe({
    required String asset,
    required Offset tip,
    required double yaw,
    required void Function(double dx, double dy) onDelta,
  }) {
    const pad = 20.0;
    return Positioned(
      left: tip.dx - probeW / 2 - pad,
      top: tip.dy - pad,
      width: probeW + pad * 2,
      height: probeH + pad * 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) => onDelta(d.delta.dx, d.delta.dy),
        child: Padding(
          padding: const EdgeInsets.all(pad),
          child: Transform.rotate(
            angle: yaw,
            alignment: Alignment.topCenter,
            child: Image.asset(
              asset,
              width: probeW,
              height: probeH,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}

/// `ToolboxPanel.js` return-to-dock — PhET `body.eroded(40) ∩ toolbox`.
///
/// Flutter adds a small toolbox inflate so finger release near the beige dock
/// still returns (Capacitance dock is smaller without the timer). Rim-only
/// misses still fail via eroded body. Does **not** reset probes (Reset All does).
bool maybeReturnVoltmeterToToolbox({
  required ClbModel model,
  required YawPitchMvt mvt,
  required Rect toolboxBounds,
}) {
  if (!model.voltmeterVisible) return false;
  final vm = model.voltmeter;
  final bodyTL = mvt.modelToViewXYZ(vm.bodyX, vm.bodyY, vm.bodyZ);
  final bodyBounds = Rect.fromLTWH(
    bodyTL.dx,
    bodyTL.dy,
    VoltmeterDragLayer.bodyW,
    VoltmeterDragLayer.bodyH,
  );
  // PhET ToolboxPanel.js:156 — body.eroded(40) ∩ toolbox.
  final eroded = bodyBounds.deflate(40);
  if (eroded.isEmpty) return false;
  // Touch halo: Capacitance toolbox is icon-only (~175×H); same rule on both tabs.
  final dock = toolboxBounds.inflate(36);
  if (!dock.overlaps(eroded)) return false;
  model.setVoltmeterVisible(false);
  vm.isDragged = false;
  return true;
}

/// PhET toolbox extract — `ToolboxPanel.js` forwarding listener.
///
/// - Places **body** at [bodyTopLeftView] (caller applies center-under-pointer).
/// - Does **not** move probes (absolute positions persist; defaults only after reset).
void placeVoltmeterFromToolbox({
  required Voltmeter voltmeter,
  required YawPitchMvt mvt,
  required Offset bodyTopLeftView,
}) {
  final bodyModel = mvt.viewToModelXY(bodyTopLeftView.dx, bodyTopLeftView.dy);
  voltmeter.bodyX = bodyModel.x;
  voltmeter.bodyY = bodyModel.y;
  voltmeter.bodyZ = 0;
  voltmeter.isDragged = true;
}

/// View top-left so body center sits under [pointerCanvas] —
/// `ToolboxPanel.js` `offsetPosition = (-width/2, -height/2)`.
Offset voltmeterBodyTopLeftCenteredOn(Offset pointerCanvas) => Offset(
      pointerCanvas.dx - VoltmeterDragLayer.bodyW / 2,
      pointerCanvas.dy - VoltmeterDragLayer.bodyH / 2,
    );

@Deprecated('Use placeVoltmeterFromToolbox')
void placeVoltmeterAssembly({
  required Voltmeter voltmeter,
  required YawPitchMvt mvt,
  required Offset bodyTopLeftView,
}) =>
    placeVoltmeterFromToolbox(
      voltmeter: voltmeter,
      mvt: mvt,
      bodyTopLeftView: bodyTopLeftView,
    );

class _VoltmeterBodyWidget extends StatelessWidget {
  const _VoltmeterBodyWidget({required this.voltageText});

  final String voltageText;

  @override
  Widget build(BuildContext context) {
    const w = VoltmeterDragLayer.bodyW;
    const h = VoltmeterDragLayer.bodyH;
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        children: [
          Image.asset(
            ClbConstants.assetVoltmeterBody,
            width: w,
            height: h,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
          ),
          Positioned(
            left: w * 0.25,
            top: h / 3 + 10,
            width: w * 0.5,
            child: Column(
              children: [
                const Text(
                  ClbStrings.voltage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: w * 0.5,
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    voltageText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProbeWiresPainter extends CustomPainter {
  _ProbeWiresPainter({
    required this.positiveBody,
    required this.positiveProbe,
    required this.negativeBody,
    required this.negativeProbe,
  });

  final Offset positiveBody;
  final Offset positiveProbe;
  final Offset negativeBody;
  final Offset negativeProbe;

  static const _bodyCtrl = Offset(0, 100);
  static const _probeCtrl = Offset(-80, 100);

  @override
  void paint(Canvas canvas, Size size) {
    void wire(Offset body, Offset probe, Color color) {
      final c1 = body + _bodyCtrl;
      final c2 = probe + _probeCtrl;
      final path = Path()
        ..moveTo(body.dx, body.dy)
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, probe.dx, probe.dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    wire(positiveBody, positiveProbe, ClbColors.redColorblind);
    wire(negativeBody, negativeProbe, Colors.black);
  }

  @override
  bool shouldRepaint(covariant _ProbeWiresPainter oldDelegate) =>
      oldDelegate.positiveBody != positiveBody ||
      oldDelegate.positiveProbe != positiveProbe ||
      oldDelegate.negativeBody != negativeBody ||
      oldDelegate.negativeProbe != negativeProbe;
}

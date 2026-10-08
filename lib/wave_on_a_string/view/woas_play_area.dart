import 'package:flutter/material.dart';

import '../../common/simulation_clock.dart';
import '../model/woas_end_type.dart';
import '../model/woas_mode.dart';
import '../model/woas_model.dart';
import 'controls/woas_bottom_control_panel.dart';
import 'controls/woas_radio_panel.dart';
import 'controls/woas_time_controls.dart';
import 'woas_end_node.dart';
import 'woas_layout.dart';
import 'woas_overlays.dart';
import 'woas_start_node.dart';
import 'woas_string_painter.dart';
import 'package:kratos/wave_on_a_string/woas_strings.dart';

/// PhET `WOASScreenView` — play area + control chrome (Phase 3).
///
/// Wave geometry comes only from [WoasModel], never View-side `sin()`.
class WoasPlayArea extends StatefulWidget {
  const WoasPlayArea({
    super.key,
    required this.model,
    this.autoStartClock = true,
  });

  final WoasModel model;

  /// Widget tests should set false — perpetual ticker hangs settle.
  final bool autoStartClock;

  @override
  State<WoasPlayArea> createState() => WoasPlayAreaState();
}

class WoasPlayAreaState extends State<WoasPlayArea>
    with TickerProviderStateMixin {
  late final SimulationClock clock;

  WoasModel get model => widget.model;

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

  void _onWrenchDrag(double modelY) {
    model.setManualDisplacement(modelY);
  }

  void _onStep() {
    model.manualStep();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(woasBackgroundArgb),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth.isFinite && constraints.maxWidth > 0
              ? constraints.maxWidth
              : woasLayoutWidth;
          final h = constraints.maxHeight.isFinite && constraints.maxHeight > 0
              ? constraints.maxHeight
              : woasLayoutHeight;
          return SizedBox(
            width: w,
            height: h,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: woasLayoutWidth,
                height: woasLayoutHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const WoasCenterLine(),
                    WoasEndNode(model: model),
                    if (model.referenceLineVisible)
                      Positioned(
                        left: 0,
                        top: model.referenceLineY - 10,
                        child: GestureDetector(
                          onVerticalDragUpdate: (d) {
                            model.setReferenceLineY(
                              (model.referenceLineY + d.delta.dy)
                                  .clamp(40.0, woasLayoutHeight - 80),
                            );
                          },
                          child: CustomPaint(
                            size: const Size(woasLayoutWidth - 28, 20),
                            painter: ReferenceLinePainter(),
                          ),
                        ),
                      ),
                    RepaintBoundary(
                      child: CustomPaint(
                        size: const Size(woasLayoutWidth, woasLayoutHeight),
                        painter: WoasStringPainter(
                          beadModelY: () => woasBeadDisplayYs(model),
                          repaintListenable: model,
                        ),
                      ),
                    ),
                    WoasStartNode(model: model, onWrenchDrag: _onWrenchDrag),
                    WoasWindowFront(model: model),
                    WoasRulersOverlay(model: model),
                    WoasStopwatchOverlay(model: model),

                    // ── Control Area (source AlignBox / ManualConstraint) ──
                    Positioned(
                      left: 10,
                      top: 10,
                      child: WoasRadioPanel<WoasMode>(
                        key: const Key('wave_mode_panel'),
                        semanticLabel: WoasStrings.waveMode,
                        values: const [
                          WoasMode.manual,
                          WoasMode.oscillate,
                          WoasMode.pulse,
                        ],
                        labels: const [WoasStrings.manual, WoasStrings.oscillate, WoasStrings.pulse],
                        keyIds: const ['Manual', 'Oscillate', 'Pulse'],
                        groupValue: model.waveMode,
                        onChanged: model.setWaveMode,
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: WoasRadioPanel<WoasEndType>(
                        key: const Key('end_type_panel'),
                        semanticLabel: WoasStrings.endType,
                        values: const [
                          WoasEndType.fixedEnd,
                          WoasEndType.looseEnd,
                          WoasEndType.noEnd,
                        ],
                        labels: const [
                          WoasStrings.fixedEnd,
                          WoasStrings.looseEnd,
                          WoasStrings.noEnd,
                        ],
                        keyIds: const ['Fixed End', 'Loose End', 'No End'],
                        groupValue: model.stringEndType,
                        onChanged: model.setStringEndType,
                      ),
                    ),
                    Positioned(
                      left: 0.23 * woasLayoutWidth - WoasRestartButton.buttonSize.width / 2,
                      top: woasLayoutHeight - 175 - WoasRestartButton.buttonSize.height / 2,
                      child: WoasRestartButton(onPressed: model.restart),
                    ),
                    Positioned(
                      left: woasLayoutWidth / 2 - 90,
                      top: woasLayoutHeight - 175 - 30,
                      child: WoasTimeControls(
                        model: model,
                        onStep: _onStep,
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: WoasResetAllControl(onPressed: model.resetAll),
                    ),
                    Positioned(
                      right: 60,
                      bottom: 10,
                      child: WoasBottomControlPanel(model: model),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Extracted for tests / overlay reuse.
class ReferenceLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(woasReferenceLineArgb)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width - 30) {
      canvas.drawLine(Offset(x, y), Offset(x + 10, y), paint);
      x += 16;
    }
    final handle = Paint()..color = const Color(0xFFD3B072);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 28, 0, 20, 20),
        const Radius.circular(2),
      ),
      handle,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

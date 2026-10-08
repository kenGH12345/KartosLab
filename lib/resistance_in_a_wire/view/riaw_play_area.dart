import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../common/widgets/kratos_reset_all_button.dart';
import '../model/resistance_in_a_wire_model.dart';
import '../resistance_in_a_wire_view_constants.dart';
import 'controls/control_panel.dart';
import 'formula_equation.dart';
import 'riaw_audio_hooks.dart';
import 'riaw_bindings.dart';
import 'static_arrow.dart';
import 'wire_node.dart';
import 'package:kratos/resistance_in_a_wire/riaw_strings.dart';

/// PhET `ResistanceInAWireScreenView` play area in **1024×618** coordinates.
class ResistanceInAWirePlayArea extends StatefulWidget {
  const ResistanceInAWirePlayArea({
    super.key,
    required this.model,
    this.dotRandom,
    this.audio,
    this.resistivityFocusNode,
    this.lengthFocusNode,
    this.areaFocusNode,
  });

  final ResistanceInAWireModel model;
  final math.Random? dotRandom;
  final ResistanceInAWireAudioHooks? audio;
  final FocusNode? resistivityFocusNode;
  final FocusNode? lengthFocusNode;
  final FocusNode? areaFocusNode;

  @override
  State<ResistanceInAWirePlayArea> createState() =>
      ResistanceInAWirePlayAreaState();
}

class ResistanceInAWirePlayAreaState extends State<ResistanceInAWirePlayArea> {
  late final ResistanceInAWireBindings _bindings;
  ResistanceInAWireAudioHooks? _ownedAudio;
  late final ResistanceInAWireAudioHooks _audio;

  double? _lastResistivity;
  double? _lastLength;
  double? _lastArea;

  final GlobalKey _panelKey =
      GlobalKey(debugLabel: 'riawControlPanel');

  Size _panelSize = Size(
    ResistanceInAWireViewConstants.controlPanelWidthEstimate,
    ResistanceInAWireViewConstants.controlPanelHeightEstimate,
  );

  ResistanceInAWireModel get model => widget.model;

  @override
  void initState() {
    super.initState();
    _bindings = ResistanceInAWireBindings(model);
    _bindings.addListener(_onChange);

    if (widget.audio != null) {
      _audio = widget.audio!;
    } else {
      _ownedAudio = ResistanceInAWireAudioHooks();
      _audio = _ownedAudio!;
    }

    _lastResistivity = model.resistivity;
    _lastLength = model.length;
    _lastArea = model.area;
  }

  void _onChange() {
    final fromKeyboard = _audio.consumeExpectKeyboard();
    if (_lastResistivity != null && model.resistivity != _lastResistivity) {
      _audio.onResistivityChanged(
        model.resistivity,
        model.resistance,
        fromKeyboard: fromKeyboard,
      );
    }
    if (_lastLength != null && model.length != _lastLength) {
      _audio.onLengthChanged(
        model.length,
        model.resistance,
        fromKeyboard: fromKeyboard,
      );
    }
    if (_lastArea != null && model.area != _lastArea) {
      _audio.onAreaChanged(
        model.area,
        model.resistance,
        fromKeyboard: fromKeyboard,
      );
    }
    _lastResistivity = model.resistivity;
    _lastLength = model.length;
    _lastArea = model.area;

    if (mounted) setState(() {});
  }

  void markKeyboardInteraction() {
    _audio.expectKeyboard = true;
  }

  void _reset() {
    model.reset();
    _audio.onReset();
  }

  void _measurePanel() {
    final box = _panelKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final s = box.size;
      if ((s.width - _panelSize.width).abs() > 0.5 ||
          (s.height - _panelSize.height).abs() > 0.5) {
        _panelSize = s;
        if (mounted) setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _bindings.removeListener(_onChange);
    _bindings.dispose();
    _ownedAudio?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => _measurePanel());

    const layout = ResistanceInAWireViewConstants.layoutSize;
    final rightInset = ResistanceInAWireViewConstants.controlPanelRightMargin;

    // Source: controlPanel.right = resetAll.right; formula.centerX = panel.left/2
    final panelLeft =
        ResistanceInAWireViewConstants.controlPanelRight - _panelSize.width;
    final formulaCenterX = panelLeft / 2;
    final formulaSize = ResistanceInAWireViewConstants.formulaPaintSize;
    final formulaLeft = formulaCenterX - formulaSize.width / 2;
    final formulaTop =
        ResistanceInAWireViewConstants.formulaCenterY - formulaSize.height / 2;

    final wireCenterY = ResistanceInAWireViewConstants.formulaCenterY +
        ResistanceInAWireViewConstants.wireCenterYOffset;
    // WireNode box is sized to max wire; center on formulaCenterX / wireCenterY.
    final wireBoxW = ResistanceInAWireViewConstants.wireViewWidthMax +
        ResistanceInAWireViewConstants.wireViewHeightMax *
            ResistanceInAWireViewConstants.perspectiveFactor *
            2 +
        16;
    final wireBoxH =
        ResistanceInAWireViewConstants.wireViewHeightMax + 16;
    final wireLeft = formulaCenterX - wireBoxW / 2;
    final wireTop = wireCenterY - wireBoxH / 2;

    final arrowW = ResistanceInAWireViewConstants.tailLength +
        ResistanceInAWireViewConstants.headHeight;
    final arrowH = ResistanceInAWireViewConstants.headWidth + 4;
    final arrowLeft = formulaCenterX - arrowW / 2;
    final arrowTop = ResistanceInAWireViewConstants.arrowY - arrowH / 2;

    return ColoredBox(
      color: ResistanceInAWireViewConstants.background,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
            width: layout.width,
            height: layout.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: formulaLeft,
                  top: formulaTop,
                  child: FormulaEquation(model: model),
                ),
                Positioned(
                  left: wireLeft,
                  top: wireTop,
                  child: WireNode(
                    model: model,
                    dotRandom: widget.dotRandom,
                  ),
                ),
                Positioned(
                  left: arrowLeft,
                  top: arrowTop,
                  child: const StaticArrow(),
                ),
                Positioned(
                  right: rightInset,
                  bottom: ResistanceInAWireViewConstants.resetBottomMargin,
                  child: Semantics(
                    button: true,
                    label: RiawStrings.resetAll,
                    child: KratosResetAllButton(
                      key: const Key('riaw_reset_all'),
                      radius: ResistanceInAWireViewConstants.resetRadius,
                      onPressed: _reset,
                    ),
                  ),
                ),
                // Control panel last (source z-order: always on top).
                Positioned(
                  right: rightInset,
                  top: ResistanceInAWireViewConstants.controlPanelTop,
                  child: KeyedSubtree(
                    key: _panelKey,
                    child: ResistanceInAWireControlPanel(
                      model: model,
                      resistivityFocusNode: widget.resistivityFocusNode,
                      lengthFocusNode: widget.lengthFocusNode,
                      areaFocusNode: widget.areaFocusNode,
                      onKeyboardInteraction: markKeyboardInteraction,
                    ),
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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../common/widgets/kratos_reset_all_button.dart';
import '../model/ohms_law_model.dart';
import '../ohms_law_view_constants.dart';
import 'controls/control_panel.dart';
import 'controls/units_radio.dart';
import 'formula_equation.dart';
import 'ohms_law_audio_hooks.dart';
import 'ohms_law_bindings.dart';
import 'wire_box.dart';
import 'package:kratos/ohms_law/ohms_law_strings.dart';

/// PhET `OhmsLawScreenView` play area in **1024×618** source coordinates
/// (`ScreenView.DEFAULT_LAYOUT_BOUNDS`; ohms-law does not override).
class OhmsLawPlayArea extends StatefulWidget {
  const OhmsLawPlayArea({
    super.key,
    required this.model,
    this.dotRandom,
    this.audio,
    this.voltageFocusNode,
    this.resistanceFocusNode,
    this.unitsFocusNode,
  });

  final OhmsLawModel model;
  final math.Random? dotRandom;

  /// Optional audio event hooks (source DiscreteSound / CurrentSound).
  final OhmsLawAudioHooks? audio;

  final FocusNode? voltageFocusNode;
  final FocusNode? resistanceFocusNode;
  final FocusNode? unitsFocusNode;

  @override
  State<OhmsLawPlayArea> createState() => OhmsLawPlayAreaState();
}

class OhmsLawPlayAreaState extends State<OhmsLawPlayArea> {
  late final OhmsLawBindings _bindings;
  OhmsLawAudioHooks? _ownedAudio;
  late final OhmsLawAudioHooks _audio;

  double? _lastVoltage;
  double? _lastResistance;
  double? _lastCurrent;

  final GlobalKey _panelKey = GlobalKey(debugLabel: 'ohmsLawControlPanel');
  final GlobalKey _unitsKey = GlobalKey(debugLabel: 'ohmsLawUnits');

  /// Measured control-panel size in layout coords (after first frame).
  Size _panelSize = Size(
    OhmsLawViewConstants.controlPanelWidthEstimate,
    OhmsLawViewConstants.controlPanelHeightEstimate,
  );

  Size _unitsSize = const Size(200, 110);

  OhmsLawModel get model => widget.model;

  @override
  void initState() {
    super.initState();
    _bindings = OhmsLawBindings(model);
    _bindings.addListener(_onChange);

    if (widget.audio != null) {
      _audio = widget.audio!;
    } else {
      _ownedAudio = OhmsLawAudioHooks();
      _audio = _ownedAudio!;
    }

    _lastVoltage = model.voltage;
    _lastResistance = model.resistance;
    _lastCurrent = model.current;
  }

  void _onChange() {
    if (_lastVoltage != null && model.voltage != _lastVoltage) {
      _audio.onVoltageChanged();
    }
    if (_lastResistance != null && model.resistance != _lastResistance) {
      _audio.onResistanceChanged();
    }
    if (_lastCurrent != null && model.current != _lastCurrent) {
      _audio.onCurrentChanged();
    }
    _lastVoltage = model.voltage;
    _lastResistance = model.resistance;
    _lastCurrent = model.current;

    if (mounted) setState(() {});
  }

  void _reset() {
    model.reset();
    _audio.onReset();
  }

  void _measureChrome() {
    final panelBox =
        _panelKey.currentContext?.findRenderObject() as RenderBox?;
    final unitsBox =
        _unitsKey.currentContext?.findRenderObject() as RenderBox?;
    var changed = false;
    if (panelBox != null && panelBox.hasSize) {
      final s = panelBox.size;
      if ((s.width - _panelSize.width).abs() > 0.5 ||
          (s.height - _panelSize.height).abs() > 0.5) {
        _panelSize = s;
        changed = true;
      }
    }
    if (unitsBox != null && unitsBox.hasSize) {
      final s = unitsBox.size;
      if ((s.width - _unitsSize.width).abs() > 0.5 ||
          (s.height - _unitsSize.height).abs() > 0.5) {
        _unitsSize = s;
        changed = true;
      }
    }
    if (changed && mounted) setState(() {});
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
    SchedulerBinding.instance.addPostFrameCallback((_) => _measureChrome());

    const layout = OhmsLawViewConstants.layoutSize;
    // FormulaNode is hardwired around equals at local X=300; place at x=0
    // (source does not set formulaNode.left — only centerY).
    const formulaLeft = 0.0;
    const formulaWidth = 640.0;
    final formulaCenterX = formulaLeft + formulaWidth / 2;
    final formulaTop = OhmsLawViewConstants.formulaCenterY - 110.0;

    final wirePad = OhmsLawViewConstants.arrowOffset + 50;
    final wireBoxW = OhmsLawViewConstants.wireWidth + wirePad * 2;
    final wireBoxH = OhmsLawViewConstants.wireHeight + wirePad * 2;
    final wireBoxLeft = formulaCenterX - wireBoxW / 2;
    final wireBoxTop = OhmsLawViewConstants.wireBoxBottom - wireBoxH;
    final wireBoxCenterY = wireBoxTop + wireBoxH / 2;

    final rightInset = OhmsLawViewConstants.layoutWidth -
        OhmsLawViewConstants.controlPanelRight;

    // Source: controlPanel.right = width - 50; units.left = controlPanel.left
    final panelLeft =
        OhmsLawViewConstants.controlPanelRight - _panelSize.width;
    final panelBottom =
        OhmsLawViewConstants.controlPanelTop + _panelSize.height;

    // Source: units.centerY = wireBox.centerY + 4
    // On 1024×618 this lands naturally below ControlPanel; keep a soft floor.
    var unitsTop = wireBoxCenterY + 4 - _unitsSize.height / 2;
    const gap = 8.0;
    if (unitsTop < panelBottom + gap) {
      unitsTop = panelBottom + gap;
    }
    // Keep Units above Reset band.
    final maxUnitsTop =
        OhmsLawViewConstants.layoutHeight - 20 - 56 - _unitsSize.height - 4;
    if (unitsTop > maxUnitsTop) {
      unitsTop = maxUnitsTop;
    }

    return ColoredBox(
      color: OhmsLawViewConstants.background,
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
                  left: wireBoxLeft,
                  top: wireBoxTop,
                  child: WireBox(
                    model: model,
                    dotRandom: widget.dotRandom,
                  ),
                ),
                Positioned(
                  right: rightInset,
                  top: OhmsLawViewConstants.controlPanelTop,
                  child: KeyedSubtree(
                    key: _panelKey,
                    child: OhmsLawControlPanel(
                      model: model,
                      voltageFocusNode: widget.voltageFocusNode,
                      resistanceFocusNode: widget.resistanceFocusNode,
                    ),
                  ),
                ),
                Positioned(
                  left: panelLeft,
                  top: unitsTop,
                  child: KeyedSubtree(
                    key: _unitsKey,
                    child: UnitsRadioGroup(
                      model: model,
                      focusNode: widget.unitsFocusNode,
                    ),
                  ),
                ),
                Positioned(
                  right: rightInset,
                  bottom: 20,
                  child: Semantics(
                    button: true,
                    label: OhmsLawStrings.resetAll,
                    child: KratosResetAllButton(
                      key: const Key('ohms_law_reset_all'),
                      radius: OhmsLawViewConstants.resetRadius,
                      onPressed: _reset,
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

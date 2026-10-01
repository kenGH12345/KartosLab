import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/widgets/nine_grid_layout.dart';
import '../interaction/va_graph_interactor.dart';
import '../interaction/va_return_animation.dart';
import '../model/enums.dart';
import '../model/equations_vector.dart';
import '../model/screen_models.dart';
import '../model/vector.dart';
import '../painters/va_arrow_geometry.dart';
import '../painters/va_scene_painter.dart';
import '../render/va_render_builder.dart';
import '../render/va_render_data.dart';
import '../va_assets.dart';
import '../vector_addition_colors.dart';
import '../vector_addition_constants.dart';
import '../vector_addition_strings.dart';
import 'va_control_icons.dart';
import 'va_number_picker.dart';
import 'va_page_shell.dart';

/// Static + interactive screen body: Model → RenderData → Painter + chrome.
class VaScreenBody extends StatefulWidget {
  const VaScreenBody({
    super.key,
    required this.model,
    this.embedded = false,
  });

  final VaScreenModel model;
  final bool embedded;

  @override
  State<VaScreenBody> createState() => VaScreenBodyState();
}

class VaScreenBodyState extends State<VaScreenBody>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  static const _builder = VaRenderBuilder();
  late final VaGraphInteractor _interactor;
  Ticker? _returnTicker;
  VaReturnAnimation? _returnAnim;
  Duration _lastTick = Duration.zero;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _interactor = VaGraphInteractor(widget.model);
  }

  @override
  void dispose() {
    _returnTicker?.dispose();
    super.dispose();
  }

  VaRenderData get renderData => _builder.build(widget.model);

  void refresh() {
    _interactor.invalidateTransform();
    if (mounted) setState(() {});
  }

  Offset? _toolboxIconCenterView(VaVector v, VaRenderData data) {
    final toolbox = data.anchors.toolboxRect;
    if (toolbox == Rect.zero) return null;
    final sets = widget.model.scene.vectorSets;
    if (sets.length == 1) {
      final set = sets.first;
      final i = set.allVectors.indexWhere((x) => identical(x, v));
      if (i < 0) return null;
      final n = set.allVectors.length;
      final slotW = toolbox.width / n;
      return Offset(
        toolbox.left + slotW * (i + 0.5),
        toolbox.top + toolbox.height / 2,
      );
    }
    final setIndex = sets.indexWhere((s) => s.allVectors.contains(v));
    if (setIndex < 0) return null;
    final n = sets.length;
    final slotW = toolbox.width / n;
    return Offset(
      toolbox.left + slotW * (setIndex + 0.5),
      toolbox.top + toolbox.height / 2,
    );
  }

  void _startReturnAnimation(VaVector v) {
    final data = renderData;
    final centerView = _toolboxIconCenterView(v, data);
    if (centerView == null) {
      _interactor.completeReturnToToolbox(v);
      refresh();
      return;
    }
    final iconCenter = _interactor.transform.viewToModel(centerView);
    _returnTicker?.dispose();
    _lastTick = Duration.zero;
    _returnAnim = VaReturnAnimation(
      vector: v,
      iconCenterModel: iconCenter,
      finalXy: v.initialXyComponents,
    );
    _returnTicker = createTicker((elapsed) {
      final anim = _returnAnim;
      if (anim == null) return;
      final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
      _lastTick = elapsed;
      if (anim.tick(dt)) {
        _returnTicker?.stop();
        _returnTicker?.dispose();
        _returnTicker = null;
        _returnAnim = null;
        _interactor.completeReturnToToolbox(v);
      }
      refresh();
    })
      ..start();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final data = renderData;
    final body = Material(
      color: VectorAdditionColors.screenBackground,
      child: NineGridLayout(
        backgroundColor: VectorAdditionColors.screenBackground,
        center: VaPageShell(
          child: Stack(
            children: [
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (e) {
                  if (_returnAnim != null) return;
                  _interactor.onPointerDown(e.localPosition);
                  refresh();
                },
                onPointerMove: (e) {
                  _interactor.onPointerMove(e.localPosition);
                  refresh();
                },
                onPointerUp: (e) {
                  final toAnimate = _interactor.onPointerUp(e.localPosition);
                  if (toAnimate != null) {
                    _startReturnAnimation(toAnimate);
                  } else {
                    refresh();
                  }
                },
                child: CustomPaint(
                  size: data.layoutSize,
                  painter: VaScenePainter(data: data),
                ),
              ),
              _VectorValuesPanel(
                data: data,
                model: widget.model,
                onChanged: refresh,
              ),
              _ControlPanel(
                data: data,
                model: widget.model,
                onChanged: refresh,
              ),
              if (data.showToolbox)
                _Toolbox(
                  data: data,
                  onSlotTap: (i) {
                    if (_interactor.activateFromToolbox(i)) refresh();
                  },
                ),
              if (data.showEraser)
                Positioned(
                  left: data.anchors.eraserRect.left,
                  top: data.anchors.eraserRect.top,
                  child: _EraserButton(
                    enabled: widget.model.scene.vectorSets
                        .any((s) => s.numberOnGraph > 0),
                    onPressed: () {
                      widget.model.erase();
                      refresh();
                    },
                  ),
                ),
              Positioned(
                left: data.anchors.sceneRadioRect.left,
                top: data.anchors.sceneRadioRect.top,
                child: _SceneRadio(
                  model: widget.model,
                  onChanged: refresh,
                ),
              ),
              Positioned(
                left: data.anchors.resetRect.left,
                top: data.anchors.resetRect.top,
                child: VaResetAllButton(
                  size: data.anchors.resetRect.width,
                  onPressed: () {
                    widget.model.reset();
                    refresh();
                  },
                ),
              ),
              if (data.anchors.equationBarRect != Rect.zero)
                _EquationBar(
                  model: widget.model as EquationsModel,
                  rect: data.anchors.equationBarRect,
                  onChanged: refresh,
                ),
              if (data.anchors.baseVectorsRect != Rect.zero)
                _BaseVectorsPanel(
                  model: widget.model as EquationsModel,
                  rect: data.anchors.baseVectorsRect,
                  onChanged: refresh,
                ),
            ],
          ),
        ),
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text(VectorAdditionStrings.title)),
      body: body,
    );
  }
}

class _VectorValuesPanel extends StatelessWidget {
  const _VectorValuesPanel({
    required this.data,
    required this.model,
    required this.onChanged,
  });
  final VaRenderData data;
  final VaScreenModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final r = data.anchors.vectorValuesRect;
    final expanded = data.vectorValuesExpanded;
    final v = data.selectedValues;
    final dp = VectorAdditionConstants.vectorValueDecimalPlaces;

    // FixedSizeAccordionBox: showTitleWhenExpanded=false → content OR title.
    late final Widget body;
    if (!expanded) {
      body = const Text(
        VectorAdditionStrings.vectorValues,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      );
    } else if (v == null) {
      body = const Text(
        VectorAdditionStrings.noVectorSelected,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    } else {
      final ang = v.angleDegrees;
      final angStr = ang == null ? '—' : ang.toStringAsFixed(dp);
      body = Text(
        '|${v.symbol}|=${v.magnitude.toStringAsFixed(dp)}   '
        'θ=$angStr°   '
        '${v.symbol}ₓ=${v.xComponent.toStringAsFixed(dp)}   '
        '${v.symbol}ᵧ=${v.yComponent.toStringAsFixed(dp)}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return Positioned(
      left: r.left,
      top: r.top,
      width: r.width,
      height: r.height,
      child: Material(
        elevation: 1.5,
        color: VectorAdditionColors.panelFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(color: VectorAdditionColors.panelStroke),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          child: Row(
            children: [
              VaAccordionButton(
                expanded: expanded,
                onPressed: () {
                  model.view.vectorValuesExpanded =
                      !model.view.vectorValuesExpanded;
                  onChanged();
                },
              ),
              const SizedBox(width: 12),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.data,
    required this.model,
    required this.onChanged,
  });

  final VaRenderData data;
  final VaScreenModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final r = data.anchors.controlPanelRect;
    final c = data.controlPanel;
    final isEq = model is EquationsModel;
    return Positioned(
      left: r.left,
      top: r.top,
      width: r.width,
      child: Material(
        color: VectorAdditionColors.panelFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(color: VectorAdditionColors.panelStroke),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // PhET EquationsGraphControlPanel order: resultant → values →
              // angles → grid → separator → Components.
              if (c.showSum)
                _check(
                  isEq
                      ? model.scene.vectorSets.first.resultantSymbol
                      : VectorAdditionStrings.sum,
                  isEq
                      ? model.view.equationsResultantVisible
                      : model.view.sumVisible,
                  (v) {
                    if (isEq) {
                      model.view.equationsResultantVisible = v;
                    } else {
                      model.view.sumVisible = v;
                    }
                    onChanged();
                  },
                ),
              _check(
                VectorAdditionStrings.values,
                model.view.valuesVisible,
                (v) {
                  model.view.valuesVisible = v;
                  onChanged();
                },
              ),
              if (c.showAngles) ...[
                _check(
                  VectorAdditionStrings.angles,
                  model.view.anglesVisible,
                  (v) {
                    model.view.anglesVisible = v;
                    onChanged();
                  },
                ),
                if (model.view.anglesVisible)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Row(
                      children: [
                        _miniRadio(
                          '±180°',
                          model.view.angleConvention == AngleConvention.signed,
                          () {
                            model.view.angleConvention = AngleConvention.signed;
                            onChanged();
                          },
                        ),
                        const SizedBox(width: 4),
                        _miniRadio(
                          '0–360°',
                          model.view.angleConvention ==
                              AngleConvention.unsigned,
                          () {
                            model.view.angleConvention =
                                AngleConvention.unsigned;
                            onChanged();
                          },
                        ),
                      ],
                    ),
                  ),
              ],
              _check(
                VectorAdditionStrings.grid,
                model.view.gridVisible,
                (v) {
                  model.view.gridVisible = v;
                  onChanged();
                },
              ),
              if (c.showComponents) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    height: 1,
                    color: VectorAdditionColors.panelStroke,
                  ),
                ),
                const Text(
                  VectorAdditionStrings.components,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _ComponentsGrid(
                  selected: model.componentStyle.style,
                  onSelected: (s) {
                    model.componentStyle.style = s;
                    onChanged();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniRadio(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: VectorAdditionColors.radioBase,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? VectorAdditionColors.radioSelectedStroke
                : VectorAdditionColors.radioDeselectedStroke,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: (v) => onChanged(v ?? false),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentsGrid extends StatelessWidget {
  const _ComponentsGrid({
    required this.selected,
    required this.onSelected,
  });

  final ComponentVectorStyle selected;
  final ValueChanged<ComponentVectorStyle> onSelected;

  static const _order = [
    ComponentVectorStyle.invisible,
    ComponentVectorStyle.triangle,
    ComponentVectorStyle.parallelogram,
    ComponentVectorStyle.projection,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 134,
      child: Wrap(
        spacing: 4,
        runSpacing: 8,
        children: [
          for (final s in _order)
            _ComponentRadioButton(
              style: s,
              selected: selected == s,
              onTap: () => onSelected(s),
            ),
        ],
      ),
    );
  }
}

class _ComponentRadioButton extends StatelessWidget {
  const _ComponentRadioButton({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final ComponentVectorStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: selected ? 1 : 0.35,
        child: Container(
          width: 62,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: VectorAdditionColors.radioBase,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? VectorAdditionColors.radioSelectedStroke
                  : VectorAdditionColors.radioDeselectedStroke,
              width: selected ? 2 : 1,
            ),
          ),
          child: VaComponentStyleIcon(style: style),
        ),
      ),
    );
  }
}

class _Toolbox extends StatelessWidget {
  const _Toolbox({required this.data, required this.onSlotTap});
  final VaRenderData data;
  final ValueChanged<int> onSlotTap;

  @override
  Widget build(BuildContext context) {
    final r = data.anchors.toolboxRect;
    return Positioned(
      left: r.left,
      top: r.top,
      width: r.width,
      height: r.height,
      child: Material(
        color: VectorAdditionColors.panelFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(color: VectorAdditionColors.panelStroke),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              for (var i = 0; i < data.toolboxSlots.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: data.toolboxSlots[i].available
                        ? () => onSlotTap(i)
                        : null,
                    child: Opacity(
                      opacity: data.toolboxSlots[i].available ? 1 : 0.35,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(36, 28),
                            painter: _MiniArrowPainter(
                              color: data.toolboxSlots[i].color,
                              tip: Offset(
                                8 +
                                    data.toolboxSlots[i].iconTipDelta.dx
                                        .clamp(-20, 20),
                                14 +
                                    data.toolboxSlots[i].iconTipDelta.dy
                                        .clamp(-12, 12),
                              ),
                            ),
                          ),
                          Text(data.toolboxSlots[i].symbol,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: data.toolboxSlots[i].color,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniArrowPainter extends CustomPainter {
  _MiniArrowPainter({required this.color, required this.tip});
  final Color color;
  final Offset tip;
  final _geo = const VaArrowGeometry(
    headWidth: 8,
    headHeight: 10,
    tailWidth: 2.5,
  );

  @override
  void paint(Canvas canvas, Size size) {
    _geo.paint(canvas, tail: const Offset(4, 14), tip: tip, color: color);
  }

  @override
  bool shouldRepaint(covariant _MiniArrowPainter oldDelegate) => true;
}

class _EraserButton extends StatelessWidget {
  const _EraserButton({required this.enabled, required this.onPressed});
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // PhET: RectangularPushButton + Image(eraser_svg) scaled to iconWidth 20.
    return Material(
      color: VectorAdditionColors.eraserYellow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: enabled ? onPressed : null,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Opacity(
              opacity: enabled ? 1 : 0.38,
              child: SvgPicture.asset(
                VaAssets.eraserSvg,
                width: VaAssets.eraserIconWidth,
                height: VaAssets.eraserIconWidth *
                    (55.96 / 69.44), // original SVG aspect
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SceneRadio extends StatelessWidget {
  const _SceneRadio({required this.model, required this.onChanged});
  final VaScreenModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (model.scenes.length < 2) {
      return Text(model.scene.name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < model.scenes.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _SceneModeButton(
              selected: model.sceneIndex == i,
              onTap: () {
                model.selectScene(i);
                onChanged();
              },
              child: model.scenes[i].coordinateSnapMode ==
                      CoordinateSnapMode.cartesian
                  ? VaCartesianSceneIcon(
                      color: model.scenes[i].vectorSets.first.palette.vectorFill,
                    )
                  : VaPolarSceneIcon(
                      color: model.scenes[i].vectorSets.first.palette.vectorFill,
                    ),
            ),
          ),
      ],
    );
  }
}

class _SceneModeButton extends StatelessWidget {
  const _SceneModeButton({
    required this.selected,
    required this.onTap,
    required this.child,
  });
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: selected ? 1 : 0.35,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: VectorAdditionColors.radioBase,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? VectorAdditionColors.radioSelectedStroke
                  : VectorAdditionColors.radioDeselectedStroke,
              width: selected ? 2 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _EquationBar extends StatelessWidget {
  const _EquationBar({
    required this.model,
    required this.rect,
    required this.onChanged,
  });
  final EquationsModel model;
  final Rect rect;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final set = model.scene.vectorSets.first;
    final vectors = [
      for (final v in set.allVectors)
        if (v is EquationsVector) v,
    ];
    final color = set.palette.vectorFill;
    final expanded = model.view.equationExpanded;

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      child: Material(
        elevation: 1.5,
        color: VectorAdditionColors.panelFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(color: VectorAdditionColors.panelStroke),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          child: Row(
            children: [
              VaAccordionButton(
                expanded: expanded,
                onPressed: () {
                  model.view.equationExpanded = !model.view.equationExpanded;
                  onChanged();
                },
              ),
              const SizedBox(width: 10),
              if (!expanded)
                const Expanded(
                  child: Text(
                    'Equation',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                )
              else ...[
                // Equation type radios — horizontal, no wrap.
                for (final t in EquationType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _EquationTypeButton(
                      selected: model.equationType == t,
                      label: t == EquationType.addition
                          ? '${_sym(vectors, 0)}+${_sym(vectors, 1)}=${set.resultantSymbol}'
                          : t == EquationType.subtraction
                              ? '${_sym(vectors, 0)}−${_sym(vectors, 1)}=${set.resultantSymbol}'
                              : '${_sym(vectors, 0)}+${_sym(vectors, 1)}+${set.resultantSymbol}=0',
                      onTap: () {
                        model.setEquationType(t);
                        onChanged();
                      },
                    ),
                  ),
                const SizedBox(width: 18),
                // Interactive coefficient equation — single row, no wrap.
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < vectors.length; i++) ...[
                          if (i > 0)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                model.equationType == EquationType.subtraction
                                    ? '−'
                                    : '+',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          VaNumberPicker(
                            value: vectors[i].coefficient,
                            min: VectorAdditionConstants.coefficientMin,
                            max: VectorAdditionConstants.coefficientMax,
                            color: color,
                            onChanged: (c) {
                              vectors[i].setCoefficient(c);
                              model.notifyEquationVectorsChanged();
                              onChanged();
                            },
                          ),
                          const SizedBox(width: 3),
                          Text(
                            vectors[i].symbol,
                            style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                        if (model.equationType == EquationType.negation) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text('+', style: TextStyle(fontSize: 20)),
                          ),
                          Text(
                            set.resultantSymbol,
                            style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: set.palette.sumFill,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('=', style: TextStyle(fontSize: 20)),
                          ),
                          const Text('0', style: TextStyle(fontSize: 20)),
                        ] else ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('=', style: TextStyle(fontSize: 20)),
                          ),
                          Text(
                            set.resultantSymbol,
                            style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: set.palette.sumFill,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _sym(List<EquationsVector> vs, int i) =>
      i < vs.length ? vs[i].symbol : '?';
}

class _EquationTypeButton extends StatelessWidget {
  const _EquationTypeButton({
    required this.selected,
    required this.label,
    required this.onTap,
  });
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: selected ? 1 : 0.35,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: VectorAdditionColors.radioBase,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? VectorAdditionColors.radioSelectedStroke
                  : VectorAdditionColors.radioDeselectedStroke,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _BaseVectorsPanel extends StatelessWidget {
  const _BaseVectorsPanel({
    required this.model,
    required this.rect,
    required this.onChanged,
  });
  final EquationsModel model;
  final Rect rect;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final set = model.scene.vectorSets.first;
    final vectors = [
      for (final v in set.allVectors)
        if (v is EquationsVector) v,
    ];
    final color = set.palette.vectorFill;
    final polar = model.scene.coordinateSnapMode == CoordinateSnapMode.polar;
    final expanded = model.view.baseVectorsExpanded;

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      child: Material(
        elevation: 1.5,
        color: VectorAdditionColors.panelFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(color: VectorAdditionColors.panelStroke),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  VaAccordionButton(
                    expanded: expanded,
                    onPressed: () {
                      model.view.baseVectorsExpanded =
                          !model.view.baseVectorsExpanded;
                      onChanged();
                    },
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      VectorAdditionStrings.baseVectors,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 8),
                for (final v in vectors)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: polar
                        ? _polarPickers(v, color)
                        : _cartesianPickers(v, color),
                  ),
                Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: model.view.baseVectorsVisible,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        onChanged: (v) {
                          model.view.baseVectorsVisible = v ?? false;
                          onChanged();
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    // PhET BaseVectorsCheckbox: VectorAdditionIconFactory.createVectorIcon
                    VaVectorCheckboxIcon(color: color),
                    const SizedBox(width: 6),
                    Text(
                      VectorAdditionStrings.baseVectors,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartesianPickers(EquationsVector v, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('${v.symbol}ₓ=',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: color,
                )),
            VaNumberPicker(
              value: v.baseX,
              min: VectorAdditionConstants.xyComponentMin,
              max: VectorAdditionConstants.xyComponentMax,
              color: Colors.black,
              onChanged: (x) {
                v.setBaseX(x);
                model.notifyEquationVectorsChanged();
                onChanged();
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('${v.symbol}ᵧ=',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: color,
                )),
            VaNumberPicker(
              value: v.baseY,
              min: VectorAdditionConstants.xyComponentMin,
              max: VectorAdditionConstants.xyComponentMax,
              color: Colors.black,
              onChanged: (y) {
                v.setBaseY(y);
                model.notifyEquationVectorsChanged();
                onChanged();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _polarPickers(EquationsVector v, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('|${v.symbol}|=',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: color,
                )),
            VaNumberPicker(
              value: v.baseMagnitude,
              min: VectorAdditionConstants.magnitudeMin,
              max: VectorAdditionConstants.magnitudeMax,
              color: Colors.black,
              onChanged: (m) {
                v.setBaseMagnitude(m);
                model.notifyEquationVectorsChanged();
                onChanged();
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('θ${v.symbol}=',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: color,
                )),
            if (model.view.angleConvention == AngleConvention.signed)
              VaNumberPicker(
                value: v.baseAngleDegrees,
                min: VectorAdditionConstants.signedAngleMin,
                max: VectorAdditionConstants.signedAngleMax,
                color: Colors.black,
                width: 52,
                step: 5,
                onChanged: (a) {
                  v.setBaseAngleDegrees(a);
                  model.notifyEquationVectorsChanged();
                  onChanged();
                },
              )
            else
              VaNumberPicker(
                value: v.baseAngleDegreesUnsigned,
                min: VectorAdditionConstants.unsignedAngleMin,
                max: VectorAdditionConstants.unsignedAngleMax,
                color: Colors.black,
                width: 52,
                step: 5,
                onChanged: (a) {
                  v.setBaseAngleDegreesUnsigned(a);
                  model.notifyEquationVectorsChanged();
                  onChanged();
                },
              ),
            const Text('°', style: TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }
}

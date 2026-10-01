import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../constants/hookes_law_constants.dart';
import '../../model/systems_model.dart';
import '../hookes_law_stage.dart';
import '../intro/intro_play_painter.dart';
import '../parametric_spring_geometry.dart';
import 'systems_system_view.dart';
import 'systems_view_properties.dart';
import 'systems_visibility_panel.dart';

/// Hooke's Law Systems screen. `js/systems/view/SystemsScreenView.ts`.
///
/// Series and parallel both stay alive. Leaving this widget does not reset
/// either model. This screen does not host Energy or Home.
class SystemsScreen extends StatefulWidget {
  const SystemsScreen({super.key, required this.model, this.viewProperties});

  final SystemsModel model;
  final SystemsViewProperties? viewProperties;

  @override
  State<SystemsScreen> createState() => _SystemsScreenState();
}

class _SystemsScreenState extends State<SystemsScreen> {
  late final SystemsViewProperties _view;
  late final bool _ownsView;
  int _epoch = 0;
  int _generation = 0;
  late SystemsKind _shown;

  @override
  void initState() {
    super.initState();
    _ownsView = widget.viewProperties == null;
    _view = widget.viewProperties ?? SystemsViewProperties();
    _generation = _view.generation;
    _shown = _view.systemType;
    _view.addListener(_onView);
  }

  @override
  void dispose() {
    _view.removeListener(_onView);
    if (_ownsView) {
      _view.dispose();
    }
    super.dispose();
  }

  void _onView() {
    if (_view.generation != _generation) {
      _generation = _view.generation;
      _epoch++;
    }
    if (_view.systemType != _shown) {
      _shown = _view.systemType;
      _epoch++;
    }
    setState(() {});
  }

  void _reset() {
    widget.model.reset();
    _view.reset();
  }

  @override
  Widget build(BuildContext context) {
    final parallel = _view.systemType == SystemsKind.parallel;
    return HookesLawStage(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            left: HookesLawConstants.systemsSystemLeft,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Offstage(
                offstage: !parallel,
                child: ParallelSystemView(
                  system: widget.model.parallelSystem,
                  properties: _view,
                  epoch: _epoch,
                ),
              ),
            ),
          ),
          Positioned.fill(
            left: HookesLawConstants.systemsSystemLeft,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Offstage(
                offstage: parallel,
                child: SeriesSystemView(
                  system: widget.model.seriesSystem,
                  properties: _view,
                  epoch: _epoch,
                ),
              ),
            ),
          ),
          Positioned(
            top: HookesLawConstants.introControlsTopMargin,
            right: HookesLawConstants.introControlsRightMargin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SystemsVisibilityPanel(properties: _view),
                const SizedBox(height: HookesLawConstants.introControlsSpacing),
                _SystemTypeControl(properties: _view),
              ],
            ),
          ),
          Positioned(
            right: HookesLawConstants.introResetMargin,
            bottom: HookesLawConstants.introResetMargin,
            child: KratosResetAllButton(
              key: const Key('systems-reset'),
              radius: HookesLawConstants.resetAllButtonRadius,
              onPressed: _reset,
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemTypeControl extends StatelessWidget {
  const _SystemTypeControl({required this.properties});

  final SystemsViewProperties properties;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TypeButton(
          key: const Key('systems-radio-parallel'),
          selected: properties.systemType == SystemsKind.parallel,
          onTap: () => properties.systemType = SystemsKind.parallel,
          child: const _MiniSystemIcon(series: false),
        ),
        const SizedBox(width: 10),
        _TypeButton(
          key: const Key('systems-radio-series'),
          selected: properties.systemType == SystemsKind.series,
          onTap: () => properties.systemType = SystemsKind.series,
          child: const _MiniSystemIcon(series: true),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFE6E6E6), Color(0xFFC4C4C4)],
            stops: [0, 0.55, 1],
          ),
          border: Border.all(
            color: selected ? const Color(0xFF000000) : IntroColors.panelStroke,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: child,
        ),
      ),
    );
  }
}

class _MiniSystemIcon extends StatelessWidget {
  const _MiniSystemIcon({required this.series});

  final bool series;

  @override
  Widget build(BuildContext context) {
    final geometry = sceneSelectionSpringGeometry();
    final spring = sceneSelectionSpringSize(geometry);
    final height = series ? spring.height * 1.2 : spring.height * 2 + 5;
    final width = series ? spring.width * 2 + 2 : spring.width + 2;
    return CustomPaint(
      size: Size(width, height),
      painter: _SystemIconPainter(series: series, geometry: geometry, spring: spring),
    );
  }
}

class _SystemIconPainter extends CustomPainter {
  const _SystemIconPainter({
    required this.series,
    required this.geometry,
    required this.spring,
  });

  final bool series;
  final ParametricSpringGeometry geometry;
  final Size spring;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      const Offset(1, 0),
      Offset(1, size.height),
      Paint()
        ..color = const Color(0xFF000000)
        ..strokeWidth = 2,
    );
    if (series) {
      _spring(canvas, 2, size.height / 2);
      _spring(canvas, 2 + spring.width, size.height / 2);
    } else {
      _spring(canvas, 2, spring.height / 2);
      _spring(canvas, 2, spring.height + 5 + spring.height / 2);
    }
  }

  void _spring(Canvas canvas, double x, double centerY) {
    canvas.save();
    canvas.translate(x, centerY);
    canvas.scale(sceneSelectionSpringScale);
    paintSceneSelectionSpring(canvas, geometry);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SystemIconPainter oldDelegate) => oldDelegate.series != series;
}

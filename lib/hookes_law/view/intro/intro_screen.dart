import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../constants/hookes_law_constants.dart';
import '../../model/intro_model.dart';
import '../hookes_law_stage.dart';
import '../parametric_spring_geometry.dart';
import 'intro_play_painter.dart';
import 'intro_system_view.dart';
import 'intro_view_properties.dart';
import 'intro_visibility_panel.dart';

/// Hooke's Law Intro screen. `js/intro/view/IntroScreenView.ts`.
///
/// Two independent single-spring systems. The second is hidden until the
/// 1 → 2 transition fades it in. This screen does not host Systems, Energy,
/// or Home.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.model, this.viewProperties});

  final IntroModel model;
  final IntroViewProperties? viewProperties;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

enum _Phase { idle, move, fade }

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late final IntroViewProperties _view;
  late final bool _ownsView;
  late final Ticker _ticker;

  int _epoch = 0;
  int _generation = 0;
  int _animTarget = 1;
  _Phase _phase = _Phase.idle;
  Duration _lastTick = Duration.zero;
  double _elapsed = 0;
  double _moveFrom = 0;
  double _moveTo = 0;
  double _fadeFrom = 1;
  double _fadeTo = 0;

  double _system1CenterY = HookesLawConstants.layoutBoundsHeight / 2;
  double _system2Opacity = 1;
  bool _system2Visible = false;

  static double get _centerOne => HookesLawConstants.layoutBoundsHeight / 2;

  static double get _centerTwo => 0.25 * HookesLawConstants.layoutBoundsHeight;

  static double get _centerSystem2 => 0.75 * HookesLawConstants.layoutBoundsHeight;

  static double get _halfSystem => HookesLawConstants.introSystemHeight / 2;

  @override
  void initState() {
    super.initState();
    _ownsView = widget.viewProperties == null;
    _view = widget.viewProperties ?? IntroViewProperties();
    _generation = _view.generation;
    _view.addListener(_onView);
    _ticker = createTicker(_onTick);
    if (_view.numberOfSystems == 1) {
      _system1CenterY = _centerOne;
      _system2Visible = false;
      _system2Opacity = 1;
    } else {
      _system1CenterY = _centerTwo;
      _system2Visible = true;
      _system2Opacity = 1;
    }
    _begin(_view.numberOfSystems);
  }

  @override
  void dispose() {
    _ticker.dispose();
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
    if (_view.numberOfSystems != _animTarget) {
      _epoch++;
      _begin(_view.numberOfSystems);
    }
    setState(() {});
  }

  /// `IntroAnimator`: 1→2 moves system 1, then fades system 2 in.
  /// 2→1 fades system 2 out, hides it, then moves system 1. Linear, 0.5 s each.
  void _begin(int target) {
    _animTarget = target;
    _elapsed = 0;
    _moveFrom = _system1CenterY;
    _moveTo = target == 1 ? _centerOne : _centerTwo;
    _fadeFrom = _system2Opacity;
    _fadeTo = target == 1 ? 0 : 1;
    _phase = target == 1 ? _Phase.fade : _Phase.move;
    _lastTick = Duration.zero;
    _ticker.stop();
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt < 0) {
      return;
    }
    _elapsed += dt;
    final t = (_elapsed / HookesLawConstants.introAnimationSeconds).clamp(0.0, 1.0);
    if (_phase == _Phase.move) {
      _system1CenterY = _moveFrom + (_moveTo - _moveFrom) * t;
      if (t >= 1) {
        _system1CenterY = _moveTo;
        if (_animTarget == 2) {
          _system2Visible = true;
          _phase = _Phase.fade;
          _elapsed = 0;
        } else {
          _phase = _Phase.idle;
          _ticker.stop();
        }
      }
    } else if (_phase == _Phase.fade) {
      _system2Opacity = _fadeFrom + (_fadeTo - _fadeFrom) * t;
      if (t >= 1) {
        _system2Opacity = _fadeTo;
        if (_animTarget == 1) {
          _system2Visible = false;
          _phase = _Phase.move;
          _elapsed = 0;
          _moveFrom = _system1CenterY;
          _moveTo = _centerOne;
        } else {
          _phase = _Phase.idle;
          _ticker.stop();
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _reset() {
    widget.model.reset();
    _view.reset();
  }

  @override
  Widget build(BuildContext context) {
    return HookesLawStage(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            key: const Key('intro-system-1'),
            left: HookesLawConstants.introSystemLeft,
            top: _system1CenterY - _halfSystem,
            child: IntroSystemView(
              system: widget.model.system1,
              systemNumber: 1,
              properties: _view,
              epoch: _epoch,
            ),
          ),
          Positioned(
            key: const Key('intro-system-2'),
            left: HookesLawConstants.introSystemLeft,
            top: _centerSystem2 - _halfSystem,
            child: Offstage(
              offstage: !_system2Visible,
              child: Opacity(
                key: const Key('intro-system-2-fade'),
                opacity: _system2Opacity.clamp(0, 1),
                child: IntroSystemView(
                  system: widget.model.system2,
                  systemNumber: 2,
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
                IntroVisibilityPanel(properties: _view),
                const SizedBox(height: HookesLawConstants.introControlsSpacing),
                _SystemCountControl(properties: _view),
              ],
            ),
          ),
          Positioned(
            right: HookesLawConstants.introResetMargin,
            bottom: HookesLawConstants.introResetMargin,
            child: KratosResetAllButton(
              key: const Key('intro-reset'),
              radius: HookesLawConstants.resetAllButtonRadius,
              onPressed: _reset,
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemCountControl extends StatelessWidget {
  const _SystemCountControl({required this.properties});

  final IntroViewProperties properties;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SystemButton(
          key: const Key('intro-radio-1'),
          selected: properties.numberOfSystems == 1,
          springs: 1,
          onTap: () => properties.numberOfSystems = 1,
        ),
        const SizedBox(width: 10),
        _SystemButton(
          key: const Key('intro-radio-2'),
          selected: properties.numberOfSystems == 2,
          springs: 2,
          onTap: () => properties.numberOfSystems = 2,
        ),
      ],
    );
  }
}

class _SystemButton extends StatelessWidget {
  const _SystemButton({
    super.key,
    required this.selected,
    required this.springs,
    required this.onTap,
  });

  final bool selected;
  final int springs;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: springs == 1
              ? const _SpringIcon()
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SpringIcon(),
                    SizedBox(height: 5),
                    _SpringIcon(),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SpringIcon extends StatelessWidget {
  const _SpringIcon();

  @override
  Widget build(BuildContext context) {
    final geometry = sceneSelectionSpringGeometry();
    return CustomPaint(
      size: sceneSelectionSpringSize(geometry),
      painter: _IconSpringPainter(geometry),
    );
  }
}

class _IconSpringPainter extends CustomPainter {
  const _IconSpringPainter(this.geometry);

  final ParametricSpringGeometry geometry;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, size.height / 2);
    canvas.scale(sceneSelectionSpringScale);
    paintSceneSelectionSpring(canvas, geometry);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IconSpringPainter oldDelegate) => false;
}

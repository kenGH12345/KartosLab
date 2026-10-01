import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../audio/base_audio.dart';
import '../model/balloons_static_electricity_constants.dart';
import '../model/balloons_static_electricity_model.dart';
import '../model/base_vec2.dart';
import 'balloon_node.dart';
import 'base_view_layout.dart';
import 'control_panel.dart';
import 'sweater_node.dart';
import 'tether_node.dart';
import 'wall_node.dart';

/// Design-coordinate play area (768×504) — PhET `BASEView`.
class BalloonsStaticElectricityPlayArea extends StatefulWidget {
  const BalloonsStaticElectricityPlayArea({
    super.key,
    required this.model,
    this.autoStartClock = true,
    this.enableAudio = true,
  });

  final BalloonsStaticElectricityModel model;
  final bool autoStartClock;
  final bool enableAudio;

  @override
  State<BalloonsStaticElectricityPlayArea> createState() =>
      BalloonsStaticElectricityPlayAreaState();
}

class BalloonsStaticElectricityPlayAreaState
    extends State<BalloonsStaticElectricityPlayArea>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration? _lastElapsed;
  BaseAudio? _audio;

  /// Z-order: true → yellow in front (default).
  bool _yellowInFront = true;

  BalloonsStaticElectricityModel get model => widget.model;

  bool get tickerActive => _ticker.isActive;

  /// Exposed for lifecycle / audio tests.
  BaseAudio? get audio => _audio;

  /// Shared tether anchor — PhET `BASEView` tetherAnchorPoint.
  late final BaseVec2 tetherAnchor = BaseVec2(
    BaseConstants.yellowInitialPosition.x + 30,
    BaseViewLayout.layoutHeight,
  );

  @override
  void initState() {
    super.initState();
    model.addListener(_onModel);
    _audio = BaseAudio(model, enabled: widget.enableAudio);
    _ticker = createTicker(_onTick);
    if (widget.autoStartClock) {
      _ticker.start();
    }
  }

  void _onModel() {
    if (mounted) setState(() {});
  }

  void _onTick(Duration elapsed) {
    final last = _lastElapsed ?? elapsed;
    _lastElapsed = elapsed;
    var dt = (elapsed - last).inMicroseconds / 1e6;
    // Large gaps (pause/resume, focus) → nominal 60fps; matches Model clamp path.
    if (dt <= 0 || dt > 0.1) dt = 1 / 60;
    model.step(dt);
  }

  /// Lifecycle: pause simulation clock (does not dispose audio).
  void pauseClock() {
    if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  /// Lifecycle: resume simulation clock.
  void resumeClock() {
    if (!_ticker.isActive) {
      _lastElapsed = null;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    final audio = _audio;
    _audio = null;
    audio?.dispose();
    model.removeListener(_onModel);
    super.dispose();
  }

  void _bringYellowFront() => setState(() => _yellowInFront = true);
  void _bringGreenFront() => setState(() => _yellowInFront = false);

  void setDefaultBalloonZOrder() => setState(() => _yellowInFront = true);

  void _onResetBalloons() {
    setDefaultBalloonZOrder();
    _audio?.onReset();
  }

  void _onResetAll() {
    setDefaultBalloonZOrder();
    _audio?.onReset();
  }

  @override
  Widget build(BuildContext context) {
    final yellowLayer = <Widget>[
      TetherNode(
        balloon: model.yellowBalloon,
        anchor: tetherAnchor,
        visible: model.yellowBalloon.isVisible,
      ),
      BalloonNode(
        model: model,
        balloon: model.yellowBalloon,
        assetPath: BaseAssets.yellowBalloon,
        semanticLabel: 'Yellow Balloon',
        onBroughtToFront: _bringYellowFront,
      ),
    ];
    final greenLayer = <Widget>[
      TetherNode(
        balloon: model.greenBalloon,
        anchor: tetherAnchor,
        visible: model.greenBalloon.isVisible,
      ),
      BalloonNode(
        model: model,
        balloon: model.greenBalloon,
        assetPath: BaseAssets.greenBalloon,
        semanticLabel: 'Green Balloon',
        onBroughtToFront: _bringGreenFront,
      ),
    ];

    return ColoredBox(
      color: BaseViewLayout.backgroundColor,
      child: SizedBox(
        width: BaseViewLayout.layoutWidth,
        height: BaseViewLayout.layoutHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned(
              left: -1000,
              top: 0,
              width: 1000,
              height: BaseViewLayout.layoutHeight,
              child: ColoredBox(color: Colors.black),
            ),
            SweaterNode(model: model),
            WallNode(model: model),
            if (_yellowInFront) ...greenLayer else ...yellowLayer,
            if (_yellowInFront) ...yellowLayer else ...greenLayer,
            ...BaseControlPanel(
              model: model,
              onResetAll: _onResetAll,
              onResetBalloons: _onResetBalloons,
            ).buildStackChildren(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/netforce_model.dart';
import '../widgets/speedometer.dart';
import '../../common/controls/arrow_painter.dart';
import '../config/forces_scenario.dart';
import '../../common/simulation_clock.dart';
import '../../common/widgets/time_control_bar.dart';
import '../../common/controls/game_timer.dart';
import '../../common/widgets/game_over_dialog.dart';
import '../../common/widgets/game_scoreboard.dart';
import '../../common/widgets/property_control_panel.dart';

class NetForceScreen extends StatefulWidget {
  const NetForceScreen({super.key, this.scenario});
  final ForcesScenario? scenario;

  @override State<NetForceScreen> createState() => _NetForceScreenState();
}

class _NetForceScreenState extends State<NetForceScreen> with TickerProviderStateMixin {
  late final NetforceModel _model;
  late final SimulationClock _clock;
  bool _showValues = true, _showSum = true, _showSpeed = true;
  final GameTimer _gameTimer = GameTimer();
  bool _gameOverShown = false;

  // 拖拽悬停状态
  bool? _hoverSide;
  int? _hoverKnotIdx;

  @override void initState() {
    super.initState();
    _model = widget.scenario != null
        ? NetforceModel.fromScenario(widget.scenario!)
        : NetforceModel();
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) { if (_model.isRunning) { _model.tick(dt); setState(() {}); } };
    _clock.onStarted = () { setState(_model.go); _gameTimer.start(); _gameOverShown = false; };
    _clock.onPaused = () { setState(_model.pause); _gameTimer.stop(); };
    _clock.onReset = () { setState(_model.reset); _gameTimer.reset(); _gameOverShown = false; };
    _clock.play();
  }
  @override void dispose() { _clock.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    if (_model.isGameOver && !_gameOverShown) {
      _gameOverShown = true;
      _gameTimer.stop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => GameOverDialog(
              score: (_model.leftForce + _model.rightForce).toInt(),
              stars: _model.winner != null ? 3 : 1,
              elapsedMs: _gameTimer.elapsedMs,
              title: '${_model.winner == 'right' ? '红队' : '蓝队'} 获胜! 🎉',
              onReplay: () {
                Navigator.of(context).pop();
                setState(_model.reset);
                _gameTimer.start();
                _gameOverShown = false;
              },
            ),
          );
        }
      });
    }
    return Material(
      type: MaterialType.transparency,
      child: Column(children: [
      Expanded(flex: 2, child: _buildForceDisplay()),
      PropertyControlPanel(
        padding: const EdgeInsets.all(12),
        spacing: 6,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _checkChip('合力', _showSum, (v) => setState(() => _showSum = v)),
            _checkChip('值', _showValues, (v) => setState(() => _showValues = v)),
            _checkChip('速度', _showSpeed, (v) => setState(() => _showSpeed = v)),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TimeControlBar(clock: _clock),
            const SizedBox(width: 12),
            _btn('Return', const Color(0xFF3B82F6), () => setState(_model.returnCart)),
          ]),
          GameScoreboard(
            level: 1, maxLevel: 1,
            score: (_model.leftForce + _model.rightForce).toInt(),
            elapsedMs: _gameTimer.elapsedMs,
            title: '总力',
          ),
        ],
      ),
      if (_showSpeed) SizedBox(height: 80, child: Speedometer(speed: _model.cartVelocity.abs() * 10)),
      Container(height: 80, color: const Color(0xFFF1F5F9), child: Row(children: [
        Expanded(child: _pullerTray(false)),
        Container(width: 2, color: const Color(0xFFCBD5E1)),
        Expanded(child: _pullerTray(true)),
      ])),
    ]),
    );

  }

  Widget _buildForceDisplay() => LayoutBuilder(builder: (ctx, c) {
    final w = c.maxWidth, h = c.maxHeight;
    final cx = w / 2, cy = h * 0.3;
    final cartX = cx + _model.cartPosition * 0.2;
    return Stack(children: [
      // 地面
      Positioned(left: 0, right: 0, bottom: 40, child: Container(height: 4, color: const Color(0xFFCBD5E1))),
      // 小车
      Positioned(left: cartX - 40, top: cy + 40, child: _cartWidget()),
      // 左力箭头
      if (_showSum && _model.leftPullers.isNotEmpty)
        Positioned(left: cartX - 160, top: cy + 20,
          child: SizedBox(width: 120, height: 30,
            child: CustomPaint(painter: ForceArrowPainter(magnitude: _model.leftForce, direction: false, color: const Color(0xFF3B82F6),
                label: _showValues ? _model.leftForce.toStringAsFixed(0) : null, maxForce: 350)))),
      // 右力箭头
      if (_showSum && _model.rightPullers.isNotEmpty)
        Positioned(left: cartX + 30, top: cy + 20,
          child: SizedBox(width: 120, height: 30,
            child: CustomPaint(painter: ForceArrowPainter(magnitude: _model.rightForce, direction: true, color: const Color(0xFFEF4444),
                label: _showValues ? _model.rightForce.toStringAsFixed(0) : null, maxForce: 350)))),
      // 合力箭头
      if (_showSum && _model.netForce.abs() > 1)
        Positioned(left: cartX - 60, top: cy - 30,
          child: SizedBox(width: 120, height: 30,
            child: CustomPaint(painter: ForceArrowPainter(magnitude: _model.netForce.abs(), direction: _model.netForce > 0, color: const Color(0xFF7C3AED),
                label: _showValues ? 'Σ${_model.netForce.toStringAsFixed(0)}' : null, maxForce: 350)))),
      // 左右绳结（每个绳子结点包裹 DragTarget）
      ...List.generate(4, (i) => _knotDragTarget(cartX - 30 - (i + 1) * 25.0, cy + 80 + i * 30.0, false, i)),
      ...List.generate(4, (i) => _knotDragTarget(cartX + 40 + i * 25.0, cy + 80 + i * 30.0, true, i)),
      // 已放置的拉绳者
      for (final p in _model.pullers.where((p) => p.knotIndex != null))
        Positioned(left: cartX + (p.side ? 55 : -85) + p.knotIndex! * 25.0, top: cy + 80 + p.knotIndex! * 30.0,
            child: _pullerChip(p)),
    ]);
  });

  Widget _knotDragTarget(double left, double top, bool side, int idx) {
    final isHovered = _hoverSide == side && _hoverKnotIdx == idx;
    final hasPuller = _model.pullers.any((p) => p.side == side && p.knotIndex == idx);
    return Positioned(left: left - 10, top: top - 10,
      child: DragTarget<Puller>(
        onWillAcceptWithDetails: (d) {
          if (!hasPuller) { setState(() { _hoverSide = side; _hoverKnotIdx = idx; }); }
          return !hasPuller;
        },
        onAcceptWithDetails: (d) {
          setState(() {
            d.data.knotIndex = idx;
            d.data.side = side;
            _hoverSide = null;
            _hoverKnotIdx = null;
          });
        },
        onLeave: (_) { if (_hoverSide == side && _hoverKnotIdx == idx) setState(() { _hoverSide = null; _hoverKnotIdx = null; }); },
        builder: (ctx, candidates, rejected) => Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasPuller ? const Color(0xFF22C55E).withAlpha(100)
                : isHovered ? const Color(0xFF3B82F6).withAlpha(80) : Colors.transparent,
            border: isHovered ? Border.all(color: const Color(0xFF3B82F6), width: 2) : null,
          ),
          child: Center(child: Icon(Icons.circle, size: 12,
              color: hasPuller ? const Color(0xFF22C55E) : const Color(0xFF94A3B8))),
        ),
      ));
  }

  Widget _cartWidget() => Container(width: 80, height: 30,
      decoration: BoxDecoration(color: const Color(0xFFD97706), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(2, (_) =>
          Container(width: 16, height: 16, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E293B))),),));

  Widget _pullerTray(bool side) => Wrap(children: _model.pullers.where((p) => p.side == side && p.knotIndex == null).map((p) =>
      Draggable<Puller>(data: p, feedback: Material(child: _pullerChip(p)), childWhenDragging: Opacity(opacity: 0.3, child: _pullerChip(p)),
          child: _pullerChip(p))).toList());

  Widget _pullerChip(Puller p) => Container(margin: const EdgeInsets.all(2), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: p.color.withAlpha(40), borderRadius: BorderRadius.circular(12), border: Border.all(color: p.color)),
      child: Text('${p.force.toInt()} N', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: p.color)));

  Widget _checkChip(String label, bool v, ValueChanged<bool> cb) => FilterChip(
      label: Text(label), selected: v, onSelected: cb,
      selectedColor: const Color(0xFF1177AA).withAlpha(30));

  Widget _btn(String label, Color c, VoidCallback on) => ElevatedButton(
      onPressed: on, style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white),
      child: Text(label));
}

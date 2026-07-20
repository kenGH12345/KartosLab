import 'package:flutter/material.dart';

import '../models/netforce_model.dart';
import '../widgets/speedometer.dart';
import '../widgets/force_arrow_painter.dart';

class NetForceScreen extends StatefulWidget {
  const NetForceScreen({super.key});
  @override State<NetForceScreen> createState() => _NetForceScreenState();
}

class _NetForceScreenState extends State<NetForceScreen> with TickerProviderStateMixin {
  final _model = NetforceModel();
  late final AnimationController _ticker;
  bool _showValues = true, _showSum = true, _showSpeed = true;

  // 拖拽悬停状态
  bool? _hoverSide;
  int? _hoverKnotIdx;

  @override void initState() { super.initState(); _ticker = AnimationController(vsync: this)..addListener(_tick); _startTicker(); }
  @override void dispose() { _ticker.dispose(); super.dispose(); }

  void _startTicker() { _ticker.repeat(period: const Duration(milliseconds: 16)); }

  void _tick() {
    if (_model.isRunning) { _model.tick(0.016); setState(() {}); }
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('合力'), backgroundColor: const Color(0xFFFEF3C7)),
    body: Column(children: [
      Expanded(flex: 2, child: _buildForceDisplay()),
      Container(padding: const EdgeInsets.all(12), color: const Color(0xFFF8FAFC),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _checkChip('合力', _showSum, (v) => setState(() => _showSum = v)),
            _checkChip('值', _showValues, (v) => setState(() => _showValues = v)),
            _checkChip('速度', _showSpeed, (v) => setState(() => _showSpeed = v)),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _btn(_model.isRunning ? '暂停' : 'Go!', _model.isRunning ? const Color(0xFFF59E0B) : const Color(0xFF22C55E),
                () => setState(() => _model.isRunning ? _model.pause() : _model.go())),
            const SizedBox(width: 12),
            _btn('Return', const Color(0xFF3B82F6), () => setState(_model.returnCart)),
            const SizedBox(width: 12),
            _btn('重置', const Color(0xFF6B7280), () => setState(_model.reset)),
          ]),
          if (_model.isGameOver)
            Padding(padding: const EdgeInsets.only(top: 8), child: Text('${_model.winner == 'right' ? '红队' : '蓝队'} 获胜! 🎉',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)))),
        ])),
      if (_showSpeed) SizedBox(height: 80, child: Speedometer(speed: _model.cartVelocity.abs() * 10)),
      Container(height: 80, color: const Color(0xFFF1F5F9), child: Row(children: [
        Expanded(child: _pullerTray(false)),
        Container(width: 2, color: const Color(0xFFCBD5E1)),
        Expanded(child: _pullerTray(true)),
      ])),
    ]),
  );

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

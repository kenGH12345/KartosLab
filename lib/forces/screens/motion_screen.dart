import 'package:flutter/material.dart';

import '../models/motion_model.dart';
import '../models/forces_item.dart';
import '../widgets/force_arrow_painter.dart';
import '../widgets/speedometer.dart';
import '../widgets/applied_force_slider.dart';
import '../widgets/accelerometer.dart';

/// Motion屏幕（无摩擦滑板模式）
class MotionScreen extends StatefulWidget {
  const MotionScreen({super.key, required this.mode, this.scenarioId});
  final MotionScreenMode mode; // motion / friction / acceleration
  final String? scenarioId;

  @override State<MotionScreen> createState() => _MotionScreenState();
}

enum MotionScreenMode { motion, friction, acceleration }

class _MotionScreenState extends State<MotionScreen> with TickerProviderStateMixin {
  late final MotionModel _model;
  late final AnimationController _ticker;
  bool _showForces = true, _showSum = true, _showValues = true, _showMasses = true, _showSpeed = true;
  double _friction = 0;

  @override void initState() {
    super.initState();
    _model = MotionModel(friction: widget.mode == MotionScreenMode.motion ? 0 : 0.25,
      showAccelerometer: widget.mode == MotionScreenMode.acceleration);
    _ticker = AnimationController(vsync: this)..addListener(_loop);
    _ticker.repeat(period: const Duration(milliseconds: 16));
  }

  @override void dispose() { _model.reset(); _ticker.dispose(); super.dispose(); }

  void _loop() { _model.tick(0.016); setState(() {}); }

  void _addItem(ForceItem item) { if (_model.canAdd) setState(() => _model.addItem(item)); }

  String get _title => switch (widget.mode) { MotionScreenMode.motion => '运动', MotionScreenMode.friction => '摩擦', MotionScreenMode.acceleration => '加速度' };

  Color get _accent => switch (widget.mode) { MotionScreenMode.motion => const Color(0xFF22C55E), MotionScreenMode.friction => const Color(0xFFF59E0B), MotionScreenMode.acceleration => const Color(0xFF7C3AED) };

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${_title} (${widget.mode.name})'), backgroundColor: _accent.withAlpha(20)),
    body: Column(children: [
      // 画布
      Expanded(flex: 3, child: _buildCanvas()),
      // 控制面板
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), color: const Color(0xFFF8FAFC),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _chip('力', _showForces, (v) => setState(() => _showForces = v)),
            if (widget.mode != MotionScreenMode.motion) _chip('合力', _showSum, (v) => setState(() => _showSum = v)),
            _chip('值', _showValues, (v) => setState(() => _showValues = v)),
            _chip('质量', _showMasses, (v) => setState(() => _showMasses = v)),
            _chip('速度', _showSpeed, (v) => setState(() => _showSpeed = v)),
          ]),
          const SizedBox(height: 6),
          AppliedForceSlider(value: _model.sim.appliedForce, onChanged: (v) => setState(() => _model.setAppliedForce(v))),
          if (widget.mode != MotionScreenMode.motion) ...[
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('摩擦: ', style: TextStyle(fontSize: 12)),
              SizedBox(width: 150, child: Slider(value: _friction, min: 0, max: 0.5, divisions: 10,
                  label: _friction.toStringAsFixed(2),
                  onChanged: (v) => setState(() { _friction = v; _model.setFriction(v); }))),
            ]),
          ],
        ])),
      // 底栏
      SizedBox(height: 60, child: _buildItemTrays()),
    ]),
  );

  Widget _buildCanvas() => LayoutBuilder(builder: (ctx, c) {
    final w = c.maxWidth, h = c.maxHeight;
    final itemX = w / 2 + _model.sim.position * 2; // 2 px/m 缩放
    final cy = h * 0.4;
    return Stack(children: [
      // 地面
      Positioned(left: 0, right: 0, bottom: h * 0.15, child: Container(height: 4, color: const Color(0xFFCBD5E1))),
      // 物品堆叠
      Positioned(left: itemX - 25, top: cy, child: _stackVisual()),
      // 速度表
      if (_showSpeed) Positioned(left: w / 2 - 60, bottom: 0, child: Speedometer(speed: _model.sim.speed)),
      // 力箭头
      if (_showForces)
        Positioned(left: itemX - 130, top: cy - 40,
          child: SizedBox(width: 120, height: 20,
            child: CustomPaint(painter: ForceArrowPainter(magnitude: _model.sim.appliedForce.abs(), direction: _model.sim.appliedForce > 0,
                color: const Color(0xFFDC2626), label: _showValues ? _model.sim.appliedForce.toStringAsFixed(1) : null)))),
      // 摩擦力箭头
      if (_showSum && _model.sim.frictionCoeff > 0 && _model.sim.frictionForce.abs() > 1)
        Positioned(left: itemX - 130, top: cy - 20,
          child: SizedBox(width: 120, height: 20,
            child: CustomPaint(painter: ForceArrowPainter(magnitude: _model.sim.frictionForce.abs(), direction: _model.sim.frictionForce > 0,
                color: const Color(0xFFF59E0B), label: _showValues ? _model.sim.frictionForce.toStringAsFixed(1) : null)))),
      // 合力箭头
      if (_showSum && widget.mode != MotionScreenMode.motion)
        Positioned(left: itemX - 130, top: cy - 2,
          child: SizedBox(width: 120, height: 20,
            child: CustomPaint(painter: ForceArrowPainter(magnitude: _model.sim.netForce.abs(), direction: _model.sim.netForce > 0,
                color: const Color(0xFF7C3AED), label: _showValues ? 'Σ${_model.sim.netForce.toStringAsFixed(1)}' : null)))),
      // 加速度计
      if (widget.mode == MotionScreenMode.acceleration)
        Positioned(left: w / 2 + 70, top: 5,
          child: Accelerometer(acceleration: _model.sim.acceleration)),
      // 质量标签
      if (_showMasses) Positioned(left: itemX - 20, top: cy + 70,
          child: Text('${_model.totalMass.toStringAsFixed(0)} kg', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
    ]);
  });

  Widget _stackVisual() => Column(mainAxisSize: MainAxisSize.min, children:
      _model.stack.map((i) => Container(width: 50, height: 20, margin: const EdgeInsets.only(bottom: 1),
          decoration: BoxDecoration(color: i.color.withAlpha(180), borderRadius: BorderRadius.circular(4), border: Border.all(color: i.color)),
          child: Center(child: Text(i.name[0], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: i.color))))).toList()
    ..insert(0, Container(width: 60, height: 6, decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(3)))));

  Widget _buildItemTrays() => Row(children: [
    Expanded(child: _itemTray(ItemSide.left)),
    Container(width: 2, color: const Color(0xFFCBD5E1)),
    Expanded(child: _itemTray(ItemSide.right)),
  ]);

  Widget _itemTray(ItemSide side) {
    final items = kForceItems.where((i) {
      if (widget.mode == MotionScreenMode.acceleration && i.id == 'bucket') return true;
      if (widget.mode != MotionScreenMode.acceleration && i.id == 'bucket') return false;
      return i.side == side;
    }).toList();
    return ListView(scrollDirection: Axis.horizontal, children: items.map((i) =>
      InkWell(onTap: () => _addItem(i),
        child: Container(width: 52, margin: const EdgeInsets.all(2), decoration: BoxDecoration(color: i.color.withAlpha(30), borderRadius: BorderRadius.circular(8)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(i.icon, size: 18, color: i.color),
            Text(i.name, style: TextStyle(fontSize: 8, color: i.color)),
            if (i.massKnown) Text('${i.mass.toInt()}kg', style: const TextStyle(fontSize: 8, color: Color(0xFF64748B))),
          ])),
      )).toList(),
    );
  }

  Widget _chip(String l, bool v, ValueChanged<bool> cb) => FilterChip(
      label: Text(l, style: const TextStyle(fontSize: 11)), selected: v, onSelected: cb,
      selectedColor: const Color(0xFF1177AA).withAlpha(30), visualDensity: VisualDensity.compact);

}

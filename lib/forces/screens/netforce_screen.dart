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
import '../../common/widgets/knowledge_panel.dart';
import '../../common/widgets/nine_grid_layout.dart';

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
    // 首次进入不自动播放：与 Reset/归位一致，都需用户点画面中央的 ▶ 开始按钮
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
      child: NineGridLayout(
        // 顶部中格 = 玩法提示条
        topCenter: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: const Color(0xFFFEF3C7),
          child: const Text(
            '🎯 拔河游戏：① 拖小人到绿点摆阵 → ② 点画面中央 ▶ 开始 → ③ ⏸ 可暂停观察',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
          ),
        ),
        // 中间格 = 拔河主画面 · 面积 ≥ 70% 屏 · 自适应
        center: _buildForceDisplay(),
        // 右侧边格 = 控制面板 · 竖排紧凑 · 窄条可滚动
        midRight: _buildSidePanel(),
        // 左侧边格 = 速度表 + 知识点入口
        midLeft: _buildSideInfo(),
        // 底部中格 = 双队拖拽托盘
        bottomCenter: _buildBottomTray(),
      ),
    );

  }

  /// 右侧边格控制面板 · 竖排紧凑 · 窄条可滚动
  Widget _buildSidePanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: PropertyControlPanel(
        padding: const EdgeInsets.all(8),
        spacing: 10,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              _checkChip('合力', _showSum, (v) => setState(() => _showSum = v)),
              _checkChip('值', _showValues, (v) => setState(() => _showValues = v)),
              _checkChip('速度', _showSpeed, (v) => setState(() => _showSpeed = v)),
            ],
          ),
          const Divider(height: 8),
          Column(children: [
            TimeControlBar(clock: _clock),
            const SizedBox(height: 4),
            Tooltip(
              message: '把小车拉回中间原位（点画面 ▶ 开始）',
              child: _btn('归位', const Color(0xFF3B82F6), () => setState(() { _model.returnCart(); })),
            ),
          ]),
          const Divider(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: GameScoreboard(
              level: 1, maxLevel: 1,
              score: (_model.leftForce + _model.rightForce).toInt(),
              elapsedMs: _gameTimer.elapsedMs,
              title: '总力',
            ),
          ),
        ],
      ),
    );
  }

  /// 左侧边格 · 速度表 + 知识点入口
  Widget _buildSideInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(children: [
        if (_showSpeed)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Speedometer(speed: _model.cartVelocity.abs() * 10),
          ),
        const SizedBox(height: 8),
        IconButton(
          icon: const Icon(Icons.menu_book_outlined, size: 22),
          tooltip: '知识点',
          onPressed: _showKnowledgeDialog,
        ),
      ]),
    );
  }

  /// 底部中格 · 双队拖拽托盘
  Widget _buildBottomTray() {
    return Column(children: [
      Row(children: const [
        Expanded(child: Center(child: Text('🔵 蓝队',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))))),
        Expanded(child: Center(child: Text('🔴 红队',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C))))),
      ]),
      Expanded(child: Row(children: [
        Expanded(child: SingleChildScrollView(child: _pullerTray(false))),
        Container(width: 2, color: const Color(0xFFCBD5E1)),
        Expanded(child: SingleChildScrollView(child: _pullerTray(true))),
      ])),
    ]);
  }

  /// 知识点卡 → 弹窗（9 宫格边条容纳不下长文本知识卡）
  void _showKnowledgeDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(4),
            child: _buildKnowledgePanel(),
          ),
        ),
      ),
    );
  }

  Widget _buildForceDisplay() => LayoutBuilder(builder: (ctx, c) {
    final w = c.maxWidth, h = c.maxHeight;
    final cx = w / 2, cy = h * 0.3;
    final cartX = cx + _model.cartPosition * 0.5;
    return Stack(children: [
      // 地面
      Positioned(left: 0, right: 0, bottom: 40, child: Container(height: 4, color: const Color(0xFFCBD5E1))),
      // 小车—— 与绳结/小人处于同一水平带，车中心 (cy+80) 恰好对齐小人腼部
      Positioned(left: cartX - 40, top: cy + 65, child: _cartWidget()),
      // 左力箭头—— 箭头在上、标签在下，halt 高度 40 给两行留空间
      if (_showSum && _model.leftPullers.isNotEmpty)
        Positioned(left: cartX - 290, top: cy + 40,
          child: SizedBox(width: 120, height: 40,
            child: CustomPaint(painter: ForceArrowPainter(magnitude: _model.leftForce, direction: false, color: const Color(0xFF3B82F6),
                label: _showValues ? _model.leftForce.toStringAsFixed(0) : null, maxForce: 350,
                centered: true, labelAlign: LabelAlign.center)))),
      // 右力箭头—— 同上
      if (_showSum && _model.rightPullers.isNotEmpty)
        Positioned(left: cartX + 110, top: cy + 40,
          child: SizedBox(width: 120, height: 40,
            child: CustomPaint(painter: ForceArrowPainter(magnitude: _model.rightForce, direction: true, color: const Color(0xFFEF4444),
                label: _showValues ? _model.rightForce.toStringAsFixed(0) : null, maxForce: 350,
                centered: true, labelAlign: LabelAlign.center)))),
      // 合力箭头—— 同上
      if (_showSum)
        Positioned(left: cartX - 60, top: cy - 15,
          child: SizedBox(width: 120, height: 40,
            child: CustomPaint(painter: ForceArrowPainter(magnitude: _model.netForce.abs(), direction: _model.netForce >= 0, color: const Color(0xFF7C3AED),
                label: _showValues ? 'Σ${_model.netForce.toStringAsFixed(0)}' : null, maxForce: 350,
                centered: true, labelAlign: LabelAlign.center)))),
      // 左右绳结（每个绳子结点包裹 DragTarget）—— 同一水平线上等距分布，看起来像一根直绳
      ...List.generate(4, (i) => _knotDragTarget(cartX - 80 - (i + 1) * 60.0, cy + 90, false, i)),
      ...List.generate(4, (i) => _knotDragTarget(cartX + 80 + i * 60.0, cy + 90, true, i)),
      // 已放置的拉绳者—— chip 为居中 Column（图标在上 + 文字在脑子下）；left 对齐绳结中心–chip宽/2 使图标居中对齐节点
      for (final p in _model.pullers.where((p) => p.knotIndex != null))
        Positioned(
            left: cartX + (p.side ? 60 + p.knotIndex! * 60.0 : -100 - (p.knotIndex! + 1) * 60.0),
            top: cy + 66,
            child: _pullerChip(p, inTray: false)),
      // 未运行且未结束时叠加中央大号开始按钮——统一首次进入 / Reset / 归位 三处 UX
      // 只占按钮本身的位置（不铺满），避免遮挡拖拽事件；用户拖人上场仍可正常放置
      if (!_model.isRunning && !_model.isGameOver)
        Positioned(
          left: cx - 60, top: cy + 4,
          child: _buildStartButton()),
    ]);
  });

  /// 中央大号 ▶ 开始按钮：只占自身位置，不拦截周围事件，用户可正常拖人上场后再点开始
  Widget _buildStartButton() => GestureDetector(
    onTap: _clock.play,
    behavior: HitTestBehavior.opaque,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 84, height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF22C55E),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: const Icon(Icons.play_arrow, size: 56, color: Colors.white),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(color: Colors.black.withAlpha(160), borderRadius: BorderRadius.circular(10)),
        child: const Text('点击开始', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    ]),
  );

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
          child: Center(
            child: hasPuller
                ? const Icon(Icons.circle, size: 12, color: Color(0xFF22C55E))
                : Icon(Icons.add, size: 14, color: const Color(0xFF94A3B8).withAlpha(isHovered ? 255 : 160)),
          ),
        ),
      ));
  }

  Widget _cartWidget() => Container(width: 80, height: 30,
      decoration: BoxDecoration(color: const Color(0xFFD97706), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(2, (_) =>
          Container(width: 16, height: 16, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E293B))),),));

  Widget _pullerTray(bool side) => Wrap(children: _model.pullers.where((p) => p.side == side && p.knotIndex == null).map((p) =>
      Draggable<Puller>(data: p,
          feedback: Material(color: Colors.transparent, child: _pullerChip(p, inTray: false)),
          childWhenDragging: Opacity(opacity: 0.3, child: _pullerChip(p)),
          child: _pullerChip(p))).toList());

  Widget _pullerChip(Puller p, {bool inTray = true}) {
    // 放到场上时图标更大（ 26 → 不拥挤，也不会盖到临近节点）；托盘里保持小图 14
    final iconSize = inTray ? 14.0 : 26.0;
    final icon = Icon(Icons.directions_run, size: iconSize, color: p.color);
    // 左队朋向左拉、右队朋向右拉：Icons.directions_run 默认朝右，左队做水平镜像
    final directedIcon = p.side
        ? icon
        : Transform(alignment: Alignment.center, transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0), child: icon);

    // 场上模式：上下布局（图标在上、力值文字在脚底），宽度固定方便与绳结居中对齐
    if (!inTray) {
      return SizedBox(
        width: 40,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          directedIcon,
          const SizedBox(height: 1),
          Text('${p.force.toInt()} N',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: p.color)),
        ]),
      );
    }

    // 托盘模式：保留原横向 Row + 背景框，便于识别可拖动
    final content = Row(mainAxisSize: MainAxisSize.min, children: [
      directedIcon,
      const SizedBox(width: 4),
      Text('${p.force.toInt()} N', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: p.color)),
    ]);
    return Container(margin: const EdgeInsets.all(2), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: p.color.withAlpha(40), borderRadius: BorderRadius.circular(12), border: Border.all(color: p.color)),
        child: content);
  }
  // ---- 合力与拔河知识点 ----
  Widget _buildKnowledgePanel() {
    return KnowledgePanel(
      title: '合力与平衡原理',
      titleIcon: '⚖️',
      titleColor: const Color(0xFF7C3AED),
      maxHeight: 220,
      sections: [
        KnowledgeSection.grid(items: const [
          KnowledgeItem(
            dot: Color(0xFF22C55E),
            title: '平衡力 (合力=0)',
            titleColor: Color(0xFF22C55E),
            desc: '左右力大小相等,方向相反,合力为零。物体静止或匀速直线运动——拔河僵持就是平衡态。',
          ),
          KnowledgeItem(
            dot: Color(0xFFEF4444),
            title: '非平衡力 (合力≠0)',
            titleColor: Color(0xFFEF4444),
            desc: '一方力大于另一方,合力指向大力方向。物体加速运动——拔河中一方被拉过去就是非平衡。',
          ),
          KnowledgeItem(
            dot: Color(0xFF3B82F6),
            title: '矢量加法',
            titleColor: Color(0xFF3B82F6),
            desc: '力是有方向的量(矢量)。合力=所有力的矢量和。同向相加,反向相减——向右为正,向左为负。',
          ),
          KnowledgeItem(
            dot: Color(0xFFF59E0B),
            title: '力的独立作用',
            titleColor: Color(0xFFF59E0B),
            desc: '每个力独立产生效果。多个力同时作用时,总效果等于各力效果的矢量和——叠加原理。',
          ),
        ]),
        KnowledgeSection.list(
          subtitle: '知识点',
          subtitleIcon: '📚',
          subtitleColor: const Color(0xFF60A5FA),
          items: const [
            KnowledgeItem(
              icon: '🎯',
              title: '牛顿第二定律在拔河中的应用',
              titleColor: Color(0xFFF59E0B),
              desc: '拔河的胜负取决于合力方向。合力向右→车向右加速；合力向左→车向左加速。'
                  'F=ma,合力越大加速度越大——所以人越多力越大,赢面越大。注意：双方对绳子的拉力是作用力与反作用力,总是相等的!胜负取决于谁对地面的摩擦力更大。',
            ),
            KnowledgeItem(
              icon: '🔗',
              title: '作用力与反作用力 · 容易混淆的点',
              titleColor: Color(0xFF22C55E),
              desc: '拔河中双方对绳子的拉力大小永远相等(牛顿第三定律)。那为什么会有胜负?因为'
                  '胜负取决于人对地面的摩擦力——摩擦力大的一方能把绳子拉向自己这边。'
                  '所以拔河比赛本质是"摩擦力比赛",不是"拉力比赛"!',
            ),
            KnowledgeItem(
              icon: '🏗️',
              title: '平衡与结构 · 工程应用',
              titleColor: Color(0xFF8B5CF6),
              desc: '桥梁、建筑、塔吊——所有结构设计的核心都是"让合力为零"。每个构件受到的所有力(重力/拉力/压力/支撑力)'
                  '必须相互抵消,结构才不会倒塌。这就是"静力平衡"——土木工程的第一课。',
            ),
          ],
        ),
      ],
    );
  }

  Widget _checkChip(String l, bool v, ValueChanged<bool> cb) => FilterChip(
      label: Text(l), selected: v, onSelected: cb,
      selectedColor: const Color(0xFF1177AA).withAlpha(30));

  Widget _btn(String label, Color c, VoidCallback on) => ElevatedButton(
      onPressed: on, style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white),
      child: Text(label));
}

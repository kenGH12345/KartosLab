import 'package:flutter/material.dart';

import '../models/motion_model.dart';
import '../models/forces_item.dart';
import '../../common/controls/arrow_painter.dart';
import '../widgets/speedometer.dart';
import '../widgets/applied_force_slider.dart';
import '../widgets/accelerometer.dart';
import '../config/forces_scenario.dart';
import '../../common/simulation_clock.dart';
import '../../common/widgets/time_control_bar.dart';
import '../../common/chart/chart_series.dart';
import '../../common/chart/kratos_chart.dart';
import '../../common/chart/chart_painter.dart';
import '../../common/controls/kratos_slider.dart';
import '../../common/widgets/knowledge_panel.dart';
import '../../common/chart/graph_suite.dart';
import '../../common/controls/kratos_number_field.dart';
import '../../common/widgets/nine_grid_layout.dart';
import '../../common/widgets/inquiry_models.dart';
import '../../common/widgets/inquiry_drawer.dart';
import '../../common/widgets/experiment_logger.dart';
import '../../common/widgets/experiment_intro_panel.dart';

/// Motion屏幕（无摩擦滑板模式）
class MotionScreen extends StatefulWidget {
  const MotionScreen({super.key, required this.mode, this.scenario});
  final MotionScreenMode mode; // motion / friction / acceleration
  final ForcesScenario? scenario;

  @override
  State<MotionScreen> createState() => _MotionScreenState();
}

enum MotionScreenMode { motion, friction, acceleration }

class _MotionScreenState extends State<MotionScreen>
    with TickerProviderStateMixin {
  late final MotionModel _model;
  late final SimulationClock _clock;
  bool _showForces = true,
      _showSum = true,
      _showValues = true,
      _showMasses = true,
      _showSpeed = true;
  bool _showChart = false;
  int _chartMode = 0;
  double _friction = 0;
  bool _inquiryOpen = false;

  @override
  void initState() {
    super.initState();
    final s = widget.scenario;
    if (s != null) {
      final defaultFriction = switch (widget.mode) {
        MotionScreenMode.motion => 0.0,
        _ => 0.25,
      };
      _model = MotionModel.fromScenario(s, overrideFriction: defaultFriction);
    } else {
      _model = MotionModel(
        friction: widget.mode == MotionScreenMode.motion ? 0 : 0.25,
        showAccelerometer: widget.mode == MotionScreenMode.acceleration,
      );
    }
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, t) {
      _model.tick(dt, t);
      setState(() {});
    };
    _clock.play();
  }

  @override
  void dispose() {
    _model.reset();
    _clock.dispose();
    super.dispose();
  }

  void _addItem(ForceItem item) {
    if (_model.canAdd) setState(() => _model.addItem(item));
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      NineGridLayout(
        // 中间格 = 运动画布 · 面积 ≥ 70% 屏 · 自适应
        center: _buildCanvas(),
        // 右侧边格 = 控制面板 · 竖排紧凑 · 窄条可滚动
        // 底部横条：操作面板横排（AppliedForceSlider 竖排窄格放不下（255px 溢出）→ footer 220px 宽容纳）
        footer: _buildSidePanel(),
        // 底部中格 = 物体托盘
        bottomCenter: _buildItemTrays(),
        // 右下边格 = 知识点入口（知识卡过长改为弹窗）
        bottomRight: Center(
          child: IconButton(
            icon: const Icon(Icons.menu_book_outlined, size: 22),
            tooltip: '知识点',
            onPressed: _showKnowledgeDialog,
          ),
        ),
        // 顶部中格 = 探究入口按钮
        topCenter: _buildInquiryEntryButton(),
        // 顶部右格 = 实验说明 + 操作指引（通用引导组件）
        topRight: ExperimentIntroPanel(
          description: widget.scenario?.description ?? '',
          task: widget.scenario?.inquiryTask,
          color: const Color(0xFF166534),
        ),
      ),
      // 探究工作流抽屉
      InquiryDrawer(
        task: widget.scenario?.inquiryTask,
        columns: widget.scenario?.inquiryTask != null
            ? _inquiryColumns(widget.scenario!.inquiryTask!)
            : const [],
        snapshotProvider: _motionSnapshot,
        open: _inquiryOpen,
      ),
    ],
  );

  /// 探究抽屉入口按钮（仅在有 inquiryTask 的 scenario 显示）。
  Widget _buildInquiryEntryButton() {
    if (widget.scenario?.inquiryTask == null) return const SizedBox.shrink();
    return Center(
      child: IconButton.filledTonal(
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.science_outlined, size: 20),
        tooltip: '探究任务',
        onPressed: () => setState(() => _inquiryOpen = !_inquiryOpen),
      ),
    );
  }

  /// motion 快照：施加力/质量（param）+ 加速度/速度（reading）。
  /// 质量取 sim.mass（物理引擎实际使用值 · 与加速度计算同源 · Major-1 修复）。
  Map<String, dynamic> _motionSnapshot() {
    return {
      'appliedForce': _model.sim.appliedForce,
      'mass': _model.sim.mass,
      'acceleration': _model.sim.acceleration,
      'speed': _model.sim.speed,
    };
  }

  List<ColumnDef> _inquiryColumns(InquiryTask task) {
    if (task.snapshotColumns.isEmpty) {
      return const [
        ColumnDef(key: 'appliedForce', label: '施加力(N)', isParam: true),
        ColumnDef(key: 'mass', label: '总质量(kg)', isParam: true),
        ColumnDef(key: 'acceleration', label: '加速度(m/s²)'),
        ColumnDef(key: 'speed', label: '速度(m/s)'),
      ];
    }
    return task.snapshotColumns
        .map(
          (c) => ColumnDef(
            key: c.key,
            label: c.label,
            isParam: c.source == 'param',
          ),
        )
        .toList(growable: false);
  }

  /// 右侧边格控制面板 · 竖排紧凑 · 窄条可滚动
  /// 底部横排操作面板：显示 chips + 施力滑块 + 时间控制 + 位置/速度 + 摩擦
  /// （molarity footer 方案推广 · 横向滚动兜底窄视口 · 不用 FittedBox 避免 Slider 类无界问题）。
  Widget _buildSidePanel() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 260,
            // chips 横向滚动单行：避免 Wrap 换行（6 chips 3 行 96px）超出 footer 高度（67.8px）
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in [
                    _chip('力', _showForces, (v) => setState(() => _showForces = v)),
                    if (widget.mode != MotionScreenMode.motion)
                      _chip('合力', _showSum, (v) => setState(() => _showSum = v)),
                    _chip('值', _showValues, (v) => setState(() => _showValues = v)),
                    _chip('质量', _showMasses, (v) => setState(() => _showMasses = v)),
                    _chip('速度', _showSpeed, (v) => setState(() => _showSpeed = v)),
                    _chip('图表', _showChart, (v) => _showChartDialog()),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: c,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 220,
            child: AppliedForceSlider(
              value: _model.sim.appliedForce,
              onChanged: (v) => setState(() => _model.setAppliedForce(v)),
            ),
          ),
          const SizedBox(width: 14),
          TimeControlBar(clock: _clock),
          const SizedBox(width: 14),
          SizedBox(
            width: 110,
            child: KratosNumberField(
              label: '位置',
              unit: 'm',
              value: _model.sim.position,
              format: '0.0',
              onChanged: (v) => setState(() => _model.sim.position = v),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 110,
            child: KratosNumberField(
              label: '速度',
              unit: 'm/s',
              value: _model.sim.velocity,
              format: '0.0',
              onChanged: (v) => setState(() => _model.sim.velocity = v),
            ),
          ),
          if (widget.mode != MotionScreenMode.motion) ...[
            const SizedBox(width: 14),
            SizedBox(
              width: 180,
              child: KratosSlider(
                label: '摩擦',
                min: 0,
                max: 0.5,
                step: 0.05,
                value: _friction,
                unit: 'μ',
                onChanged: (v) => setState(() {
                  _friction = v;
                  _model.setFriction(v);
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 图表 → 弹窗（9 宫格边条容纳不下图表）
  void _showChartDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 420),
          child: _buildChart(),
        ),
      ),
    );
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

  Widget _buildCanvas() => LayoutBuilder(
    builder: (ctx, c) {
      final w = c.maxWidth, h = c.maxHeight;
      final itemX = w / 2 + _model.sim.position * 2; // 2 px/m 缩放
      final cy = h * 0.4;
      return Stack(
        children: [
          // 地面
          Positioned(
            left: 0,
            right: 0,
            bottom: h * 0.15,
            child: Container(height: 4, color: const Color(0xFFCBD5E1)),
          ),
          // 物品堆叠
          Positioned(left: itemX - 25, top: cy, child: _stackVisual()),
          // 速度表
          if (_showSpeed)
            Positioned(
              left: w / 2 - 60,
              bottom: 0,
              child: Speedometer(speed: _model.sim.speed),
            ),
          // 力箭头
          if (_showForces)
            Positioned(
              left: itemX - 130,
              top: cy - 40,
              child: SizedBox(
                width: 120,
                height: 20,
                child: CustomPaint(
                  painter: ForceArrowPainter(
                    magnitude: _model.sim.appliedForce.abs(),
                    direction: _model.sim.appliedForce > 0,
                    color: const Color(0xFFDC2626),
                    label: _showValues
                        ? _model.sim.appliedForce.toStringAsFixed(1)
                        : null,
                  ),
                ),
              ),
            ),
          // 摩擦力箭头
          if (_showSum &&
              _model.sim.frictionCoeff > 0 &&
              _model.sim.frictionForce.abs() > 1)
            Positioned(
              left: itemX - 130,
              top: cy - 20,
              child: SizedBox(
                width: 120,
                height: 20,
                child: CustomPaint(
                  painter: ForceArrowPainter(
                    magnitude: _model.sim.frictionForce.abs(),
                    direction: _model.sim.frictionForce > 0,
                    color: const Color(0xFFF59E0B),
                    label: _showValues
                        ? _model.sim.frictionForce.toStringAsFixed(1)
                        : null,
                  ),
                ),
              ),
            ),
          // 合力箭头
          if (_showSum && widget.mode != MotionScreenMode.motion)
            Positioned(
              left: itemX - 130,
              top: cy - 2,
              child: SizedBox(
                width: 120,
                height: 20,
                child: CustomPaint(
                  painter: ForceArrowPainter(
                    magnitude: _model.sim.netForce.abs(),
                    direction: _model.sim.netForce > 0,
                    color: const Color(0xFF7C3AED),
                    label: _showValues
                        ? 'Σ${_model.sim.netForce.toStringAsFixed(1)}'
                        : null,
                  ),
                ),
              ),
            ),
          // 加速度计
          if (widget.mode == MotionScreenMode.acceleration)
            Positioned(
              left: w / 2 + 70,
              top: 5,
              child: Accelerometer(acceleration: _model.sim.acceleration),
            ),
          // 质量标签
          if (_showMasses)
            Positioned(
              left: itemX - 20,
              top: cy + 70,
              child: Text(
                '${_model.totalMass.toStringAsFixed(0)} kg',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
        ],
      );
    },
  );

  Widget _stackVisual() => Column(
    mainAxisSize: MainAxisSize.min,
    children:
        _model.stack
            .map(
              (i) => Container(
                width: 50,
                height: 20,
                margin: const EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(
                  color: i.color.withAlpha(180),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: i.color),
                ),
                child: Center(
                  child: Text(
                    i.name[0],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: i.color,
                    ),
                  ),
                ),
              ),
            )
            .toList()
          ..insert(
            0,
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
  );

  Widget _buildItemTrays() => Row(
    children: [
      Expanded(child: _itemTray(ItemSide.left)),
      Container(width: 2, color: const Color(0xFFCBD5E1)),
      Expanded(child: _itemTray(ItemSide.right)),
    ],
  );

  Widget _itemTray(ItemSide side) {
    final items = kForceItems.where((i) {
      if (widget.mode == MotionScreenMode.acceleration && i.id == 'bucket')
        return true;
      if (widget.mode != MotionScreenMode.acceleration && i.id == 'bucket')
        return false;
      return i.side == side;
    }).toList();
    return ListView(
      scrollDirection: Axis.horizontal,
      children: items
          .map(
            (i) => InkWell(
              onTap: () => _addItem(i),
              child: Container(
                width: 52,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: i.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(i.icon, size: 18, color: i.color),
                    Text(i.name, style: TextStyle(fontSize: 8, color: i.color)),
                    if (i.massKnown)
                      Text(
                        '${i.mass.toInt()}kg',
                        style: const TextStyle(
                          fontSize: 8,
                          color: Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ---- 力与运动知识点 ----
  Widget _buildKnowledgePanel() {
    return KnowledgePanel(
      title: '力与运动原理',
      titleIcon: '🚀',
      titleColor: const Color(0xFF3B82F6),
      maxHeight: 220,
      sections: [
        KnowledgeSection.grid(
          items: const [
            KnowledgeItem(
              dot: Color(0xFFDC2626),
              title: '牛顿第一定律 (惯性)',
              titleColor: Color(0xFFDC2626),
              desc: '不受力或合力为零时,物体保持静止或匀速直线运动。质量越大惯性越大——刹车距离更长。',
            ),
            KnowledgeItem(
              dot: Color(0xFF22C55E),
              title: '牛顿第二定律 F=ma',
              titleColor: Color(0xFF22C55E),
              desc: '物体加速度与合力成正比,与质量成反比。a=F/m——同样的力推小车加速快,推大车加速慢。',
            ),
            KnowledgeItem(
              dot: Color(0xFF3B82F6),
              title: '牛顿第三定律',
              titleColor: Color(0xFF3B82F6),
              desc: '作用力与反作用力大小相等、方向相反,作用在不同物体上。你推墙=墙也在推你。',
            ),
            KnowledgeItem(
              dot: Color(0xFFF59E0B),
              title: '摩擦力',
              titleColor: Color(0xFFF59E0B),
              desc: '阻碍相对运动的力。f=μN。与接触面粗糙程度(μ)和正压力(N)有关。冰面μ小→滑得远。',
            ),
          ],
        ),
        KnowledgeSection.list(
          subtitle: '知识点',
          subtitleIcon: '📚',
          subtitleColor: const Color(0xFF60A5FA),
          items: const [
            KnowledgeItem(
              icon: '🧭',
              title: '合力与运动状态改变',
              titleColor: Color(0xFFF59E0B),
              desc:
                  '合力不为零→速度改变(加速/减速/转向)。合力为零→速度不变(静止或匀速)。'
                  '不是\"力维持运动\"而是\"力改变运动\"——这是从亚里士多德到牛顿的认知革命。',
            ),
            KnowledgeItem(
              icon: '📐',
              title: '受力分析 · 自由体图',
              titleColor: Color(0xFF22C55E),
              desc:
                  '画自由体图是解力学题的第一步：把物体隔离出来,画出所有作用力(重力/支持力/摩擦力/推力等)。'
                  '然后用F=ma列方程——这是从初中到大学物理都通用的方法。',
            ),
            KnowledgeItem(
              icon: '🏎️',
              title: '质量与加速度 · 生活体验',
              titleColor: Color(0xFF8B5CF6),
              desc:
                  '同样油门,空车加速快、满载加速慢——这就是m越大a越小。赛车减重、火箭分级抛壳都是这个道理。'
                  '安全带和气囊通过延长碰撞时间来减小加速度,保护乘客——F=ma的救命应用。',
            ),
          ],
        ),
      ],
    );
  }

  Widget _chip(String l, bool v, ValueChanged<bool> cb) => FilterChip(
    label: Text(l, style: const TextStyle(fontSize: 11)),
    selected: v,
    onSelected: cb,
    selectedColor: const Color(0xFF1177AA).withAlpha(30),
    visualDensity: VisualDensity.compact,
  );

  Widget _buildChart() {
    const allSeries = [
      ChartSeries(title: '位置', abbr: 'x', unit: 'm', color: Color(0xFF3B82F6)),
      ChartSeries(
        title: '速度',
        abbr: 'v',
        unit: 'm/s',
        color: Color(0xFFEF4444),
      ),
    ];
    final suites = [
      GraphSuite(label: '全部', series: allSeries),
      GraphSuite(label: '位置', series: [allSeries[0]]),
      GraphSuite(label: '速度', series: [allSeries[1]]),
    ];
    final active = suites[_chartMode];
    final maxDomain = _clock.totalTime > 20 ? _clock.totalTime + 5 : 20.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GraphSuiteSelector(
          suites: suites,
          selectedIndex: _chartMode,
          onChanged: (i) => setState(() => _chartMode = i),
        ),
        SizedBox(
          height: 150,
          child: KratosChart(
            series: active.series,
            dataProviders: active.series.length >= 2
                ? [_model.posData, _model.velData]
                : active.series.first.abbr == 'x'
                ? [_model.posData]
                : [_model.velData],
            domainRange: Range(0, maxDomain),
            rangeRange: const Range(-20, 20),
            currentTime: _clock.totalTime,
            domainLabel: '时间 (s)',
            showGrid: true,
            height: 150,
          ),
        ),
      ],
    );
  }
}

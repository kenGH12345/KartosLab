import 'dart:math';
import 'package:flutter/material.dart';
import '../../common/simulation_clock.dart';
import '../../common/widgets/time_control_bar.dart';
import '../../common/widgets/knowledge_panel.dart';
import '../../common/widgets/scenario_menu_button.dart';
import '../../common/widgets/nine_grid_layout.dart';
import '../../common/widgets/inquiry_models.dart';
import '../../common/widgets/inquiry_drawer.dart';
import '../../common/widgets/experiment_logger.dart';
import '../../common/widgets/experiment_intro_panel.dart';
import '../config/wave_interference_scenario.dart';
import '../config/wave_interference_scenario_manager.dart';
import '../model/wave_engine.dart';
import '../painters/wave_heatmap_painter.dart';

enum BarrierMode { none, singleSlit, doubleSlit }

class WaveInterferenceScreen extends StatefulWidget {
  const WaveInterferenceScreen({super.key});
  @override
  State<WaveInterferenceScreen> createState() => _WaveInterferenceScreenState();
}

class _WaveInterferenceScreenState extends State<WaveInterferenceScreen>
    with TickerProviderStateMixin {
  static const int gridW = 80;
  static const int gridH = 55;

  late final WaveEngine _engine;
  late final SimulationClock _clock;
  final WaveInterferenceScenarioManager _manager =
      WaveInterferenceScenarioManager();
  String _currentScenarioId = 'default';
  bool _scenariosLoaded = false;

  double _frequency = 0.4;
  double _amplitude = 1.5;
  final int _oscRadius = 2;
  WaveType _waveType = WaveType.water;
  BarrierMode _barrierMode = BarrierMode.doubleSlit;
  // C7：源/挡板位置可拖（网格坐标 · clamp 到画布内）
  int _sourceX = 8;
  int _barrierX = 35;
  int _slitSize = 10;
  int _slitSeparation = 24;
  bool _inquiryOpen = false;

  @override
  void initState() {
    super.initState();
    _engine = WaveEngine(width: gridW, height: gridH);
    _rebuildBarriers();
    _clock = SimulationClock(fps: 30);
    _clock.attach(this);
    _clock.onTick = (dt, _) {
      _step(dt);
      setState(() {});
    };
    _clock.play();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    await _manager.loadScenarios();
    if (!mounted) return;
    _applyScenario(_currentScenarioId);
    setState(() => _scenariosLoaded = true);
  }

  /// 按 id 应用 scenario 参数到当前 state（不重建 engine · 保持时钟连续）
  /// waveType 属显示偏好，不受 scenario 影响
  void _applyScenario(String id) {
    final scenario = _manager.findById(id);
    if (scenario == null) return;
    _frequency = scenario.frequency;
    _amplitude = scenario.amplitude;
    _slitSize = scenario.slitSize;
    _slitSeparation = scenario.slitSeparation;
    // scenario 只有 barrierEnabled 布尔；false → none；true → 若当前是 none 则默认 doubleSlit，否则保持
    if (!scenario.barrierEnabled) {
      _barrierMode = BarrierMode.none;
    } else if (_barrierMode == BarrierMode.none) {
      _barrierMode = BarrierMode.doubleSlit;
    }
    _currentScenarioId = id;
    _rebuildBarriers();
    // 有 inquiryTask 即默认展开（做中学进入即见任务 · task==null 时抽屉不渲染）
    _inquiryOpen = scenario.inquiryTask != null;
  }

  void _rebuildBarriers() {
    _engine.clearBarriers();
    switch (_barrierMode) {
      case BarrierMode.none:
        break;
      case BarrierMode.singleSlit:
        _engine.setSingleSlit(_barrierX, 2, _slitSize);
      case BarrierMode.doubleSlit:
        _engine.setDoubleSlit(_barrierX, 2, _slitSize, _slitSeparation);
    }
  }

  void _step(double dt) {
    // Drive oscillator source（源位置可拖 · clamp 画布内）
    double val = _amplitude * cos(2 * pi * _frequency * _engine.time);
    _engine.setSource(_sourceX, gridH ~/ 2, _oscRadius, val);
    _engine.propagate(0.1);
  }

  @override
  void dispose() {
    _engine.dispose();
    _clock.dispose();
    super.dispose();
  }

  void _setFrequency(double v) => setState(() => _frequency = v);
  void _setAmplitude(double v) => setState(() => _amplitude = v);
  void _setSlitSize(double v) {
    _slitSize = v.round();
    _rebuildBarriers();
    setState(() {});
  }

  void _setSlitSep(double v) {
    _slitSeparation = v.round();
    _rebuildBarriers();
    setState(() {});
  }

  void _setBarrierMode(BarrierMode m) {
    _barrierMode = m;
    _rebuildBarriers();
    setState(() {});
  }

  void _setWaveType(WaveType t) => setState(() => _waveType = t);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('波的干涉', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        toolbarHeight: 44,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            tooltip: '知识点',
            onPressed: _showKnowledgeDialog,
          ),
          _buildScenarioMenu(),
        ],
      ),
      body: Stack(
        children: [
          NineGridLayout(
            // 中间格 = 实验画面 · 面积 ≥ 70% 屏 · 随格子尺寸自适应
            // C7 手势：拖波源（红色亮点）或拖挡板条（barrierMode≠none 时）
            center: LayoutBuilder(
              builder: (context, c) {
                final cellW = c.maxWidth / gridW;
                final cellH = c.maxHeight / gridH;
                // 命中检测：距目标网格位置（屏幕像素）< 阈值
                bool near(int gridX, int gridY, Offset p, double th) =>
                    (Offset(gridX * cellW + cellW / 2, gridY * cellH + cellH / 2) -
                            p)
                        .distance <
                    th;
                return GestureDetector(
                  onPanUpdate: (d) {
                    final gx =
                        (d.localPosition.dx / cellW).round().clamp(2, gridW - 2);
                    final nearSource =
                        near(_sourceX, gridH ~/ 2, d.localPosition, cellW * 1.2);
                    final nearBarrier =
                        _barrierMode != BarrierMode.none &&
                            near(_barrierX, gridH ~/ 2, d.localPosition,
                                cellW * 1.2);
                    if (nearSource) {
                      setState(() => _sourceX = gx);
                    } else if (nearBarrier) {
                      setState(() {
                        _barrierX = gx;
                        _rebuildBarriers();
                      });
                    }
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: WaveHeatmapPainter(
                      _engine,
                      gridW: gridW,
                      gridH: gridH,
                      waveType: _waveType,
                    ),
                  ),
                );
              },
            ),
            // 右侧边格 = 竖排紧凑控制面板 · 窄条可滚动
            // 底部横条：操作面板横排（molarity footer 方案推广 · 窄视口横向滚动+缩放）
            footer: _buildSideControlPanel(),
            // 顶部中格 = 探究入口按钮
            topCenter: _buildInquiryEntryButton(),
            // 顶部右格 = 实验说明 + 操作指引（通用引导组件）
            topRight: ExperimentIntroPanel(
              description: _currentScenario?.description ?? '',
              task: _currentScenario?.inquiryTask,
              color: const Color(0xFF2563EB),
            ),
          ),
          // 探究工作流抽屉
          InquiryDrawer(
            task: _currentScenario?.inquiryTask,
            columns: _currentScenario?.inquiryTask != null
                ? _inquiryColumns(_currentScenario!.inquiryTask!)
                : const [],
            snapshotProvider: _waveSnapshot,
            open: _inquiryOpen,
          ),
        ],
      ),
    );
  }

  /// 当前 scenario（经 manager 按 id 取 · 无则 null）。
  WaveInterferenceScenario? get _currentScenario =>
      _manager.findById(_currentScenarioId);

  /// 探究抽屉入口按钮（仅在有 inquiryTask 的 scenario 显示）。
  Widget _buildInquiryEntryButton() {
    if (_currentScenario?.inquiryTask == null) return const SizedBox.shrink();
    return Center(
      child: IconButton.filledTonal(
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.science_outlined, size: 20),
        tooltip: '探究任务',
        onPressed: () => setState(() => _inquiryOpen = !_inquiryOpen),
      ),
    );
  }

  /// wave-interference 快照：频率/缝间距（param）+ 条纹间距估算（reading）。
  Map<String, dynamic> _waveSnapshot() {
    // 条纹间距估算：模拟内 d·sinθ = n·λ，间距 ∝ λ/d = c/(f·d)
    final waveSpeed = 0.5; // FDTD c^2=0.25 → c=0.5
    final lambda = waveSpeed / _frequency;
    final fringe = lambda / _slitSeparation;
    return {
      'frequency': _frequency,
      'slitSeparation': _slitSeparation.toDouble(),
      'fringeSpacing': fringe,
    };
  }

  List<ColumnDef> _inquiryColumns(InquiryTask task) {
    if (task.snapshotColumns.isEmpty) {
      return const [
        ColumnDef(key: 'frequency', label: '频率', isParam: true),
        ColumnDef(key: 'slitSeparation', label: '缝间距', isParam: true),
        ColumnDef(key: 'fringeSpacing', label: '条纹间距(估)'),
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
  /// 底部横排操作面板：波类型/挡板 chips + 频率/振幅/缝宽滑块 + 重置 + 时间控制
  /// （molarity footer 方案推广 · 窄视口 FittedBox 缩放 + 横向滚动）。
  Widget _buildSideControlPanel() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            // Wrap 包 SizedBox 限宽（FittedBox 无界宽下 Wrap 无限展开的通用约束 · 同其他屏）
            SizedBox(
              width: 240,
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _waveTypeChip(WaveType.water, '🌊 水波'),
                  _waveTypeChip(WaveType.light, '💡 光波'),
                  _waveTypeChip(WaveType.sound, '🔊 声波'),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 240,
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _barrierModeChip(BarrierMode.none, '无挡板'),
                  _barrierModeChip(BarrierMode.singleSlit, '单缝'),
                  _barrierModeChip(BarrierMode.doubleSlit, '双缝'),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 180,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _readoutRow('频率', (_frequency * 10).toStringAsFixed(2)),
                  Slider(
                    value: _frequency,
                    min: 0.1,
                    max: 1.0,
                    divisions: 18,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: _setFrequency,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 180,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _readoutRow('振幅', _amplitude.toStringAsFixed(1)),
                  Slider(
                    value: _amplitude,
                    min: 0.2,
                    max: 3.0,
                    divisions: 28,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: _setAmplitude,
                  ),
                ],
              ),
            ),
            if (_barrierMode != BarrierMode.none) ...[
              const SizedBox(width: 14),
              SizedBox(
                width: 180,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _readoutRow(
                      _barrierMode == BarrierMode.doubleSlit ? '缝宽 / 间距' : '缝宽',
                      _barrierMode == BarrierMode.doubleSlit
                          ? '$_slitSize / $_slitSeparation'
                          : '$_slitSize',
                    ),
                    Slider(
                      value: _slitSize.toDouble(),
                      min: 4,
                      max: 20,
                      divisions: 16,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: _setSlitSize,
                    ),
                    if (_barrierMode == BarrierMode.doubleSlit)
                      Slider(
                        value: _slitSeparation.toDouble(),
                        min: 12,
                        max: 36,
                        divisions: 24,
                        activeColor: const Color(0xFF2563EB),
                        onChanged: _setSlitSep,
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(width: 14),
            FilterChip(
              label: const Text('重置波形', style: TextStyle(fontSize: 11)),
              selected: false,
              onSelected: (_) {
                _engine.reset();
                setState(() {});
              },
            ),
            const SizedBox(width: 14),
            TimeControlBar(clock: _clock),
          ],
        ),
      ),
    );
  }

  Widget _readoutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }

  /// 知识点卡 → AppBar Info 弹窗（9 宫格边条容纳不下长文本知识卡）
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

  /// AppBar 右上角场景切换菜单 · 委托给 L0 组件
  Widget _buildScenarioMenu() {
    return ScenarioMenuButton(
      entries: _manager.scenarios
          .map(
            (WaveInterferenceScenario s) =>
                ScenarioMenuEntry(id: s.scenarioId, name: s.name),
          )
          .toList(),
      currentId: _currentScenarioId,
      loading: !_scenariosLoaded,
      accentColor: const Color(0xFF2563EB),
      onSelected: (id) => setState(() => _applyScenario(id)),
    );
  }

  Widget _waveTypeChip(WaveType t, String label) {
    final selected = _waveType == t;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: selected,
      selectedColor: const Color(0xFF2563EB).withAlpha(40),
      onSelected: (_) => _setWaveType(t),
    );
  }

  Widget _barrierModeChip(BarrierMode m, String label) {
    final selected = _barrierMode == m;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: selected,
      selectedColor: const Color(0xFF0891B2).withAlpha(40),
      onSelected: (_) => _setBarrierMode(m),
    );
  }

  Widget _buildKnowledgePanel() {
    return KnowledgePanel(
      title: '波的干涉原理',
      titleIcon: '\ud83c\udf0a',
      titleColor: const Color(0xFF2563EB),
      sections: [
        KnowledgeSection.grid(
          items: const [
            KnowledgeItem(
              icon: '\ud83d\udca7',
              title: '波源',
              titleColor: Color(0xFF2563EB),
              desc: '振荡器产生向外扩散的圆形涟漪，就像往水里扔石子。',
            ),
            KnowledgeItem(
              icon: '\ud83d\udcd0',
              title: '双缝',
              titleColor: Color(0xFF0891B2),
              desc: '波通过两条缝后，从缝中发出两列新的圆形波。这两列波相互干涉，产生加强和减弱。',
            ),
            KnowledgeItem(
              icon: '\u2795',
              title: '相长干涉',
              titleColor: Color(0xFF16A34A),
              desc: '波峰遇波峰、波谷遇波谷：振幅叠加，形成更亮的条纹。',
            ),
            KnowledgeItem(
              icon: '\u2796',
              title: '相消干涉',
              titleColor: Color(0xFFDC2626),
              desc: '波峰遇波谷：相互抵消，形成暗条纹。',
            ),
          ],
        ),
        KnowledgeSection.list(
          subtitle: '核心概念',
          subtitleIcon: '\ud83d\udcda',
          subtitleColor: const Color(0xFF60A5FA),
          items: const [
            KnowledgeItem(
              icon: '\ud83c\udf0a',
              title: '水波干涉（杨氏双缝实验）',
              titleColor: Color(0xFF2563EB),
              desc:
                  '托马斯·杨在 1801 年首次用实验证明了光的波动性。这里用水波看到同样的原理：两个相干波源产生明暗相间的干涉条纹向外辐射。',
            ),
            KnowledgeItem(
              icon: '\ud83d\udcd0',
              title: '双缝干涉公式',
              titleColor: Color(0xFF0891B2),
              desc:
                  '明条纹出现在满足 d·sinθ = n·λ 的角度，其中 d = 缝间距，λ = 波长，n = 0, 1, 2... 调整"间距"滑块，可以看到缝间距越大、干涉条纹越密。',
            ),
            KnowledgeItem(
              icon: '\ud83d\udd0d',
              title: '波长与频率',
              titleColor: Color(0xFF22C55E),
              desc:
                  '频率越高 → 波长越短 → 干涉条纹越密。波的传播速度（由模拟中的 c^2=0.25 参数决定）固定，因此 λ 与频率成反比。',
            ),
            KnowledgeItem(
              icon: '\ud83d\udd2c',
              title: 'FDTD 波动方程',
              titleColor: Color(0xFFA855F7),
              desc:
                  '本模拟用时域有限差分法（FDTD）求解二维波动方程。每个网格单元的值根据相邻单元更新。所有边缘的吸收边界防止波的反射。',
            ),
          ],
        ),
      ],
    );
  }
}

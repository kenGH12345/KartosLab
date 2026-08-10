import 'package:flutter/material.dart';
import '../../common/simulation_clock.dart';
import '../../common/widgets/time_control_bar.dart';
import '../../common/widgets/property_control_panel.dart';
import '../../common/widgets/knowledge_panel.dart';
import '../../common/widgets/scenario_menu_button.dart';
import '../../common/widgets/nine_grid_layout.dart';
import '../../common/widgets/inquiry_models.dart';
import '../../common/widgets/inquiry_drawer.dart';
import '../../common/widgets/experiment_logger.dart';
import '../config/radio_waves_scenario.dart';
import '../config/radio_waves_scenario_manager.dart';
import '../model/radio_state.dart';
import '../painters/field_painter.dart';

class RadioWavesScreen extends StatefulWidget {
  const RadioWavesScreen({super.key});
  @override
  State<RadioWavesScreen> createState() => _RadioWavesScreenState();
}

class _RadioWavesScreenState extends State<RadioWavesScreen>
    with TickerProviderStateMixin {
  late final RadioState _state;
  late final SimulationClock _clock;
  final RadioWavesScenarioManager _manager = RadioWavesScenarioManager();
  String _currentScenarioId = 'default';
  bool _scenariosLoaded = false;
  bool _inquiryOpen = false;

  @override
  void initState() {
    super.initState();
    _state = RadioState();
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) {
      _state.stepInTime(dt);
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

  /// 按 id 应用 scenario 参数到当前 state（不重建 state，保持时钟连续）
  void _applyScenario(String id) {
    final scenario = _manager.findById(id);
    if (scenario == null) return;
    _state.setFrequency(scenario.frequency);
    _state.setAmplitude(scenario.amplitude);
    _state.showCurve = scenario.showCurve;
    _state.showArrows = scenario.showArrows;
    _state.dynamicFieldEnabled = scenario.dynamicFieldEnabled;
    _currentScenarioId = id;
    // 场景切换时复位探究抽屉（Major-2 · 与 circuit 先例一致）
    _inquiryOpen = false;
  }

  @override
  void dispose() {
    _state.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('电磁波', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF7C3AED),
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
            center: CustomPaint(
              size: Size.infinite,
              painter: FieldPainter(_state),
            ),
            // 右侧边格 = 竖排紧凑控制面板 · 窄条可滚动
            midRight: _buildSideControlPanel(),
            // 顶部中格 = 探究入口按钮
            topCenter: _buildInquiryEntryButton(),
          ),
          // 探究工作流抽屉
          InquiryDrawer(
            task: _currentScenario?.inquiryTask,
            columns: _currentScenario?.inquiryTask != null
                ? _inquiryColumns(_currentScenario!.inquiryTask!)
                : const [],
            snapshotProvider: _radioWavesSnapshot,
            open: _inquiryOpen,
          ),
        ],
      ),
    );
  }

  /// 当前 scenario（经 manager 按 id 取 · 无则 null）。
  RadioWavesScenario? get _currentScenario => _manager.findById(_currentScenarioId);

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

  /// radio-waves 快照：频率/振幅（param）+ 可见波峰数（reading 估算）。
  Map<String, dynamic> _radioWavesSnapshot() {
    // 波峰数估算：模拟频率 0.05-2.0 对应屏幕上可见完整波数
    final waveCount = (_state.frequency * 6).round();
    return {
      'frequency': _state.frequency,
      'amplitude': _state.amplitude,
      'waveCount': waveCount,
    };
  }

  List<ColumnDef> _inquiryColumns(InquiryTask task) {
    if (task.snapshotColumns.isEmpty) {
      return const [
        ColumnDef(key: 'frequency', label: '频率', isParam: true),
        ColumnDef(key: 'amplitude', label: '振幅', isParam: true),
        ColumnDef(key: 'waveCount', label: '可见波峰数'),
      ];
    }
    return task.snapshotColumns
        .map((c) => ColumnDef(key: c.key, label: c.label, isParam: c.source == 'param'))
        .toList(growable: false);
  }

  /// 右侧边格控制面板 · 竖排紧凑 · 窄条可滚动
  Widget _buildSideControlPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: PropertyControlPanel(
        padding: const EdgeInsets.all(8),
        spacing: 12,
        children: [
          _readoutRow('频率', '${_state.frequency.toStringAsFixed(2)} Hz'),
          Slider(
            value: _state.frequency, min: 0.05, max: 2.0, divisions: 39,
            activeColor: const Color(0xFF7C3AED),
            onChanged: (v) => setState(() => _state.setFrequency(v)),
          ),
          _readoutRow('振幅', _state.amplitude.toStringAsFixed(2)),
          Slider(
            value: _state.amplitude, min: 0, max: 1, divisions: 20,
            activeColor: const Color(0xFF7C3AED),
            onChanged: (v) => setState(() => _state.setAmplitude(v)),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              FilterChip(label: const Text('曲线', style: TextStyle(fontSize: 11)),
                selected: _state.showCurve, selectedColor: const Color(0xFFDC2626).withAlpha(40),
                onSelected: (_) => setState(() => _state.toggleCurve())),
              FilterChip(label: const Text('箭头', style: TextStyle(fontSize: 11)),
                selected: _state.showArrows, selectedColor: const Color(0xFF22C55E).withAlpha(40),
                onSelected: (_) => setState(() => _state.toggleArrows())),
              FilterChip(label: const Text('动态', style: TextStyle(fontSize: 11)),
                selected: _state.dynamicFieldEnabled, selectedColor: const Color(0xFF7C3AED).withAlpha(40),
                onSelected: (_) => setState(() => _state.toggleDynamicField())),
            ],
          ),
          const Divider(height: 12),
          Center(child: TimeControlBar(clock: _clock)),
        ],
      ),
    );
  }

  Widget _readoutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
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
          .map((RadioWavesScenario s) => ScenarioMenuEntry(id: s.scenarioId, name: s.name))
          .toList(),
      currentId: _currentScenarioId,
      loading: !_scenariosLoaded,
      accentColor: const Color(0xFF7C3AED),
      onSelected: (id) => setState(() => _applyScenario(id)),
    );
  }

  Widget _buildKnowledgePanel() {
    return KnowledgePanel(
      title: '电磁波原理',
      titleIcon: '\ud83d\udcfb',
      titleColor: const Color(0xFF7C3AED),
      sections: [
        KnowledgeSection.grid(items: const [
          KnowledgeItem(icon: '\u26a1', title: '振荡电子', titleColor: Color(0xFF3B82F6),
            desc: '天线上的电子振荡产生变化的电场，以电磁波的形式向外传播。'),
          KnowledgeItem(icon: '\ud83c\udf00', title: '滞后场（推迟场）', titleColor: Color(0xFF22C55E),
            desc: '距离 d 处的场滞后 d/c（光传播时间）。你在远处看到的场，其实是电子在过去时刻的行为。'),
          KnowledgeItem(icon: '\ud83d\udcc8', title: '加速即辐射', titleColor: Color(0xFFDC2626),
            desc: '只有加速运动的电荷才会辐射电磁波。匀速运动只产生静电场；加速运动才产生向外传播的波。'),
          KnowledgeItem(icon: '\ud83d\udce1', title: '天线物理', titleColor: Color(0xFFF59E0B),
            desc: '无线电天线通过驱动电子振荡来工作，振荡的电荷以相同频率辐射电磁波。'),
        ]),
        KnowledgeSection.list(
          subtitle: '核心概念', subtitleIcon: '\ud83d\udcda', subtitleColor: const Color(0xFF60A5FA),
          items: const [
            KnowledgeItem(icon: '\ud83d\udc49', title: '无线电发射如何工作',
              titleColor: Color(0xFFF59E0B),
              desc: '1) 发射电路以选定频率驱动电子在天线上往复运动。2) 加速电子产生变化的电场和磁场。3) 这些场以光速向外传播。4) 接收天线拾取振荡的场，感应出微小电流。所有无线通信都靠这个原理——从 AM/FM 收音机到 WiFi 再到 5G。'),
            KnowledgeItem(icon: '\ud83d\udd0d', title: '静态场 vs 动态场',
              titleColor: Color(0xFF22C55E),
              desc: '静态场（库仑场）：按 1/r^2 衰减，始终指向/背离电荷。动态场（辐射场）：按 1/r 衰减，以波的形式传播。在远距离处只有动态场起作用——这就是无线电信号能传得很远的原因。'),
            KnowledgeItem(icon: '\ud83c\udf0d', title: '与光速的联系',
              titleColor: Color(0xFF3B82F6),
              desc: '电磁波以光速（c = 3×10^8 m/s）传播。本模拟中的滞后效应显示：远处某点的场反映的是电子 d/c 秒前的行为。这与遥远恒星发出的光让我们看到过去是同一个原理。'),
            KnowledgeItem(icon: '\ud83d\udcfb', title: 'AM 与 FM 广播',
              titleColor: Color(0xFFA855F7),
              desc: 'AM（调幅）：通过改变波的振幅来编码声音。FM（调频）：通过改变波的频率来编码声音。两者使用相同的底层物理——发射天线中振荡的电子——但调制的载波属性不同。'),
          ],
        ),
      ],
    );
  }
}

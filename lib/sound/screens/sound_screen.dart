import 'package:flutter/material.dart';
import "../../common/simulation_clock.dart";
import "../../common/widgets/time_control_bar.dart";
import "../../common/widgets/knowledge_panel.dart";
import "../../common/widgets/nine_grid_layout.dart";
import "../../common/widgets/property_control_panel.dart";
import "../config/sound_scenario.dart";
import "../config/sound_scenario_manager.dart";
import "../model/sound_state.dart";
import "../painters/spherical_view_painter.dart";
import "../painters/waveform_profile_painter.dart";
import "../widgets/sound_info_cards.dart";

/// Sound 声波 sim 屏幕。
///
/// 两种互补视角，通过顶部 Tab 切换：
/// 1. 球面波俯视图 — 完整 360° 同心圆灰度带（亮=压缩 / 暗=稀疏）
/// 2. 一维波形剖面图 — 距离-压强正弦曲线（红=正压 / 蓝=负压）
///
/// 硬性要求：主图容器 Center 居中 + LayoutBuilder 屏幕适配
class SoundScreen extends StatefulWidget {
  const SoundScreen({super.key});
  @override
  State<SoundScreen> createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen>
    with TickerProviderStateMixin {
  late final SoundState _state;
  late final SimulationClock _clock;
  late final TabController _tabController;
  final SoundScenarioManager _manager = SoundScenarioManager();
  String _currentScenarioId = 'default';
  bool _scenariosLoaded = false;

  // 声速常量 · 空气中约 343 m/s（20°C）
  static const double _kSoundSpeed = 343.0;

  @override
  void initState() {
    super.initState();
    _state = SoundState();
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) {
      _state.stepInTime(dt);
      setState(() {});
    };
    _clock.play();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    await _manager.loadScenarios();
    if (!mounted) return;
    _applyScenario(_currentScenarioId);
    setState(() => _scenariosLoaded = true);
  }

  void _applyScenario(String id) {
    final scenario = _manager.findById(id);
    if (scenario == null) return;
    _state.setFrequency(scenario.frequency);
    _state.setAmplitude(scenario.amplitude);
    _currentScenarioId = id;
  }

  @override
  void dispose() {
    _state.dispose();
    _clock.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// 由频率算波长（防除零）· λ = c / f
  double get _wavelength =>
      _state.frequency > 1 ? _kSoundSpeed / _state.frequency : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Sound Waves 声波', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        toolbarHeight: 44,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            tooltip: '知识点',
            onPressed: _showKnowledgeDialog,
          ),
        ],
      ),
      body: NineGridLayout(
        // 中间格 = 主图（含 Tab 切换的两种视图）· 面积 ≥ 70% 屏 · 自适应
        center: _buildStageArea(),
        // 顶部中格 = 视角 Tab 栏
        topCenter: _buildTabBar(),
        // 右侧边格 = 竖排紧凑控制面板 · 窄条可滚动
        midRight: _buildSideControlPanel(),
        // 底部中格 = 场景快切条
        bottomCenter: _buildScenarioBar(),
      ),
    );
  }

  // ============ 顶部 Tab ============
  Widget _buildTabBar() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x1F000000), blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: const Color(0xFF0F172A),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.blur_circular, size: 16),
                  SizedBox(width: 6),
                  Text('球面波俯视图'),
                ]),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.waves, size: 16),
                  SizedBox(width: 6),
                  Text('一维波形剖面图'),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ 主图区域（填满中间格 · 9 宫格保证面积 ≥ 70% 屏）============
  Widget _buildStageArea() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(child: _buildStageContent()),
          // 左上信息卡（频率 / 波长 / 波速 / 响度 · 四合一）
          Positioned(
            top: 12,
            left: 12,
            child: SoundInfoCard(
              frequencyHz: _state.frequency,
              wavelengthMeters: _wavelength,
              speedMetersPerSecond: _kSoundSpeed,
              loudnessPercent: _state.amplitude * 100,
            ),
          ),
          // 底部图例（不同 Tab 显示不同图例）
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: _tabController.index == 0
                  ? const SphericalLegend()
                  : const ProfileLegend(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageContent() {
    return IndexedStack(
      index: _tabController.index,
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: SphericalViewPainter(_state),
        ),
        CustomPaint(
          size: Size.infinite,
          painter: WaveformProfilePainter(_state),
        ),
      ],
    );
  }

  // ============ 频率 / 振幅 / 时钟控制（右侧边格 · 竖排紧凑）============
  Widget _buildSideControlPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: PropertyControlPanel(
        padding: const EdgeInsets.all(8),
        spacing: 12,
        children: [
          _compactSlider(
            icon: '\ud83d\udd0a',
            label: '频率 Frequency',
            value: _state.frequency,
            min: 0,
            max: 1000,
            divisions: 100,
            valueText: '${_state.frequency.round()} Hz',
            accent: const Color(0xFF0D9488),
            onChanged: (v) => setState(() => _state.setFrequency(v)),
          ),
          _compactSlider(
            icon: '\ud83d\udce2',
            label: '振幅 Amplitude',
            value: _state.amplitude,
            min: 0,
            max: 1,
            divisions: 20,
            valueText: _state.amplitude.toStringAsFixed(2),
            accent: const Color(0xFFEF4444),
            onChanged: (v) => setState(() => _state.setAmplitude(v)),
          ),
          const Divider(height: 12),
          Center(child: _timeControls()),
        ],
      ),
    );
  }

  Widget _compactSlider({
    required String icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueText,
    required Color accent,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text('$icon $label',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            ),
            Text(valueText,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: accent)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: accent,
          onChanged: onChanged,
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

  Widget _timeControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TimeControlBar(clock: _clock, showTimeDisplay: false),
      ],
    );
  }

  // ============ 场景快切按钮条 ============
  Widget _buildScenarioBar() {
    if (!_scenariosLoaded) {
      return const SizedBox(
          height: 40,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    // 场景 ID → (图标, 标签) 的展示映射（对齐视觉稿）
    const iconMap = <String, String>{
      'default': '\ud83c\udfb5',      // 🎵 音符
      'low-frequency': '\ud83e\udd41', // 🥁 大鼓（低频）
      'high-frequency': '\ud83c\udfbb', // 🎻 小提琴（高频）
      'loud-low': '\ud83c\udfb8',      // 🎸 低音吉他（低音大鼓）
      'silent': '\ud83d\udd07',        // 🔇 静音
    };
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _manager.scenarios.length,
        separatorBuilder: (_, i) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final SoundScenario s = _manager.scenarios[i];
          final bool selected = s.scenarioId == _currentScenarioId;
          return _scenarioChip(
            icon: iconMap[s.scenarioId] ?? '\ud83c\udfb6',
            label: s.name,
            selected: selected,
            onTap: () => setState(() => _applyScenario(s.scenarioId)),
          );
        },
      ),
    );
  }

  Widget _scenarioChip({
    required String icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  selected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF334155))),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgePanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: KnowledgePanel(
        title: 'Sound Wave Principles',
        titleIcon: '\ud83d\udd0a',
        titleColor: const Color(0xFF0D9488),
        sections: [
          KnowledgeSection.grid(items: const [
            KnowledgeItem(
                icon: '\u3030\ufe0f',
                title: 'Frequency',
                titleColor: Color(0xFF0F766E),
                desc:
                    'Number of vibrations per second (Hz). Higher frequency = higher pitch.'),
            KnowledgeItem(
                icon: '\ud83d\udcf6',
                title: 'Amplitude',
                titleColor: Color(0xFF0F766E),
                desc:
                    'Maximum displacement. Larger amplitude = louder sound.'),
            KnowledgeItem(
                icon: '\ud83c\udf0a',
                title: 'Wavelength',
                titleColor: Color(0xFF0EA5E9),
                desc: 'Distance between peaks. Wavelength = speed / frequency.'),
            KnowledgeItem(
                icon: '\ud83d\udcd0',
                title: 'Spherical Attenuation',
                titleColor: Color(0xFF8B5CF6),
                desc: 'Amplitude falls with distance from point source.'),
          ]),
        ],
      ),
    );
  }
}

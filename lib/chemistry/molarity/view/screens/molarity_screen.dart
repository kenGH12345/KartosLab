import 'package:flutter/material.dart';

import '../../../../common/widgets/experiment_logger.dart';
import '../../../../common/widgets/inquiry_drawer.dart';
import '../../../../common/widgets/nine_grid_layout.dart';
import '../../../../common/widgets/experiment_intro_panel.dart';
import '../../config/molarity_scenario.dart';
import '../../config/molarity_scenario_manager.dart';
import '../../controller/molarity_controller.dart';
import '../painters/beaker_painter.dart';
import '../painters/concentration_bar_painter.dart';
import '../painters/precipitate_painter.dart';
import '../painters/solution_painter.dart';
import '../widgets/amount_slider.dart';
import '../widgets/saturated_indicator.dart';
import '../widgets/solute_combo_box.dart';
import '../widgets/volume_slider.dart';

/// Molarity 主屏：NineGridLayout 组装（中间格 ≥70% 承载烧杯画面）。
class MolarityScreen extends StatefulWidget {
  const MolarityScreen({
    super.key,
    this.scenario,
    this.scenarioList = const [],
    this.manager,
  });

  /// 初始场景（App 路由注入 · null 时取场景池首个）。
  final MolarityScenario? scenario;
  final List<MolarityScenario> scenarioList;
  final MolarityScenarioManager? manager;

  @override
  State<MolarityScreen> createState() => _MolarityScreenState();
}

class _MolarityScreenState extends State<MolarityScreen> {
  late final MolarityController _controller;
  bool _loaded = false;
  bool _inquiryOpen = true; // 预测阶段默认展开：进入即见预测题（置顶），可手动收起

  MolarityScenario? get _scenario {
    final id = _controller.currentState?.scenarioId;
    if (id == null) return widget.scenario;
    return _controller.manager.findById(id);
  }

  @override
  void initState() {
    super.initState();
    _controller = MolarityController(
      manager: widget.manager ?? MolarityScenarioManager(),
    );
    _init();
  }

  Future<void> _init() async {
    await _controller.init(scenarioId: widget.scenario?.scenarioId);
    if (!mounted) return;
    setState(() => _loaded = true);
  }

  void _applyScenario(MolarityScenario s) {
    setState(() {
      _controller.loadScenario(s.scenarioId);
      // 有预测题则默认展开（预测阶段），无预测题收起
      _inquiryOpen = s.inquiryTask?.predictions.isNotEmpty ?? false;
    });
  }

  void _onShowValuesChanged(bool v) {
    setState(() => _controller.toggleValues(v));
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final state = _controller.state;
    final solution = state.solution;
    final scenario = _scenario;

    return Scaffold(
      appBar: AppBar(
        title: const Text('摩尔浓度'),
        backgroundColor: const Color(0xFFE8F6FB),
        foregroundColor: const Color(0xFF062A3A),
      ),
      body: Stack(
        children: [
          ListenableBuilder(
            listenable: solution,
            builder: (context, _) {
              return NineGridLayout(
                // 左上格：重置
                topLeft: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: IconButton(
                      tooltip: '重置',
                      onPressed: () => setState(_controller.reset),
                      icon: const Icon(Icons.restart_alt),
                    ),
                  ),
                ),
                // 顶部中格：场景标题 + 场景切换（FittedBox 防窄视口溢出）
                topCenter: Padding(
                  padding: const EdgeInsets.all(8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          scenario?.name ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (_controller.manager.scenarios.length > 1) ...[
                          const SizedBox(width: 8),
                          _buildScenarioMenu(),
                        ],
                      ],
                    ),
                  ),
                ),
                // 顶部右格：实验说明 + 操作指引（通用引导组件）
                topRight: ExperimentIntroPanel(
                  description: scenario?.description ?? '',
                  task: scenario?.inquiryTask,
                  color: const Color(0xFF0891B2),
                ),
                // 左格：探究入口（窄格放窄控件）
                midLeft: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: IconButton(
                      tooltip: '探究任务',
                      onPressed: () =>
                          setState(() => _inquiryOpen = !_inquiryOpen),
                      icon: const Icon(Icons.science_outlined),
                    ),
                  ),
                ),
                // 中间格：烧杯画面（面积 ≥70%）
                center: LayoutBuilder(
                  builder: (context, c) {
                    final beakerW = c.maxWidth * 0.72;
                    final beakerH = c.maxHeight * 0.86;
                    final maxVolume = scenario?.volumeRange.max ?? 1.0;
                    final fill = solution.volume / maxVolume;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: beakerW,
                          height: beakerH,
                          child: CustomPaint(
                            painter: BeakerPainter(volumeFraction: fill),
                          ),
                        ),
                        SizedBox(
                          width: beakerW * 0.88,
                          height: beakerH * 0.9,
                          child: CustomPaint(
                            painter: SolutionPainter(
                              color: solution.solutionColor,
                              fillFraction: fill,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: beakerW * 0.9,
                          height: beakerH * 0.4,
                          child: CustomPaint(
                            painter: PrecipitatePainter(
                              particleCount: solution.numberOfParticles,
                              color: solution.solute.particleColor,
                              particleSize: solution.solute.particleSize,
                            ),
                          ),
                        ),
                        Positioned(
                          top: beakerH * 0.06,
                          child: SaturatedIndicator(
                            visible: solution.isSaturated,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                // 底部横条：操作面板横排（浓度条 + 溶质 + 溶质量/体积滑块 · 对齐 PhET 底部控件条 · 窄视口横向滚动兜底）
                footer: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  // FittedBox scaleDown：矮视口 footer 高度不足时整体纵向缩放（R1 降级 · 不溢出）
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        // 浓度条（横置）
                        Semantics(
                          label:
                              '溶液浓度 ${solution.concentration.toStringAsFixed(2)} 摩尔每升'
                              '${solution.isSaturated ? '，溶液已饱和' : ''}',
                          child: SizedBox(
                            width: 150,
                            height: 64,
                            child: CustomPaint(
                              painter: ConcentrationBarPainter(
                                concentration: solution.concentration,
                                maxConcentration:
                                    scenario?.concentrationMax ?? 5.0,
                                color: solution.solutionColor,
                                showValue: state.valuesVisible,
                                isSaturated: solution.isSaturated,
                                orientation:
                                    ConcentrationBarOrientation.horizontal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // 溶质下拉
                        SizedBox(
                          width: 150,
                          child: SoluteComboBox(
                            state: state,
                            width: double.infinity,
                            onSelected: (s) => _controller.selectSolute(
                              state.solutes.indexOf(s),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // 溶质量滑块
                        SizedBox(
                          width: 200,
                          child: AmountSlider(
                            value: solution.soluteAmount,
                            range:
                                scenario?.soluteAmountRange ??
                                const ParamRange(
                                  min: 0,
                                  max: 1,
                                  step: 0.01,
                                  unit: 'mol',
                                ),
                            onChanged: _controller.setSoluteAmount,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // 体积滑块
                        SizedBox(
                          width: 200,
                          child: VolumeSlider(
                            value: solution.volume,
                            range:
                                scenario?.volumeRange ??
                                const ParamRange(
                                  min: 0.2,
                                  max: 1,
                                  step: 0.01,
                                  unit: 'L',
                                ),
                            onChanged: _controller.setVolume,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 左下格：显示数值开关
                bottomLeft: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: IconButton(
                      tooltip: state.valuesVisible ? '隐藏数值' : '显示数值',
                      onPressed: () =>
                          _onShowValuesChanged(!state.valuesVisible),
                      icon: const Icon(Icons.numbers),
                    ),
                  ),
                ),
              );
            },
          ),
          // 探究抽屉（常驻 · Offstage 保持状态）
          InquiryDrawer(
            task: scenario?.inquiryTask,
            columns: _inquiryColumns(scenario),
            snapshotProvider: _snapshot,
            open: _inquiryOpen,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _snapshot() {
    final s = _controller.state.solution;
    return {
      'soluteAmount': s.soluteAmount,
      'volume': s.volume,
      'concentration': s.concentration,
      'precipitate': s.precipitateAmount,
    };
  }

  List<ColumnDef> _inquiryColumns(MolarityScenario? scenario) {
    final cols = scenario?.inquiryTask?.snapshotColumns ?? const [];
    return cols
        .map(
          (c) => ColumnDef(
            key: c.key,
            label: c.label,
            isParam: c.source == 'param',
          ),
        )
        .toList(growable: false);
  }

  Widget _buildScenarioMenu() {
    return PopupMenuButton<MolarityScenario>(
      tooltip: '切换场景',
      onSelected: _applyScenario,
      itemBuilder: (_) => _controller.manager.scenarios
          .map((s) => PopupMenuItem(value: s, child: Text(s.name)))
          .toList(growable: false),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '切换场景',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF64748B)),
        ],
      ),
    );
  }
}

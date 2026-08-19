import 'package:flutter/material.dart';
import '../../common/simulation_clock.dart';
import '../../common/widgets/time_control_bar.dart';
import '../../common/widgets/knowledge_panel.dart';
import '../../common/widgets/nine_grid_layout.dart';
import '../../common/widgets/experiment_intro_panel.dart';
import '../../common/widgets/inquiry_models.dart';
import '../../common/widgets/inquiry_drawer.dart';
import '../../common/widgets/experiment_logger.dart';
import '../../common/controls/spectrum_slider.dart';
import '../model/filter.dart';
import '../model/single_bulb_state.dart';
import '../solver/photon_beam.dart';
import '../solver/color_model.dart';
import '../painters/single_bulb_painter.dart';
import '../config/color_vision_scenario.dart';

class SingleBulbScreen extends StatefulWidget {
  const SingleBulbScreen({super.key, this.scenario});
  final ColorVisionScenario? scenario;
  @override
  State<SingleBulbScreen> createState() => _SingleBulbScreenState();
}

class _SingleBulbScreenState extends State<SingleBulbScreen>
    with TickerProviderStateMixin {
  late final SingleBulbState _state;
  late final SimulationClock _clock;
  FilterType _filterType = FilterType.none;
  BulbMode _bulbMode = BulbMode.white;
  double _bulbWavelength = 550;
  bool _inquiryOpen = false;

  @override
  void initState() {
    super.initState();
    final s = widget.scenario;
    // 有 inquiryTask 即默认展开（做中学进入即见任务 · task==null 时抽屉不渲染）
    _inquiryOpen = s?.inquiryTask != null;

    final filterType = _parseFilterType(s?.filterType ?? 'none');

    final beam = PhotonBeam(
      color: const Color(0xFFFFFFFF),
      originX: 50,
      originY: 190,
      maxDistance: 400,
    );
    beam.setIntensity(100);

    _state = SingleBulbState(
      beam: beam,
      filter: Filter(type: filterType),
      filterX: 200,
      personPosition: s?.personPosition ?? 320,
      bulbMode: BulbMode.white,
      bulbWavelength: 550,
    );

    _filterType = filterType;

    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, t) {
      _state.stepInTime(dt);
      setState(() {});
    };
    _clock.play();
  }

  FilterType _parseFilterType(String s) {
    switch (s) {
      case 'red':
        return FilterType.red;
      case 'green':
        return FilterType.green;
      case 'blue':
        return FilterType.blue;
      case 'custom':
        return FilterType.custom;
      default:
        return FilterType.none;
    }
  }

  @override
  void dispose() {
    _state.dispose();
    _clock.dispose();
    super.dispose();
  }

  void _setFilter(FilterType ft) {
    setState(() {
      _filterType = ft;
      _state.setFilter(Filter(type: ft));
    });
  }

  void _setBulbMode(BulbMode mode) {
    setState(() {
      _bulbMode = mode;
      _state.setBulbMode(mode);
    });
  }

  void _setWavelength(double nm) {
    setState(() {
      _bulbWavelength = nm;
      _state.setBulbWavelength(nm);
    });
  }

  Color _perceivedColor() {
    if (_filterType == FilterType.none) {
      if (_bulbMode == BulbMode.mono) return _state.bulbColor;
      return ColorModel.mixRGB(100, 100, 100);
    }
    if (_bulbMode == BulbMode.mono) {
      // Mono source through filter — apply pass rates to source color
      final (pr, pg, pb) = _state.filter.passRates;
      final sc = _state.bulbColor;
      return Color.fromARGB(
        255,
        ((sc.r * 255.0).round() * pr).round().clamp(0, 255),
        ((sc.g * 255.0).round() * pg).round().clamp(0, 255),
        ((sc.b * 255.0).round() * pb).round().clamp(0, 255),
      );
    }
    final (pr, pg, pb) = _state.filter.passRates;
    return Color.fromARGB(
      255,
      (255 * pr).round(),
      (255 * pg).round(),
      (255 * pb).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perceived = _perceivedColor();
    return Stack(
      children: [
        NineGridLayout(
          // 顶部中格 = 实验说明 + 操作指引（通用引导组件）
          topCenter: ExperimentIntroPanel(
            description: widget.scenario?.description ?? '',
            task: widget.scenario?.inquiryTask,
            color: const Color(0xFF7C3AED),
          ),
          // 顶部右格 = 探究抽屉入口按钮（无 inquiryTask 不渲染）
          topRight: _buildInquiryEntryButton(),
          // 中间格 = 主实验画面 · 面积 ≥ 70% 屏 · 自适应
          center: CustomPaint(
            size: Size.infinite,
            painter: SingleBulbPainter(_state),
          ),
          // 右侧边格 = 竖排紧凑控制面板 · 窄条可滚动
          // 底部横条：操作面板横排（molarity footer 方案推广 · midRight 竖排在 130px 窄格有 90px 溢出，
          // 横排 footer 在宽视口无溢出）
          footer: _buildFooterControls(perceived),
          // 右下边格 = 知识点入口（知识卡过长 · 改为弹窗）
          bottomRight: Center(
            child: IconButton(
              icon: const Icon(Icons.menu_book_outlined, size: 22),
              tooltip: '知识点',
              onPressed: _showKnowledgeDialog,
            ),
          ),
        ),
        // 探究工作流抽屉（Offstage 保持记录/结论 State · 无 inquiryTask 不渲染）
        InquiryDrawer(
          task: _inquiryTask,
          columns: _inquiryTask != null
              ? _inquiryColumns(_inquiryTask!)
              : const [],
          snapshotProvider: _singleBulbSnapshot,
          open: _inquiryOpen,
        ),
      ],
    );
  }

  /// 当前 scenario 的探究任务（无 inquiryTask 时为 null → 抽屉不渲染）。
  InquiryTask? get _inquiryTask => widget.scenario?.inquiryTask;

  /// 探究抽屉入口按钮（仅在有 inquiryTask 的 scenario 显示）。
  Widget _buildInquiryEntryButton() {
    final task = _inquiryTask;
    if (task == null) return const SizedBox.shrink();
    return Center(
      child: IconButton.filledTonal(
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.science_outlined, size: 20),
        tooltip: '探究任务',
        onPressed: () => setState(() => _inquiryOpen = !_inquiryOpen),
      ),
    );
  }

  /// single_bulb 快照：光源/波长/滤光片（param）+ 看到颜色（reading）。
  Map<String, dynamic> _singleBulbSnapshot() {
    final perceived = _perceivedColor();
    return {
      'bulbMode': _bulbMode == BulbMode.white ? '白光' : '单色光',
      'wavelength':
          _bulbMode == BulbMode.mono ? _bulbWavelength.round() : '—',
      'filter': _ftLabel(_filterType),
      'perceivedColor': ColorModel.colorName(perceived),
    };
  }

  List<ColumnDef> _inquiryColumns(InquiryTask task) {
    if (task.snapshotColumns.isEmpty) {
      return const [
        ColumnDef(key: 'bulbMode', label: '光源', isParam: true),
        ColumnDef(key: 'wavelength', label: '波长(nm)', isParam: true),
        ColumnDef(key: 'filter', label: '滤光片', isParam: true),
        ColumnDef(key: 'perceivedColor', label: '看到颜色'),
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
  /// 底部横排操作面板：光源/滤光片选择 + 波长滑块 + 看到颜色 + 时间控制
  /// （molarity footer 方案推广 · 横向滚动兜底窄视口 · 不用 FittedBox 避免 Slider 类无界问题）。
  Widget _buildFooterControls(Color perceived) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 190,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('光源',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ChoiceChip(
                      label: const Text('白光', style: TextStyle(fontSize: 10)),
                      selected: _bulbMode == BulbMode.white,
                      onSelected: (_) => _setBulbMode(BulbMode.white),
                      selectedColor: const Color(0xFFE2E8F0),
                      visualDensity: VisualDensity.compact,
                    ),
                    ChoiceChip(
                      label: const Text('单色', style: TextStyle(fontSize: 10)),
                      selected: _bulbMode == BulbMode.mono,
                      onSelected: (_) => _setBulbMode(BulbMode.mono),
                      selectedColor: _state.bulbColor.withAlpha(40),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_bulbMode == BulbMode.mono) ...[
            const SizedBox(width: 14),
            SizedBox(
              width: 280,
              child: SpectrumSlider(
                wavelength: _bulbWavelength,
                onChanged: _setWavelength,
                step: 5,
              ),
            ),
          ],
          const SizedBox(width: 14),
          SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('滤光片',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                // chips 横向滚动单行：避免 Wrap 换行抬高 Column 超出 footer 高度（16px 溢出修复）
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: FilterType.values
                        .map(
                          (ft) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(
                                _ftLabel(ft),
                                style: const TextStyle(fontSize: 10),
                              ),
                              selected: _filterType == ft,
                              onSelected: (_) => _setFilter(ft),
                              selectedColor: _ftColor(ft).withAlpha(40),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: perceived,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '看到颜色：${ColorModel.colorName(perceived)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          TimeControlBar(clock: _clock),
        ],
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

  String _ftLabel(FilterType ft) {
    switch (ft) {
      case FilterType.none:
        return '无';
      case FilterType.red:
        return '红色';
      case FilterType.green:
        return '绿色';
      case FilterType.blue:
        return '蓝色';
      case FilterType.custom:
        return '自定义';
    }
  }

  Color _ftColor(FilterType ft) {
    switch (ft) {
      case FilterType.none:
        return const Color(0xFF94A3B8);
      case FilterType.red:
        return const Color(0xFFFF0000);
      case FilterType.green:
        return const Color(0xFF00FF00);
      case FilterType.blue:
        return const Color(0xFF0000FF);
      case FilterType.custom:
        return const Color(0xFFA855F7);
    }
  }

  // ---- 颜色过滤原理 + 知识点 (通过 KnowledgePanel L0 组件展示) ----
  Widget _buildKnowledgePanel() {
    return KnowledgePanel(
      title: '颜色过滤原理',
      titleIcon: '💡',
      titleColor: const Color(0xFFF59E0B),
      sections: [
        KnowledgeSection.grid(
          items: [
            KnowledgeItem(
              dot: const Color(0xFFEF4444),
              title: '红色滤光片',
              titleColor: const Color(0xFFEF4444),
              desc: '吸收绿光和蓝光,只允许红光通过。白光透过后呈红色。',
              active: _filterType == FilterType.red,
            ),
            KnowledgeItem(
              dot: const Color(0xFF22C55E),
              title: '绿色滤光片',
              titleColor: const Color(0xFF22C55E),
              desc: '吸收红光和蓝光,只允许绿光通过。白光透过后呈绿色。',
              active: _filterType == FilterType.green,
            ),
            KnowledgeItem(
              dot: const Color(0xFF3B82F6),
              title: '蓝色滤光片',
              titleColor: const Color(0xFF3B82F6),
              desc: '吸收红光和绿光,只允许蓝光通过。白光透过后呈蓝色。',
              active: _filterType == FilterType.blue,
            ),
            const KnowledgeItem(
              icon: '🧅',
              title: '叠加效应',
              titleColor: Color(0xFFA855F7),
              desc: '多层滤光片叠加时,只有全部允许通过的颜色才能穿过。例如红+绿=黑(无光通过)。',
            ),
          ],
        ),
        KnowledgeSection.list(
          subtitle: '知识点',
          subtitleIcon: '📚',
          subtitleColor: const Color(0xFF60A5FA),
          items: const [
            KnowledgeItem(
              icon: '➖',
              title: '减色法原理',
              titleColor: Color(0xFFF59E0B),
              desc:
                  '滤光片的颜色混合属于"减色法"：物体(或滤光片)吸收某些波长的光,反射/透射其余波长的光。'
                  '与光源直接发光的"加色法"(如显示器RGB)相反——加色越混越亮,减色越混越暗。',
            ),
            KnowledgeItem(
              icon: '🎯',
              title: '选择性吸收',
              titleColor: Color(0xFF22C55E),
              desc:
                  '滤光片含有特定颜料或染料分子,其电子能级只能吸收特定波长范围的光子能量。'
                  '例如红色滤光片的分子吸收蓝紫光和绿光光子,只让红光光子通过——这就是"选择性吸收"的量子力学本质。',
            ),
            KnowledgeItem(
              icon: '🆚',
              title: '加色法 vs 减色法 · 生活对照',
              titleColor: Color(0xFF8B5CF6),
              desc:
                  '加色法(光源): 红+绿=黄(手机/电视屏幕)。减色法(滤光/颜料): 黄颜料吸收蓝光,反射红绿→你看到黄色。'
                  '这就是为什么打印用CMYK(青/品红/黄/黑)而非RGB——纸张上做的是减色混合。',
            ),
          ],
        ),
      ],
    );
  }
}

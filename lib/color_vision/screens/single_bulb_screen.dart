import 'package:flutter/material.dart';
import '../../common/simulation_clock.dart';
import '../../common/widgets/time_control_bar.dart';
import '../../common/widgets/property_control_panel.dart';
import '../../common/widgets/knowledge_panel.dart';
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
  @override State<SingleBulbScreen> createState() => _SingleBulbScreenState();
}

class _SingleBulbScreenState extends State<SingleBulbScreen>
    with TickerProviderStateMixin {
  late final SingleBulbState _state;
  late final SimulationClock _clock;
  FilterType _filterType = FilterType.none;
  BulbMode _bulbMode = BulbMode.white;
  double _bulbWavelength = 550;

  @override
  void initState() {
    super.initState();
    final s = widget.scenario;

    final filterType = _parseFilterType(s?.filterType ?? 'none');

    final beam = PhotonBeam(
      color: const Color(0xFFFFFFFF),
      originX: 50, originY: 190,
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
      case 'red': return FilterType.red;
      case 'green': return FilterType.green;
      case 'blue': return FilterType.blue;
      case 'custom': return FilterType.custom;
      default: return FilterType.none;
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
      return Color.fromARGB(255,
        ((sc.r * 255.0).round() * pr).round().clamp(0, 255),
        ((sc.g * 255.0).round() * pg).round().clamp(0, 255),
        ((sc.b * 255.0).round() * pb).round().clamp(0, 255),
      );
    }
    final (pr, pg, pb) = _state.filter.passRates;
    return Color.fromARGB(255, (255 * pr).round(), (255 * pg).round(), (255 * pb).round());
  }

  @override
  Widget build(BuildContext context) {
    final perceived = _perceivedColor();
    return Column(children: [
      Expanded(
        flex: 5,
        child: CustomPaint(
          size: Size.infinite,
          painter: SingleBulbPainter(_state),
        ),
      ),
      // 颜色过滤原理 + 知识点 (使用 L0 公共 KnowledgePanel)
      // Layout fix (req-color-vision-layout-fix v1.1 方案B):
      // 用 Expanded(flex:3) + SingleChildScrollView 约束知识面板高度,
      // 防止 KnowledgeItem.active 高亮时撑高吃掉主图空间 (L0-2/L0-3 违规)。
      Expanded(
        flex: 3,
        child: SingleChildScrollView(
          child: _buildKnowledgePanel(),
        ),
      ),
      PropertyControlPanel(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        spacing: 6,
        children: [
          // Bulb mode toggle
          Row(children: [
            const Text('Source:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('White', style: TextStyle(fontSize: 10)),
              selected: _bulbMode == BulbMode.white,
              onSelected: (_) => _setBulbMode(BulbMode.white),
              selectedColor: const Color(0xFFE2E8F0),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            ChoiceChip(
              label: const Text('Mono', style: TextStyle(fontSize: 10)),
              selected: _bulbMode == BulbMode.mono,
              onSelected: (_) => _setBulbMode(BulbMode.mono),
              selectedColor: _state.bulbColor.withAlpha(40),
              visualDensity: VisualDensity.compact,
            ),
          ]),
          // SpectrumSlider (visible in mono mode)
          if (_bulbMode == BulbMode.mono)
            SpectrumSlider(
              wavelength: _bulbWavelength,
              onChanged: _setWavelength,
              step: 5,
            ),
          // Filter selector
          Row(children: [
            const Text('Filter:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: FilterType.values.map((ft) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ChoiceChip(
                    label: Text(_ftLabel(ft), style: const TextStyle(fontSize: 10)),
                    selected: _filterType == ft,
                    onSelected: (_) => _setFilter(ft),
                    selectedColor: _ftColor(ft).withAlpha(40),
                    visualDensity: VisualDensity.compact,
                  ),
                )).toList()),
              ),
            ),
          ]),
          // Perceived color
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: perceived,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Person sees: ${ColorModel.colorName(perceived)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ]),
          TimeControlBar(clock: _clock),
        ],
      ),
    ]);
  }

  String _ftLabel(FilterType ft) {
    switch (ft) {
      case FilterType.none: return 'None';
      case FilterType.red: return 'Red';
      case FilterType.green: return 'Green';
      case FilterType.blue: return 'Blue';
      case FilterType.custom: return 'Custom';
    }
  }

  Color _ftColor(FilterType ft) {
    switch (ft) {
      case FilterType.none: return const Color(0xFF94A3B8);
      case FilterType.red: return const Color(0xFFFF0000);
      case FilterType.green: return const Color(0xFF00FF00);
      case FilterType.blue: return const Color(0xFF0000FF);
      case FilterType.custom: return const Color(0xFFA855F7);
    }
  }

  // ---- 颜色过滤原理 + 知识点 (通过 KnowledgePanel L0 组件展示) ----
  Widget _buildKnowledgePanel() {
    return KnowledgePanel(
      title: '颜色过滤原理',
      titleIcon: '💡',
      titleColor: const Color(0xFFF59E0B),
      sections: [
        KnowledgeSection.grid(items: [
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
        ]),
        KnowledgeSection.list(
          subtitle: '知识点',
          subtitleIcon: '📚',
          subtitleColor: const Color(0xFF60A5FA),
          items: const [
            KnowledgeItem(
              icon: '➖',
              title: '减色法原理 (Subtractive Mixing)',
              titleColor: Color(0xFFF59E0B),
              desc: '滤光片的颜色混合属于"减色法"：物体(或滤光片)吸收某些波长的光,反射/透射其余波长的光。'
                  '与光源直接发光的"加色法"(如显示器RGB)相反——加色越混越亮,减色越混越暗。',
            ),
            KnowledgeItem(
              icon: '🎯',
              title: '选择性吸收 (Selective Absorption)',
              titleColor: Color(0xFF22C55E),
              desc: '滤光片含有特定颜料或染料分子,其电子能级只能吸收特定波长范围的光子能量。'
                  '例如红色滤光片的分子吸收蓝紫光和绿光光子,只让红光光子通过——这就是"选择性吸收"的量子力学本质。',
            ),
            KnowledgeItem(
              icon: '🆚',
              title: '加色法 vs 减色法 · 生活对照',
              titleColor: Color(0xFF8B5CF6),
              desc: '加色法(光源): 红+绿=黄(手机/电视屏幕)。减色法(滤光/颜料): 黄颜料吸收蓝光,反射红绿→你看到黄色。'
                  '这就是为什么打印用CMYK(青/品红/黄/黑)而非RGB——纸张上做的是减色混合。',
            ),
          ],
        ),
      ],
    );
  }
}

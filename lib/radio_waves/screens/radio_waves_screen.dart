import 'package:flutter/material.dart';
import '../../common/simulation_clock.dart';
import '../../common/widgets/time_control_bar.dart';
import '../../common/widgets/property_control_panel.dart';
import '../../common/widgets/knowledge_panel.dart';
import '../../common/widgets/scenario_menu_button.dart';
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
        title: const Text('Radio Waves', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        toolbarHeight: 44,
        actions: [_buildScenarioMenu()],
      ),
      body: Column(children: [
        Expanded(
          flex: 5,
          child: CustomPaint(
            size: Size.infinite,
            painter: FieldPainter(_state),
          ),
        ),
        _buildKnowledgePanel(),
        PropertyControlPanel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          spacing: 4,
          children: [
            // Frequency
            Row(children: [
              const Text('Frequency:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Text('${_state.frequency.toStringAsFixed(2)} Hz',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
            ]),
            Slider(
              value: _state.frequency, min: 0.05, max: 2.0, divisions: 39,
              activeColor: const Color(0xFF7C3AED),
              onChanged: (v) => setState(() => _state.setFrequency(v)),
            ),
            // Amplitude
            Row(children: [
              const Text('Amplitude:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Text(_state.amplitude.toStringAsFixed(2),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
            ]),
            Slider(
              value: _state.amplitude, min: 0, max: 1, divisions: 20,
              activeColor: const Color(0xFF7C3AED),
              onChanged: (v) => setState(() => _state.setAmplitude(v)),
            ),
            // Toggles
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              FilterChip(label: const Text('Curve', style: TextStyle(fontSize: 11)),
                selected: _state.showCurve, selectedColor: const Color(0xFFDC2626).withAlpha(40),
                onSelected: (_) => setState(() => _state.toggleCurve())),
              FilterChip(label: const Text('Arrows', style: TextStyle(fontSize: 11)),
                selected: _state.showArrows, selectedColor: const Color(0xFF22C55E).withAlpha(40),
                onSelected: (_) => setState(() => _state.toggleArrows())),
              FilterChip(label: const Text('Dynamic', style: TextStyle(fontSize: 11)),
                selected: _state.dynamicFieldEnabled, selectedColor: const Color(0xFF7C3AED).withAlpha(40),
                onSelected: (_) => setState(() => _state.toggleDynamicField())),
            ]),
            TimeControlBar(clock: _clock),
          ],
        ),
      ]),
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
      title: 'Electromagnetic Wave Principles',
      titleIcon: '\ud83d\udcfb',
      titleColor: const Color(0xFF7C3AED),
      sections: [
        KnowledgeSection.grid(items: const [
          KnowledgeItem(icon: '\u26a1', title: 'Oscillating Electron', titleColor: Color(0xFF3B82F6),
            desc: 'An electron oscillating on the antenna creates a changing electric field that propagates outward as an electromagnetic wave.'),
          KnowledgeItem(icon: '\ud83c\udf00', title: 'Retarded Field', titleColor: Color(0xFF22C55E),
            desc: 'Field at distance d lags by d/c (light travel time). What you see far away is what the electron was doing in the past.'),
          KnowledgeItem(icon: '\ud83d\udcc8', title: 'Acceleration = Radiation', titleColor: Color(0xFFDC2626),
            desc: 'Only accelerating charges radiate EM waves. Steady velocity produces static field only; acceleration produces propagating waves.'),
          KnowledgeItem(icon: '\ud83d\udce1', title: 'Antenna Physics', titleColor: Color(0xFFF59E0B),
            desc: 'Radio antennas work by driving electrons to oscillate. The oscillating charge radiates EM waves at the same frequency.'),
        ]),
        KnowledgeSection.list(
          subtitle: 'Key Concepts', subtitleIcon: '\ud83d\udcda', subtitleColor: const Color(0xFF60A5FA),
          items: const [
            KnowledgeItem(icon: '\ud83d\udc49', title: 'How Radio Transmission Works',
              titleColor: Color(0xFFF59E0B),
              desc: '1) Transmitter circuit drives electrons up and down an antenna at a chosen frequency. 2) Accelerating electrons create changing electric and magnetic fields. 3) These fields propagate outward at the speed of light. 4) A receiving antenna picks up the oscillating field, inducing a tiny current. This is how all wireless communication works -- from AM/FM radio to WiFi to 5G.'),
            KnowledgeItem(icon: '\ud83d\udd0d', title: 'Static vs Dynamic Field',
              titleColor: Color(0xFF22C55E),
              desc: 'Static field (Coulomb): falls off as 1/r^2, always points toward/away from the charge. Dynamic field (radiation): falls off as 1/r, propagates as a wave. At large distances, only the dynamic field matters -- this is why radio signals travel far.'),
            KnowledgeItem(icon: '\ud83c\udf0d', title: 'Speed of Light Connection',
              titleColor: Color(0xFF3B82F6),
              desc: 'EM waves travel at the speed of light (c = 3 x 10^8 m/s). The retardation effect in this simulation shows that the field at a distant point reflects what the electron was doing d/c seconds ago. This is the same principle behind the light from distant stars showing us the past.'),
            KnowledgeItem(icon: '\ud83d\udcfb', title: 'AM vs FM Radio',
              titleColor: Color(0xFFA855F7),
              desc: 'AM (Amplitude Modulation): encodes sound by varying wave amplitude. FM (Frequency Modulation): encodes sound by varying wave frequency. Both use the same underlying physics -- an oscillating electron in the transmitter antenna -- but modulate different properties of the carrier wave.'),
          ],
        ),
      ],
    );
  }
}
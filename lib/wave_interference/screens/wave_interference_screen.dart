import 'dart:math';
import 'package:flutter/material.dart';
import '../../common/simulation_clock.dart';
import '../../common/widgets/time_control_bar.dart';
import '../../common/widgets/property_control_panel.dart';
import '../../common/widgets/knowledge_panel.dart';
import '../../common/widgets/scenario_menu_button.dart';
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
  final WaveInterferenceScenarioManager _manager = WaveInterferenceScenarioManager();
  String _currentScenarioId = 'default';
  bool _scenariosLoaded = false;

  double _frequency = 0.4;
  double _amplitude = 1.5;
  final int _oscRadius = 2;
  WaveType _waveType = WaveType.water;
  BarrierMode _barrierMode = BarrierMode.doubleSlit;
  final int _barrierX = 35;
  int _slitSize = 10;
  int _slitSeparation = 24;

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
    // Drive oscillator source
    double val = _amplitude * cos(2 * pi * _frequency * _engine.time);
    _engine.setSource(8, gridH ~/ 2, _oscRadius, val);
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
  void _setSlitSize(double v) { _slitSize = v.round(); _rebuildBarriers(); setState(() {}); }
  void _setSlitSep(double v) { _slitSeparation = v.round(); _rebuildBarriers(); setState(() {}); }
  void _setBarrierMode(BarrierMode m) { _barrierMode = m; _rebuildBarriers(); setState(() {}); }
  void _setWaveType(WaveType t) => setState(() => _waveType = t);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wave Interference', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        toolbarHeight: 44,
        actions: [_buildScenarioMenu()],
      ),
      body: Column(children: [
        Expanded(flex: 5, child: CustomPaint(
          size: Size.infinite,
          painter: WaveHeatmapPainter(_engine,
            gridW: gridW, gridH: gridH, waveType: _waveType),
        )),
        _buildKnowledgePanel(),
        PropertyControlPanel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          spacing: 3,
          children: [
            // Wave type selector
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _waveTypeChip(WaveType.water, '🌊 Water'),
              const SizedBox(width: 4),
              _waveTypeChip(WaveType.light, '💡 Light'),
              const SizedBox(width: 4),
              _waveTypeChip(WaveType.sound, '🔊 Sound'),
            ]),
            const SizedBox(height: 2),
            // Barrier mode selector
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _barrierModeChip(BarrierMode.none, 'No Barrier'),
              const SizedBox(width: 4),
              _barrierModeChip(BarrierMode.singleSlit, 'Single Slit'),
              const SizedBox(width: 4),
              _barrierModeChip(BarrierMode.doubleSlit, 'Double Slit'),
            ]),
            Row(children: [
              const Text('Frequency:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              Text((_frequency * 10).toStringAsFixed(2), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
            ]),
            Slider(value: _frequency, min: 0.1, max: 1.0, divisions: 18, activeColor: const Color(0xFF2563EB), onChanged: _setFrequency),
            Row(children: [
              const Text('Amplitude:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              Text(_amplitude.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
            ]),
            Slider(value: _amplitude, min: 0.2, max: 3.0, divisions: 28, activeColor: const Color(0xFF2563EB), onChanged: _setAmplitude),
            if (_barrierMode != BarrierMode.none) ...[
              Row(children: [
                const Text('Slit Size:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(width: 6), Text('$_slitSize', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                if (_barrierMode == BarrierMode.doubleSlit) ...[
                  const SizedBox(width: 12),
                  const Text('Separation:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 6), Text('$_slitSeparation', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                ],
              ]),
              Row(children: [
                Expanded(child: Slider(value: _slitSize.toDouble(), min: 4, max: 20, divisions: 16, activeColor: const Color(0xFF2563EB), onChanged: _setSlitSize)),
                if (_barrierMode == BarrierMode.doubleSlit) ...[
                  const SizedBox(width: 8),
                  Expanded(child: Slider(value: _slitSeparation.toDouble(), min: 12, max: 36, divisions: 24, activeColor: const Color(0xFF2563EB), onChanged: _setSlitSep)),
                ],
              ]),
            ],
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              FilterChip(label: const Text('Reset Wave', style: TextStyle(fontSize: 11)), selected: false, onSelected: (_) { _engine.reset(); setState(() {}); }),
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
          .map((WaveInterferenceScenario s) => ScenarioMenuEntry(id: s.scenarioId, name: s.name))
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
      title: 'Wave Interference Principles',
      titleIcon: '\ud83c\udf0a',
      titleColor: const Color(0xFF2563EB),
      sections: [
        KnowledgeSection.grid(items: const [
          KnowledgeItem(icon: '\ud83d\udca7', title: 'Wave Source', titleColor: Color(0xFF2563EB), desc: 'An oscillator creates circular ripples that spread outward, like dropping a pebble in water.'),
          KnowledgeItem(icon: '\ud83d\udcd0', title: 'Double Slit', titleColor: Color(0xFF0891B2), desc: 'When waves pass through two slits, they emerge as two new circular sources. These sources interfere constructively and destructively.'),
          KnowledgeItem(icon: '\u2795', title: 'Constructive Interference', titleColor: Color(0xFF16A34A), desc: 'Peak meets peak or trough meets trough: amplitudes add up for brighter bands.'),
          KnowledgeItem(icon: '\u2796', title: 'Destructive Interference', titleColor: Color(0xFFDC2626), desc: 'Peak meets trough: they cancel out for dark bands.'),
        ]),
        KnowledgeSection.list(subtitle: 'Key Concepts', subtitleIcon: '\ud83d\udcda', subtitleColor: const Color(0xFF60A5FA), items: const [
          KnowledgeItem(icon: '\ud83c\udf0a', title: 'Water Wave Interference (Young Double-Slit)', titleColor: Color(0xFF2563EB), desc: 'Thomas Young first demonstrated the wave nature of light in 1801. Here we see the same principle with water waves: two coherent sources create an interference pattern of alternating bright and dark bands radiating outward.'),
          KnowledgeItem(icon: '\ud83d\udcd0', title: 'The Double-Slit Equation', titleColor: Color(0xFF0891B2), desc: 'Bright fringes occur at angles where d sin(theta) = n * lambda, where d = slit separation, lambda = wavelength, n = 0, 1, 2... Adjust the separation slider to see how wider slit spacing creates more closely spaced interference fringes.'),
          KnowledgeItem(icon: '\ud83d\udd0d', title: 'Wavelength and Frequency', titleColor: Color(0xFF22C55E), desc: 'Higher frequency -> shorter wavelength -> closer interference fringes. The wave speed (c) is fixed by the simulation''s c^2=0.25 parameter, so lambda is inversely proportional to frequency.'),
          KnowledgeItem(icon: '\ud83d\udd2c', title: 'FDTD Wave Equation', titleColor: Color(0xFFA855F7), desc: 'This simulation solves the 2D wave equation using a finite-difference time-domain (FDTD) method. Each grid cell''s value is updated based on its neighbors. Absorbing boundaries on all edges prevent wave reflections.'),
        ]),
      ],
    );
  }
}
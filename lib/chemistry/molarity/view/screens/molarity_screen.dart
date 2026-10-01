import 'package:flutter/material.dart';

import '../../../../common/widgets/experiment_logger.dart';
import '../../../../common/widgets/inquiry_drawer.dart';
import '../../../../common/widgets/scenario_menu_button.dart';
import '../../audio/molarity_audio.dart';
import '../../config/molarity_scenario.dart';
import '../../config/molarity_scenario_manager.dart';
import '../../controller/molarity_controller.dart';
import '../molarity_layout.dart';
import '../widgets/molarity_play_area.dart';

/// Molarity standalone screen — PhET `MolarityScreenView` geometry (1100×700).
///
/// Source interactions only: solute/volume VerticalSliders · Solute ComboBox ·
/// Solution Values checkbox · Reset All.
///
/// **ABSENT (not in PhET Molarity):** Shaker, Dropper, Probe, Faucet, Drain,
/// Evaporation, Remove Solute, solute-bottle / faucet drag affordances.
///
/// No physics `Timer` / `Ticker` / `step(dt)` — Property → View only.
class MolarityScreen extends StatefulWidget {
  const MolarityScreen({
    super.key,
    this.scenario,
    this.scenarioList = const [],
    this.manager,
    this.audio,
  });

  final MolarityScenario? scenario;
  final List<MolarityScenario> scenarioList;
  final MolarityScenarioManager? manager;

  /// Injected for tests ([RecordingMolarityAudio]); production uses
  /// [MolarityAudioPlayer] when null (unless [debugTestAudio] is set).
  final MolarityAudio? audio;

  /// Widget-test override so Home → Molarity does not construct platform
  /// [AudioPlayer] (MissingPluginException). Cleared in tearDown by tests.
  static MolarityAudio? debugTestAudio;

  @override
  State<MolarityScreen> createState() => _MolarityScreenState();
}

class _MolarityScreenState extends State<MolarityScreen> {
  late final MolarityController _controller;
  bool _loaded = false;
  bool _inquiryOpen = false;

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
      audio:
          widget.audio ??
          MolarityScreen.debugTestAudio ??
          MolarityAudioPlayer(),
    );
    _init();
  }

  Future<void> _init() async {
    await _controller.init(scenarioId: widget.scenario?.scenarioId);
    if (!mounted) return;
    final s = _scenario;
    setState(() {
      _loaded = true;
      // Inquiry is KartosLab chrome — default closed so PhET play area is primary.
      _inquiryOpen = false;
      if (s?.inquiryTask?.predictions.isNotEmpty ?? false) {
        // Keep closed on cold start for visual fidelity; user opens via chip.
        _inquiryOpen = false;
      }
    });
  }

  void _applyScenario(MolarityScenario s) {
    setState(() {
      _controller.loadScenario(s.scenarioId);
      _inquiryOpen = false;
    });
  }

  @override
  void dispose() {
    // Fire-and-forget: platform AudioPlayer.dispose must not block widget teardown.
    final pending = _controller.disposeAudio();
    pending.ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const ColoredBox(
        color: MolarityLayout.background,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final state = _controller.state;
    final solution = state.solution;
    final scenario = _scenario;

    // SizedBox.expand: Home Scaffold body gives loose constraints; a Stack with
    // only Positioned children otherwise collapses to 0×0 (FittedBox scale →
    // NaN hit-tests). Phase 2 tests masked this by wrapping in tight SizedBox.
    return Material(
      color: MolarityLayout.background,
      child: SizedBox.expand(
        child: Stack(
          children: [
            // Canonical 1100×700 play area, letterboxed / fitted.
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: ListenableBuilder(
                        listenable: solution,
                        builder: (context, _) {
                          return MolarityPlayArea(
                            state: state,
                            onSoluteAmount: (v) =>
                                setState(() => _controller.setSoluteAmount(v)),
                            onVolume: (v) =>
                                setState(() => _controller.setVolume(v)),
                            onSoluteIndex: (i) =>
                                setState(() => _controller.selectSolute(i)),
                            onValuesVisible: (v) =>
                                setState(() => _controller.toggleValues(v)),
                            onReset: () => setState(_controller.resetAllPhET),
                            onDragStart: _controller.beginUserDrag,
                            onDragEnd: _controller.endUserDrag,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            // KartosLab chrome (non-PhET): scenario switch + inquiry — corner chips.
            Positioned(
              top: 8,
              left: 8,
              child: Row(
                children: [
                  if (_controller.manager.scenarios.length > 1)
                    ScenarioMenuButton(
                      entries: _controller.manager.scenarios
                          .map(
                            (s) => ScenarioMenuEntry(
                              id: s.scenarioId,
                              name: s.name,
                            ),
                          )
                          .toList(growable: false),
                      currentId: _controller.currentState?.scenarioId,
                      onSelected: (id) {
                        for (final s in _controller.manager.scenarios) {
                          if (s.scenarioId == id) {
                            _applyScenario(s);
                            break;
                          }
                        }
                      },
                      accentColor: const Color(0xFF555555),
                      tooltip: '切换场景',
                    ),
                  IconButton(
                    tooltip: '探究任务',
                    onPressed: () =>
                        setState(() => _inquiryOpen = !_inquiryOpen),
                    icon: const Icon(Icons.science_outlined, size: 22),
                    color: const Color(0xFF555555),
                  ),
                ],
              ),
            ),
            InquiryDrawer(
              task: scenario?.inquiryTask,
              columns: _inquiryColumns(scenario),
              snapshotProvider: _snapshot,
              open: _inquiryOpen,
            ),
          ],
        ),
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
}

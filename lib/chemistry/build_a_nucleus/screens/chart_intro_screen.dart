/// Chart Intro 正式 Screen：只组合已有 Controller / Widget / Clock。
///
/// 不查核素、不算座位、不实现 fade 业务。
/// 默认 0p0n。[已确认] `BANConstants.DEFAULT_INITIAL_* = 0`
library;

import 'package:flutter/material.dart';

import '../../../common/simulation_clock.dart';
import '../../../common/widgets/nine_grid_layout.dart';
import '../chart_intro/chart_intro_visuals.dart';
import '../chart_intro/controller/chart_intro_controller.dart';
import '../chart_intro/widgets/chart_intro_count_panel.dart';
import '../chart_intro/widgets/chart_intro_nucleon_controls.dart';
import '../chart_intro/widgets/chart_intro_status_text.dart';
import '../chart_intro/widgets/chart_intro_symbol_view.dart';
import '../chart_intro/widgets/mini_atom_view.dart';
import '../chart_intro/widgets/nuclide_chart_view.dart';
import '../chart_intro/widgets/shell_nucleus_view.dart';
import '../data/nuclide_data_loader.dart';

class ChartIntroScreen extends StatefulWidget {
  const ChartIntroScreen({
    super.key,
    this.controller,
    this.tickOnClock = true,
    this.embedded = false,
  });

  /// 测试可注入；为 null 时本屏创建并在 dispose 时销毁。
  final ChartIntroController? controller;

  /// 测试可关：只靠 [ChartIntroController.tick]。
  final bool tickOnClock;

  /// 作为 Tab 子页时去掉本屏 AppBar。
  final bool embedded;

  @override
  State<ChartIntroScreen> createState() => _ChartIntroScreenState();
}

class _ChartIntroScreenState extends State<ChartIntroScreen>
    with TickerProviderStateMixin {
  ChartIntroController? _owned;
  late final SimulationClock _clock;

  ChartIntroController? get controller => widget.controller ?? _owned;

  @override
  void initState() {
    super.initState();
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) => controller?.tick(dt);
    if (widget.tickOnClock) _clock.play();
    if (widget.controller == null) {
      NuclideDataLoader.load().then((repo) {
        if (!mounted) return;
        setState(() => _owned = ChartIntroController(repository: repo));
      });
    }
  }

  @override
  void dispose() {
    _clock.pause();
    _clock.dispose();
    _owned?.dispose();
    _owned = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final body = KeyedSubtree(
      key: const ValueKey('chart_intro_screen'),
      child: c == null
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: c,
              builder: (context, _) => _buildBody(c),
            ),
    );
    if (widget.embedded) return _playBackground(body);
    return Scaffold(
      backgroundColor: ChartIntroVisuals.screenBackground,
      appBar: AppBar(title: const Text('构建原子核 · Chart Intro')),
      body: body,
    );
  }

  /// [已确认] screenBackground WHITE。只铺本屏 play，不改 Theme / Decay。
  Widget _playBackground(Widget child) {
    return ColoredBox(
      color: ChartIntroVisuals.screenBackground,
      child: child,
    );
  }

  /// [有意差异] 原版绝对定位；工程强制 [NineGridLayout]。
  Widget _buildBody(ChartIntroController c) {
    final s = c.state;
    final caption = ChartIntroStatusText.elementCaption(s);
    return NineGridLayout(
      topLeft: FittedBox(
        alignment: Alignment.topLeft,
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (caption.isNotEmpty)
              Text(
                caption,
                key: const ValueKey('chart_intro_element'),
                style: const TextStyle(
                  color: ChartIntroVisuals.elementNameColor,
                  fontSize: ChartIntroVisuals.regularFontSize,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ChartIntroCountPanel(state: s),
          ],
        ),
      ),
      topCenter: FittedBox(
        fit: BoxFit.scaleDown,
        child: MiniAtomView.fromState(s, c.repository),
      ),
      topRight: FittedBox(
        alignment: Alignment.topRight,
        fit: BoxFit.scaleDown,
        child: PeriodicTableAndSymbolView.fromState(
          s,
          c.repository.table.elements,
          key: const ValueKey('chart_intro_periodic_table'),
        ),
      ),
      center: FittedBox(
        fit: BoxFit.scaleDown,
        child: ShellNucleusView.fromState(s, fades: c.fades),
      ),
      midRight: KeyedSubtree(
        key: const ValueKey('chart_intro_chart'),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ChartIntroChartPanel(controller: c),
        ),
      ),
      bottomRight: TextButton(
        key: const ValueKey('chart_intro_reset'),
        onPressed: c.reset,
        child: const Text('Reset'),
      ),
      footer: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ChartIntroNucleonControls(controller: c),
        ),
      ),
    );
  }
}

/// Chart Intro 核心交互面：箭头改 p/n → State → 壳层 fade / 图 / mini-atom。
///
/// 交互面测试壳。正式 Screen 见 `screens/chart_intro_screen.dart`。
/// Clock 只推进壳层 fade，dispose 时停掉，避免 issue #220。
library;

import 'package:flutter/material.dart';

import '../../../../common/simulation_clock.dart';
import '../chart_intro_visuals.dart';
import '../controller/chart_intro_controller.dart';
import 'chart_intro_count_panel.dart';
import 'chart_intro_nucleon_controls.dart';
import 'chart_intro_status_text.dart';
import 'mini_atom_view.dart';
import 'nuclide_chart_view.dart';
import 'shell_nucleus_view.dart';

class ChartIntroInteractView extends StatefulWidget {
  const ChartIntroInteractView({
    super.key,
    required this.controller,
    this.tickOnClock = true,
  });

  final ChartIntroController controller;

  /// 测试可关：只靠 [ChartIntroController.tick] 推进 fade。
  final bool tickOnClock;

  @override
  State<ChartIntroInteractView> createState() => _ChartIntroInteractViewState();
}

class _ChartIntroInteractViewState extends State<ChartIntroInteractView>
    with TickerProviderStateMixin {
  late final SimulationClock _clock;

  @override
  void initState() {
    super.initState();
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) => widget.controller.tick(dt);
    if (widget.tickOnClock) _clock.play();
  }

  @override
  void dispose() {
    _clock.pause();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final c = widget.controller;
        final s = c.state;
        final caption = ChartIntroStatusText.elementCaption(s);
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              ChartIntroNucleonControls(controller: c),
              TextButton(
                key: const ValueKey('chart_intro_reset'),
                onPressed: c.reset,
                child: const Text('重置'),
              ),
              MiniAtomView.fromState(s, c.repository),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: ShellNucleusView.fromState(s, fades: c.fades),
              ),
              KeyedSubtree(
                key: const ValueKey('chart_intro_chart'),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: NuclideChartView.fromState(s, c.repository),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

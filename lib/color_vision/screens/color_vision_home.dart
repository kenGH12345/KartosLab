import 'package:flutter/material.dart';
import '../../common/widgets/phet_tab_bar.dart';
import '../screens/rgb_bulbs_screen.dart';
import '../screens/single_bulb_screen.dart';
import '../config/color_vision_scenario.dart';
import '../config/color_vision_scenario_manager.dart';

class ColorVisionHome extends StatefulWidget {
  const ColorVisionHome({super.key});
  @override State<ColorVisionHome> createState() => _ColorVisionHomeState();
}

class _ColorVisionHomeState extends State<ColorVisionHome> {
  ColorVisionScenarioManager? _mgr;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mgr = ColorVisionScenarioManager();
    await mgr.loadScenarios();
    if (!mounted) return;
    setState(() => _mgr = mgr);
  }

  @override
  Widget build(BuildContext context) {
    final mgr = _mgr;
    if (mgr == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final rgbScenario = mgr.findById('rgb-default');
    final filterScenario = mgr.findById('single-white-red-filter');
    final rgbScenarios =
        mgr.scenarios.where((s) => s.screen == CVScreen.rgb).toList(growable: false);

    return PhetTabbedScreen(
      title: 'Color Vision',
      accentColor: const Color(0xFF7C3AED),
      tabs: [
        PhetTab(
          label: 'Magic Lab',
          icon: Icons.science,
          child: MagicLabScreen(
            scenario: rgbScenario,
            scenarioList: rgbScenarios,
            manager: mgr,
          ),
        ),
        PhetTab(
          label: 'Filter',
          icon: Icons.filter_vintage,
          child: SingleBulbScreen(scenario: filterScenario),
        ),
      ],
    );
  }
}

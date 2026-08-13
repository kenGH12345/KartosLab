import 'package:flutter/material.dart';

import 'netforce_screen.dart';
import 'motion_screen.dart';
import '../config/scenario_manager.dart';
import '../../common/widgets/kratos_tab_bar.dart';

/// 力与运动主页：Tab 切换 4 个实验模式 · 支持 JSON scenario 加载（§C1 合规）
class ForcesHome extends StatefulWidget {
  const ForcesHome({super.key});
  @override State<ForcesHome> createState() => _ForcesHomeState();
}

class _ForcesHomeState extends State<ForcesHome> {
  ForcesScenarioManager? _scenarioManager;

  static const _scenarioMap = <String, String>{
    '合力': 'netforce-tug',
    '运动': 'motion-explore',
    '摩擦': 'friction-explore',
    '加速度': 'acceleration-explore',
  };

  @override void initState() {
    super.initState();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    try {
      final mgr = ForcesScenarioManager();
      await mgr.loadScenarios();
      if (!mounted) return;
      setState(() => _scenarioManager = mgr);
    } catch (e) {
      debugPrint('Failed to load forces scenarios: $e');
    }
  }

  @override Widget build(BuildContext context) {
    final mgr = _scenarioManager;
    if (mgr == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return KratosTabbedScreen(
      title: '力与运动',
      accentColor: const Color(0xFF166534),
      tabBarPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      tabs: [
        KratosTab(
          label: '合力', icon: Icons.sports_kabaddi,
          child: NetForceScreen(scenario: mgr.tryLoad(_scenarioMap['合力'] ?? '')),
        ),
        KratosTab(
          label: '运动', icon: Icons.speed,
          child: MotionScreen(mode: MotionScreenMode.motion, scenario: mgr.tryLoad(_scenarioMap['运动'] ?? '')),
        ),
        KratosTab(
          label: '摩擦', icon: Icons.sledding,
          child: MotionScreen(mode: MotionScreenMode.friction, scenario: mgr.tryLoad(_scenarioMap['摩擦'] ?? '')),
        ),
        KratosTab(
          label: '加速度', icon: Icons.sensors,
          child: MotionScreen(mode: MotionScreenMode.acceleration, scenario: mgr.tryLoad(_scenarioMap['加速度'] ?? '')),
        ),
      ],
    );
  }
}

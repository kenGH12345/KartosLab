import 'package:flutter/material.dart';

import 'netforce_screen.dart';
import 'motion_screen.dart';
import '../config/scenario_manager.dart';

/// 力与运动主页：4 个实验模式 · 支持 JSON scenario 加载（§C1 合规）
class ForcesHome extends StatefulWidget {
  const ForcesHome({super.key});
  @override State<ForcesHome> createState() => _ForcesHomeState();
}

class _ForcesHomeState extends State<ForcesHome> {
  ForcesScenarioManager? _scenarioManager;

  // 模式 → scenarioId 映射表（每个模式默认加载对应 JSON 场景）
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
  // 用户可直接跳转的 4 个模式
  static const screens = [
    _ScreenInfo(title: '合力', subtitle: '拔河比赛\n力的合成与平衡', icon: Icons.sports_kabaddi, color: Color(0xFF22C55E)),
    _ScreenInfo(title: '运动', subtitle: '力、质量\n与加速度', icon: Icons.speed, color: Color(0xFF3B82F6)),
    _ScreenInfo(title: '摩擦', subtitle: '摩擦力\n对运动的影响', icon: Icons.sledding, color: Color(0xFFF59E0B)),
    _ScreenInfo(title: '加速度', subtitle: '测量加速度\n探索 F=ma', icon: Icons.sensors, color: Color(0xFF7C3AED)),
  ];

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('力与运动'), backgroundColor: const Color(0xFFFEF3C7)),
    body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      const Text('选择一个实验', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      const SizedBox(height: 16),
      Expanded(child: GridView.count(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, children: [
        for (final s in screens) _card(s),
      ])),
    ])),
  );

  Widget _card(_ScreenInfo s) => InkWell(onTap: () => _open(s), borderRadius: BorderRadius.circular(12),
      child: Container(decoration: BoxDecoration(color: s.color.withAlpha(15), borderRadius: BorderRadius.circular(12), border: Border.all(color: s.color.withAlpha(60))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(s.icon, size: 48, color: s.color),
            const SizedBox(height: 8),
            Text(s.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: s.color)),
            const SizedBox(height: 4),
            Text(s.subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ])));

  void _open(_ScreenInfo s) {
    final scenario = _scenarioManager?.tryLoad(_scenarioMap[s.title] ?? '');
    Widget page;
    switch (s.title) {
      case '合力': page = NetForceScreen(scenario: scenario);
      case '运动': page = MotionScreen(mode: MotionScreenMode.motion, scenario: scenario);
      case '摩擦': page = MotionScreen(mode: MotionScreenMode.friction, scenario: scenario);
      case '加速度': page = MotionScreen(mode: MotionScreenMode.acceleration, scenario: scenario);
      default: return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _ScreenInfo {
  const _ScreenInfo({required this.title, required this.subtitle, required this.icon, required this.color});
  final String title, subtitle;
  final IconData icon;
  final Color color;
}

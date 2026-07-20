import 'package:flutter/material.dart';

import '../optics/config/scenario_manager.dart';
import '../optics/config/lab_scenario.dart';

class ScenarioSelectionScreen extends StatefulWidget {
  const ScenarioSelectionScreen({super.key});

  @override
  State<ScenarioSelectionScreen> createState() => _ScenarioSelectionScreenState();
}

class _ScenarioSelectionScreenState extends State<ScenarioSelectionScreen>
    with SingleTickerProviderStateMixin {
  final _scenarioManager = ScenarioManager();
  Map<String, List<LabScenario>> _domainGroups = {};
  List<String> _domainOrder = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    await _scenarioManager.loadScenarios();
    final groups = _scenarioManager.getScenariosByDomain();
    final order = groups.keys.toList();

    // 按 domainLabels 中的顺序排列
    order.sort((a, b) {
      if (a == 'other') return 1;
      if (b == 'other') return -1;
      return 0;
    });

    setState(() {
      _domainGroups = groups;
      _domainOrder = order;
      _loading = false;
      _tabController.dispose();
      _tabController = TabController(length: order.length, vsync: this);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择实验场景'),
        backgroundColor: const Color(0xFFE8F6FB),
        foregroundColor: const Color(0xFF062A3A),
        bottom: _loading || _domainOrder.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF062A3A),
                unselectedLabelColor: const Color(0xFF6B7280),
                indicatorColor: const Color(0xFF1177AA),
                tabs: _domainOrder.map((domain) {
                  final label = ScenarioManager.domainLabels[domain] ?? domain;
                  return Tab(text: label);
                }).toList(),
              ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _domainOrder.isEmpty
              ? _buildEmptyState()
              : TabBarView(
                  controller: _tabController,
                  children: _domainOrder.map((domain) {
                    final scenarios = _domainGroups[domain] ?? [];
                    return _buildScenarioGrid(scenarios);
                  }).toList(),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('暂无可用场景',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('请在 assets/scenarios/ 目录下添加场景配置文件',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildScenarioGrid(List<LabScenario> scenarios) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: scenarios.length,
        itemBuilder: (context, index) {
          final scenario = scenarios[index];
          return _ScenarioCard(
            scenario: scenario,
            onTap: () => _loadScenario(scenario.scenarioId),
          );
        },
      ),
    );
  }

  void _loadScenario(String scenarioId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(scenarioId);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载场景失败: $e')),
        );
      }
    }
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({required this.scenario, required this.onTap});

  final LabScenario scenario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _getDifficultyIcon(scenario.level),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(scenario.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ]),
              const SizedBox(height: 8),
              Expanded(
                child: Text(scenario.description,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF6B7280)),
                    maxLines: 3, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(height: 8),
              _buildDifficultyTag(scenario.level),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getDifficultyIcon(ScenarioLevel level) {
    switch (level) {
      case ScenarioLevel.beginner:
        return const Icon(Icons.star_rounded, color: Color(0xFF22C55E), size: 20);
      case ScenarioLevel.intermediate:
        return const Icon(Icons.star_half_rounded, color: Color(0xFFF59E0B), size: 20);
      case ScenarioLevel.advanced:
        return const Icon(Icons.star_border_rounded, color: Color(0xFFEF4444), size: 20);
    }
  }

  Widget _buildDifficultyTag(ScenarioLevel level) {
    final (color, label) = switch (level) {
      ScenarioLevel.beginner => (const Color(0xFF22C55E), '入门'),
      ScenarioLevel.intermediate => (const Color(0xFFF59E0B), '进阶'),
      ScenarioLevel.advanced => (const Color(0xFFEF4444), '高级'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

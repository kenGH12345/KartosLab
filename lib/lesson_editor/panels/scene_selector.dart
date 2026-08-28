import 'package:flutter/material.dart';

import '../../common/controls/kratos_combo_box.dart';
import '../../common/scenario/lesson_sim_host.dart';
import '../../common/scenario/lesson_plan.dart';

/// 场景选择器（T10 · F5 · AC-5）。
///
/// - sim 下拉 + scenarioId 下拉二级联动
/// - 数据源：动态读 [LessonSimHosts.loadSceneCatalog]（注册表驱动 · T2 拍板）
/// - 双刷新机制（用户 2026-08-26 拍板）：进入时加载 + 手动「刷新场景列表」
///   按钮（新增 sim 接线后无需重启即可选到）
/// - 加载失败/未选 sim → 降级为占位提示（不 crash）
class SceneSelector extends StatefulWidget {
  const SceneSelector({
    super.key,
    required this.scenario,
    required this.onChanged,
  });

  /// 当前节点的场景引用（sim/scenarioId 可能为空字符串占位）。
  final LessonScenarioRef? scenario;

  /// 场景变更回调（null = 清除引用）。
  final ValueChanged<LessonScenarioRef?> onChanged;

  @override
  State<SceneSelector> createState() => _SceneSelectorState();
}

class _SceneSelectorState extends State<SceneSelector> {
  /// sim → 可完成 scenarioId 列表（null = 未加载成功）。
  Map<String, List<String>>? _catalog;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final catalog = await LessonSimHosts.loadSceneCatalog();
      if (!mounted) return;
      setState(() => _catalog = catalog);
    } catch (e) {
      debugPrint('SceneSelector: 场景目录加载失败 $e');
      if (!mounted) return;
      setState(() => _catalog = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = _catalog;
    // items 前插空串占位（"未选择"）— KratosComboBox.value 必须 ∈ items，
    // 否则 DropdownButton 触发断言。空串占位让新节点的占位 scenario
    // （sim=''/scenarioId=''）合法显示。
    final sims = catalog == null
        ? const <String>[]
        : <String>['', ...catalog.keys];
    final currentSim = widget.scenario?.sim;
    final scenarioIds =
        (currentSim == null || currentSim.isEmpty || catalog == null)
            ? const <String>[]
            : <String>['', ...?catalog[currentSim]];
    final currentScenarioId = widget.scenario?.scenarioId ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('场景',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Spacer(),
            IconButton(
              tooltip: '刷新场景列表',
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (_catalog == null && !_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text('场景目录加载失败',
                style: TextStyle(fontSize: 11, color: Color(0xFFB91C1C))),
          ),
        if (catalog != null) ...[
          const SizedBox(height: 4),
          KratosComboBox<String>(
            label: '模块 (sim)',
            items: sims,
            itemLabels: const ['未选择'],
            value: (currentSim != null && sims.contains(currentSim)) ? currentSim : '',
            width: double.infinity,
            onChanged: (sim) {
              if (sim.isEmpty) {
                widget.onChanged(null);
              } else {
                final ids = catalog[sim] ?? const <String>[];
                widget.onChanged(
                  LessonScenarioRef(
                    sim: sim,
                    scenarioId: ids.isNotEmpty ? ids.first : '',
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 6),
          KratosComboBox<String>(
            label: '场景 (scenarioId)',
            items: scenarioIds,
            itemLabels: const ['未选择'],
            value: scenarioIds.contains(currentScenarioId)
                ? currentScenarioId
                : '',
            width: double.infinity,
            onChanged: (scenarioId) => widget.onChanged(
              LessonScenarioRef(
                sim: currentSim ?? '',
                scenarioId: scenarioId,
              ),
            ),
          ),
          if (currentSim != null && currentSim.isNotEmpty && scenarioIds.length == 1)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('该 sim 暂无可用场景（可能未接线或不可完成）',
                  style: TextStyle(fontSize: 11, color: Color(0xFFB45309))),
            ),
        ],
      ],
    );
  }
}

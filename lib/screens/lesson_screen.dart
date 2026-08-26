import 'package:flutter/material.dart';

import '../common/scenario/lesson_plan.dart';
import '../common/scenario/lesson_runtime.dart';
import '../common/scenario/lesson_sim_host.dart';
import '../common/widgets/lesson_progress_bar.dart';

/// 剧本运行宿主屏（跨模块导航层，与 home_screen 同目录层级）。
///
/// 装配：LessonRuntime（状态机）+ LessonHooks（事件钩子）→ 经
/// simHostBuilder（固定传 LessonSimHosts.dispatch() · D9）透传给 sim screen。
/// 流转反馈双通道（AC-21）：AnimatedSwitcher fade 过渡 + SnackBar 完成提示。
class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.plan,
    required this.simHostBuilder,
  });

  /// 已解析剧本（入口卡片加载产物）。
  final LessonPlan plan;

  /// 固定传 `LessonSimHosts.dispatch()`（D9 跨 sim 分派）。
  final LessonSimHostBuilder simHostBuilder;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final LessonRuntime _runtime;
  late final LessonHooks _hooks;
  String? _lastCurrent;

  /// Major-4 · jumpTo 触发的节点切换不属"完成流转"——置位后跳过下一次
  /// SnackBar 流转反馈（否则从已完成节点跳走会误报「已完成 X → 进入 Y」）。
  bool _suppressNextFeedback = false;

  @override
  void initState() {
    super.initState();
    _runtime = LessonRuntime()..load(widget.plan);
    _hooks = LessonHooks(
      onScenarioSuccess: _runtime.onScenarioSuccess,
      onPredictionResult: _runtime.onPredictionResult,
    );
    _lastCurrent = _runtime.current;
    _runtime.addListener(_onRuntimeChanged);
  }

  @override
  void dispose() {
    _runtime.removeListener(_onRuntimeChanged);
    _runtime.dispose();
    super.dispose();
  }

  /// 进度 chips 点击（T-P2-03）：锁定拦截在 runtime.jumpTo 内——返回 false
  /// → SnackBar '节点未解锁'（AC-34 点击不响应语义）；true → 节点切换
  /// （Major-4：jumpTo 路径抑制「完成流转」SnackBar）。
  void _onNodeTap(String nodeId) {
    if (_runtime.jumpTo(nodeId)) {
      _suppressNextFeedback = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(
          content: Text('节点未解锁'),
          duration: Duration(seconds: 2),
        ));
    });
  }

  /// 流转反馈通道 ②：current 变化（且原节点已完成）→ SnackBar 提示（AC-21）。
  void _onRuntimeChanged() {
    final prev = _lastCurrent;
    final cur = _runtime.current;
    if (cur == prev) return;
    _lastCurrent = cur;
    if (_suppressNextFeedback) {
      _suppressNextFeedback = false; // Major-4：jumpTo 切换不弹完成提示
      return;
    }
    if (prev == null || !_runtime.completed.contains(prev)) return;
    final plan = widget.plan;
    final doneNode = plan.find(prev);
    final nextNode = cur == null ? null : plan.find(cur);
    if (doneNode == null || nextNode == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('✅ 已完成「${doneNode.title}」→ 进入「${nextNode.title}」'),
            duration: const Duration(seconds: 2),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AC-19：剧本名 + 当前节点标题
        title: ListenableBuilder(
          listenable: _runtime,
          builder: (_, _) => Text(
            '${widget.plan.name} · ${_runtime.currentNode?.title ?? ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: ListenableBuilder(
            listenable: _runtime,
            builder: (_, _) => LessonProgressBar(
              runtime: _runtime,
              onNodeTap: _onNodeTap,
            ),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _runtime,
        builder: (_, _) {
          if (_runtime.isLessonCompleted) {
            return _LessonCompleteView(plan: widget.plan, runtime: _runtime);
          }
          final node = _runtime.currentNode;
          if (node == null) {
            return const Center(child: Text('剧本状态异常'));
          }
          // 流转反馈通道 ①：AnimatedSwitcher fade 过渡（AC-21）
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            child: KeyedSubtree(
              // 节点切换 → 旧 sim screen 整体销毁、新 sim screen 全新构建
              // （跨 sim 无状态残留 · D9/方案 §7 时序）
              key: ValueKey('lesson-node-${node.id}'),
              child: widget.simHostBuilder(context, node, _hooks),
            ),
          );
        },
      ),
    );
  }
}

/// 课时完成视图（AC-22）：🎉 + 课时名 + 节点回顾列表 + 返回首页。
class _LessonCompleteView extends StatelessWidget {
  const _LessonCompleteView({required this.plan, required this.runtime});

  final LessonPlan plan;
  final LessonRuntime runtime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text('课时完成！', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(plan.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            // 节点回顾列表（各节点 title + 完成态）
            for (final node in plan.nodes)
              if (node.scenario != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        runtime.completed.contains(node.id)
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: runtime.completed.contains(node.id)
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(node.title,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home_outlined),
              label: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

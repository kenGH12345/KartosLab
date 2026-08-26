import 'package:flutter/material.dart';

import '../../screens/lesson_screen.dart';
import '../scenario/lesson_manifest.dart';
import '../scenario/lesson_plan.dart';
import '../scenario/lesson_sim_host.dart';

/// 首页课时入口区（StatefulWidget：异步加载 lessons manifest）。
///
/// 挂载：home_screen 的 _SubjectGroupBlock 内，sim 卡片网格之后，按 manifest
/// 中 sim==该组 sim 的课时渲染入口卡片列表。无注册课时 / manifest 缺失 /
/// loadEntries 抛错 → 渲染 SizedBox.shrink()（AC-17 无课时 sim 首页显示不变）。
class LessonEntrySection extends StatefulWidget {
  const LessonEntrySection({super.key, required this.sim});

  /// 目标 sim key（'circuit' / 'color_vision' / ...）。
  final String sim;

  /// 测试注入用：覆盖 manifest 读取（默认真实 assets）。
  @visibleForTesting
  static Future<List<LessonManifestEntry>> Function()? entriesOverride;

  @override
  State<LessonEntrySection> createState() => _LessonEntrySectionState();
}

class _LessonEntrySectionState extends State<LessonEntrySection> {
  List<LessonManifestEntry>? _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    List<LessonManifestEntry> all;
    try {
      all = await (LessonEntrySection.entriesOverride?.call() ??
          LessonManifestLoader().loadEntries());
    } catch (e) {
      // 降级：注册表异常 → 隐藏入口（不 crash · AC-17 链路）
      debugPrint('LessonEntrySection: 课时注册表加载失败，隐藏入口: $e');
      all = const [];
    }
    if (!mounted) return;
    setState(() {
      _entries = [for (final e in all) if (e.sim == widget.sim) e];
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    if (entries == null || entries.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final e in entries) ...[
            LessonEntryCard(
              entry: e,
              onTap: () => _launch(context, e),
            ),
            if (e != entries.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  /// 启动流程（方案 §2.7 _launch）：
  /// ① LessonSimHosts 惰性加载全部已注册 sim manager（混合剧本需要 · D9）
  /// ② loader.loadAll(scenarioPlayable)
  /// ③ 找 id 匹配 plan（找不到 → SnackBar '课时暂不可用' · AC-6 降级末端）
  /// ④ push LessonScreen(simHostBuilder: LessonSimHosts.dispatch())（AC-18）
  Future<void> _launch(BuildContext context, LessonManifestEntry entry) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await LessonSimHosts.ensureManagersLoaded();
    final plans = await LessonManifestLoader()
        .loadAll(scenarioPlayable: LessonSimHosts.scenarioPlayable());
    LessonPlan? plan;
    for (final p in plans) {
      if (p.lessonId == entry.id) {
        plan = p;
        break;
      }
    }
    if (plan == null) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('课时暂不可用')));
      return;
    }
    await navigator.push(MaterialPageRoute(
      builder: (_) => LessonScreen(
        plan: plan!,
        simHostBuilder: LessonSimHosts.dispatch(),
      ),
    ));
  }
}

/// 单张课时入口卡片（样式复用 home_screen._SimCard 视觉语言：
/// 白底圆角卡 + Icons.menu_book_rounded + sim 主色描边）。
class LessonEntryCard extends StatelessWidget {
  const LessonEntryCard({super.key, required this.entry, required this.onTap});

  final LessonManifestEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1177AA), width: 1.2),
          ),
          child: Row(
            children: [
              const Icon(Icons.menu_book_rounded,
                  size: 22, color: Color(0xFF1177AA)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.name,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.play_circle_outline,
                  size: 20, color: Color(0xFF1177AA)),
            ],
          ),
        ),
      ),
    );
  }
}

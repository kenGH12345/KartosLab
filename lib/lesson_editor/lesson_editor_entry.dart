import 'package:flutter/material.dart';

import 'screens/lesson_editor_screen.dart';

/// 首页「剧本编辑器」入口按钮（F1 · AC-1）。
///
/// 与首页 sim 卡片的导航模式一致：Navigator.push 直跳（项目无路由表）。
class LessonEditorEntry extends StatelessWidget {
  const LessonEditorEntry({super.key});

  static const Color _primary = Color(0xFF1177AA);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const LessonEditorScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_tree_rounded,
                    color: _primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '剧本编辑器',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF073B54),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '拖拽编排不同 sim 的课时剧本',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B8291),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF6B8291)),
            ],
          ),
        ),
      ),
    );
  }
}

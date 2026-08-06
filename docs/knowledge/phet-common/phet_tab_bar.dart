import 'package:flutter/material.dart';

/// PhET 风格标签栏——封装 Flutter TabBar + TabBarView。
///
/// 用法：
/// ```dart
/// PhetTabbedScreen(
///   tabs: [
///     PhetTab(label: '位置', icon: Icons.trending_up, child: PositionView()),
///     PhetTab(label: '速度', icon: Icons.speed, child: VelocityView()),
///     PhetTab(label: '加速度', icon: Icons.bolt, child: AccelerationView()),
///   ],
/// )
/// ```
class PhetTab {
  final String label;
  final IconData? icon;
  final Widget child;
  final Color? color;

  const PhetTab({required this.label, this.icon, required this.child, this.color});
}

/// 标签栏 + 内容区域的组合组件。
class PhetTabbedScreen extends StatelessWidget {
  const PhetTabbedScreen({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.title,
    this.accentColor,
    this.onTabChanged,
    this.tabBarPadding,
  });

  final List<PhetTab> tabs;
  final int initialIndex;
  final String? title;
  final Color? accentColor;
  final ValueChanged<int>? onTabChanged;
  final EdgeInsetsGeometry? tabBarPadding;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? const Color(0xFF1177AA);
    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex,
      child: Builder(
        builder: (ctx) {
          final controller = DefaultTabController.of(ctx);
          controller.addListener(() {
            if (!controller.indexIsChanging) onTabChanged?.call(controller.index);
          });
          return Column(
            children: [
              if (title != null)
                Padding(
                  padding: tabBarPadding ?? const EdgeInsets.only(top: 8, left: 12, right: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(title!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  ),
                ),
              Padding(
                padding: tabBarPadding ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: TabBar(
                  controller: controller,
                  labelColor: accent,
                  unselectedLabelColor: const Color(0xFF64748B),
                  indicatorColor: accent,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                  tabs: tabs.map((t) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (t.icon != null) ...[
                          Icon(t.icon, size: 16),
                          const SizedBox(width: 4),
                        ],
                        Text(t.label),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: controller,
                  children: tabs.map((t) => t.child).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 仅含标签栏（不含 TabBarView），用于需要自定义内容区域的场景。
class PhetTabBar extends StatelessWidget {
  const PhetTabBar({
    super.key,
    required this.tabs,
    required this.controller,
    this.accentColor,
    this.padding,
  });

  final List<PhetTab> tabs;
  final TabController controller;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? const Color(0xFF1177AA);
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TabBar(
        controller: controller,
        labelColor: accent,
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorColor: accent,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        tabs: tabs.map((t) => Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (t.icon != null) ...[Icon(t.icon, size: 16), const SizedBox(width: 4)],
              Text(t.label),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

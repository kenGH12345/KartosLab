import 'package:flutter/material.dart';

/// Kratos 风格标签栏——封装 Flutter TabBar + TabBarView。
///
/// 用法：
/// ```dart
/// KratosTabbedScreen(
///   tabs: [
///     KratosTab(label: '位置', icon: Icons.trending_up, child: PositionView()),
///     KratosTab(label: '速度', icon: Icons.speed, child: VelocityView()),
///     KratosTab(label: '加速度', icon: Icons.bolt, child: AccelerationView()),
///   ],
/// )
/// ```
class KratosTab {
  final String label;
  final IconData? icon;
  final Widget child;
  final Color? color;

  const KratosTab({required this.label, this.icon, required this.child, this.color});
}

/// 标签栏 + 内容区域的组合组件。
class KratosTabbedScreen extends StatefulWidget {
  const KratosTabbedScreen({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.title,
    this.accentColor,
    this.onTabChanged,
    this.tabBarPadding,
  });

  final List<KratosTab> tabs;
  final int initialIndex;
  final String? title;
  final Color? accentColor;
  final ValueChanged<int>? onTabChanged;
  final EdgeInsetsGeometry? tabBarPadding;

  @override
  State<KratosTabbedScreen> createState() => _KratosTabbedScreenState();
}

class _KratosTabbedScreenState extends State<KratosTabbedScreen> with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: widget.tabs.length,
      initialIndex: widget.initialIndex,
      vsync: this,
    );
    _controller.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_controller.indexIsChanging) {
      widget.onTabChanged?.call(_controller.index);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTabChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? const Color(0xFF1177AA);
    return Scaffold(
      appBar: widget.title != null
          ? AppBar(
              title: Text(widget.title!),
              backgroundColor: accent,
              foregroundColor: Colors.white,
              elevation: 0,
            )
          : null,
      body: Column(
      children: [
        Padding(
          padding: widget.tabBarPadding ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: TabBar(
            controller: _controller,
            labelColor: accent,
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: accent,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            tabs: widget.tabs.map((t) => Tab(
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
            controller: _controller,
            children: widget.tabs.map((t) => t.child).toList(),
          ),
        ),
      ],
      ),
    );
  }
}

/// 仅含标签栏（不含 TabBarView），用于需要自定义内容区域的场景。
class KratosTabBar extends StatelessWidget {
  const KratosTabBar({
    super.key,
    required this.tabs,
    required this.controller,
    this.accentColor,
    this.padding,
  });

  final List<KratosTab> tabs;
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

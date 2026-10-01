import 'package:flutter/material.dart';

/// Kratos 风格标签栏——封装 Flutter TabBar + 点击切换动画内容区。
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
  final Widget? tabIcon;
  final Widget child;
  final Color? color;

  const KratosTab({
    required this.label,
    this.icon,
    this.tabIcon,
    required this.child,
    this.color,
  });
}

/// 点击 Tab 切换时旧页渐出、新页渐入（交叉淡化），禁止滑动手势。
///
/// 子页保持挂载（类似 IndexedStack），避免切回时丢失仿真状态。
/// 底层垫不透明底色，交叉半透明时不会闪出 Scaffold 白底。
class KratosTabSwitcher extends StatefulWidget {
  const KratosTabSwitcher({
    super.key,
    required this.controller,
    required this.children,
    this.duration = const Duration(milliseconds: 280),
    this.curve = Curves.easeInOut,
    this.backdropColor = const Color(0xFFF5F5F5),
  });

  final TabController controller;
  final List<Widget> children;
  final Duration duration;
  final Curve curve;
  /// Shown under crossfading pages so the scaffold never flashes through.
  final Color backdropColor;

  @override
  State<KratosTabSwitcher> createState() => _KratosTabSwitcherState();
}

class _KratosTabSwitcherState extends State<KratosTabSwitcher>
    with SingleTickerProviderStateMixin {
  late int _index;
  int? _outgoing;
  late final AnimationController _fade;
  late Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _index = widget.controller.index;
    _fade = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener(_onFadeStatus);
    _t = CurvedAnimation(parent: _fade, curve: widget.curve);
    // Settled: fully on the active page.
    _fade.value = 1.0;
    widget.controller.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(covariant KratosTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _fade.duration = widget.duration;
    }
    if (oldWidget.curve != widget.curve) {
      _t = CurvedAnimation(parent: _fade, curve: widget.curve);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTabChanged);
      widget.controller.addListener(_onTabChanged);
      _index = widget.controller.index;
      _outgoing = null;
      _fade.value = 1.0;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    _fade.removeStatusListener(_onFadeStatus);
    _fade.dispose();
    super.dispose();
  }

  void _onFadeStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    if (_outgoing == null) return;
    setState(() => _outgoing = null);
  }

  void _onTabChanged() {
    final next = widget.controller.index;
    if (next == _index || !mounted) return;
    setState(() {
      _outgoing = _index;
      _index = next;
    });
    _fade.duration = widget.duration;
    // t: 0 = fully outgoing, 1 = fully incoming.
    _fade.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.children.length == widget.controller.length,
      'KratosTabSwitcher children length must match TabController.length',
    );

    final n = widget.children.length;
    // Keep Stack slot order stable. Reordering children reused State onto the
    // wrong tab (Membrane Transport FeatureSet model did not follow the tab).
    return ColoredBox(
      color: widget.backdropColor,
      child: AnimatedBuilder(
        animation: Listenable.merge([_t, widget.controller]),
        builder: (context, _) {
          final t = _t.value;
          final active = widget.controller.index;
          return Stack(
            fit: StackFit.expand,
            children: [
              for (var i = 0; i < n; i++)
                Offstage(
                  key: ValueKey<int>(i),
                  offstage: i != active && i != _outgoing,
                  child: IgnorePointer(
                    ignoring: i != active,
                    child: Opacity(
                      opacity: i == active
                          ? (i == _index ? t : 1.0)
                          : (i == _outgoing ? (1.0 - t) : 0.0),
                      child: TickerMode(
                        enabled: i == active || i == _outgoing,
                        child: widget.children[i],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
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
    this.appBarActions,
    this.tabBarIsScrollable = false,
  });

  final List<KratosTab> tabs;
  final int initialIndex;
  final String? title;
  final Color? accentColor;
  final ValueChanged<int>? onTabChanged;
  final EdgeInsetsGeometry? tabBarPadding;
  final List<Widget>? appBarActions;

  /// When true, TabBar scrolls horizontally (long labels / many tabs).
  final bool tabBarIsScrollable;

  @override
  State<KratosTabbedScreen> createState() => _KratosTabbedScreenState();
}

class _KratosTabbedScreenState extends State<KratosTabbedScreen>
    with SingleTickerProviderStateMixin {
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
              actions: widget.appBarActions,
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: widget.tabBarPadding ??
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: TabBar(
              controller: _controller,
              isScrollable: widget.tabBarIsScrollable,
              labelColor: accent,
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: accent,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              tabs: widget.tabs
                  .map(
                    (t) => Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (t.tabIcon != null) ...[
                            t.tabIcon!,
                            const SizedBox(width: 6),
                          ] else if (t.icon != null) ...[
                            Icon(t.icon, size: 16),
                            const SizedBox(width: 4),
                          ],
                          Text(t.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: KratosTabSwitcher(
              controller: _controller,
              children: widget.tabs.map((t) => t.child).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 仅含标签栏（不含内容区），用于需要自定义内容区域的场景。
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
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        tabs: tabs
            .map(
              (t) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (t.tabIcon != null) ...[
                      t.tabIcon!,
                      const SizedBox(width: 6),
                    ] else if (t.icon != null) ...[
                      Icon(t.icon, size: 16),
                      const SizedBox(width: 4),
                    ],
                    Text(t.label),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

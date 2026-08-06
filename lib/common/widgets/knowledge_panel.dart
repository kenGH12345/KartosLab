import 'package:flutter/material.dart';

/// 通用"物理原理 + 知识点"面板 —— 所有 sim 复用。
///
/// 用法：
/// ```dart
/// KnowledgePanel(
///   title: '颜色过滤原理',
///   titleIcon: '💡',
///   titleColor: Color(0xFFF59E0B),
///   sections: [
///     KnowledgeSection.grid(items: [
///       KnowledgeItem(dot: Colors.red, title: '红色滤光片', titleColor: Colors.red,
///                     desc: '吸收绿蓝光,只透红光。', active: filterType == 'red'),
///     ]),
///     KnowledgeSection.list(
///       subtitle: '知识点',
///       subtitleIcon: '📚',
///       subtitleColor: Color(0xFF60A5FA),
///       items: [
///         KnowledgeItem(icon: '➖', title: '减色法原理', titleColor: Colors.amber,
///                       desc: '滤光片属减色混合...'),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// 深色主题、圆角、边框、可滚动、有 maxHeight 约束（默认 320）。
class KnowledgePanel extends StatelessWidget {
  const KnowledgePanel({
    super.key,
    required this.title,
    required this.sections,
    this.titleIcon,
    this.titleColor = const Color(0xFFF59E0B),
    this.maxHeight = 320,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  });

  final String title;
  final String? titleIcon;
  final Color titleColor;
  final List<KnowledgeSection> sections;
  final double maxHeight;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(title, titleIcon, titleColor, 13, FontWeight.w700),
            const SizedBox(height: 8),
            for (int i = 0; i < sections.length; i++) ...[
              if (i > 0) ...[
                const SizedBox(height: 10),
                Container(height: 1, color: const Color(0xFF334155)),
                const SizedBox(height: 10),
              ],
              _buildSection(sections[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(KnowledgeSection s) {
    switch (s.kind) {
      case _SectionKind.grid:
        return _buildGrid(s.items);
      case _SectionKind.list:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (s.subtitle != null) ...[
              _header(s.subtitle!, s.subtitleIcon,
                  s.subtitleColor ?? const Color(0xFF60A5FA), 12, FontWeight.w700),
              const SizedBox(height: 6),
            ],
            for (int i = 0; i < s.items.length; i++) ...[
              if (i > 0) const SizedBox(height: 5),
              _KnowledgeLongTile(item: s.items[i]),
            ],
          ],
        );
    }
  }

  /// 网格瓷砖：2 列 · N 行 · 奇数项独占左列
  Widget _buildGrid(List<KnowledgeItem> items) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 6));
      final left = items[i];
      final right = (i + 1 < items.length) ? items[i + 1] : null;
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _KnowledgeGridTile(item: left)),
          const SizedBox(width: 8),
          Expanded(
            child: right != null
                ? _KnowledgeGridTile(item: right)
                : const SizedBox.shrink(),
          ),
        ],
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _header(
      String text, String? icon, Color color, double fs, FontWeight fw) {
    return Row(children: [
      if (icon != null) ...[
        Text(icon, style: TextStyle(fontSize: fs + 1)),
        const SizedBox(width: 6),
      ],
      Flexible(
        child: Text(text,
            style: TextStyle(color: color, fontSize: fs, fontWeight: fw)),
      ),
    ]);
  }
}

/// 面板中的一个"分节"—— 两种形态之一：`grid` 或 `list`
class KnowledgeSection {
  const KnowledgeSection._({
    required this.kind,
    required this.items,
    this.subtitle,
    this.subtitleIcon,
    this.subtitleColor,
  });

  /// 2 列瓷砖网格。每格适合放"要点式简短说明"。
  factory KnowledgeSection.grid({required List<KnowledgeItem> items}) =>
      KnowledgeSection._(kind: _SectionKind.grid, items: items);

  /// 全宽长条列表 · 可带一个二级标题（subtitle）。适合放"深度知识点"。
  factory KnowledgeSection.list({
    required List<KnowledgeItem> items,
    String? subtitle,
    String? subtitleIcon,
    Color? subtitleColor,
  }) =>
      KnowledgeSection._(
        kind: _SectionKind.list,
        items: items,
        subtitle: subtitle,
        subtitleIcon: subtitleIcon,
        subtitleColor: subtitleColor,
      );

  final _SectionKind kind;
  final List<KnowledgeItem> items;
  final String? subtitle;
  final String? subtitleIcon;
  final Color? subtitleColor;
}

enum _SectionKind { grid, list }

/// 单条知识条目。
///
/// `icon` 和 `dot` 二选一（都不给也可以）：
/// - `dot` 显示为一个带发光效果的彩色圆点（适合"颜色/信号类"标识）
/// - `icon` 显示为 emoji / 符号
class KnowledgeItem {
  const KnowledgeItem({
    required this.title,
    required this.desc,
    this.titleColor = const Color(0xFF60A5FA),
    this.icon,
    this.dot,
    this.active = false,
  });

  final String title;
  final String desc;
  final Color titleColor;
  final String? icon;
  final Color? dot;
  final bool active;
}

class _KnowledgeGridTile extends StatelessWidget {
  const _KnowledgeGridTile({required this.item});
  final KnowledgeItem item;

  @override
  Widget build(BuildContext context) {
    final active = item.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? item.titleColor.withAlpha(30) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? item.titleColor : const Color(0xFF334155),
          width: active ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (item.dot != null)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.dot,
                  boxShadow: [
                    BoxShadow(color: item.dot!.withAlpha(120), blurRadius: 4)
                  ],
                ),
              ),
            if (item.icon != null)
              Text(item.icon!, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: item.titleColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 3),
          Text(
            item.desc,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 10,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeLongTile extends StatelessWidget {
  const _KnowledgeLongTile({required this.item});
  final KnowledgeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (item.icon != null)
              Text(item.icon!, style: const TextStyle(fontSize: 14)),
            if (item.dot != null)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.dot,
                  boxShadow: [
                    BoxShadow(color: item.dot!.withAlpha(120), blurRadius: 4)
                  ],
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: item.titleColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            item.desc,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

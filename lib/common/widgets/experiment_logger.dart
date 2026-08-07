import 'package:flutter/material.dart';

/// 快照提供者回调：各 sim 提供当前「参数 + 读数」快照 Map。
/// key 需与 [ExperimentLogger.columns] 的 key 匹配。
typedef SnapshotProvider = Map<String, dynamic> Function();

/// 表格列定义（供表头渲染与取值）。
@immutable
class ColumnDef {
  final String key;
  final String label;
  final bool isParam;

  const ColumnDef({required this.key, required this.label, this.isParam = false});
}

/// 实验记录器：学生手动快照当前实验状态，累积对比数据。
///
/// - 数据仅内存（session 级）· 不持久化
/// - 容量上限 [maxRows]（默认 20），超出拒绝新增并提示
/// - [onExport] 预留导出回调，null 时不显示导出按钮（本轮不实现导出）
class ExperimentLogger extends StatefulWidget {
  const ExperimentLogger({
    super.key,
    required this.columns,
    required this.snapshotProvider,
    this.maxRows = 20,
    this.compact = false,
    this.onExport,
  });

  final List<ColumnDef> columns;
  final SnapshotProvider snapshotProvider;
  final int maxRows;
  final bool compact;
  final VoidCallback? onExport;

  @override
  State<ExperimentLogger> createState() => _ExperimentLoggerState();
}

class _ExperimentLoggerState extends State<ExperimentLogger> {
  final List<Map<String, dynamic>> _rows = [];

  void _record() {
    final provider = widget.snapshotProvider;
    final snapshot = provider();
    setState(() {
      if (_rows.length >= widget.maxRows) {
        _showFullNotice();
        return;
      }
      _rows.insert(0, {
        'ts': _now(),
        ...snapshot,
      });
    });
  }

  String _now() {
    final t = DateTime.now();
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(t.hour)}:${p(t.minute)}:${p(t.second)}';
  }

  void _showFullNotice() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('记录已满（最多 ${widget.maxRows} 条），请删除最早记录',
              style: const TextStyle(fontSize: 12)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _removeAt(int index) => setState(() => _rows.removeAt(index));

  void _clearAll() => setState(() => _rows.clear());

  String _cellText(Map<String, dynamic> row, String key) {
    final v = row[key];
    if (v == null) return '—';
    if (v is double) return v.toStringAsFixed(2);
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final textSize = compact ? 10.5 : 12.0;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 6 : 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.table_chart_outlined, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('实验记录（${_rows.length}/${widget.maxRows}）',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w800, color: const Color(0xFF334155))),
                ),
                if (widget.onExport != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    tooltip: '导出',
                    onPressed: widget.onExport,
                  ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                  tooltip: '清空全部',
                  onPressed: _rows.isEmpty ? null : _clearAll,
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (_rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('还没有记录。调整参数后点击「记录本次实验」。',
                    style: TextStyle(fontSize: textSize - 1, color: const Color(0xFF94A3B8))),
              )
            else
              _buildTable(textSize),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _record,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: compact ? 4 : 8),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: Text('记录本次实验', style: TextStyle(fontSize: textSize)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(double textSize) {
    final cols = widget.columns;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: {
          0: const IntrinsicColumnWidth(),
          1: const IntrinsicColumnWidth(),
          for (var i = 0; i < cols.length; i++) i + 2: const IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(color: const Color(0xFFE2E8F0), width: 0.5),
        children: [
          // 表头
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF)),
            children: [
              _headerCell('#', textSize),
              _headerCell('时间', textSize),
              for (final c in cols)
                _headerCell(c.label, textSize, isParam: c.isParam),
              _headerCell('', textSize),
            ],
          ),
          // 数据行
          for (final (i, row) in _rows.indexed)
            TableRow(
              children: [
                _cell('${_rows.length - i}', textSize),
                _cell(row['ts']?.toString() ?? '—', textSize, muted: true),
                for (final c in cols) _cell(_cellText(row, c.key), textSize),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, size: 12, color: Color(0xFF94A3B8)),
                  tooltip: '删除该行',
                  onPressed: () => _removeAt(i),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double size, {bool isParam = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(
        isParam ? '$text*' : text,
        style: TextStyle(
          fontSize: size - 1,
          fontWeight: FontWeight.w700,
          color: isParam ? const Color(0xFF7C3AED) : const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _cell(String text, double size, {bool muted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size - 1,
          color: muted ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

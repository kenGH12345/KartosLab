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
/// 两种数据模式：
/// - 非受控（默认，[rows] == null）：内部持有行数据，[snapshotProvider] 取快照
/// - 受控（[rows] != null）：行数据由外部持有（InquiryDrawer 状态机统一管理），
///   记录/删除/清空分别回调 [onRecord]/[onDeleteAt]/[onClear]
///
/// - 数据仅内存（session 级）· 不持久化
/// - 容量上限 [maxRows]（默认 20），超出拒绝新增并提示
/// - [enabled] == false 时记录按钮禁用（IXD Spec TASK-002：任务未确认时
///   允许调参数但不允许正式记录）
/// - [onExport] 预留导出回调，null 时不显示导出按钮（本轮不实现导出）
/// - [onRowsChanged] 可选：每次记录/删除/清空后回调当前行列表，供外部消费
///   （如 SnapshotChart 图表联动）；null 时行为与旧版一致（向后兼容）
class ExperimentLogger extends StatefulWidget {
  const ExperimentLogger({
    super.key,
    required this.columns,
    required this.snapshotProvider,
    this.maxRows = 20,
    this.compact = false,
    this.onExport,
    this.onRowsChanged,
    this.rows,
    this.onRecord,
    this.onDeleteAt,
    this.onClear,
    this.enabled = true,
  });

  final List<ColumnDef> columns;
  final SnapshotProvider snapshotProvider;
  final int maxRows;
  final bool compact;
  final VoidCallback? onExport;
  final ValueChanged<List<Map<String, dynamic>>>? onRowsChanged;

  /// 受控模式行数据；非 null 时内部不再持有状态。
  final List<Map<String, dynamic>>? rows;

  /// 受控模式记录回调。
  final VoidCallback? onRecord;

  /// 受控模式删除指定行回调。
  final void Function(int index)? onDeleteAt;

  /// 受控模式清空回调。
  final VoidCallback? onClear;

  /// 记录按钮是否可用（false = TASK-002 未确认任务禁用）。
  final bool enabled;

  @override
  State<ExperimentLogger> createState() => _ExperimentLoggerState();
}

class _ExperimentLoggerState extends State<ExperimentLogger> {
  final List<Map<String, dynamic>> _localRows = [];

  List<Map<String, dynamic>> get _rows => widget.rows ?? _localRows;

  bool get _controlled => widget.rows != null;

  void _record() {
    if (_controlled) {
      widget.onRecord?.call();
      return;
    }
    if (_rows.length >= widget.maxRows) {
      _showFullNotice();
      return;
    }
    final snapshot = widget.snapshotProvider();
    setState(() {
      _rows.insert(0, {
        'ts': _now(),
        ...snapshot,
      });
    });
    widget.onRowsChanged?.call(_rows);
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

  void _removeAt(int index) {
    if (_controlled) {
      widget.onDeleteAt?.call(index);
      return;
    }
    setState(() => _rows.removeAt(index));
    widget.onRowsChanged?.call(_rows);
  }

  void _clearAll() {
    if (_controlled) {
      widget.onClear?.call();
      return;
    }
    setState(() => _rows.clear());
    widget.onRowsChanged?.call(_rows);
  }

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
              child: Tooltip(
                // TASK-002：未确认任务时禁用 + 提示
                message: widget.enabled ? '' : '请先完成上一阶段后解锁记录',
                child: FilledButton.icon(
                  onPressed: widget.enabled ? _record : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: compact ? 4 : 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label:
                      Text('记录本次实验', style: TextStyle(fontSize: textSize)),
                ),
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

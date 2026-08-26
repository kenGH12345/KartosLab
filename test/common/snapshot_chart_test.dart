import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/chart/snapshot_chart.dart';
import 'package:kratos/common/widgets/experiment_logger.dart';
import 'package:kratos/common/widgets/inquiry_drawer.dart';
import 'package:kratos/common/widgets/inquiry_models.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  const columns = [
    ColumnDef(key: 'resistance', label: '电阻(Ω)', isParam: true),
    ColumnDef(key: 'current', label: '电流(A)'),
  ];

  Finder chartPainter() => find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter.runtimeType.toString().contains('SnapshotChartPainter'),
      );

  testWidgets('默认选轴：x=第一个 param 列，y=第一个 reading 列，≥2 数值行渲染散点', (tester) async {
    await tester.pumpWidget(wrap(const SnapshotChart(
      rows: [
        {'resistance': 10.0, 'current': 1.0},
        {'resistance': 20.0, 'current': 0.5},
      ],
      columns: columns,
    )));
    expect(find.text('关系图（电阻(Ω) × 电流(A)）'), findsOneWidget);
    expect(chartPainter(), findsOneWidget);
  });

  testWidgets('不足 2 组数据时显示空态提示，不渲染散点', (tester) async {
    await tester.pumpWidget(wrap(const SnapshotChart(
      rows: [
        {'resistance': 10.0, 'current': 1.0},
      ],
      columns: columns,
    )));
    expect(find.textContaining('记录 ≥ 2 组数据后自动生成关系图'), findsOneWidget);
    expect(chartPainter(), findsNothing);
  });

  testWidgets('无 param 列/reading 列时返回空（不崩溃）', (tester) async {
    await tester.pumpWidget(wrap(const SnapshotChart(
      rows: [
        {'v': 1.0},
        {'v': 2.0},
      ],
      columns: [ColumnDef(key: 'v', label: 'V')],
    )));
    // 无 param 列 → 无 x 轴 → 不渲染图表区块（不崩溃）
    expect(find.textContaining('关系图（'), findsNothing);
    expect(chartPainter(), findsNothing);
  });

  testWidgets('非数值行（如文本列）被跳过，数值行仍渲染', (tester) async {
    await tester.pumpWidget(wrap(const SnapshotChart(
      rows: [
        {'resistance': 10.0, 'current': 1.0, 'winner': '蓝队'},
        {'resistance': 20.0, 'current': 0.5, 'winner': '红队'},
        {'resistance': 'N/A', 'current': 'N/A'},
      ],
      columns: [
        ColumnDef(key: 'resistance', label: '电阻(Ω)', isParam: true),
        ColumnDef(key: 'current', label: '电流(A)'),
      ],
    )));
    // 两行数值 + 一行非数值：非数值行被跳过，仍可成图
    expect(chartPainter(), findsOneWidget);
  });

  testWidgets('ExperimentLogger 记录后 onRowsChanged 回调 · 与 SnapshotChart 联动', (tester) async {
    List<Map<String, dynamic>>? latest;
    var value = 1.0;
    await tester.pumpWidget(wrap(ExperimentLogger(
      columns: columns,
      snapshotProvider: () => {'resistance': 10.0, 'current': value},
      onRowsChanged: (rows) => latest = rows,
    )));

    // 记录 1 次：回调拿到 1 行
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    expect(latest, hasLength(1));
    expect(latest!.first['current'], 1.0);

    // 记录 2 次后 latest 2 行
    value = 0.5;
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    expect(latest, hasLength(2));

    // 清空：回调拿到 0 行
    await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
    await tester.pump();
    expect(latest, isEmpty);
  });

  testWidgets('InquiryDrawer 集成：记录 2 次后出现关系图', (tester) async {
    // 状态机下 Drawer 内容较高（5 阶段卡片），放大测试视口确保可点击
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    var value = 10.0;
    await tester.pumpWidget(wrap(InquiryDrawer(
      task: const InquiryTask(
        question: '保持电压不变，改变电阻，观察电流变化。',
        snapshotColumns: [
          InquirySnapshotColumn(key: 'resistance', label: '电阻(Ω)', source: 'param'),
          InquirySnapshotColumn(key: 'current', label: '电流(A)'),
        ],
      ),
      columns: columns,
      snapshotProvider: () => {'resistance': value, 'current': 1.0},
      open: true,
    )));

    // 无预测题 → 猜测跳过 · 任务卡 Active：先确认任务解锁操作（TASK-001）
    expect(find.text('我已了解任务，开始实验'), findsOneWidget);
    await tester.tap(find.text('我已了解任务，开始实验'));
    await tester.pump(const Duration(milliseconds: 600));

    // 操作卡 Active：tap 记录按钮（pump 充分时长确保 ensureVisible 滚动与
    // AnimatedSize 动画完全结束，避免 hit-test 命中动画中间态）
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('记录本次实验'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('实验记录（1/20）'), findsOneWidget);
    value = 20.0;
    // 记录卡已解锁：操作卡 + 记录卡各有记录按钮，点操作卡的（首个）
    expect(find.text('记录本次实验'), findsNWidgets(2));
    await tester.tap(find.text('记录本次实验').first);
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.textContaining('实验记录（2/20）'), findsOneWidget);
    expect(find.textContaining('关系图（电阻(Ω) × 电流(A)）'), findsOneWidget);
    expect(chartPainter(), findsOneWidget);
  });

  testWidgets('删除单行后 onRowsChanged 联动', (tester) async {
    List<Map<String, dynamic>>? latest;
    await tester.pumpWidget(wrap(ExperimentLogger(
      columns: columns,
      snapshotProvider: () => {'resistance': 10.0, 'current': 1.0},
      onRowsChanged: (rows) => latest = rows,
    )));
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    expect(latest, hasLength(2));

    final deleteBtn = tester.widget<IconButton>(
      find.ancestor(of: find.byIcon(Icons.close), matching: find.byType(IconButton)).first,
    );
    deleteBtn.onPressed!();
    await tester.pump();
    expect(latest, hasLength(1));
  });

  testWidgets('maxRows 满额后记录不触发 onRowsChanged', (tester) async {
    List<Map<String, dynamic>>? latest;
    await tester.pumpWidget(wrap(ExperimentLogger(
      columns: columns,
      snapshotProvider: () => {'resistance': 10.0, 'current': 1.0},
      maxRows: 2,
      onRowsChanged: (rows) => latest = rows,
    )));
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    expect(latest, hasLength(2));

    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    expect(latest, hasLength(2)); // 满额拒绝 → 回调未再触发
    expect(find.text('实验记录（2/2）'), findsOneWidget);
  });

  testWidgets('全相等值（单点退化）不崩溃且有默认跨度', (tester) async {
    await tester.pumpWidget(wrap(const SnapshotChart(
      rows: [
        {'resistance': 10.0, 'current': 1.0},
        {'resistance': 10.0, 'current': 1.0},
      ],
      columns: columns,
    )));
    expect(chartPainter(), findsOneWidget);
  });

  testWidgets('行数≥2 但所选轴无数值时显示"缺少数值数据"（color_vision 场景）', (tester) async {
    await tester.pumpWidget(wrap(const SnapshotChart(
      rows: [
        {'red': 1.0, 'colorName': '红'},
        {'red': 0.5, 'colorName': '红+绿'},
      ],
      columns: [
        ColumnDef(key: 'red', label: '红', isParam: true),
        ColumnDef(key: 'colorName', label: '混合色'),
      ],
    )));
    expect(find.textContaining('有效数值数据不足 2 组'), findsOneWidget);
    expect(chartPainter(), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/widgets/experiment_logger.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('初始为空：无记录提示可见', (tester) async {
    await tester.pumpWidget(wrap(ExperimentLogger(
      columns: const [ColumnDef(key: 'current', label: '电流(A)')],
      snapshotProvider: () => {'current': 1.0},
    )));
    expect(find.textContaining('还没有记录'), findsOneWidget);
  });

  testWidgets('点击记录追加一行，表格显示快照值', (tester) async {
    var value = 1.0;
    await tester.pumpWidget(wrap(ExperimentLogger(
      columns: const [
        ColumnDef(key: 'resistance', label: '电阻(Ω)', isParam: true),
        ColumnDef(key: 'current', label: '电流(A)'),
      ],
      snapshotProvider: () => {'resistance': 10.0, 'current': value},
    )));
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    expect(find.text('10.00'), findsOneWidget);
    expect(find.text('1.00'), findsOneWidget);

    value = 2.0;
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    expect(find.text('2.00'), findsOneWidget);
    // 两行数据：两行 resistance 均为 10.00
    expect(find.text('10.00'), findsNWidgets(2));
  });

  testWidgets('达到 maxRows 后拒绝新增并提示', (tester) async {
    await tester.pumpWidget(wrap(ExperimentLogger(
      columns: const [ColumnDef(key: 'v', label: 'V')],
      snapshotProvider: () => {'v': 1.0},
      maxRows: 2,
    )));
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    expect(find.textContaining('记录已满'), findsOneWidget);
    // 计数显示 2/2
    expect(find.text('实验记录（2/2）'), findsOneWidget);
  });

  testWidgets('删除单行', (tester) async {
    await tester.pumpWidget(wrap(ExperimentLogger(
      columns: const [ColumnDef(key: 'v', label: 'V')],
      snapshotProvider: () => {'v': 1.0},
    )));
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    expect(find.text('实验记录（1/20）'), findsOneWidget);
    // 直接触发删除按钮（表格横向滚动时 hit-test 可能偏移）
    final deleteBtn = tester.widget<IconButton>(
      find.ancestor(of: find.byIcon(Icons.close), matching: find.byType(IconButton)),
    );
    deleteBtn.onPressed!();
    await tester.pump();
    expect(find.text('实验记录（0/20）'), findsOneWidget);
  });

  testWidgets('清空全部', (tester) async {
    await tester.pumpWidget(wrap(ExperimentLogger(
      columns: const [ColumnDef(key: 'v', label: 'V')],
      snapshotProvider: () => {'v': 1.0},
    )));
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
    await tester.pump();
    expect(find.text('实验记录（0/20）'), findsOneWidget);
    expect(find.textContaining('还没有记录'), findsOneWidget);
  });

  testWidgets('快照 Map 缺失 key 时显示占位符', (tester) async {
    await tester.pumpWidget(wrap(ExperimentLogger(
      columns: const [ColumnDef(key: 'missing', label: '缺失列')],
      snapshotProvider: () => {'other': 1.0},
    )));
    await tester.tap(find.text('记录本次实验'));
    await tester.pump();
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('onExport == null 时不显示导出按钮', (tester) async {
    await tester.pumpWidget(wrap(ExperimentLogger(
      columns: const [ColumnDef(key: 'v', label: 'V')],
      snapshotProvider: () => {'v': 1.0},
    )));
    expect(find.byIcon(Icons.file_download_outlined), findsNothing);
  });
}

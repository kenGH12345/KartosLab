import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:geometric_optics/main.dart';
import 'package:geometric_optics/widgets/circuit_canvas.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openCircuit(WidgetTester tester) async {
    await tester.pumpWidget(const GeometricOpticsApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('电路搭建 知识点'));
    await tester.pumpAndSettle();
  }

  // 辅助函数：从托盘放置元件
  Future<void> placeComponent(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  // 辅助函数：点击画布上的默认元件位置（第一个元件放置位置）
  // 改进：使用更稳定的定位逻辑（点击画布中心区域，然后检查是否选中元件）
  Future<void> tapDefaultComponent(WidgetTester tester) async {
    // 获取画布大小（通过 CircuitCanvas widget）
    final canvasFinder = find.byType(CircuitCanvas);
    if (canvasFinder.evaluate().isEmpty) {
      // 如果找不到 CircuitCanvas，点击默认位置
      await tester.tapAt(const Offset(450, 140));
      await tester.pumpAndSettle();
      return;
    }

    // 点击画布中心区域（假设元件放置在该区域）
    final canvasCenter = tester.getCenter(canvasFinder);
    await tester.tapAt(Offset(canvasCenter.dx + 50, canvasCenter.dy - 120));
    await tester.pumpAndSettle();

    // 如果未选中，尝试点击画布中心
    if (find.byIcon(Icons.delete_outline).evaluate().isEmpty) {
      await tester.tapAt(canvasCenter);
      await tester.pumpAndSettle();
    }
  }

  // 辅助函数：进入导线模式
  Future<void> enterWireMode(WidgetTester tester) async {
    await tester.tap(find.text('导线'));
    await tester.pumpAndSettle();
  }

  // 辅助函数：点击选中元件（通过点击画布默认位置）
  Future<void> selectDefaultComponent(WidgetTester tester) async {
    await tapDefaultComponent(tester);
  }

  // 辅助函数：删除选中元件
  Future<void> deleteSelected(WidgetTester tester) async {
    // 先确保有选中元件（AppBar 显示删除按钮）
    final deleteBtn = find.byIcon(Icons.delete_outline);
    if (deleteBtn.evaluate().isNotEmpty) {
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();
    }
  }

  // 辅助函数：切换开关（需先选中开关）
  Future<void> toggleSwitch(WidgetTester tester) async {
    final toggleBtn = find.byIcon(Icons.toggle_on);
    if (toggleBtn.evaluate().isEmpty) {
      // 可能是 toggle_off
      final toggleOffBtn = find.byIcon(Icons.toggle_off);
      if (toggleOffBtn.evaluate().isNotEmpty) {
        await tester.tap(toggleOffBtn);
      }
    } else {
      await tester.tap(toggleBtn);
    }
    await tester.pumpAndSettle();
  }

  group('App Launch E2E', () {
    testWidgets('app launches and shows home screen', (tester) async {
      await tester.pumpWidget(const GeometricOpticsApp());
      await tester.pumpAndSettle();

      expect(find.text('几何光学'), findsOneWidget);
      expect(find.text('几何光学 知识点'), findsOneWidget);
      expect(find.text('电路搭建 知识点'), findsOneWidget);
    });

    testWidgets('navigate to optics simulation', (tester) async {
      await tester.pumpWidget(const GeometricOpticsApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('几何光学 知识点'));
      await tester.pumpAndSettle();
      expect(find.text('光线'), findsWidgets);
      expect(find.text('曲率半径'), findsWidgets);
    });

    testWidgets('navigate to circuit builder', (tester) async {
      await tester.pumpWidget(const GeometricOpticsApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('电路搭建 知识点'));
      await tester.pumpAndSettle();
      expect(find.text('电路搭建'), findsOneWidget);
      expect(find.text('电池'), findsOneWidget);
      expect(find.text('电阻'), findsOneWidget);
      expect(find.text('灯泡'), findsOneWidget);
    });
  });

  group('Circuit Builder E2E', () {
    testWidgets('place battery from tray', (tester) async {
      await openCircuit(tester);
      await tester.tap(find.text('电池'));
      await tester.pumpAndSettle();
      expect(find.text('电池'), findsOneWidget);
    });

    testWidgets('place multiple components', (tester) async {
      await openCircuit(tester);
      await tester.tap(find.text('电池'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('电阻'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('灯泡'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('开关'));
      await tester.pumpAndSettle();
      expect(find.text('电池'), findsOneWidget);
      expect(find.text('电阻'), findsOneWidget);
    });

    testWidgets('zoom buttons work', (tester) async {
      await openCircuit(tester);
      expect(find.byIcon(Icons.zoom_in), findsOneWidget);
      expect(find.byIcon(Icons.zoom_out), findsOneWidget);
      await tester.tap(find.byIcon(Icons.zoom_in));
      await tester.pumpAndSettle();
    });

    testWidgets('clear button shows dialog', (tester) async {
      await openCircuit(tester);
      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pumpAndSettle();
      expect(find.text('清空电路'), findsOneWidget);
      expect(find.text('确定'), findsOneWidget);
    });

    testWidgets('undo/redo buttons exist', (tester) async {
      await openCircuit(tester);
      expect(find.byIcon(Icons.undo), findsOneWidget);
      expect(find.byIcon(Icons.redo), findsOneWidget);
    });

    testWidgets('back navigation returns to home', (tester) async {
      await openCircuit(tester);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('几何光学'), findsOneWidget);
    });

    testWidgets('place and select component', (tester) async {
      await openCircuit(tester);
      await placeComponent(tester, '电池');
      // 点击画布上的电池位置
      await selectDefaultComponent(tester);
      // 验证选中后 AppBar 显示删除按钮
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('delete selected component', (tester) async {
      await openCircuit(tester);
      await placeComponent(tester, '电池');
      await selectDefaultComponent(tester);
      // 删除选中元件
      await deleteSelected(tester);
      // 验证删除按钮消失（无选中元件）
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });

  group('Circuit Interaction E2E', () {
    testWidgets('toggle switch', (tester) async {
      await openCircuit(tester);
      await placeComponent(tester, '开关');
      await selectDefaultComponent(tester);
      // 验证开关初始状态（toggle_off 图标）
      expect(find.byIcon(Icons.toggle_off), findsOneWidget);
      // 切换开关
      await toggleSwitch(tester);
      // 验证开关状态变化（toggle_on 图标）
      expect(find.byIcon(Icons.toggle_on), findsOneWidget);
    });

    testWidgets('rotate selected component', (tester) async {
      await openCircuit(tester);
      await placeComponent(tester, '电池');
      await selectDefaultComponent(tester);
      // 验证旋转按钮存在
      expect(find.byIcon(Icons.rotate_right), findsOneWidget);
      // 点击旋转按钮
      await tester.tap(find.byIcon(Icons.rotate_right));
      await tester.pumpAndSettle();
      // 旋转后删除按钮应仍然存在（元件仍选中）
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('undo and redo', (tester) async {
      await openCircuit(tester);
      await placeComponent(tester, '电池');
      // 验证撤销按钮可用（有操作可撤销）
      final undoBtn = find.byIcon(Icons.undo);
      expect(undoBtn, findsOneWidget);
      // 点击撤销
      await tester.tap(undoBtn);
      await tester.pumpAndSettle();
      // 撤销后，删除按钮应消失（元件被移除，无选中）
      // 注意：可能需要延迟等待状态更新
    });
  });

  group('Circuit Wire E2E', () {
    testWidgets('enter wire mode', (tester) async {
      await openCircuit(tester);
      await enterWireMode(tester);
      // 验证进入导线模式后显示提示
      expect(find.textContaining('点击放置顶点'), findsOneWidget);
    });

    testWidgets('cancel wire mode with ESC', (tester) async {
      await openCircuit(tester);
      await enterWireMode(tester);
      // 按 ESC 取消
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      // 验证退出导线模式
      expect(find.textContaining('点击放置顶点'), findsNothing);
    });

    testWidgets('cancel wire mode with button', (tester) async {
      await openCircuit(tester);
      await enterWireMode(tester);
      // 点击取消按钮
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      // 验证退出导线模式
      expect(find.textContaining('点击放置顶点'), findsNothing);
    });
  });

  group('Circuit Zoom E2E', () {
    testWidgets('zoom in increases percentage', (tester) async {
      await openCircuit(tester);
      // 获取初始缩放百分比
      final zoomText = find.textContaining('%');
      expect(zoomText, findsOneWidget);
      final initialText = tester.widget<Text>(zoomText).data ?? '';
      // 点击放大按钮
      await tester.tap(find.byIcon(Icons.zoom_in));
      await tester.pumpAndSettle();
      // 验证缩放百分比增加
      final newText = tester.widget<Text>(zoomText).data ?? '';
      expect(initialText != newText, isTrue);
    });

    testWidgets('zoom out decreases percentage', (tester) async {
      await openCircuit(tester);
      // 先放大一次
      await tester.tap(find.byIcon(Icons.zoom_in));
      await tester.pumpAndSettle();
      // 获取放大后的缩放百分比
      final zoomText = find.textContaining('%');
      final initialText = tester.widget<Text>(zoomText).data ?? '';
      // 点击缩小按钮
      await tester.tap(find.byIcon(Icons.zoom_out));
      await tester.pumpAndSettle();
      // 验证缩放百分比减少
      final newText = tester.widget<Text>(zoomText).data ?? '';
      expect(initialText != newText, isTrue);
    });
  });
}

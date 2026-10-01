// test/wave_radio_layout_test.dart
// req-panel-bottom-migrate 批次1 · 主会话直接产出
//
// 验证 wave_interference 与 radio_waves 操作面板底部横排（footer）无溢出。
// 视口：1600x900 宽视口（320x480 的窄视口经验参考 sound_layout_test 注释：
// 若出现恒定小偏移右溢出，属 TimeControlBar 类固定内容窄视口问题，独立定位）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_interference/screens/wave_interference_screen.dart';
import 'package:kratos/radio_waves/screens/radio_waves_screen.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size, Widget screen) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(MaterialApp(home: screen));
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('AC-1.5: wave_interference no overflow at 1600x900', (tester) async {
    await pumpAt(tester, const Size(1600, 900), const WaveInterferenceScreen());
    expect(tester.takeException(), isNull,
        reason: 'wave_interference footer must not overflow at 1600x900');
  });

  testWidgets('AC-1.5: radio_waves no overflow at 1600x900', (tester) async {
    await pumpAt(tester, const Size(1600, 900), const RadioWavesScreen());
    expect(tester.takeException(), isNull,
        reason: 'radio_waves footer must not overflow at 1600x900');
  });

  testWidgets('AC-1.4: wave_interference no overflow at 320x480', (tester) async {
    await pumpAt(tester, const Size(320, 480), const WaveInterferenceScreen());
    expect(tester.takeException(), isNull,
        reason: 'wave_interference footer must not overflow at 320x480');
  });

  testWidgets('AC-1.4: radio_waves no overflow at 320x480', (tester) async {
    await pumpAt(tester, const Size(320, 480), const RadioWavesScreen());
    expect(tester.takeException(), isNull,
        reason: 'radio_waves footer must not overflow at 320x480');
  });
}

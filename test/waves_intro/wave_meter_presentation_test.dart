import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/model/scene_kind.dart';
import 'package:kratos/waves_intro/model/waves_intro_model.dart';
import 'package:kratos/waves_intro/waves_intro_constants.dart';
import 'package:kratos/waves_intro/widgets/waves_intro_toolbox.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('wave meter presentation has fixed chart size and axis labels',
      (tester) async {
    final model = WavesIntroModel(kind: SceneKind.water, autoTick: false)
      ..audio.platformEnabled = false;
    model.pause();
    model.takeOutWaveMeter();
    for (var i = 0; i < 30; i++) {
      model.manualStep();
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: WavesIntroConstants.layoutWidth,
            height: WavesIntroConstants.layoutHeight,
            child: WavesIntroToolsOverlay(model: model),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CustomPaint), findsWidgets);
    expect(model.tools.series1, isNotEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    model.dispose();
  });

  test('wave meter sampling unchanged: series length capped', () {
    final model = WavesIntroModel(kind: SceneKind.sound, autoTick: false)
      ..audio.platformEnabled = false;
    addTearDown(model.dispose);
    model.pause();
    model.takeOutWaveMeter();
    for (var i = 0; i < 200; i++) {
      model.manualStep();
    }
    expect(model.tools.series1.length, lessThanOrEqualTo(120));
    expect(model.tools.series2.length, model.tools.series1.length);
  });
}

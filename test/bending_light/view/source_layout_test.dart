import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/components/control_widgets.dart';
import 'package:kratos/bending_light/model/substance.dart';
import 'package:kratos/bending_light/screens/bending_light_viewport.dart';
import 'package:kratos/bending_light/view/source_layout.dart';

void main() {
  test('layout bounds stay 834 by 504 and fill the window', () {
    expect(SourceLayout.layoutWidth, 834);
    expect(SourceLayout.layoutHeight, 504);
    expect(BendingLightViewport.stageWidth, 834);
    expect(BendingLightViewport.stageHeight, 504);
    // Each axis fills the window, so a 1024×618 view has no side or top margin.
    expect(BendingLightViewport.scaleX(const Size(1024, 618)), closeTo(1024 / 834, 1e-9));
    expect(BendingLightViewport.scaleY(const Size(1024, 618)), closeTo(618 / 504, 1e-9));
  });

  test('medium panel anchors come from the interface, not the screen top', () {
    expect(SourceLayout.introTopPanelBottom, 236);
    expect(SourceLayout.introBottomPanelTop, 273);
    expect(SourceLayout.mediumPanelWidth, 237);
    expect(SourceLayout.edgePadding, 10);
  });

  test('chart body is 135 by 100 scaled by 0.93, plot is inset', () {
    const body = Size(135 * 0.93, 100 * 0.93);
    expect(body.width, closeTo(125.55, 1e-9));
    expect(body.height, 93);
    final plot = SourceLayout.chartPlotLocal(body);
    expect(plot.width, lessThan(body.width));
    expect(plot.height, lessThan(body.height));
    expect(plot.left, greaterThan(0));
  });

  test('chart gradient matches WaveSensorNode stops', () {
    expect(SourceLayout.chartFillTop, const Color(0xFF5EB4DE));
    expect(SourceLayout.chartFillBottom, const Color(0xFF005B86));
    expect(SourceLayout.chartStrokeTop, const Color(0xFF2F9BCE));
    expect(SourceLayout.chartStrokeBottom, const Color(0xFF00486A));
  });

  testWidgets('medium panel width is the source slider plus margins', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: MediumControlPanel(
          title: 'Material',
          substance: Substance.air,
          decimals: 2,
          onSubstance: (_) {},
          onCustomIndex: (_) {},
        ),
      ),
    ));
    expect(
      tester.getSize(find.byType(MediumControlPanel)).width,
      SourceLayout.mediumPanelWidth,
    );
  });
}

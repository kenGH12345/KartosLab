import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/components/control_widgets.dart';
import 'package:kratos/bending_light/components/intensity_meter_widget.dart';
import 'package:kratos/bending_light/components/probe_glyph.dart';
import 'package:kratos/bending_light/components/scenery_controls.dart';
import 'package:kratos/bending_light/components/toolbox_icons.dart';
import 'package:kratos/bending_light/components/wave_view.dart';
import 'package:kratos/bending_light/model/substance.dart';
import 'package:kratos/bending_light/view/source_layout.dart';
import 'package:kratos/bending_light/bl_strings.dart';

void main() {
  test('graph highlight is ShadedRectangle, not flat white', () {
    const base = Color(0xFFFFFFFF);
    final darker = graphHighlightLuminance(base, -0.6);
    final dark = graphHighlightLuminance(base, -0.5);
    expect(darker, isNot(base));
    expect(dark, isNot(base));
    expect(darker.computeLuminance(), lessThan(base.computeLuminance()));
    expect(graphHighlightLuminance(base, 0.5), base);
  });

  testWidgets('index slider updates the model and resets with the value', (tester) async {
    var n = Substance.water.indexForRed;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: PhetHSlider(
            value: n,
            min: MediumControlPanel.iorMin,
            max: MediumControlPanel.iorMax,
            trackWidth: SourceLayout.sliderTrackWidth,
            onChanged: (v) => n = v,
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(PhetHSlider)).width, SourceLayout.sliderTrackWidth);

    await tester.drag(find.byType(PhetHSlider), const Offset(40, 0));
    await tester.pump();
    expect(n, greaterThan(Substance.water.indexForRed));

    n = Substance.air.indexForRed;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: PhetHSlider(
            value: n,
            min: MediumControlPanel.iorMin,
            max: MediumControlPanel.iorMax,
            onChanged: (v) => n = v,
          ),
        ),
      ),
    );
    expect(n, Substance.air.indexForRed);
  });

  testWidgets('combo box opens, selects, and closes on reset', (tester) async {
    var name = BlStrings.air;
    Future<void> pump() {
      return tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: PhetComboBox(
              value: name,
              items: const [BlStrings.air, BlStrings.water, BlStrings.glass],
              onSelected: (v) => name = v,
            ),
          ),
        ),
      );
    }

    await pump();
    expect(find.text(BlStrings.water), findsNothing);

    await tester.tap(find.byType(PhetComboBox));
    await tester.pump();
    expect(find.text(BlStrings.water), findsOneWidget);
    expect(find.text(BlStrings.glass), findsOneWidget);

    await tester.tap(find.text(BlStrings.water));
    await tester.pump();
    expect(name, BlStrings.water);

    name = BlStrings.air;
    await pump();
    expect(find.text(BlStrings.water), findsNothing);
    expect(find.text(BlStrings.air), findsWidgets);
  });

  testWidgets('arrow buttons step and stop at the bounds', (tester) async {
    var n = 1.5;
    const min = 1.0;
    const max = 1.6;
    const step = 0.1;

    Future<void> pump() {
      return tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              PhetArrowButton(
                pointRight: false,
                enabled: n > min + 1e-9,
                onPressed: () {
                  n = (n - step).clamp(min, max);
                },
              ),
              PhetArrowButton(
                pointRight: true,
                enabled: n < max - 1e-9,
                onPressed: () {
                  n = (n + step).clamp(min, max);
                },
              ),
            ],
          ),
        ),
      );
    }

    await pump();
    await tester.tap(find.bySemanticsLabel('increase'));
    await pump();
    expect(n, closeTo(1.6, 1e-9));

    await tester.tap(find.bySemanticsLabel('increase'), warnIfMissed: false);
    await pump();
    expect(n, closeTo(1.6, 1e-9));

    await tester.tap(find.bySemanticsLabel('decrease'));
    await pump();
    expect(n, closeTo(1.5, 1e-9));
  });

  testWidgets('toolbox drag preview is the icon, not a text chip', (tester) async {
    Offset? dropped;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ToolboxChip(
            semanticsLabel: 'Intensity',
            onDragEnd: (g) => dropped = g,
            child: const IntensityToolboxIcon(),
          ),
        ),
      ),
    );

    expect(find.text(BlStrings.intensity), findsNothing);
    expect(find.byType(IntensityToolboxIcon), findsOneWidget);
    expect(find.byType(ProbeGlyph), findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(find.byType(ToolboxChip)));
    await gesture.moveBy(const Offset(80, 40));
    await tester.pump();
    expect(find.byType(IntensityToolboxIcon), findsWidgets);
    expect(find.text(BlStrings.intensity), findsNothing);
    await gesture.up();
    await tester.pump();
    expect(dropped, isNotNull);
  });

  test('chart body bounds stay on the source rectangle', () {
    expect(SourceLayout.chartOuterWidth, 135);
    expect(SourceLayout.chartOuterHeight, 100);
    expect(SourceLayout.chartBodyScale, 0.93);
    expect(SourceLayout.chartFillTop, const Color(0xFF5EB4DE));
    expect(SourceLayout.chartFillBottom, const Color(0xFF005B86));
  });
}

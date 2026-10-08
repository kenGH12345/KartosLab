import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/components/control_widgets.dart';
import 'package:kratos/bending_light/components/source_nodes.dart';
import 'package:kratos/bending_light/components/probe_glyph.dart';
import 'package:kratos/bending_light/components/toolbox_icons.dart';
import 'package:kratos/bending_light/components/velocity_arrow.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/enums.dart';
import 'package:kratos/bending_light/model/intro_model.dart';
import 'package:kratos/bending_light/model/substance.dart';
import 'package:kratos/bending_light/bl_strings.dart';

void main() {
  testWidgets('ray and wave radios toggle and reset', (tester) async {
    var wave = false;
    Future<void> pump() {
      return tester.pumpWidget(
        MaterialApp(
          home: RayViewRow(
            wave: wave,
            showNormal: false,
            includeChecks: false,
            onRay: () => wave = false,
            onWave: () => wave = true,
            onNormal: (_) {},
          ),
        ),
      );
    }

    await pump();
    expect(find.text(BlStrings.ray), findsOneWidget);
    await tester.tap(find.text(BlStrings.wave));
    await pump();
    expect(wave, isTrue);
    wave = false;
    await pump();
    expect(wave, isFalse);
  });

  testWidgets('checkbox toggles and does not toggle from an outside tap', (tester) async {
    var checked = false;
    Future<void> pump() {
      return tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: PhetCheckbox(checked: checked, onChanged: (v) => checked = v),
          ),
        ),
      );
    }

    await pump();
    expect(find.bySemanticsLabel('unchecked'), findsOneWidget);
    await tester.tap(find.byType(PhetCheckbox));
    await pump();
    expect(checked, isTrue);
    expect(find.bySemanticsLabel('checked'), findsOneWidget);
    await tester.tapAt(const Offset(8, 8));
    await pump();
    expect(checked, isTrue);
    checked = false;
    await pump();
    expect(find.bySemanticsLabel('unchecked'), findsOneWidget);
  });

  testWidgets('time control play pause step stays on the model', (tester) async {
    final model = IntroModel(
      bottomSubstance: Substance.water,
      horizontalPlayAreaOffset: true,
    )..setLaserView(LaserViewEnum.wave);
    await tester.pumpWidget(
      MaterialApp(
        home: ListenableBuilder(
          listenable: model,
          builder: (context, _) => SourceTimeControl(
            isPlaying: model.isPlaying,
            speed: model.speed,
            onPlayPause: model.togglePlaying,
            onStep: model.stepOnce,
            onSpeed: model.setSpeed,
          ),
        ),
      ),
    );

    expect(model.isPlaying, isTrue);
    await tester.tap(find.bySemanticsLabel(BlStrings.pause));
    await tester.pump();
    expect(model.isPlaying, isFalse);

    final before = model.time;
    await tester.tap(find.bySemanticsLabel(BlStrings.step));
    await tester.pump();
    expect(model.time, greaterThan(before));

    await tester.tap(find.bySemanticsLabel(BlStrings.play));
    await tester.pump();
    expect(model.isPlaying, isTrue);
    final playingTime = model.time;
    await tester.tap(find.bySemanticsLabel(BlStrings.step), warnIfMissed: false);
    await tester.pump();
    expect(model.time, playingTime);

    await tester.tap(find.bySemanticsLabel(BlStrings.pause));
    await tester.pump();
    expect(model.isPlaying, isFalse);

    model.reset();
    await tester.pump();
    expect(model.time, 0);
    expect(model.isPlaying, isTrue);
  });

  test('toolbox scales and prism icon height come from source', () {
    expect(const IntensityMeterGraphic(outerScale: 0.45).outerScale, 0.45);
    expect(const VelocitySensorGraphic(nodeScale: 1.2).nodeScale, 1.2);
    expect(VelocitySensorGraphic.bodyScale, 0.7);
    expect(const WaveSensorGraphic(outerScale: 0.4).outerScale, 0.4);
    final square = prismIconGeometry('square');
    expect(square.size.height, closeTo(55, 0.01));
    expect(square.rotationCenter.dx, closeTo(square.size.width / 2, 1));
    expect(square.rotationCenter.dy, closeTo(27.5, 1));
    final triangle = prismIconGeometry('triangle');
    expect(triangle.size.height, closeTo(55, 0.01));
  });

  test('probe node kite contains the handle and not the sensor hole', () {
    final shape = buildProbeShape(
      radius: 50,
      innerRadius: 35,
      handleWidth: 50,
      handleHeight: 30,
    );
    final outline = buildProbeOutline(
      radius: 50,
      handleWidth: 50,
      handleHeight: 30,
    );
    expect(outline.contains(const Offset(0, -30)), isTrue);
    expect(shape.contains(Offset.zero), isFalse);
    expect(shape.contains(const Offset(0, 65)), isTrue);
    expect(shape.contains(const Offset(-80, 0)), isFalse);
    expect(outline.getBounds().bottom, closeTo(80, 0.5));
  });

  test('placed velocity node scale is 2 and toolbox scale stays 1.2', () {
    expect(VelocitySensorGraphic.placedNodeScale, 2);
    expect(VelocitySensorGraphic.bodyScale, 0.7);
    expect(const VelocitySensorGraphic(nodeScale: 1.2).nodeScale, 1.2);
    expect(velocityArrowScale, 1.5e-14);
    expect(velocityReadout(BlVec2.zero), '?');
  });

  test('wave sensor icon has two distinct wires', () {
    final wires = WaveSensorGraphic.wires();
    expect(wires, hasLength(2));
    expect(wires[0].end.x, isNot(closeTo(wires[1].end.x, 0.01)));
    expect(wires[0].start.x, closeTo(wires[1].start.x, 0.01));
    expect(wires[0].control1.x, greaterThan(wires[0].start.x));
  });

  test('prism icon keeps knob.png anchor and mediumColorFactory fill', () {
    final square = prismIconGeometry('square');
    final circle = prismIconGeometry('circle');
    expect(square.knob, isNotNull);
    expect(circle.knob, isNull);
    final knob = square.knob!;
    expect(knob.height, greaterThan(0));
    expect(knob.width / knob.height, closeTo(34 / 31, 0.02));
    final factory = MediumColorFactory();
    final glass = factory.getColor(Substance.glass.indexOfRefractionForRedLight);
    expect(glass & 0xFFFFFF, 0xABA9D4);
    expect(factory.getColor(1), 0xFFFFFFFF);
    factory.lightType = ColorModeEnum.white;
    expect(factory.getColor(1) & 0xFFFFFF, 0);
    final reset = MediumColorFactory();
    expect(reset.lightType, ColorModeEnum.singleColor);
    expect(reset.getColor(Substance.water.indexOfRefractionForRedLight) & 0xFFFFFF, 0xC6E2F6);
  });
}

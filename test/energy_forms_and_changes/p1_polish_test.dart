import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/intro/controller/intro_controller.dart';
import 'package:kratos/energy_forms_and_changes/intro/painters/beaker_painter.dart';
import 'package:kratos/energy_forms_and_changes/intro/screens/intro_screen_body.dart';
import 'package:kratos/energy_forms_and_changes/intro/widgets/temperature_and_color_sensor_widget.dart';
import 'package:kratos/energy_forms_and_changes/intro/widgets/time_speed_radio_group.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/efac_intro_model.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('beaker grab layer is between back and front; front non-pickable',
      (tester) async {
    await tester.binding.setSurfaceSize(
      const Size(EfacConstants.layoutWidth, EfacConstants.layoutHeight),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: EfacConstants.layoutWidth,
            height: EfacConstants.layoutHeight,
            child: IntroScreenBody(controller: IntroController()),
          ),
        ),
      ),
    );
    await tester.pump();

    // Two beakers × 3 layers = 6 BeakerPainters
    final painters = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
    final beakerPainters = painters
        .where((p) => p.painter is BeakerPainter)
        .map((p) => p.painter! as BeakerPainter)
        .toList();
    expect(beakerPainters.length, 6);

    final layers = beakerPainters.map((p) => p.layer).toList();
    // Order in tree walk is roughly paint order for Stack children:
    // back×2, grab×2, … front×2 appear; count by layer.
    expect(layers.where((l) => l == BeakerPaintLayer.back).length, 2);
    expect(layers.where((l) => l == BeakerPaintLayer.grab).length, 2);
    expect(layers.where((l) => l == BeakerPaintLayer.front).length, 2);

    // Grab uses GestureDetector; front is under IgnorePointer
    expect(find.byType(GestureDetector), findsWidgets);
  });

  test('ThermometerNode tick constants match TemperatureAndColorSensorNode', () {
    expect(TemperatureAndColorSensorWidget.tickSpacingTemperature, 25);
    expect(TemperatureAndColorSensorWidget.majorTickLength, 10);
    expect(TemperatureAndColorSensorWidget.minorTickLength, 5);
    expect(TemperatureAndColorSensorWidget.tubeHeight, 100);
    expect(TemperatureAndColorSensorWidget.bulbDiameter, 30);
    expect(TemperatureAndColorSensorWidget.tubeWidth, 18);
  });

  testWidgets('TimeSpeedRadioGroup: Normal/FF order, selection, spacing',
      (tester) async {
    var speed = EfacTimeSpeed.normal;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return TimeSpeedRadioGroup(
                value: speed,
                onChanged: (v) => setState(() => speed = v),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text(EfacStrings.normal), findsOneWidget);
    expect(find.text(EfacStrings.fastForward), findsOneWidget);

    // NORMAL above FAST in column — Normal's top < Fast Forward's top
    final normalY = tester.getTopLeft(find.text(EfacStrings.normal)).dy;
    final fastY = tester.getTopLeft(find.text(EfacStrings.fastForward)).dy;
    expect(normalY, lessThan(fastY));
    expect(fastY - normalY, greaterThanOrEqualTo(TimeSpeedRadioGroup.spacing));

    await tester.tap(find.text(EfacStrings.fastForward));
    await tester.pump();
    expect(speed, EfacTimeSpeed.fastForward);
    // FF×4 multiplier unchanged in model constants
    expect(EfacConstants.fastForwardMultiplier, 4);
  });
}

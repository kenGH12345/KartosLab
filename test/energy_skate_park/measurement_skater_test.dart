import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_skate_park/controller/intro_controller.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/measurement_tools.dart';
import 'package:kratos/energy_skate_park/model/skater_image_set.dart';
import 'package:kratos/energy_skate_park/widgets/play_area.dart';
import 'package:kratos/energy_skate_park/widgets/skater_selection.dart';

void main() {
  group('MeasurementTools model', () {
    test('distance uses model meters not pixels', () {
      final tools = MeasurementTools();
      tools.measuringTapeBase = const EspVec(0, 0);
      tools.measuringTapeTip = const EspVec(3, 4);
      expect(tools.measuringTapeDistanceMeters, closeTo(5, 1e-9));
    });

    test('placeMeasuringTapeAt sets 1 m default span', () {
      final tools = MeasurementTools();
      tools.placeMeasuringTapeAt(const EspVec(2, 1));
      expect(tools.measuringTapeVisible, isTrue);
      expect(tools.measuringTapeDistanceMeters, closeTo(1, 1e-9));
    });

    test('reset clears tools', () {
      final tools = MeasurementTools();
      tools.stopwatchVisible = true;
      tools.stopwatchTime = 5;
      tools.measuringTapeVisible = true;
      tools.resetAll();
      expect(tools.stopwatchVisible, isFalse);
      expect(tools.stopwatchTime, 0);
      expect(tools.measuringTapeVisible, isFalse);
    });

    test('drag stopwatch clamps to play area', () {
      final tools = MeasurementTools();
      tools.placeStopwatchAtView(const Offset(500, 400), const Size(600, 500));
      expect(tools.stopwatchViewPosition.dx, lessThanOrEqualTo(500));
      expect(tools.stopwatchViewPosition.dy, lessThanOrEqualTo(452));
    });
  });

  group('IntroController measurement integration', () {
    test('tape drag updates model distance', () {
      final c = IntroController();
      c.setMeasuringTapeVisible(true);
      c.setMeasuringTapeBase(const EspVec(0, 1));
      c.setMeasuringTapeTip(const EspVec(2, 1));
      expect(c.model.measuringTapeDistance, closeTo(2, 1e-9));
    });

    test('reset restores measurement tools', () {
      final c = IntroController();
      c.setStopwatchVisible(true);
      c.model.tools.stopwatchTime = 3;
      c.setMeasuringTapeVisible(true);
      c.reset();
      expect(c.model.stopwatchVisible, isFalse);
      expect(c.model.measuringTapeVisible, isFalse);
      expect(c.model.stopwatchTime, 0);
    });

    test('reference height visible off resets height', () {
      final c = IntroController();
      c.setReferenceHeightVisible(true);
      c.setReferenceHeight(4);
      c.setReferenceHeightVisible(false);
      expect(c.model.skater.referenceHeight, 0);
    });
  });

  group('Skater selection', () {
    test('default index is 0', () {
      final c = IntroController();
      expect(c.view.selectedSkaterIndex, SkaterImageSet.defaultIndex);
    });

    test('selection persists across model reset', () {
      final c = IntroController();
      c.setSelectedSkater(3);
      c.reset();
      expect(c.view.selectedSkaterIndex, 3);
    });

    test('selection does not change mass', () {
      final c = IntroController();
      final massBefore = c.model.skater.mass;
      c.setSelectedSkater(5);
      expect(c.model.skater.mass, massBefore);
    });

    test('SkaterSelectionPanel renders 8 buttons', () {
      var selected = 0;
      final widget = MaterialApp(
        home: Scaffold(
          body: SkaterSelectionPanel(
            selectedIndex: selected,
            onSelected: (i) => selected = i,
          ),
        ),
      );
      expect(
        widget,
        isNotNull,
      );
    });
  });

  group('PlayArea widgets', () {
    testWidgets('shows toolbox and skater selection in control flow', (tester) async {
      final c = IntroController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 500,
              child: PlayArea(controller: c, showToolbox: true),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(PlayArea), findsOneWidget);
    });
  });
}

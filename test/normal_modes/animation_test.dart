import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/normal_modes/controller/one_dimension_controller.dart';
import 'package:kratos/normal_modes/controller/two_dimensions_controller.dart';
import 'package:kratos/normal_modes/model/nm_vec.dart';
import 'package:kratos/normal_modes/normal_modes_constants.dart';

void main() {
  test('pause then resume continues analytic time', () {
    final c = OneDimensionController();
    c.model.modeAmplitudes[0] = 0.08;
    c.tick(NormalModesConstants.fixedDt);
    final t1 = c.model.time;
    final y1 = c.model.masses[1].displacement.y;
    c.model.playing = false;
    c.tick(NormalModesConstants.fixedDt);
    expect(c.model.time, t1);
    c.model.playing = true;
    c.tick(NormalModesConstants.fixedDt);
    expect(c.model.time, greaterThan(t1));
    expect(c.model.masses[1].displacement.y, isNot(y1));
  });

  test('reset while running restores A=0', () {
    final c = OneDimensionController();
    c.model.modeAmplitudes[0] = 0.1;
    c.tick(NormalModesConstants.fixedDt);
    c.reset();
    expect(c.model.modeAmplitudes[0], 0);
    expect(c.spectrumExpanded, isTrue);
    expect(c.modesExpanded, isTrue);
  });

  test('1D drag end decomposes and zeros time', () {
    final c = OneDimensionController();
    c.beginDrag(1);
    c.updateDrag(1, 0.05);
    expect(c.model.arrowsVisible, isFalse);
    c.endDrag(interrupted: false);
    expect(c.model.draggingMassIndex, -1);
    expect(c.model.time, 0);
    expect(c.model.modeAmplitudes[0], greaterThan(0));
  });

  test('2D drag end decomposes both axes', () {
    final c = TwoDimensionsController();
    c.beginDrag(1, 1);
    c.updateDrag(1, 1, const NmVec(0.04, -0.03));
    c.endDrag(interrupted: false);
    expect(c.model.draggingMassIndexes, isNull);
    expect(c.model.time, 0);
    expect(
      c.model.modeXAmplitudes[0][0] + c.model.modeYAmplitudes[0][0],
      greaterThan(0),
    );
  });

  test('parameter change while paused updates positions', () {
    final c = OneDimensionController();
    c.model.playing = false;
    c.setModeAmplitude(0, 0.1);
    expect(c.model.masses[2].displacement.y, isNot(0));
  });
}

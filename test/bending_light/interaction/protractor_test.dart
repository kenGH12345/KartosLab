import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/components/protractor_widget.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/intro_model.dart';
import 'package:kratos/bending_light/model/substance.dart';

void main() {
  test('protractor reading follows model ray geometry', () {
    final model = IntroModel(
      bottomSubstance: Substance.water,
      horizontalPlayAreaOffset: true,
    );
    model.setLaserOn(true);
    final first = protractorReadingNear(model.rays, BlVec2.zero);
    model.laser.setAngle(2.8);
    model.updateModel();
    final second = protractorReadingNear(model.rays, BlVec2.zero);
    expect(first, isNotNull);
    expect(second, isNotNull);
    expect(second, isNot(closeTo(first!, 0.05)));
  });

  test('reading is not a preset constant', () {
    final model = IntroModel(
      bottomSubstance: Substance.glass,
      horizontalPlayAreaOffset: true,
    );
    model.setLaserOn(true);
    final reading = protractorReadingNear(model.rays, BlVec2.zero)!;
    expect(reading.isFinite, isTrue);
    model.laser.setAngle(2.2);
    model.updateModel();
    final moved = protractorReadingNear(model.rays, BlVec2.zero)!;
    expect(moved, isNot(closeTo(reading, 0.2)));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/waves_intro_constants.dart';

void main() {
  test('WavesScreenView layout anchors match PhET', () {
    expect(WavesIntroConstants.layoutWidth, 1024);
    expect(WavesIntroConstants.layoutHeight, 618);
    expect(WavesIntroConstants.waveAreaViewSize, 500);
    expect(WavesIntroConstants.layoutMargin, 8);
    expect(WavesIntroConstants.waveMargin, 8);
    expect(WavesIntroConstants.waveAreaTop, 31);
    expect(WavesIntroConstants.waveAreaCenterX, 370);
    expect(WavesIntroConstants.waveAreaLeft, 120);
    expect(WavesIntroConstants.waveAreaRight, 620);
    expect(WavesIntroConstants.waveAreaBottom, 531);
    expect(WavesIntroConstants.panelMaxWidth, 200);
  });
}

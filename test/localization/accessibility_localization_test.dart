import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/l10n/scan/english_residue_classifier.dart';

void main() {
  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));

  test('accessibility strings are Chinese', () {
    final c = EnglishResidueClassifier();
    expect(loc.accessibility.resetAll, '全部重置');
    expect(loc.accessibility.increaseMass, '增加质量');
    expect(loc.accessibility.decreaseMass, '减小质量');
    expect(c.hasUserVisibleEnglish(loc.accessibility.resetAll), isFalse);
    expect(c.hasUserVisibleEnglish(loc.accessibility.increaseMass), isFalse);
    expect(
      c.hasUserVisibleEnglish(loc.accessibility.openSimulation('浮力')),
      isFalse,
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/l10n/namespaces/accessibility_l10n.dart';
import 'package:kratos/l10n/namespaces/common_l10n.dart';
import 'package:kratos/l10n/namespaces/home_l10n.dart';
import 'package:kratos/l10n/namespaces/physics_l10n.dart';
import 'package:kratos/l10n/namespaces/sim_titles_l10n.dart';

void main() {
  test('no duplicate localization keys across namespaces', () {
    final all = <String>[
      ...CommonL10n.keys,
      ...HomeL10n.keys,
      ...PhysicsL10n.keys,
      ...AccessibilityL10n.keys,
      ...SimTitlesL10n.keys,
    ];
    expect(all.toSet().length, all.length);
  });

  test('KartosLocalization.allKeys matches namespace union', () {
    expect(KartosLocalization.allKeys.length, greaterThan(50));
    expect(KartosLocalization.allKeys.contains('common.resetAll'), isTrue);
    expect(KartosLocalization.allKeys.contains('home.appTitle'), isTrue);
    expect(
      KartosLocalization.allKeys.contains('sim.bending-light.title'),
      isTrue,
    );
  });

  test('required common keys resolve in zh-CN', () {
    KartosLocalization.setLocale(KartosLocale.zhCN);
    expect(loc.common.resetAll, '全部重置');
    expect(loc.common.play, '播放');
    expect(loc.common.pause, '暂停');
    expect(loc.shared.resetAll, '全部重置');
  });
}

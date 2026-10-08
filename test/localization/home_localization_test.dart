import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/l10n/namespaces/sim_titles_l10n.dart';
import 'package:kratos/l10n/scan/english_residue_classifier.dart';
import 'package:kratos/screens/home_disciplines.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  setUp(() => KartosLocalization.setLocale(KartosLocale.zhCN));

  test('every home catalog sim has Chinese title/subtitle', () {
    final classifier = EnglishResidueClassifier();
    final disciplines = buildHomeDisciplines();
    expect(disciplines, isNotEmpty);

    for (final d in disciplines) {
      expect(classifier.hasUserVisibleEnglish(d.name), isFalse, reason: d.name);
      for (final g in d.groups) {
        expect(classifier.hasUserVisibleEnglish(g.name), isFalse, reason: g.name);
        for (final sim in g.sims) {
          expect(SimTitlesL10n.simulationIds.contains(sim.id), isTrue);
          expect(
            classifier.hasUserVisibleEnglish(sim.title),
            isFalse,
            reason: '${sim.id} title=${sim.title}',
          );
          // Subtitles may contain allowlisted tokens (χ², VSEPR, pH).
          final suspicious = classifier.extractSuspiciousWords(sim.subtitle);
          expect(
            suspicious,
            isEmpty,
            reason: '${sim.id} subtitle=${sim.subtitle} → $suspicious',
          );
        }
      }
    }
  });

  testWidgets('HomeScreen shows Chinese app title and no Physics englishName',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text(loc.home.appTitle), findsOneWidget);
    expect(find.text('Physics'), findsNothing);
    expect(find.text('Chemistry'), findsNothing);
    expect(find.text(loc.sim.title('bending-light')), findsOneWidget);
    expect(find.text('Bending Light'), findsNothing);
  });
}

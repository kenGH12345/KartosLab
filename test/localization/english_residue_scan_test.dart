import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/l10n/scan/english_residue_classifier.dart';

/// PHASE 1 scope: Home + shared chrome must not ship user-visible English.
/// Broader lib/ remains NOT STARTED for sims — not FAIL here.
void main() {
  final classifier = EnglishResidueClassifier();

  final scopedFiles = <String>[
    'lib/screens/home_screen.dart',
    'lib/screens/home_disciplines.dart',
    'lib/common/widgets/time_control_bar.dart',
    'lib/common/widgets/kratos_reset_all_button.dart',
    'lib/common/widgets/kratos_phet_time_control.dart',
    'lib/common/controls/spectrum_slider.dart',
  ];

  test('classifier distinguishes allowlisted technical terms', () {
    expect(
      classifier.classifyToken('kg', filePath: 'lib/x.dart'),
      EnglishResidueKind.allowedTechnical,
    );
    expect(
      classifier.classifyToken('PhET', filePath: 'lib/x.dart'),
      EnglishResidueKind.allowedTechnical,
    );
    expect(
      classifier.classifyToken('bending-light', filePath: 'lib/x.dart'),
      EnglishResidueKind.internalIdentifier,
    );
    expect(
      classifier.classifyToken('Reset', filePath: 'lib/x.dart'),
      EnglishResidueKind.userVisibleEnglish,
    );
  });

  test('PHASE1 scoped files have no hardcoded user-visible English literals', () {
    final root = Directory.current.path;
    final lit = RegExp(r"""(['"])([^'"\\]*(?:\\.[^'"\\]*)*)\1""");

    for (final rel in scopedFiles) {
      final file = File('$root${Platform.pathSeparator}${rel.replaceAll('/', Platform.pathSeparator)}');
      expect(file.existsSync(), isTrue, reason: rel);
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trimLeft();
        if (line.startsWith('//') || line.startsWith('import ') || line.startsWith('///')) {
          continue;
        }
        // Skip Key(...) automation ids, asset paths, and Dart interpolations.
        if (line.contains('Key(') || line.contains('assets/')) continue;
        for (final m in lit.allMatches(lines[i])) {
          final text = m.group(2)!
              .replaceAll(r'\n', '\n')
              .replaceAll(r"\'", "'");
          if (text.isEmpty) continue;
          if (text.contains(r'${') || text.contains(r'$')) continue;
          if (text.startsWith('package:') || text.contains('/')) continue;
          if (RegExp(r'^[a-z0-9_\-./]+$').hasMatch(text)) continue; // ids/paths
          if (RegExp(r'^[\d.\s]+$').hasMatch(text)) continue;
          final words = classifier.extractSuspiciousWords(text);
          expect(
            words,
            isEmpty,
            reason: '$rel:${i + 1} "$text" → $words',
          );
        }
      }
    }
  });
}

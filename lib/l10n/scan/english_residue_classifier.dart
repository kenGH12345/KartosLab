/// Classification of English / Latin tokens found during localization scans.
enum EnglishResidueKind {
  /// Natural-language English visible to end users — FAIL in localized scopes.
  userVisibleEnglish,

  /// Units, formulas, scientific symbols — allowed.
  allowedTechnical,

  /// PhET / archaeology / docs evidence — out of product UI scope.
  sourceOnly,

  /// Class names, IDs, routes, file names.
  internalIdentifier,

  /// Logs / asserts / debug-only.
  developerOnly,
}

/// Allowlist + heuristics for PHASE 1 English-residue rules.
///
/// Reads product policy from `LOCALIZATION_EXCEPTIONS.md` (implemented here).
class EnglishResidueClassifier {
  EnglishResidueClassifier({
    this.allowedTerms = const {
      'PhET',
      'KartosLab',
      'Kratos',
      'pH',
      'RGB',
      'VSEPR',
      'Planck',
      'Wien',
      'χ²',
      'chi²',
    },
    this.allowedUnits = const {
      'kg',
      'g',
      'mg',
      'm',
      'cm',
      'mm',
      'nm',
      'km',
      'm³',
      'm3',
      'L',
      'mL',
      'Pa',
      'kPa',
      'N',
      'J',
      'W',
      'V',
      'A',
      'Hz',
      'kHz',
      'MHz',
      '°C',
      'K',
      's',
      'ms',
      'Ω',
      'ohm',
    },
  });

  final Set<String> allowedTerms;
  final Set<String> allowedUnits;

  static final RegExp _latinWord = RegExp(r"[A-Za-z][A-Za-z']*");
  static final RegExp _cjk = RegExp(r'[\u4e00-\u9fff]');
  static final RegExp _kebabId = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)+$');
  static final RegExp _snakeId = RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)+$');
  /// Class-like identifiers only when they end with known type suffixes.
  static final RegExp _pascal = RegExp(
    r'^[A-Z][a-zA-Z0-9]*(?:Model|Screen|Controller|Home|Strings|Module|Button)$',
  );

  EnglishResidueKind classifyToken(
    String token, {
    required String filePath,
    bool isComment = false,
    bool isLog = false,
  }) {
    final path = filePath.replaceAll('\\', '/');
    if (path.contains('/phet/') ||
        path.contains('phet sourses') ||
        path.contains('/requirements/') ||
        path.contains('/docs/')) {
      return EnglishResidueKind.sourceOnly;
    }
    if (isLog || isComment || path.contains('/debug_')) {
      return EnglishResidueKind.developerOnly;
    }
    if (allowedTerms.contains(token) || allowedUnits.contains(token)) {
      return EnglishResidueKind.allowedTechnical;
    }
    if (_kebabId.hasMatch(token) ||
        _snakeId.hasMatch(token) ||
        _pascal.hasMatch(token) ||
        token.contains('_') && !token.contains(' ')) {
      return EnglishResidueKind.internalIdentifier;
    }
    if (token.length <= 2 && RegExp(r'^[A-Za-zρλθαβγωμσΔπ]$').hasMatch(token)) {
      return EnglishResidueKind.allowedTechnical;
    }
    if (RegExp(r'^F\s*=\s*ma$', caseSensitive: false).hasMatch(token)) {
      return EnglishResidueKind.allowedTechnical;
    }
    return EnglishResidueKind.userVisibleEnglish;
  }

  /// Returns Latin natural-language words that look user-visible in [text].
  List<String> extractSuspiciousWords(String text) {
    if (!_latinWord.hasMatch(text)) return const [];
    final words = <String>[];
    for (final m in _latinWord.allMatches(text)) {
      final w = m.group(0)!;
      if (allowedUnits.contains(w) || allowedTerms.contains(w)) continue;
      if (w.length == 1) continue;
      // Chinese + unit like "质量 kg" is fine; skip pure unit tokens already.
      words.add(w);
    }
    // If text is mostly CJK with only allowlisted Latin, treat as clean.
    if (_cjk.hasMatch(text)) {
      return words
          .where(
            (w) =>
                classifyToken(w, filePath: 'lib/ui.dart') ==
                EnglishResidueKind.userVisibleEnglish,
          )
          .toList();
    }
    return words
        .where(
          (w) =>
              classifyToken(w, filePath: 'lib/ui.dart') ==
              EnglishResidueKind.userVisibleEnglish,
        )
        .toList();
  }

  bool hasUserVisibleEnglish(String text) =>
      extractSuspiciousWords(text).isNotEmpty;
}

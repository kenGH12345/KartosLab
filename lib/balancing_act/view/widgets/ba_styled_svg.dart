import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Runtime CSS→presentation-attribute inliner for PhET SVGs.
///
/// `flutter_svg` ignores `<style/>` / `class=` (logs `unhandled element <style/>`),
/// so class-based fills render as black silhouettes. This loader expands CSS into
/// attributes **in memory** — original asset files are never mutated.
class BaStyledSvg {
  BaStyledSvg._();

  static final Map<String, String> _cache = {};

  /// Load asset and return CSS-inlined SVG markup (cached).
  static Future<String> loadMarkup(String assetPath) async {
    final cached = _cache[assetPath];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(assetPath);
    final inlined = inlineCssStyles(raw);
    _cache[assetPath] = inlined;
    return inlined;
  }

  /// Expand `<style>` class rules onto elements as presentation attributes.
  @visibleForTesting
  static String inlineCssStyles(String svg) {
    final styleMatch = RegExp(
      r'<style[^>]*>([\s\S]*?)</style>',
      caseSensitive: false,
    ).firstMatch(svg);
    if (styleMatch == null) return svg;

    final css = styleMatch.group(1)!;
    final rules = <String, Map<String, String>>{};

    // `.cls-1{fill:#fff;}` or `.cls-1,.cls-2{fill:none;stroke:#000;}`
    final ruleRe = RegExp(r'([^{}]+)\{([^}]*)\}');
    for (final m in ruleRe.allMatches(css)) {
      final selectors = m.group(1)!.split(',');
      final body = m.group(2)!;
      final props = <String, String>{};
      for (final part in body.split(';')) {
        final p = part.trim();
        if (p.isEmpty) continue;
        final colon = p.indexOf(':');
        if (colon <= 0) continue;
        final key = p.substring(0, colon).trim().toLowerCase();
        final val = p.substring(colon + 1).trim();
        props[key] = val;
      }
      for (var sel in selectors) {
        sel = sel.trim();
        if (sel.startsWith('.')) sel = sel.substring(1);
        if (sel.isEmpty) continue;
        rules.putIfAbsent(sel, () => <String, String>{}).addAll(props);
      }
    }

    var out = svg.replaceFirst(styleMatch.group(0)!, '');

    // Apply classes on opening tags that have class="..."
    out = out.replaceAllMapped(
      RegExp(r'''<(path|polygon|polyline|rect|circle|ellipse|line|g|text)\b([^>]*?)(/?)>''',
          caseSensitive: false),
      (m) {
        final tag = m.group(1)!;
        var attrs = m.group(2)!;
        final selfClose = m.group(3)!;
        final classMatch = RegExp(
          r'''\bclass\s*=\s*["']([^"']*)["']''',
          caseSensitive: false,
        ).firstMatch(attrs);
        if (classMatch == null) return m.group(0)!;

        final classNames = classMatch.group(1)!.split(RegExp(r'\s+'));
        final merged = <String, String>{};
        for (final c in classNames) {
          final r = rules[c];
          if (r != null) merged.addAll(r);
        }

        // Remove class=...
        attrs = attrs.replaceFirst(classMatch.group(0)!, '');

        for (final e in merged.entries) {
          final attrName = _cssToAttr(e.key);
          if (attrName == null) continue;
          // Don't override existing presentation attributes
          if (RegExp('\\b$attrName\\s*=', caseSensitive: false).hasMatch(attrs)) {
            continue;
          }
          final v = e.value;
          attrs = ' $attrName="${_escapeAttr(v)}"$attrs';
        }

        return '<$tag$attrs$selfClose>';
      },
    );

    return out;
  }

  static String? _cssToAttr(String cssProp) {
    switch (cssProp) {
      case 'fill':
      case 'stroke':
      case 'opacity':
      case 'display':
        return cssProp;
      case 'stroke-width':
      case 'stroke-linecap':
      case 'stroke-linejoin':
      case 'stroke-miterlimit':
      case 'stroke-dasharray':
      case 'stroke-opacity':
      case 'fill-opacity':
      case 'fill-rule':
        return cssProp;
      default:
        return null; // skip unsupported (e.g. filter)
    }
  }

  static String _escapeAttr(String v) =>
      v.replaceAll('&', '&amp;').replaceAll('"', '&quot;');
}

/// Asset SVG with CSS styles expanded for flutter_svg.
class BaSvgPicture extends StatelessWidget {
  const BaSvgPicture.asset(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: BaStyledSvg.loadMarkup(assetPath),
      builder: (context, snap) {
        if (!snap.hasData) {
          return SizedBox(width: width, height: height);
        }
        return SvgPicture.string(
          snap.data!,
          width: width,
          height: height,
          fit: fit,
          allowDrawingOutsideViewBox: true,
        );
      },
    );
  }
}

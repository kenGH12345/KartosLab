import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/view/widgets/ba_styled_svg.dart';

void main() {
  test('inlineCssStyles expands class fills to presentation attributes', () {
    const raw = '''
<svg xmlns="http://www.w3.org/2000/svg">
  <defs><style>.cls-1{fill:#b32a2e;}.cls-2{fill:#fff;stroke-width:0px;}</style></defs>
  <path class="cls-1" d="M0,0"/>
  <path class="cls-2" d="M1,1"/>
</svg>''';
    final out = BaStyledSvg.inlineCssStyles(raw);
    expect(out.contains('<style'), isFalse);
    expect(out, contains('fill="#b32a2e"'));
    expect(out, contains('fill="#fff"'));
    expect(out, isNot(contains('class=')));
  });

  test('inlineCssStyles merges multi-selector rules', () {
    const raw = '''
<svg>
  <style>.cls-1,.cls-2{fill:none;stroke-width:.75px;}.cls-1{stroke:#000;}</style>
  <path class="cls-1" d="M0,0"/>
</svg>''';
    final out = BaStyledSvg.inlineCssStyles(raw);
    expect(out, contains('fill="none"'));
    expect(out, contains('stroke="#000"'));
    expect(out, contains('stroke-width=".75px"'));
  });

  test('inlineCssStyles does not override existing presentation attrs', () {
    const raw = '''
<svg>
  <style>.cls-1{fill:#f00;}</style>
  <path class="cls-1" fill="#0f0" d="M0,0"/>
</svg>''';
    final out = BaStyledSvg.inlineCssStyles(raw);
    expect(out, contains('fill="#0f0"'));
    expect(out, isNot(contains('fill="#f00"')));
  });

  test('passthrough when no style block', () {
    const raw = '<svg><path fill="#abc" d="M0,0"/></svg>';
    expect(BaStyledSvg.inlineCssStyles(raw), raw);
  });
}

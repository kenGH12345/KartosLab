/// Chart Intro 元素名文案。对标 `ElementNameText.ts`，与 Decay
/// [NuclideStatusText] 同句式，但不依赖 [BuildANucleusState]。
library;

import '../model/chart_intro_state.dart';

class ChartIntroStatusText {
  const ChartIntroStatusText._();

  static String elementCaption(ChartIntroState s) {
    final name = s.elementName;
    final n = s.neutronCount;
    final mass = s.massNumber;
    final nameMass = name.isEmpty ? '' : '$name - $mass';

    if (!s.nuclideExists && mass != 0) {
      if (name.isEmpty) {
        return '$mass neutrons does not form';
      }
      return '$nameMass does not form';
    }
    if (name.isEmpty) {
      if (n == 0) return '';
      if (n == 1) return '$n neutron';
      return 'Cluster of $n neutrons';
    }
    return nameMass;
  }
}

#!/usr/bin/env python3
"""Generate lib/beers_law_lab/model/molar_absorptivity_data.dart from extracted JSON."""

import json
import pathlib

root = pathlib.Path(__file__).resolve().parents[1]
data = json.loads(
    (root / "tmp_molar_data.json").read_text(encoding="utf-8-sig")
)
order = [
    "DRINK_MIX",
    "COBALT_II_NITRATE",
    "COBALT_CHLORIDE",
    "POTASSIUM_DICHROMATE",
    "POTASSIUM_CHROMATE",
    "NICKEL_II_CHLORIDE",
    "COPPER_SULFATE",
    "POTASSIUM_PERMANGANATE",
]
dart_names = {
    "DRINK_MIX": "drinkMix",
    "COBALT_II_NITRATE": "cobaltIINitrate",
    "COBALT_CHLORIDE": "cobaltChloride",
    "POTASSIUM_DICHROMATE": "potassiumDichromate",
    "POTASSIUM_CHROMATE": "potassiumChromate",
    "NICKEL_II_CHLORIDE": "nickelIIChloride",
    "COPPER_SULFATE": "copperSulfate",
    "POTASSIUM_PERMANGANATE": "potassiumPermanganate",
}

header = """// AUTO-GENERATED from PhET MolarAbsorptivityData.ts — do not hand-edit values.
// Source: beers-law-lab/js/beerslaw/model/MolarAbsorptivityData.ts
// 401 samples: wavelength 380..780 nm inclusive.

import 'beers_law_constants.dart';

/// PhET `MolarAbsorptivityData` — molar absorptivity (1/(cm·M)) vs wavelength.
class MolarAbsorptivityData {
  MolarAbsorptivityData(this.values)
      : assert(values.length == BeersLawConstants.numberOfVisibleWavelengths),
        lambdaMax = _computeLambdaMax(values);

  final List<double> values;

  /// Wavelength (nm) with maximum molar absorptivity (lower λ on ties).
  final double lambdaMax;

  double wavelengthToMolarAbsorptivity(double wavelength) {
    assert(wavelength >= BeersLawConstants.minWavelength &&
        wavelength <= BeersLawConstants.maxWavelength);
    final index = (wavelength - BeersLawConstants.minWavelength).floor();
    return values[index.clamp(0, values.length - 1)];
  }

  static double _computeLambdaMax(List<double> values) {
    var indexMax = 0;
    var max = values[0];
    for (var i = 1; i < values.length; i++) {
      if (values[i] > max) {
        max = values[i];
        indexMax = i;
      }
    }
    return indexMax + BeersLawConstants.minWavelength;
  }
"""

parts = [header]
for n in order:
    vals = data[n]
    assert len(vals) == 401, (n, len(vals))
    lines = []
    for i in range(0, 401, 16):
        chunk = ", ".join(vals[i : i + 16])
        lines.append(f"    {chunk},")
    body = "\n".join(lines)
    parts.append(
        f"""
  static final {dart_names[n]} = MolarAbsorptivityData(const <double>[
{body}
  ]);
"""
    )
parts.append("}\n")

out_path = root / "lib" / "beers_law_lab" / "model" / "molar_absorptivity_data.dart"
out_path.parent.mkdir(parents=True, exist_ok=True)
out_path.write_text("".join(parts), encoding="utf-8")
print("Wrote", out_path, "bytes", out_path.stat().st_size)

vals = [float(x) for x in data["DRINK_MIX"]]
imax = max(range(401), key=lambda i: vals[i])
print("DRINK_MIX lambdaMax", 380 + imax, "a=", vals[imax])

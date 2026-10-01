// 一次性数据提取脚本：PhET shred 仓库 TS 数据表 → KARTOSLAB JSON 资产。
//
// 输入（已固化在 requirements/req-build-a-nucleus/reference/，来源见输出 JSON 的 source 字段）：
//   - AtomData.ts      : stableElementTable / DECAYS_INFO_TABLE / HalfLifeConstants / mapElectronCountToRadius
//   - AtomNameUtils.ts : symbolTable / englishNameTable
//
// 输出：assets/data/nuclide_table.json（结构见 schemas/nuclide_table.schema.json）
//
// 用法：node scripts/extract_nuclide_data.mjs
//
// 注意：shred 的 ISOTOPE_INFO_TABLE / standardMassTable / numNeutronsInMostStableIsotope 未被
// Build a Nucleus 使用（依据：js/common、js/decay 全部源码中 AtomInfoUtils 的调用点），故不提取。

import fs from 'node:fs';
import path from 'node:path';

const ROOT = path.resolve(import.meta.dirname, '..');
const REF_DIR = path.join(ROOT, 'requirements/req-build-a-nucleus/reference');
const OUT_PATH = path.join(ROOT, 'assets/data/nuclide_table.json');

// 从 TS 源码中提取 `export const <name> = <literal>;` 的字面量并求值。
// 数据源是受信的第一方参考文件，且字面量为纯 JS 表达式（数值/字符串/null/嵌套数组对象），可用 eval。
function extractConst(src, name) {
  const declIdx = src.indexOf(`export const ${name}`);
  if (declIdx < 0) throw new Error(`declaration not found: ${name}`);
  const eqIdx = src.indexOf('=', declIdx);
  let i = eqIdx + 1;
  while (i < src.length && src[i] !== '[' && src[i] !== '{') i++;
  if (i >= src.length) throw new Error(`literal start not found: ${name}`);
  const open = src[i];
  const close = open === '[' ? ']' : '}';
  let depth = 0;
  let inStr = null;
  for (let j = i; j < src.length; j++) {
    const c = src[j];
    if (inStr) {
      if (c === inStr && src[j - 1] !== '\\') inStr = null;
      continue;
    }
    if (c === "'" || c === '"') {
      inStr = c;
      continue;
    }
    if (c === open) depth++;
    else if (c === close) {
      depth--;
      if (depth === 0) {
        // eslint-disable-next-line no-eval
        return eval(`(${src.slice(i, j + 1)})`);
      }
    }
  }
  throw new Error(`literal not closed: ${name}`);
}

const atomData = fs.readFileSync(path.join(REF_DIR, 'AtomData.ts'), 'utf8');
const atomNames = fs.readFileSync(path.join(REF_DIR, 'AtomNameUtils.ts'), 'utf8');

const stableElementTable = extractConst(atomData, 'stableElementTable');
const decaysInfoTable = extractConst(atomData, 'DECAYS_INFO_TABLE');
const halfLifeConstants = extractConst(atomData, 'HalfLifeConstants');
const electronCloudRadii = extractConst(atomData, 'mapElectronCountToRadius');
const symbolTable = extractConst(atomNames, 'symbolTable');
const englishNameTable = extractConst(atomNames, 'englishNameTable');

if (symbolTable.length !== englishNameTable.length) {
  throw new Error('symbol/name table length mismatch');
}

const capitalize = (s) => (s.length === 0 ? s : s[0].toUpperCase() + s.slice(1));

const elements = symbolTable.map((symbol, z) => ({
  z,
  symbol,
  name: z === 0 ? '' : capitalize(englishNameTable[z]),
}));

const table = {
  version: '1.0.0',
  source: {
    description:
      'Nuclide stability / half-life / decay-mode data ported from PhET shred (Relational ENSDF, 2022). ' +
      'Element symbols and English names from shred AtomNameUtils.',
    files: [
      'https://github.com/phetsims/shred/blob/main/js/AtomData.ts',
      'https://github.com/phetsims/shred/blob/main/js/AtomNameUtils.ts',
    ],
    retrievedAt: '2026-08-28',
    license: 'GPL-3.0 (PhET Interactive Simulations, University of Colorado Boulder)',
  },
  elements,
  // 与 shred stableElementTable 同构：数组下标 = 质子数 Z，元素 = 稳定中子数 N 列表。
  stableNeutrons: stableElementTable,
  // 半衰期（秒）。键 "Z" → 键 "N" → 秒数；null = 存在但半衰期未知；键缺失 = 该核素无数据。
  halfLives: halfLifeConstants,
  // 衰变模式。键 "Z" → 键 "N" → ENSDF 衰变串 → 分支比(%)；值为 null = 存在但衰变模式未知。
  // ENSDF 键到 5 种衰变类型的映射逻辑在 Dart 侧（NuclideRepository），与 shred AtomInfoUtils 保持一致。
  decays: decaysInfoTable,
  // 电子云半径（PhET 视觉用，基于实验原子半径经美术调整）。键 = 电子数（= 中性原子的 Z）。
  electronCloudRadii,
};

// ---- 锚点自检（与 reference/AtomData.ts 中实际值一一对应）----
const anchors = [
  ['H-3 half-life', table.halfLives['1']['2'], 388781328],
  ['C-14 half-life', table.halfLives['6']['8'], 1.79874e11],
  ['Pu-240 half-life', table.halfLives['94']['146'], 2.07045e11],
  ['free neutron half-life', table.halfLives['0']['1'], 613.9],
  ['Be-6 half-life', table.halfLives['4']['2'], 4.95911e-21],
  ['Be-6 decays 2P', table.decays['4']['2']['2P'], 100],
  ['Be-6 decays A', table.decays['4']['2']['A'], 100],
  ['C stable neutrons', JSON.stringify(table.stableNeutrons[6]), JSON.stringify([6, 7])],
  ['element 26 symbol', table.elements[26].symbol, 'Fe'],
  ['element 26 name', table.elements[26].name, 'Iron'],
  ['element 94 symbol', table.elements[94].symbol, 'Pu'],
];
for (const [label, actual, expected] of anchors) {
  if (actual !== expected) {
    throw new Error(`anchor check failed: ${label} — expected ${expected}, got ${actual}`);
  }
}

fs.mkdirSync(path.dirname(OUT_PATH), { recursive: true });
fs.writeFileSync(OUT_PATH, JSON.stringify(table));

const nuclideCount = Object.values(halfLifeConstants).reduce(
  (sum, row) => sum + Object.keys(row).length,
  0,
);
const stableCount = stableElementTable.reduce((sum, list) => sum + list.length, 0);
const sizeKb = (fs.statSync(OUT_PATH).size / 1024).toFixed(1);
console.log(`OK -> ${path.relative(ROOT, OUT_PATH)}`);
console.log(`elements=${elements.length} stableEntries=${stableCount} halfLifeEntries=${nuclideCount} size=${sizeKb}KB`);

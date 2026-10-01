import fs from 'node:fs';
import path from 'node:path';

// 全量扫描本需求相关文件中的字面 <|...|> 标记
const roots = [
  'lib/chemistry/build_a_nucleus',
  'test/chemistry/build_a_nucleus',
  'requirements/req-build-a-nucleus',
  'scripts/extract_nuclide_data.mjs',
];

function* walk(p) {
  const stat = fs.statSync(p);
  if (stat.isDirectory()) {
    for (const e of fs.readdirSync(p)) yield* walk(path.join(p, e));
  } else {
    yield p;
  }
}

let total = 0;
for (const root of roots) {
  for (const f of walk(root)) {
    if (!/\.(dart|md|mjs|ts|json)$/.test(f)) continue;
    const text = fs.readFileSync(f, 'utf8');
    const hits = [];
    for (let i = 0; i < text.length; i++) {
      if (text.startsWith('<|', i)) {
        // 前文 12 字符用于判断上下文
        hits.push({ at: i, before: text.slice(Math.max(0, i - 12), i), marker: text.slice(i, text.indexOf('>', i) + 1) });
      }
    }
    if (hits.length) {
      total += hits.length;
      console.log(`${f} (${hits.length})`);
      for (const h of hits.slice(0, 8)) {
        console.log('   ...' + JSON.stringify(h.before) + ' ' + h.marker);
      }
    }
  }
}
console.log('total markers:', total);

import fs from 'node:fs';
import path from 'node:path';

const ROOT = path.resolve(import.meta.dirname, '..');
const SINCE = new Date('2026-08-28T11:40:00').getTime();
const DIRS = ['lib', 'test', 'assets', 'schemas', 'scripts', 'requirements', 'integration_test'];
const FILES = ['pubspec.yaml', 'pubspec.lock'];

function* walk(p) {
  let stat;
  try {
    stat = fs.statSync(p);
  } catch {
    return;
  }
  if (stat.isDirectory()) {
    for (const e of fs.readdirSync(p)) yield* walk(path.join(p, e));
  } else {
    yield p;
  }
}

const rows = [];
for (const d of DIRS) {
  for (const f of walk(path.join(ROOT, d))) {
    const st = fs.statSync(f);
    if (st.mtimeMs > SINCE) rows.push({ t: st.mtimeMs, size: st.size, f });
  }
}
for (const f of FILES) {
  const p = path.join(ROOT, f);
  if (fs.existsSync(p)) {
    const st = fs.statSync(p);
    if (st.mtimeMs > SINCE) rows.push({ t: st.mtimeMs, size: st.size, f: p });
  }
}
rows.sort((a, b) => a.t - b.t);
for (const r of rows) {
  const time = new Date(r.t).toTimeString().slice(0, 8);
  console.log(`${time}  ${String(r.size).padStart(9)}  ${path.relative(ROOT, r.f)}`);
}

const path = require('path');
const { chromium } = require(path.join(__dirname, 'node_modules', 'playwright'));

(async () => {
  const b = await chromium.launch({ headless: true });
  const p = await b.newPage({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1,
  });
  await p.goto(
    'https://phet.colorado.edu/sims/html/states-of-matter/latest/states-of-matter_all.html?locale=en',
    { waitUntil: 'domcontentloaded', timeout: 180000 }
  );
  await p.waitForFunction(
    () => phet?.joist?.sim?.screenProperty && phet.joist.sim.simScreens?.length >= 3,
    undefined,
    { timeout: 180000 }
  );
  await p.waitForTimeout(1500);
  await p.evaluate(() => {
    phet.joist.sim.screenProperty.value = phet.joist.sim.simScreens[0];
  });
  await p.waitForTimeout(1000);

  const info = await p.evaluate(() => {
    const view = phet.joist.sim.screenProperty.value.view;
    const sample = [];
    let textish = 0;
    function walk(n, d, path) {
      if (!n || d > 30 || sample.length > 60) return;
      const ctor = n.constructor?.name || '?';
      const keys = Object.keys(n).filter((k) => /string|text|label/i.test(k)).slice(0, 8);
      let val = null;
      try {
        if (n.stringProperty) {
          const v = n.stringProperty.value;
          val = typeof v === 'string' ? v : v?.toString?.() || typeof v;
          textish++;
        }
      } catch (e) {}
      if (keys.length || val) {
        sample.push({ path, ctor, keys, val: val && String(val).slice(0, 80) });
      }
      // also check getText?
      try {
        if (typeof n.getText === 'function') {
          sample.push({ path, ctor, getText: String(n.getText()).slice(0, 80) });
        }
      } catch (e) {}
      const ch = n.children || [];
      for (let i = 0; i < ch.length; i++) walk(ch[i], d + 1, path + '/' + (ch[i].constructor?.name || i));
    }
    walk(view, 0, 'view');
    return {
      textish,
      child0: view.children?.[0]?.constructor?.name,
      nChildren: view.children?.length,
      sample,
    };
  });
  console.log(JSON.stringify(info, null, 2));

  // Find tandem names under view
  const tandems = await p.evaluate(() => {
    const view = phet.joist.sim.screenProperty.value.view;
    const out = [];
    function walk(n, d) {
      if (!n || d > 35 || out.length > 80) return;
      const name = n.tandem?.name;
      if (name) {
        const b = n.getGlobalBounds?.() || n.globalBounds;
        out.push({
          name,
          ctor: n.constructor?.name,
          cx: b ? +((b.centerX ?? (b.minX + b.maxX) / 2).toFixed(1)) : null,
          cy: b ? +((b.centerY ?? (b.minY + b.maxY) / 2).toFixed(1)) : null,
          w: b ? +b.width.toFixed(1) : null,
        });
      }
      for (const c of n.children || []) walk(c, d + 1);
    }
    walk(view, 0);
    return out;
  });
  console.log('--- TANDEMS ---');
  console.log(JSON.stringify(tandems, null, 2));
  await b.close();
})().catch((e) => {
  console.error(e);
  process.exit(1);
});

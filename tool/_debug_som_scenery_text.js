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
  const texts = await p.evaluate(() => {
    const sim = phet.joist.sim;
    const roots = [sim.homeScreen?.view, sim.rootNode, sim.navigationBar].filter(Boolean);
    const out = [];
    function walk(n, d) {
      if (!n || d > 45 || out.length > 100) return;
      try {
        let s = null;
        if (typeof n.string === 'string') s = n.string;
        else if (n.stringProperty?.value) s = String(n.stringProperty.value);
        if (s && s.trim()) {
          const b = n.getGlobalBounds?.() || n.globalBounds;
          if (b && b.width > 0) {
            out.push({
              s: s.slice(0, 80),
              cx: +((b.centerX ?? (b.minX + b.maxX) / 2).toFixed(1)),
              cy: +((b.centerY ?? (b.minY + b.maxY) / 2).toFixed(1)),
              w: +b.width.toFixed(1),
            });
          }
        }
      } catch (e) {}
      for (const c of n.children || []) walk(c, d + 1);
    }
    roots.forEach((r) => walk(r, 0));
    return out;
  });
  console.log(JSON.stringify(texts, null, 2));

  // Also try clicking home screen buttons via sim API to enter screen 0 then dump texts
  await p.evaluate(() => {
    phet.joist.sim.screenProperty.value = phet.joist.sim.simScreens[0];
  });
  await p.waitForTimeout(1000);
  const texts2 = await p.evaluate(() => {
    const view = phet.joist.sim.screenProperty.value.view;
    const out = [];
    function walk(n, d) {
      if (!n || d > 45 || out.length > 120) return;
      try {
        let s = null;
        if (typeof n.string === 'string') s = n.string;
        else if (n.stringProperty?.value) s = String(n.stringProperty.value);
        if (s && s.trim()) {
          const b = n.getGlobalBounds?.() || n.globalBounds;
          if (b && b.width > 0) {
            out.push({
              s: s.slice(0, 80),
              cx: +((b.centerX ?? (b.minX + b.maxX) / 2).toFixed(1)),
              cy: +((b.centerY ?? (b.minY + b.maxY) / 2).toFixed(1)),
              w: +b.width.toFixed(1),
              tandem: n.tandem?.name || '',
            });
          }
        }
      } catch (e) {}
      for (const c of n.children || []) walk(c, d + 1);
    }
    walk(view, 0);
    return out;
  });
  console.log('--- STATES SCREEN TEXTS ---');
  console.log(JSON.stringify(texts2, null, 2));
  await b.close();
})().catch((e) => {
  console.error(e);
  process.exit(1);
});

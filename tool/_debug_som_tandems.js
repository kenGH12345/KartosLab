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
  await p.waitForTimeout(1000);
  await p.evaluate(() => {
    phet.joist.sim.screenProperty.value = phet.joist.sim.simScreens[0];
  });
  await p.waitForTimeout(800);

  const names = await p.evaluate(() => {
    const view = phet.joist.sim.screenProperty.value.view;
    const out = [];
    function walk(n, d) {
      if (!n || d > 40) return;
      const name = n.tandem?.name;
      if (name && name !== 'optionalTandem') {
        const b = n.getGlobalBounds?.() || n.globalBounds;
        out.push({
          name,
          cx: b && b.width > 0 ? +((b.centerX ?? (b.minX + b.maxX) / 2).toFixed(1)) : null,
          cy: b && b.width > 0 ? +((b.centerY ?? (b.minY + b.maxY) / 2).toFixed(1)) : null,
          w: b ? +b.width.toFixed(1) : null,
          h: b ? +b.height.toFixed(1) : null,
        });
      }
      for (const c of n.children || []) walk(c, d + 1);
    }
    walk(view, 0);
    return out;
  });
  console.log(names.map((x) => x.name).join('\n'));
  console.log('---BOUNDS---');
  console.log(JSON.stringify(names.filter((x) => x.cx != null), null, 2));
  await b.close();
})().catch((e) => {
  console.error(e);
  process.exit(1);
});

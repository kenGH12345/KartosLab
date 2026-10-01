const { chromium } = require('playwright');

(async () => {
  const b = await chromium.launch({ headless: true });
  const p = await b.newPage({ viewport: { width: 1280, height: 800 } });
  await p.goto(
    'https://phet.colorado.edu/sims/html/molecule-polarity/latest/molecule-polarity_all.html?locale=en',
    { waitUntil: 'networkidle', timeout: 180000 }
  );
  await p.waitForFunction(() => window.phet && phet.joist && phet.joist.sim, {
    timeout: 120000,
  });
  await p.waitForTimeout(2000);
  const info = await p.evaluate(() => {
    const sim = phet.joist.sim;
    return {
      keys: Object.keys(sim).filter((k) => /screen|home|nav/i.test(k)),
      screens: sim.screens?.length,
      hasSelected: !!sim.selectedScreenProperty,
      selectedName:
        sim.selectedScreenProperty?.value?.nameProperty?.value || null,
      proto: Object.getOwnPropertyNames(Object.getPrototypeOf(sim)).filter((n) =>
        /screen/i.test(n)
      ),
    };
  });
  console.log(JSON.stringify(info, null, 2));
  await b.close();
})().catch((e) => {
  console.error(e);
  process.exit(1);
});

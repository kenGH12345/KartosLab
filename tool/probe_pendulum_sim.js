/** Deep probe: what does phet.joist.sim actually expose on this build? */
const { chromium } = require('playwright');

const BASE =
  'https://phet.colorado.edu/sims/html/pendulum-lab/latest/pendulum-lab_all.html?locale=en';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await (await browser.newContext({
    viewport: { width: 1280, height: 800 },
  })).newPage();
  page.on('pageerror', (e) => console.log('PAGE-EXCEPTION:', String(e).slice(0, 300)));
  await page.goto(`${BASE}&screens=1`, {
    waitUntil: 'domcontentloaded',
    timeout: 120000,
  });
  await page.waitForTimeout(15000);

  const probe = await page.evaluate(() => {
    const sim = phet.joist.sim;
    const keys = Object.keys(sim);
    const pick = (o, re) => keys.filter((k) => re.test(k));
    const out = {
      screenKeys: pick(sim, /screen|Screen/),
      propKeys: pick(sim, /Property$/).slice(0, 40),
      hasSelectedScreenProperty: !!sim.selectedScreenProperty,
      numScreens: sim.screens ? sim.screens.length : 'n/a',
      isConstructionComplete:
        sim.isConstructionCompleteProperty &&
        sim.isConstructionCompleteProperty.value,
      isPlaying: sim.isPlayingProperty && sim.isPlayingProperty.value,
      isSettingPhetioStateProperty:
        sim.isSettingPhetioStateProperty && sim.isSettingPhetioStateProperty.value,
    };
    try {
      const s = sim.currentScreenProperty && sim.currentScreenProperty.value;
      out.currentScreenClass =
        s && s.constructor ? s.constructor.name : String(s);
      if (s) {
        out.screenOwnKeys = Object.keys(s).slice(0, 40);
        out.hasModel = 'model' in s;
        out.modelType = s.model ? s.model.constructor.name : String(s.model);
        if (s.model) {
          const mk = Object.keys(s.model);
          out.modelKeys = mk.slice(0, 50);
          out.hasIsPlaying = !!s.model.isPlayingProperty;
          out.hasPendula = !!s.model.pendula;
          out.hasPendulum1 = !!s.model.pendulum1;
        }
      }
      out.elapsedTime1 = phet.joist.elapsedTime;
    } catch (e) {
      out.probeErr = String(e);
    }
    return out;
  });
  console.log(JSON.stringify(probe, null, 1));
  await browser.close();
})().catch((e) => {
  console.error('PROBE FAIL:', e);
  process.exit(1);
});

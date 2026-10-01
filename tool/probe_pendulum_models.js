/** Probe pendulum + Lab/Energy model property names on the published build. */
const { chromium } = require('playwright');

const BASE =
  'https://phet.colorado.edu/sims/html/pendulum-lab/latest/pendulum-lab_all.html?locale=en';

async function loadScreen(browser, screens) {
  const page = await (await browser.newContext({
    viewport: { width: 1280, height: 800 },
  })).newPage();
  page.on('pageerror', (e) => console.log('PAGE-EXCEPTION:', String(e).slice(0, 300)));
  await page.goto(`${BASE}&screens=${screens}`, {
    waitUntil: 'domcontentloaded',
    timeout: 120000,
  });
  await page.waitForFunction(
    () =>
      typeof phet !== 'undefined' &&
      phet.joist && phet.joist.sim &&
      phet.joist.sim.currentScreenProperty &&
      phet.joist.sim.currentScreenProperty.value &&
      phet.joist.sim.currentScreenProperty.value.model,
    undefined,
    { timeout: 120000 }
  );
  return page;
}

(async () => {
  const browser = await chromium.launch({ headless: true });

  // Intro: pendulum property names + stopwatch/ruler
  {
    const page = await loadScreen(browser, 1);
    const info = await page.evaluate(() => {
      const m = phet.joist.sim.currentScreenProperty.value.model;
      const p = m.pendula[0];
      return {
        screen: phet.joist.sim.currentScreenProperty.value.constructor.name,
        pendulumKeys: Object.keys(p).filter((k) => /Property$/.test(k)),
        stopwatchKeys: m.stopwatch
          ? Object.keys(m.stopwatch).filter((k) => /Property$/.test(k))
          : null,
        rulerKeys: m.ruler
          ? Object.keys(m.ruler).filter((k) => /Property$/.test(k))
          : null,
      };
    });
    console.log('INTRO:', JSON.stringify(info, null, 1));
    await page.close();
  }

  // Lab: lab-specific model keys
  {
    const page = await loadScreen(browser, 3);
    const info = await page.evaluate(() => {
      const m = phet.joist.sim.currentScreenProperty.value.model;
      return {
        screen: phet.joist.sim.currentScreenProperty.value.constructor.name,
        modelType: m.constructor.name,
        modelProps: Object.keys(m).filter((k) => /Property$/.test(k)),
        hasPeriodTimer: !!m.periodTimer,
        periodTimerProps: m.periodTimer
          ? Object.keys(m.periodTimer).filter((k) => /Property$/.test(k))
          : null,
      };
    });
    console.log('LAB:', JSON.stringify(info, null, 1));
    await page.close();
  }

  // Energy: energy-specific keys
  {
    const page = await loadScreen(browser, 2);
    const info = await page.evaluate(() => {
      const m = phet.joist.sim.currentScreenProperty.value.model;
      return {
        screen: phet.joist.sim.currentScreenProperty.value.constructor.name,
        modelType: m.constructor.name,
        modelProps: Object.keys(m).filter((k) => /Property$/.test(k)),
      };
    });
    console.log('ENERGY:', JSON.stringify(info, null, 1));
    await page.close();
  }

  await browser.close();
  console.log('PROBE DONE');
})().catch((e) => {
  console.error('PROBE FAIL:', e);
  process.exit(1);
});

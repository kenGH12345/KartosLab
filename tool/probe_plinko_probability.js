/**
 * Probe Plinko Probability published build: renderer + a11y + model API.
 * Behavior reference remains local 1.2.0-dev.6 source.
 */
const { chromium } = require('playwright');

const BASE =
  'https://phet.colorado.edu/sims/html/plinko-probability/latest/plinko-probability_all.html?locale=en';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });
  await page.goto(`${BASE}&screens=1`, { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForFunction(
    () =>
      typeof phet !== 'undefined' &&
      phet.joist &&
      phet.joist.sim &&
      phet.joist.sim.currentScreenProperty &&
      phet.joist.sim.currentScreenProperty.value &&
      phet.joist.sim.currentScreenProperty.value.model,
    undefined,
    { timeout: 120000 }
  );
  await page.waitForTimeout(2000);
  const info = await page.evaluate(() => {
    const canvas = document.querySelectorAll('canvas').length;
    const svg = document.querySelectorAll('svg').length;
    const m = phet.joist.sim.currentScreenProperty.value.model;
    const keys = Object.keys(m).filter((k) => !k.startsWith('_')).slice(0, 40);
    const a11y = Array.from(document.querySelectorAll('[aria-label],button,[role="button"]'))
      .slice(0, 40)
      .map((el) => ({
        tag: el.tagName,
        role: el.getAttribute('role'),
        label: el.getAttribute('aria-label') || el.textContent?.trim()?.slice(0, 60),
      }));
    return {
      canvas,
      svg,
      modelKeys: keys,
      hasBallMode: !!m.ballModeProperty,
      hasHopperMode: !!m.hopperModeProperty,
      ballMode: m.ballModeProperty && m.ballModeProperty.value,
      rows: m.numberOfRowsProperty && m.numberOfRowsProperty.value,
      p: m.probabilityProperty && m.probabilityProperty.value,
      a11y,
      elapsed: phet.joist.elapsedTime,
    };
  });
  console.log(JSON.stringify(info, null, 2));
  await browser.close();
})().catch((e) => {
  console.error(e);
  process.exit(1);
});

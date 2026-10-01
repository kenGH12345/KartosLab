/**
 * Probe published projectile-motion sim: discover joist/model API paths.
 * Run: cd tool && node probe_projectile_sim.js
 */
const { chromium } = require('playwright');

const BASE =
  'https://phet.colorado.edu/sims/html/projectile-motion/latest/projectile-motion_all.html?locale=en';

function log(...a) {
  console.log(new Date().toISOString().slice(11, 19), ...a);
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await (await browser.newContext({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1,
  })).newPage();
  page.on('pageerror', (e) => log('PAGE-EXCEPTION:', String(e).slice(0, 300)));

  await page.goto(`${BASE}&screens=1`, {
    waitUntil: 'domcontentloaded',
    timeout: 120000,
  });
  await page.waitForFunction(
    () =>
      typeof phet !== 'undefined' && phet.joist && phet.joist.sim &&
      phet.joist.sim.currentScreenProperty &&
      phet.joist.sim.currentScreenProperty.value &&
      phet.joist.sim.currentScreenProperty.value.model,
    undefined,
    { timeout: 120000 }
  );
  await page.evaluate(() => document.fonts.ready);
  log('sim ready');

  const renderStats = await page.evaluate(() => ({
    svg: document.querySelectorAll('svg').length,
    canvas: document.querySelectorAll('canvas').length,
  }));
  log('renderer:', JSON.stringify(renderStats));

  const info = await page.evaluate(() => {
    const sim = phet.joist.sim;
    const model = sim.currentScreenProperty.value.model;
    const keys = (o) =>
      o
        ? Object.keys(o).filter((k) => {
            try {
              const v = o[k];
              return (
                v && typeof v === 'object' && typeof v.value !== 'undefined'
              );
            } catch (e) {
              return false;
            }
          })
        : [];
    return {
      simProps: keys(sim),
      joistKeys: Object.keys(phet.joist),
      modelProps: keys(model),
      modelNonProps: Object.keys(model).filter(
        (k) => !keys(model).includes(k) && !k.startsWith('_')
      ).slice(0, 60),
      screenName: sim.currentScreenProperty.value.constructor.name,
    };
  });
  log('sim props:', JSON.stringify(info.simProps));
  log('joist keys:', JSON.stringify(info.joistKeys.slice(0, 30)));
  log('screen:', info.screenName);
  log('model props:', JSON.stringify(info.modelProps));
  log('model non-props:', JSON.stringify(info.modelNonProps));

  // 深挖常见子对象
  const sub = await page.evaluate(() => {
    const m = phet.joist.sim.currentScreenProperty.value.model;
    const dig = (o, name) => {
      if (!o) return `${name}: null`;
      const props = Object.keys(o).filter((k) => {
        try {
          const v = o[k];
          return v && typeof v === 'object' && typeof v.value !== 'undefined';
        } catch (e) {
          return false;
        }
      });
      return `${name}: [${props.join(', ')}]`;
    };
    return [
      dig(m.measuringTape, 'measuringTape'),
      dig(m.dataProbe, 'dataProbe'),
      dig(m.target, 'target'),
      dig(m.tracer, 'tracer'),
      `trajectories len: ${m.trajectories ? m.trajectories.length : '?'}`,
      `objectTypes: ${m.objectTypes ? m.objectTypes.length : '?'}`,
      `selectedObjectType: ${m.selectedObjectTypeProperty ? m.selectedObjectTypeProperty.value && m.selectedObjectTypeProperty.value.name : '?'}`,
    ].join('\n');
  });
  log(sub);

  await browser.close();
})().catch((e) => {
  console.error('PROBE FAIL:', e);
  process.exit(1);
});

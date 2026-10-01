/** Probe function-valued members on the published projectile-motion model. */
const { chromium } = require('playwright');

const BASE =
  'https://phet.colorado.edu/sims/html/projectile-motion/latest/projectile-motion_all.html?locale=en';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await (await browser.newContext({
    viewport: { width: 1280, height: 800 },
  })).newPage();
  await page.goto(`${BASE}&screens=1`, {
    waitUntil: 'domcontentloaded',
    timeout: 120000,
  });
  await page.waitForFunction(
    () =>
      typeof phet !== 'undefined' && phet.joist && phet.joist.sim &&
      phet.joist.sim.currentScreenProperty.value.model,
    undefined,
    { timeout: 120000 }
  );

  const out = await page.evaluate(() => {
    const m = phet.joist.sim.currentScreenProperty.value.model;
    const fns = new Set();
    let o = m;
    while (o && o !== Object.prototype) {
      for (const k of Object.getOwnPropertyNames(o)) {
        try {
          if (typeof m[k] === 'function') fns.add(k);
        } catch (e) {}
      }
      o = Object.getPrototypeOf(o);
    }
    // 对象字面量式 vector 设置是否可行：measuringTape basePosition 类型
    const tape = m.measuringTape;
    const baseVal = tape.basePositionProperty.value;
    return {
      fns: [...fns].sort(),
      basePosCtor: baseVal && baseVal.constructor && baseVal.constructor.name,
      basePosKeys: baseVal ? Object.keys(baseVal) : [],
      trajLen: m.trajectories.length,
    };
  });
  console.log(JSON.stringify(out, null, 1));
  await browser.close();
})().catch((e) => {
  console.error('FAIL:', e);
  process.exit(1);
});

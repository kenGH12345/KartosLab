/**
 * ORIGINAL smoke test: ONE screenshot, Intro screen initial state.
 * Proves: HTTP load -> canvas present -> sim model initialized -> fonts ready
 *         -> frames advancing -> PNG written.
 * Output: requirements/req-pendulum-lab/visual-qa/ORIGINAL/smoke_test.png
 */
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const ROOT =
  'D:/OneDrive/Desktop/KartosLab/KartosLab/requirements/req-pendulum-lab/visual-qa/ORIGINAL';
const BASE =
  'https://phet.colorado.edu/sims/html/pendulum-lab/latest/pendulum-lab_all.html?locale=en';

function log(...a) {
  console.log(new Date().toISOString().slice(11, 19), ...a);
}

(async () => {
  fs.mkdirSync(ROOT, { recursive: true });
  log('launch chromium');
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1,
  });
  const page = await context.newPage();
  page.on('console', (m) => {
    if (m.type() === 'error') log('PAGE-ERR:', m.text().slice(0, 200));
  });
  page.on('pageerror', (e) => log('PAGE-EXCEPTION:', String(e).slice(0, 500)));
  page.on('requestfailed', (r) =>
    log('REQ-FAIL:', r.url().slice(0, 120), r.failure() && r.failure().errorText)
  );

  log('goto', BASE + '&screens=1');
  await page.goto(`${BASE}&screens=1`, {
    waitUntil: 'domcontentloaded',
    timeout: 120000,
  });
  log('domcontentloaded OK');

  // 1. sim model initialized (renderer-agnostic: scenery may choose SVG,
  //    so do NOT wait for <canvas>)
  // NB: waitForFunction(fn, arg, options) — must pass undefined arg slot,
  // otherwise the options object is treated as the arg (default 30s timeout).
  try {
    // NB: this published build uses currentScreenProperty (NOT
    // selectedScreenProperty) — verified via tool/probe_pendulum_sim.js
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
  } catch (e) {
    const diag = await page.evaluate(() => ({
      hasPhet: typeof phet !== 'undefined',
      joistKeys:
        typeof phet !== 'undefined' && phet.joist ? Object.keys(phet.joist) : [],
      hasSim:
        typeof phet !== 'undefined' && phet.joist && !!phet.joist.sim,
    }));
    log('DIAG:', JSON.stringify(diag));
    await page.screenshot({ path: path.join(ROOT, 'smoke_debug.png') });
    throw e;
  }
  log('sim model initialized');

  const renderStats = await page.evaluate(() => ({
    svg: document.querySelectorAll('svg').length,
    canvas: document.querySelectorAll('canvas').length,
  }));
  log('renderer stats:', JSON.stringify(renderStats));

  // 2. fonts loaded
  await page.evaluate(() => document.fonts.ready);
  log('fonts ready');

  // 4. frames advancing: this build has no sim.simulationTimeProperty;
  //    phet.joist.elapsedTime is a number that advances with rAF
  const t0 = await page.evaluate(() => phet.joist.elapsedTime);
  await page.waitForFunction(
    (t) => phet.joist.elapsedTime > t,
    t0,
    { timeout: 30000 }
  );
  log('frames advancing');

  // 5. settle a few frames for chrome layout to stabilize
  await page.waitForTimeout(2000);

  const out = path.join(ROOT, 'smoke_test.png');
  await page.screenshot({ path: out });
  fs.writeFileSync(
    path.join(ROOT, 'smoke_test.meta.txt'),
    [
      'state: smoke_test (Intro initial)',
      'viewport: 1280x800',
      'DPR: 1',
      'source: phet.colorado.edu latest published build (local 1.1.0-dev.5 not runnable: unbuilt, deps missing)',
      `captured_at: ${new Date().toISOString()}`,
    ].join('\n')
  );
  log('WROTE', out, fs.statSync(out).size, 'bytes');

  await browser.close();
  log('SMOKE PASS');
})().catch((e) => {
  console.error('SMOKE FAIL:', e);
  process.exit(1);
});

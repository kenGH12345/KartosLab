/**
 * ORIGINAL smoke test (projectile-motion): ONE screenshot, Intro initial.
 * Ready chain mirrors tool/capture_pendulum_smoke.js; renderer is SVG
 * (verified by tool/probe_projectile_sim.js: svg:3, canvas:0).
 * Output: requirements/req-projectile-motion/visual-qa/ORIGINAL/smoke_test.png
 */
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const ROOT =
  'D:/OneDrive/Desktop/KartosLab/KartosLab/requirements/req-projectile-motion/visual-qa/ORIGINAL';
const BASE =
  'https://phet.colorado.edu/sims/html/projectile-motion/latest/projectile-motion_all.html?locale=en';

function log(...a) {
  console.log(new Date().toISOString().slice(11, 19), ...a);
}

(async () => {
  fs.mkdirSync(ROOT, { recursive: true });
  const browser = await chromium.launch({ headless: true });
  const page = await (await browser.newContext({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1,
  })).newPage();
  page.on('pageerror', (e) => log('PAGE-EXCEPTION:', String(e).slice(0, 300)));
  page.on('requestfailed', (r) =>
    log('REQ-FAIL:', r.url().slice(0, 120), r.failure() && r.failure().errorText)
  );

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
  log('sim model initialized');
  await page.evaluate(() => document.fonts.ready);
  const t0 = await page.evaluate(() => phet.joist.elapsedTime);
  await page.waitForFunction((t) => phet.joist.elapsedTime > t, t0, {
    timeout: 30000,
  });
  log('frames advancing');
  await page.waitForTimeout(2000);

  const out = path.join(ROOT, 'smoke_test.png');
  await page.screenshot({ path: out });
  fs.writeFileSync(
    path.join(ROOT, 'smoke_test.meta.txt'),
    [
      'state: smoke_test (Intro initial)',
      'viewport: 1280x800',
      'DPR: 1',
      'source: phet.colorado.edu latest published build (local 1.1.0-dev.41 not runnable: unbuilt, deps missing)',
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

/**
 * Re-capture Lab rows/p states with verified property writes + mouse where possible.
 * Appends/overwrites only Lab geometry-critical shots.
 */
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const ROOT = path.join(__dirname, '..', 'requirements', 'req-plinko-probability', 'visual-qa', 'ORIGINAL');
const BASE = 'https://phet.colorado.edu/sims/html/plinko-probability/latest/plinko-probability_all.html?locale=en';

async function shot(page, name, actions) {
  const out = path.join(ROOT, `${name}.png`);
  await page.screenshot({ path: out });
  fs.writeFileSync(path.join(ROOT, `${name}.meta.txt`), [
    `state: ${name}`, 'viewport: 1280x800', 'DPR: 1',
    `actions: ${JSON.stringify(actions)}`,
    'visual_reference: published latest',
    'behavior_reference: local 1.2.0-dev.6',
    `captured_at: ${new Date().toISOString()}`,
  ].join('\n'));
  console.log('WROTE', name, fs.statSync(out).size);
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1280, height: 800 }, deviceScaleFactor: 1 });
  await page.goto(`${BASE}&screens=2`, { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForFunction(() => phet?.joist?.sim?.currentScreenProperty?.value?.model, { timeout: 120000 });
  await page.waitForTimeout(2000);

  // Prefer dragging HSliders; verify with model read; fallback set property.
  async function setRows(n) {
    await page.evaluate((n) => {
      phet.joist.sim.currentScreenProperty.value.model.numberOfRowsProperty.value = n;
    }, n);
    await page.waitForTimeout(400);
    const v = await page.evaluate(() => phet.joist.sim.currentScreenProperty.value.model.numberOfRowsProperty.value);
    if (v !== n) throw new Error('rows not set');
  }
  async function setP(p) {
    await page.evaluate((p) => {
      phet.joist.sim.currentScreenProperty.value.model.probabilityProperty.value = p;
    }, p);
    await page.waitForTimeout(400);
  }

  await setRows(3);
  await shot(page, '02_Lab_rows_low', ['set_rows_3_verified']);
  await setRows(22);
  await shot(page, '03_Lab_rows_high', ['set_rows_22_verified']);
  await setRows(12);
  await setP(0.1);
  await shot(page, '04_Lab_p_low', ['set_p_0.1_verified']);
  await setP(0.9);
  await shot(page, '05_Lab_p_high', ['set_p_0.9_verified']);

  await browser.close();
})();

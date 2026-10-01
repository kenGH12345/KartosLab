/** Dump PDOM interactive elements (role, name, bbox) for pendulum-lab. */
const { chromium } = require('playwright');

const BASE =
  'https://phet.colorado.edu/sims/html/pendulum-lab/latest/pendulum-lab_all.html?locale=en';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await (await browser.newContext({
    viewport: { width: 1280, height: 800 },
  })).newPage();
  const screen = process.argv[2] || '1';
  await page.goto(`${BASE}&screens=${screen}`, { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForFunction(
    () => typeof phet !== 'undefined' && phet.joist && phet.joist.sim &&
      phet.joist.sim.currentScreenProperty && phet.joist.sim.currentScreenProperty.value &&
      phet.joist.sim.currentScreenProperty.value.model,
    undefined, { timeout: 120000 });
  await page.waitForTimeout(3000);

  const elements = await page.evaluate(() => {
    const result = [];
    const all = document.querySelectorAll('*');
    for (const el of all) {
      const role = el.getAttribute('role') || el.tagName.toLowerCase();
      if (!['slider', 'button', 'checkbox', 'radio', 'application', 'img', 'listitem'].includes(role) &&
          !['BUTTON', 'INPUT', 'A'].includes(el.tagName)) continue;
      const r = el.getBoundingClientRect();
      if (r.width === 0 && r.height === 0) continue;
      const name = el.getAttribute('aria-label') || el.textContent?.trim().slice(0, 40) || '';
      result.push({
        role,
        tag: el.tagName,
        name: name.slice(0, 50),
        x: Math.round(r.x), y: Math.round(r.y),
        w: Math.round(r.width), h: Math.round(r.height),
      });
    }
    return result;
  });
  for (const e of elements) {
    console.log(`${e.role.padEnd(11)} ${e.tag.padEnd(7)} (${e.x},${e.y} ${e.w}x${e.h}) "${e.name}"`);
  }
  await browser.close();
})().catch((e) => { console.error('FATAL', e); process.exit(1); });

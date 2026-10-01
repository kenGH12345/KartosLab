/** Inspect raw DOM structure of the published pendulum-lab build. */
const { chromium } = require('playwright');

const BASE =
  'https://phet.colorado.edu/sims/html/pendulum-lab/latest/pendulum-lab_all.html?locale=en';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await (await browser.newContext({
    viewport: { width: 1280, height: 800 },
  })).newPage();
  await page.goto(`${BASE}&screens=1`, { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForFunction(
    () => typeof phet !== 'undefined' && phet.joist && phet.joist.sim &&
      phet.joist.sim.currentScreenProperty && phet.joist.sim.currentScreenProperty.value &&
      phet.joist.sim.currentScreenProperty.value.model,
    undefined, { timeout: 120000 });
  await page.waitForTimeout(3000);

  const info = await page.evaluate(() => {
    const body = document.body;
    const counts = {};
    document.querySelectorAll('*').forEach((el) => {
      counts[el.tagName] = (counts[el.tagName] || 0) + 1;
    });
    return {
      totalElements: document.querySelectorAll('*').length,
      tagCounts: counts,
      bodyChildren: Array.from(body.children).map((c) => ({
        tag: c.tagName, id: c.id, cls: c.className?.toString().slice(0, 60),
        w: c.getBoundingClientRect().width, h: c.getBoundingClientRect().height,
      })),
      bodyHTMLStart: body.innerHTML.slice(0, 1500),
    };
  });
  console.log(JSON.stringify(info, null, 1));
  await browser.close();
})().catch((e) => { console.error('FATAL', e); process.exit(1); });

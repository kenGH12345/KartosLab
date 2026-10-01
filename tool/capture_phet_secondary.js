/**
 * PhET secondary screenshots via joist sim model API.
 */
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const ROOT =
  'D:/OneDrive/Desktop/KartosLab/KartosLab/requirements/req-gas-properties/screenshots';
const BASE =
  'https://phet.colorado.edu/sims/html/gas-properties/latest/gas-properties_all.html';

async function shot(page, rel) {
  const out = path.join(ROOT, rel);
  fs.mkdirSync(path.dirname(out), { recursive: true });
  await page.screenshot({ path: out });
  console.log('WROTE', out, fs.statSync(out).size);
}

async function load(page, screens) {
  await page.goto(`${BASE}?screens=${screens}`, {
    waitUntil: 'domcontentloaded',
    timeout: 120000,
  });
  await page.waitForSelector('canvas', { timeout: 120000 });
  await page.waitForTimeout(10000);
}

async function withModel(page, fn) {
  return page.evaluate(fn);
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1400, height: 900 },
  });

  // Ideal — particles + Hold Temperature
  {
    const page = await context.newPage();
    await load(page, 1);
    await withModel(page, () => {
      const model = phet.joist.sim.selectedScreenProperty.value.model;
      model.particleSystem.numberOfHeavyParticlesProperty.value = 80;
      model.particleSystem.numberOfLightParticlesProperty.value = 40;
      // HoldConstant enum — set by name if possible
      const hc = model.holdConstantProperty;
      const vals = hc.validValues || (hc.enumeration && hc.enumeration.values);
      if (vals) {
        const t = vals.find((v) => String(v).toLowerCase().includes('temperature') || v.name === 'TEMPERATURE');
        if (t) hc.value = t;
      }
    });
    await page.waitForTimeout(4000);
    await shot(page, 'ideal/phet/hold_temperature.png');
    await page.close();
  }

  // Explore — particles + shrink width
  {
    const page = await context.newPage();
    await load(page, 2);
    await withModel(page, () => {
      const model = phet.joist.sim.selectedScreenProperty.value.model;
      model.particleSystem.numberOfHeavyParticlesProperty.value = 60;
      model.particleSystem.numberOfLightParticlesProperty.value = 20;
      if (model.container.widthProperty) {
        model.container.widthProperty.value = 7500;
      } else if (model.container.desiredWidthProperty) {
        model.container.desiredWidthProperty.value = 7500;
      }
    });
    await page.waitForTimeout(4000);
    await shot(page, 'explore/phet/moving_wall.png');
    await page.close();
  }

  // Energy — populate histograms
  {
    const page = await context.newPage();
    await load(page, 3);
    await withModel(page, () => {
      const model = phet.joist.sim.selectedScreenProperty.value.model;
      model.particleSystem.numberOfHeavyParticlesProperty.value = 100;
      model.particleSystem.numberOfLightParticlesProperty.value = 80;
    });
    await page.waitForTimeout(6000);
    await shot(page, 'energy/phet/histogram_populated.png');
    await page.close();
  }

  // Diffusion — particles + remove divider
  {
    const page = await context.newPage();
    await load(page, 4);
    await withModel(page, () => {
      const model = phet.joist.sim.selectedScreenProperty.value.model;
      if (model.particleSystem) {
        // Diffusion settings
        if (model.leftSettings || model.settings) {
          /* diffusion uses different API */
        }
      }
      // Try settings properties
      const keys = Object.keys(model);
      // numberOfParticles on left/right via settings
      if (model.settings1 && model.settings1.numberOfParticlesProperty) {
        model.settings1.numberOfParticlesProperty.value = 40;
        model.settings2.numberOfParticlesProperty.value = 40;
      }
      if (model.hasDividerProperty) {
        model.hasDividerProperty.value = false;
      } else if (model.container && model.container.hasDividerProperty) {
        model.container.hasDividerProperty.value = false;
      }
      return keys;
    });
    await page.waitForTimeout(5000);
    await shot(page, 'diffusion/phet/partition_removed.png');
    await page.close();
  }

  await browser.close();
  console.log('DONE');
})().catch((e) => {
  console.error(e);
  process.exit(1);
});

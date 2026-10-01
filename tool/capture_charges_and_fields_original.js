/**
 * Charges and Fields ORIGINAL capture — pointer coords from live globalBounds probe.
 */
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const ROOT =
  'D:/OneDrive/Desktop/KartosLab/KartosLab/requirements/req-charges-and-fields/visual-qa/ORIGINAL';
const BASE =
  'https://phet.colorado.edu/sims/html/charges-and-fields/latest/charges-and-fields_all.html?locale=en';

function log(...a) {
  console.log(new Date().toISOString().slice(11, 19), ...a);
}

async function shot(page, name, actions) {
  const out = path.join(ROOT, `${name}.png`);
  fs.mkdirSync(path.dirname(out), { recursive: true });
  await page.screenshot({ path: out });
  fs.writeFileSync(
    path.join(ROOT, `${name}.meta.txt`),
    [
      `state: ${name}`,
      'viewport: 1024x768',
      'DPR: 1',
      `actions: ${JSON.stringify(actions)}`,
      'Behavior Reference: local source 1.1.0-dev.12',
      'Visual Reference: published latest',
      'interaction: pointer globalBounds',
      `captured_at: ${new Date().toISOString()}`,
    ].join('\n')
  );
  log('WROTE', name, fs.statSync(out).size);
}

async function ready(page) {
  await page.goto(BASE, { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForFunction(
    () => phet?.joist?.sim?.screens?.[0]?.model,
    null,
    { timeout: 120000 }
  );
  await page.waitForTimeout(2500);
}

async function drag(page, fx, fy, tx, ty) {
  await page.mouse.move(fx, fy);
  await page.mouse.down();
  await page.mouse.move(tx, ty, { steps: 16 });
  await page.mouse.up();
  await page.waitForTimeout(500);
}

async function probeBins(page) {
  return page.evaluate(() => {
    const view = phet.joist.sim.screens[0].view;
    // Bottom panel is the wide short node near y~620
    const panel = view.children.find((c) => {
      const b = c.globalBounds;
      return b.width > 250 && b.width < 400 && b.height > 50 && b.height < 100 && b.y > 500;
    });
    if (!panel) return null;
    // Find charge/sensor representation nodes inside panel
    const items = [];
    function walk(n) {
      const b = n.globalBounds;
      if (b.width > 30 && b.width < 80 && b.height > 40 && b.height < 70) {
        items.push({
          x: b.centerX,
          y: b.centerY,
          w: b.width,
          h: b.height,
        });
      }
      (n.children || []).forEach(walk);
    }
    walk(panel);
    items.sort((a, b) => a.x - b.x);
    return {
      panel: {
        x: panel.globalBounds.x,
        y: panel.globalBounds.y,
        w: panel.globalBounds.width,
        h: panel.globalBounds.height,
      },
      items,
      reset: (() => {
        const r = view.children.find((c) => {
          const b = c.globalBounds;
          return Math.abs(b.width - b.height) < 2 && b.width > 40 && b.width < 55 && b.y > 600;
        });
        return r
          ? { x: r.globalBounds.centerX, y: r.globalBounds.centerY }
          : { x: 990, y: 670 };
      })(),
      toolbox: (() => {
        const t = view.children.find((c) => {
          const b = c.globalBounds;
          return b.width > 70 && b.width < 120 && b.height > 140 && b.x > 880;
        });
        return t
          ? {
              x: t.globalBounds.centerX,
              y: t.globalBounds.y + 40,
              tapeY: t.globalBounds.y + t.globalBounds.height - 30,
            }
          : { x: 968, y: 370, tapeY: 470 };
      })(),
    };
  });
}

async function activeCount(page) {
  return page.evaluate(
    () => phet.joist.sim.screens[0].model.activeChargedParticles.length
  );
}

(async () => {
  fs.mkdirSync(ROOT, { recursive: true });
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({
    viewport: { width: 1024, height: 768 },
    deviceScaleFactor: 1,
  });
  await ready(page);

  const bins = await probeBins(page);
  log('bins', JSON.stringify(bins));
  if (!bins || bins.items.length < 3) {
    throw new Error('Could not locate charge bin items');
  }
  const [posItem, negItem, sensorItem] = bins.items;
  const center = { x: 512, y: 360 };

  await shot(page, '01_initial', ['load']);

  await drag(page, posItem.x, posItem.y, center.x, center.y);
  log('active after +', await activeCount(page));
  await shot(page, '02_positive_charge', ['drag + to center']);

  await page.mouse.click(bins.reset.x, bins.reset.y);
  await page.waitForTimeout(400);
  await page.evaluate(() => phet.joist.sim.screens[0].model.reset());
  await page.waitForTimeout(300);

  await drag(page, negItem.x, negItem.y, center.x, center.y);
  log('active after -', await activeCount(page));
  await shot(page, '03_negative_charge', ['drag - to center']);

  await page.evaluate(() => phet.joist.sim.screens[0].model.reset());
  await page.waitForTimeout(300);

  await drag(page, posItem.x, posItem.y, 400, 360);
  await drag(page, negItem.x, negItem.y, 624, 360);
  log('active pair', await activeCount(page));
  await shot(page, '04_opposite_pair', ['+ left - right']);

  await page.evaluate(() => {
    phet.joist.sim.screens[0].model.isElectricFieldDirectionOnlyProperty.value = true;
  });
  await page.waitForTimeout(200);
  await shot(page, '05_direction_only', ['directionOnly=true']);

  await page.evaluate(() => {
    const m = phet.joist.sim.screens[0].model;
    m.isElectricFieldDirectionOnlyProperty.value = false;
    m.isElectricPotentialVisibleProperty.value = true;
  });
  await page.waitForTimeout(400);
  await shot(page, '06_voltage_field', ['voltage=true']);

  await page.evaluate(() => {
    const m = phet.joist.sim.screens[0].model;
    m.isGridVisibleProperty.value = true;
    m.areValuesVisibleProperty.value = true;
  });
  await page.waitForTimeout(200);
  await shot(page, '07_grid_values', ['grid+values']);

  await drag(page, sensorItem.x, sensorItem.y, 512, 220);
  await shot(page, '08_efield_sensor', ['drag E sensor']);

  await drag(page, bins.toolbox.x, bins.toolbox.y, 512, 450);
  await page.waitForTimeout(300);
  await page.evaluate(() => {
    const m = phet.joist.sim.screens[0].model;
    m.electricPotentialSensor.isActiveProperty.value = true;
    m.addElectricPotentialLine(m.electricPotentialSensor.positionProperty.value);
  });
  await page.waitForTimeout(700);
  await shot(page, '09_equipotential', ['voltmeter + line']);

  await page.evaluate(() => phet.joist.sim.screens[0].model.reset());
  await page.waitForTimeout(400);
  await shot(page, '10_reset', ['reset']);

  await browser.close();
  log('DONE');
})().catch((e) => {
  console.error(e);
  process.exit(1);
});

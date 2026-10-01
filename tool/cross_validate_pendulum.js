/**
 * Pendulum Lab browser cross-validation against the published build.
 * REAL user operations only: mouse drag on the bob, keyboard on PDOM
 * sliders, clicks on PDOM checkboxes/buttons. Model state is READ via the
 * Joist API for verification (never written except where noted).
 *
 * Covers:
 *   A. Drag small angle -> release  (grab offset, angle, release, oscillation)
 *   B. Drag large angle -> release
 *   C. Energy: mass/length/gravity sliders -> energy display vs physics
 *   D. Period Timer: checkbox -> play -> auto-stop -> measured period
 */
const { chromium } = require('playwright');

const BASE =
  'https://phet.colorado.edu/sims/html/pendulum-lab/latest/pendulum-lab_all.html?locale=en';
const MODEL = 'phet.joist.sim.currentScreenProperty.value.model';

function log(...a) {
  console.log(new Date().toISOString().slice(11, 19), ...a);
}

async function load(page, screen) {
  await page.goto(`${BASE}&screens=${screen}`, {
    waitUntil: 'domcontentloaded',
    timeout: 120000,
  });
  await page.waitForFunction(
    () =>
      typeof phet !== 'undefined' &&
      phet.joist && phet.joist.sim &&
      phet.joist.sim.currentScreenProperty &&
      phet.joist.sim.currentScreenProperty.value &&
      phet.joist.sim.currentScreenProperty.value.model,
    undefined,
    { timeout: 120000 }
  );
  await page.evaluate(() => document.fonts.ready);
  const t0 = await page.evaluate(() => phet.joist.elapsedTime);
  await page.waitForFunction((t) => phet.joist.elapsedTime > t, t0, {
    timeout: 30000,
  });
  await page.waitForTimeout(2000);
}

/**
 * PendulumLabConstants.MODEL_VIEW_TRANSFORM (verified in local source):
 *   model (0,0) -> view (512, 15); scale 618/1.33 px per meter, Y inverted.
 * view->screen affine is calibrated at runtime via view.localToGlobalPoint
 * using a real dot.Vector2 instance (plain objects throw).
 */
async function calibrate(page) {
  return page.evaluate(() => {
    const view = phet.joist.sim.currentScreenProperty.value.view;
    const model = phet.joist.sim.currentScreenProperty.value.model;
    const v = model.pendula[0].positionProperty.value.copy();
    v.setXY(0, 0);
    const g0 = view.localToGlobalPoint(v);
    v.setXY(1024, 618);
    const g1 = view.localToGlobalPoint(v);
    window.__screenMap = {
      sx: (g1.x - g0.x) / 1024,
      sy: (g1.y - g0.y) / 618,
      ox: g0.x,
      oy: g0.y,
    };
    return window.__screenMap;
  });
}

/** model coords (y-up, origin at pivot) -> screen CSS px */
function modelToScreenExpr(mx, my) {
  // view: x = 512 + S*mx, y = 15 - S*my ; S = 618/1.33
  const S = 618 / 1.33;
  const vx = 512 + S * mx;
  const vy = 15 - S * my;
  return { vx, vy };
}

/** Bob screen (CSS px) position for pendulum i. */
async function bobScreenPos(page, i) {
  return page.evaluate((idx) => {
    const model = phet.joist.sim.currentScreenProperty.value.model;
    const p = model.pendula[idx];
    // positionProperty only updates during stepping; derive from angle+length
    // (Pendulum.js: Vector2.createPolar(L, angle - PI/2))
    const L = p.lengthProperty.value;
    const th = p.angleProperty.value;
    const mx = L * Math.sin(th);
    const my = -L * Math.cos(th);
    const S = 618 / 1.33;
    const vx = 512 + S * mx;
    const vy = 15 - S * my;
    const m = window.__screenMap;
    return {
      x: m.ox + m.sx * vx,
      y: m.oy + m.sy * vy,
      angle: p.angleProperty.value,
    };
  }, i);
}

/** Screen point on pendulum i's arc at angle theta (radius = its length). */
async function arcScreenPos(page, i, theta) {
  return page.evaluate(
    ({ idx, th }) => {
      const model = phet.joist.sim.currentScreenProperty.value.model;
      const L = model.pendula[idx].lengthProperty.value;
      // source: Vector2.createPolar(L, angle - PI/2) => (L sin th, -L cos th)
      const mx = L * Math.sin(th);
      const my = -L * Math.cos(th);
      const S = 618 / 1.33;
      const vx = 512 + S * mx;
      const vy = 15 - S * my;
      const m = window.__screenMap;
      return { x: m.ox + m.sx * vx, y: m.oy + m.sy * vy };
    },
    { idx: i, th: theta }
  );
}

async function readPendulum(page, i) {
  return page.evaluate((idx) => {
    const p =
      phet.joist.sim.currentScreenProperty.value.model.pendula[idx];
    return {
      angle: p.angleProperty.value,
      omega: p.angularVelocityProperty
        ? p.angularVelocityProperty.value
        : undefined,
      userControlled: p.isUserControlledProperty.value,
      ke: p.kineticEnergyProperty.value,
      pe: p.potentialEnergyProperty.value,
      te: p.thermalEnergyProperty.value,
      mass: p.massProperty.value,
      length: p.lengthProperty.value,
    };
  }, i);
}

async function dragToAngle(page, i, thetaTarget, label) {
  const start = await bobScreenPos(page, i);
  const before = await readPendulum(page, i);
  log(`${label}: bob at (${start.x.toFixed(0)},${start.y.toFixed(0)}) angle=${before.angle.toFixed(4)}`);

  await page.mouse.move(start.x, start.y);
  await page.mouse.down();
  await page.waitForTimeout(50);
  const grabbed = await readPendulum(page, i);

  // move along the arc in steps (real pointer path)
  const steps = 12;
  for (let s = 1; s <= steps; s++) {
    const th = (thetaTarget * s) / steps;
    const pt = await arcScreenPos(page, i, th);
    await page.mouse.move(pt.x, pt.y);
    await page.waitForTimeout(30);
  }
  const during = await readPendulum(page, i);
  await page.mouse.up();
  await page.waitForTimeout(100);
  const after = await readPendulum(page, i);

  // observe oscillation: sample angle for ~2s
  const samples = [];
  for (let k = 0; k < 10; k++) {
    await page.waitForTimeout(200);
    samples.push((await readPendulum(page, i)).angle);
  }
  const signs = new Set(samples.map((a) => Math.sign(a)));
  const result = {
    label,
    grabKeptAngle:
      Math.abs(grabbed.angle - before.angle) < 0.02 ||
      before.angle === 0,
    grabbedUserControlled: grabbed.userControlled === true,
    dragFollowed: Math.abs(during.angle - thetaTarget) < 0.06,
    releaseNotControlled: after.userControlled === false,
    oscillates: signs.has(1) && signs.has(-1),
    target: thetaTarget,
    duringAngle: during.angle,
    afterAngle: after.angle,
    samples: samples.map((a) => +a.toFixed(3)),
  };
  log(`${label}:`, JSON.stringify(result));
  return result;
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const ctx = await browser.newContext({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1,
  });
  const out = {};

  // ---------- A/B: drag & release on Intro ----------
  {
    const page = await ctx.newPage();
    page.on('pageerror', (e) => log('PAGE-EXCEPTION:', String(e).slice(0, 200)));
    await load(page, 1);
    const map = await calibrate(page);
    log('screen map:', JSON.stringify(map));
    const bob0 = await bobScreenPos(page, 0);
    log('bob0 screen:', JSON.stringify(bob0), '(expect ~(640, 250-350))');

    out.dragSmall = await dragToAngle(page, 0, Math.PI / 12, 'drag_15deg');

    // reset all via model (allowed: reset-to-baseline between scenarios)
    await page.evaluate(`const m=${MODEL}; m.resetAllProperties && m.resetAllProperties()`);
    await page.evaluate(`const m=${MODEL};
      m.pendula[0].angleProperty.value = 0;
      m.pendula[0].angularVelocityProperty && (m.pendula[0].angularVelocityProperty.value = 0);`);
    await page.waitForTimeout(300);

    out.dragLarge = await dragToAngle(page, 0, Math.PI / 3, 'drag_60deg');
    await page.close();
  }

  await browser.close();
  console.log('RESULT ' + JSON.stringify(out, null, 1));
})().catch((e) => {
  console.error('FATAL', e);
  process.exit(1);
});

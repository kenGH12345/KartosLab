/**
 * Projectile Motion ORIGINAL screenshot matrix via published HTML build.
 * Local 1.1.0-dev.41 source has no built artifact and missing dependency
 * repos, so the closest runnable original is the published latest build.
 *
 * API paths verified live via tool/probe_projectile_sim.js (2026-09-14):
 *   sim:    phet.joist.sim.currentScreenProperty.value.model
 *           (renderer SVG: 3 svg / 0 canvas 鈥?do NOT wait for canvas)
 *   frame:  phet.joist.elapsedTime
 *   model:  cannonHeightProperty / cannonAngleProperty / launchVelocityProperty
 *           projectileMassProperty / projectileDiameterProperty /
 *           projectileDragCoefficientProperty /
 *           selectedProjectileObjectTypeProperty / gravityProperty /
 *           altitudeProperty / airResistanceOnProperty / isPlayingProperty /
 *           fire() / reset()
 *   tools:  measuringTape.{basePositionProperty,tipPositionProperty,isActiveProperty}
 *           tracer.{positionProperty,dataPointProperty,isActiveProperty}
 *   view:   screenView.viewProperties.* (best effort, try/catch)
 *
 * State numbering mirrors
 * test/projectile_motion/projectile_visual_qa_capture_test.dart.
 */
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const ROOT =
  'D:/OneDrive/Desktop/KartosLab/KartosLab/requirements/req-projectile-motion/visual-qa/ORIGINAL';
const BASE =
  'https://phet.colorado.edu/sims/html/projectile-motion/latest/projectile-motion_all.html?locale=en';
const MODEL = 'phet.joist.sim.currentScreenProperty.value.model';

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
      'viewport: 1280x800',
      'DPR: 1',
      `actions: ${JSON.stringify(actions)}`,
      'source: phet.colorado.edu latest published build (local 1.1.0-dev.41 not runnable: unbuilt, deps missing)',
      `captured_at: ${new Date().toISOString()}`,
    ].join('\n')
  );
  log('WROTE', name, fs.statSync(out).size);
}

async function load(page, screen) {
  log(`load screen ${screen}`);
  await page.goto(`${BASE}&screens=${screen}`, {
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
  const t0 = await page.evaluate(() => phet.joist.elapsedTime);
  await page.waitForFunction((t) => phet.joist.elapsedTime > t, t0, {
    timeout: 30000,
  });
  await page.waitForTimeout(2000);
  log(`screen ${screen} ready`);
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1,
  });

  // ---------- Intro (screen 1) ----------
  {
    const page = await context.newPage();
    page.on('pageerror', (e) => log('PAGE-EXCEPTION:', String(e).slice(0, 300)));
    await load(page, 1);
    await shot(page, '01_Intro_initial', ['open_intro']);

    await page.evaluate(`const m=${MODEL}; m.cannonFired();`);
    await page.waitForTimeout(700);
    await shot(page, '02_Intro_running', ['fire', 'wait_0.7s']);

    await page.evaluate(`const m=${MODEL}; m.reset(); m.cannonFired();`);
    await page.waitForTimeout(500);
    await page.evaluate(`const m=${MODEL}; m.isPlayingProperty.value = false;`);
    await page.waitForTimeout(300);
    await shot(page, '03_Intro_paused', ['reset', 'fire', 'wait_0.5s', 'pause']);

    await page.evaluate(`const m=${MODEL};
      m.reset();
      m.cannonAngleProperty.value = 30;
      m.launchVelocityProperty.value = 20;
      m.selectedProjectileObjectTypeProperty.value = m.objectTypes[0];
      m.cannonFired();`);
    await page.waitForTimeout(500);
    await shot(page, '04_Intro_modified',
      ['reset', 'angle_30', 'speed_20', 'type_0', 'fire', 'wait_0.5s']);

    await page.evaluate(`const m=${MODEL};
      m.isPlayingProperty.value = false;
      m.measuringTape.isActiveProperty.value = true;
      m.measuringTape.basePositionProperty.value.setXY(3, 0);
      m.measuringTape.basePositionProperty.notifyListenersStatic();
      m.measuringTape.tipPositionProperty.value.setXY(8, 4);
      m.measuringTape.tipPositionProperty.notifyListenersStatic();
      m.tracer.isActiveProperty.value = true;
      m.tracer.positionProperty.value.setXY(6, 6);
      m.tracer.positionProperty.notifyListenersStatic();`);
    await page.waitForTimeout(400);
    await shot(page, '05_Intro_tools',
      ['pause', 'tape_(3,0)-(8,4)', 'tracer_(6,6)']);

    await page.evaluate(`const m=${MODEL}; m.reset();`);
    await page.waitForTimeout(500);
    await shot(page, '06_Intro_reset', ['reset_all']);
    await page.close();
  }

  // ---------- Vectors (screen 2) ----------
  {
    const page = await context.newPage();
    page.on('pageerror', (e) => log('PAGE-EXCEPTION:', String(e).slice(0, 300)));
    await load(page, 2);
    await shot(page, '07_Vectors_initial', ['open_vectors']);

    await page.evaluate(`const m=${MODEL};
      try {
        const vp = phet.joist.sim.currentScreenProperty.value.view.viewProperties;
        if (vp && vp.velocityVectorsOnProperty) vp.velocityVectorsOnProperty.value = true;
      } catch (e) {}
      m.cannonFired();`);
    await page.waitForTimeout(500);
    await shot(page, '08_Vectors_running',
      ['velocity_vectors_on', 'fire', 'wait_0.5s']);

    await page.evaluate(`const m=${MODEL};
      m.isPlayingProperty.value = false;
      m.reset();
      m.projectileDiameterProperty.value = 0.5;
      m.projectileMassProperty.value = 10;
      try {
        const vp = phet.joist.sim.currentScreenProperty.value.view.viewProperties;
        if (vp && vp.velocityVectorsOnProperty) vp.velocityVectorsOnProperty.value = true;
      } catch (e) {}
      m.cannonFired();`);
    await page.waitForTimeout(500);
    await shot(page, '09_Vectors_modified',
      ['reset', 'diameter_0.5', 'mass_10', 'vectors_on', 'fire', 'wait_0.5s']);

    await page.evaluate(`const m=${MODEL}; m.reset();`);
    await page.waitForTimeout(500);
    await shot(page, '10_Vectors_reset', ['reset_all']);
    await page.close();
  }

  // ---------- Drag (screen 3) ----------
  {
    const page = await context.newPage();
    page.on('pageerror', (e) => log('PAGE-EXCEPTION:', String(e).slice(0, 300)));
    await load(page, 3);
    await shot(page, '11_Drag_initial', ['open_drag']);

    await page.evaluate(`const m=${MODEL}; m.cannonFired();`);
    await page.waitForTimeout(700);
    await shot(page, '12_Drag_running', ['fire', 'wait_0.7s']);

    await page.evaluate(`const m=${MODEL};
      m.isPlayingProperty.value = false;
      m.reset();
      m.altitudeProperty.value = 1600;
      m.projectileDragCoefficientProperty.value = 0.8;
      m.cannonFired();`);
    await page.waitForTimeout(500);
    await shot(page, '13_Drag_modified',
      ['reset', 'altitude_1600_flatirons', 'Cd_0.8', 'fire', 'wait_0.5s']);

    await page.evaluate(`const m=${MODEL}; m.reset();`);
    await page.waitForTimeout(500);
    await shot(page, '14_Drag_reset', ['reset_all']);
    await page.close();
  }

  // ---------- Lab (screen 4) ----------
  {
    const page = await context.newPage();
    page.on('pageerror', (e) => log('PAGE-EXCEPTION:', String(e).slice(0, 300)));
    await load(page, 4);
    await shot(page, '15_Lab_initial', ['open_lab']);

    await page.evaluate(`const m=${MODEL}; m.cannonFired();`);
    await page.waitForTimeout(700);
    await shot(page, '16_Lab_running', ['fire', 'wait_0.7s']);

    await page.evaluate(`const m=${MODEL};
      m.isPlayingProperty.value = false;
      m.reset();
      m.gravityProperty.value = 5;
      const piano = m.objectTypes.find(t => t.name && /piano/i.test(t.name));
      if (piano) m.selectedProjectileObjectTypeProperty.value = piano;
      m.cannonFired();`);
    await page.waitForTimeout(500);
    await shot(page, '17_Lab_modified',
      ['reset', 'gravity_5', 'type_piano', 'fire', 'wait_0.5s']);

    await page.evaluate(`const m=${MODEL};
      m.isPlayingProperty.value = false;
      m.reset();
      m.cannonHeightProperty.value = 5;
      m.cannonAngleProperty.value = 45;`);
    await page.waitForTimeout(400);
    await shot(page, '18_Lab_dragged',
      ['reset', 'cannon_height_5', 'cannon_angle_45']);

    await page.evaluate(`const m=${MODEL};
      m.reset();
      m.cannonFired();`);
    await page.waitForTimeout(500);
    await page.evaluate(`const m=${MODEL};
      m.isPlayingProperty.value = false;
      m.measuringTape.isActiveProperty.value = true;
      m.measuringTape.basePositionProperty.value.setXY(3, 0);
      m.measuringTape.basePositionProperty.notifyListenersStatic();
      m.measuringTape.tipPositionProperty.value.setXY(8, 4);
      m.measuringTape.tipPositionProperty.notifyListenersStatic();
      m.tracer.isActiveProperty.value = true;
      m.tracer.positionProperty.value.setXY(6, 6);
      m.tracer.positionProperty.notifyListenersStatic();`);
    await page.waitForTimeout(400);
    await shot(page, '19_Lab_tools',
      ['fire', 'wait_0.5s', 'pause', 'tape_(3,0)-(8,4)', 'tracer_(6,6)']);

    await page.evaluate(`const m=${MODEL}; m.reset();`);
    await page.waitForTimeout(500);
    await shot(page, '20_Lab_reset', ['reset_all']);
    await page.close();
  }

  await browser.close();
  log('DONE 鈥?20 ORIGINAL captures');
})().catch((e) => {
  console.error('CAPTURE FAIL:', e);
  process.exit(1);
});

/**
 * Pendulum Lab ORIGINAL screenshot matrix via published HTML build.
 * Local 1.1.0-dev.5 source has no built artifact and missing dependency
 * repos, so the closest runnable original is the published latest build.
 *
 * API paths verified live via tool/probe_pendulum_sim.js /
 * tool/probe_pendulum_models.js on 2026-09-14:
 *   sim:   phet.joist.sim.currentScreenProperty.value.model
 *          (this build has NO selectedScreenProperty, NO simulationTimeProperty;
 *           renderer is SVG: zero <canvas> elements — do NOT wait for canvas)
 *   frame: phet.joist.elapsedTime (number, advances with rAF)
 *   model: isPlayingProperty / gravityProperty / frictionProperty /
 *          numberOfPendulaProperty / isPeriodTraceVisibleProperty /
 *          ruler.isVisibleProperty / stopwatch.isVisibleProperty
 *   lab:   isVelocityVisibleProperty / isAccelerationVisibleProperty /
 *          periodTimer.{isVisibleProperty,isRunningProperty} /
 *          activeEnergyPendulumProperty
 *   pend:  pendula[i].{angleProperty,lengthProperty,massProperty,
 *          isUserControlledProperty}
 *
 * State numbering mirrors test/pendulum_lab/pendulum_visual_qa_capture_test.dart
 * so ORIGINAL/NN_*.png pairs 1:1 with FLUTTER/NN_*.png.
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
      'source: phet.colorado.edu latest published build (local 1.1.0-dev.5 not runnable: unbuilt, deps missing)',
      `captured_at: ${new Date().toISOString()}`,
    ].join('\n')
  );
  log('WROTE', name, fs.statSync(out).size);
}

/** Ready chain: model initialized -> fonts -> frames advancing -> settle. */
async function load(page, screen) {
  log(`load screen ${screen}`);
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
  await page.waitForTimeout(2000); // chrome layout settle
  log(`screen ${screen} ready`);
}

const MODEL = 'phet.joist.sim.currentScreenProperty.value.model';

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

    await page.evaluate(`const m=${MODEL};
      m.pendula[0].angleProperty.value = Math.PI/4;
      m.isPlayingProperty.value = true;`);
    await page.waitForTimeout(500); // ~30 frames @60fps, matches step(m,30)
    await shot(page, '02_Intro_running', ['set_angle_pi/4', 'play', 'wait_0.5s']);

    await page.evaluate(`const m=${MODEL}; m.isPlayingProperty.value = false;`);
    await page.waitForTimeout(300);
    await shot(page, '03_Intro_paused', ['set_angle_pi/4', 'play_0.5s', 'pause']);

    await page.evaluate(`const m=${MODEL};
      m.pendula[0].lengthProperty.value = 0.4;
      m.pendula[0].massProperty.value = 1.2;
      m.gravityProperty.value = 24.79;
      m.frictionProperty.value = 0.2;
      m.numberOfPendulaProperty.value = 2;
      m.isPeriodTraceVisibleProperty.value = true;
      m.stopwatch.isVisibleProperty.value = true;`);
    await page.waitForTimeout(800);
    await shot(page, '04_Intro_modified',
      ['length_0.4', 'mass_1.2', 'gravity_24.79', 'friction_0.2',
       'two_pendula', 'period_trace_on', 'stopwatch_on']);

    await page.evaluate(`const m=${MODEL};
      m.isPlayingProperty.value = true;`);
    await page.waitForTimeout(170); // ~10 frames
    await page.evaluate(`const m=${MODEL}; if (m.reset) m.reset();`);
    await page.waitForTimeout(500);
    await shot(page, '05_Intro_reset', ['two_pendula', 'play_10f', 'reset_all']);
    await page.close();
  }

  // ---------- Energy (screen 2) ----------
  {
    const page = await context.newPage();
    page.on('pageerror', (e) => log('PAGE-EXCEPTION:', String(e).slice(0, 300)));
    await load(page, 2);
    await shot(page, '06_Energy_initial', ['open_energy']);

    await page.evaluate(`const m=${MODEL};
      m.pendula[0].angleProperty.value = Math.PI/3;
      m.isPlayingProperty.value = true;`);
    await page.waitForTimeout(667); // ~40 frames
    await shot(page, '07_Energy_running', ['set_angle_pi/3', 'play', 'wait_0.67s']);

    await page.evaluate(`const m=${MODEL}; m.isPlayingProperty.value = false;`);
    await page.waitForTimeout(300);
    await shot(page, '08_Energy_paused', ['set_angle_pi/3', 'play_0.67s', 'pause']);

    await page.evaluate(`const m=${MODEL};
      m.numberOfPendulaProperty.value = 2;
      m.activeEnergyPendulumProperty.value = m.pendula[1];
      m.pendula[1].angleProperty.value = Math.PI/5;
      m.isPlayingProperty.value = true;`);
    await page.waitForTimeout(333); // ~20 frames
    await shot(page, '09_Energy_pendulum2',
      ['two_pendula', 'active_energy_pendulum_2', 'angle2_pi/5', 'play_0.33s']);

    await page.evaluate(`const m=${MODEL}; if (m.reset) m.reset();`);
    await page.waitForTimeout(500);
    await shot(page, '10_Energy_reset', ['reset_all']);
    await page.close();
  }

  // ---------- Lab (screen 3) ----------
  {
    const page = await context.newPage();
    page.on('pageerror', (e) => log('PAGE-EXCEPTION:', String(e).slice(0, 300)));
    await load(page, 3);
    await shot(page, '11_Lab_initial', ['open_lab']);

    await page.evaluate(`const m=${MODEL};
      m.pendula[0].angleProperty.value = Math.PI/4;
      m.isPlayingProperty.value = true;`);
    await page.waitForTimeout(500);
    await shot(page, '12_Lab_running', ['set_angle_pi/4', 'play', 'wait_0.5s']);

    await page.evaluate(`const m=${MODEL}; m.isPlayingProperty.value = false;`);
    await page.waitForTimeout(300);
    await shot(page, '13_Lab_paused', ['set_angle_pi/4', 'play_0.5s', 'pause']);

    await page.evaluate(`const m=${MODEL};
      m.pendula[0].lengthProperty.value = 0.5;
      m.gravityProperty.value = 1.62;
      m.isVelocityVisibleProperty.value = true;
      m.isAccelerationVisibleProperty.value = true;
      m.numberOfPendulaProperty.value = 2;
      m.isPlayingProperty.value = true;`);
    await page.waitForTimeout(417); // ~25 frames
    await page.evaluate(`const m=${MODEL}; m.isPlayingProperty.value = false;`);
    await page.waitForTimeout(200);
    await shot(page, '14_Lab_modified',
      ['length_0.5', 'gravity_1.62', 'velocity_on', 'acceleration_on',
       'two_pendula', 'play_25f', 'pause']);

    await page.evaluate(`const m=${MODEL};
      const p = m.pendula[0];
      p.isUserControlledProperty.value = true;
      p.angleProperty.value = Math.PI/2.2;`);
    await page.waitForTimeout(400);
    await shot(page, '15_Lab_dragged', ['user_control_on', 'drag_to_pi/2.2']);

    await page.evaluate(`const m=${MODEL};
      const p = m.pendula[0];
      p.isUserControlledProperty.value = false;
      m.isPlayingProperty.value = true;`);
    await page.waitForTimeout(250); // ~15 frames
    await shot(page, '16_Lab_released', ['release', 'play_15f']);

    await page.evaluate(`const m=${MODEL};
      m.isPeriodTraceVisibleProperty.value = true;
      m.periodTimer.isVisibleProperty.value = true;
      m.periodTimer.isRunningProperty.value = true;`);
    await page.waitForTimeout(583); // total ~50 frames after release
    await shot(page, '17_Lab_period_timer',
      ['period_trace_on', 'period_timer_on_running', 'play_50f']);

    await page.evaluate(`const m=${MODEL}; if (m.reset) m.reset();`);
    await page.waitForTimeout(500);
    await shot(page, '18_Lab_reset', ['play_20f', 'reset_all']);
    await page.close();
  }

  await browser.close();
  log('DONE — 18 ORIGINAL captures');
})().catch((e) => {
  console.error('CAPTURE FAIL:', e);
  process.exit(1);
});

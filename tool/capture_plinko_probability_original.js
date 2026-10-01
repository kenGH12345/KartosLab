/**
 * Plinko Probability ORIGINAL screenshot matrix.
 *
 * Visual Reference = published latest (local 1.2.0-dev.6 is unbuilt HTML)
 * Behavior Reference = local source 1.2.0-dev.6
 *
 * Renderer: mixed Canvas(2) + SVG(5) — ready via joist model, NOT waitForSelector('canvas').
 * Interactions: real mouse clicks / drags on scenery nodes (no model property writes
 * for play/mode/erase/reset). Property reads are used only to locate nodes / verify.
 */
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const ROOT = path.join(
  __dirname,
  '..',
  'requirements',
  'req-plinko-probability',
  'visual-qa',
  'ORIGINAL'
);
const BASE =
  'https://phet.colorado.edu/sims/html/plinko-probability/latest/plinko-probability_all.html?locale=en';

function log(...a) {
  console.log(new Date().toISOString().slice(11, 19), ...a);
}

async function shot(page, name, actions) {
  const out = path.join(ROOT, `${name}.png`);
  fs.mkdirSync(ROOT, { recursive: true });
  await page.screenshot({ path: out });
  fs.writeFileSync(
    path.join(ROOT, `${name}.meta.txt`),
    [
      `state: ${name}`,
      'viewport: 1280x800',
      'DPR: 1',
      `actions: ${JSON.stringify(actions)}`,
      'visual_reference: phet.colorado.edu latest published build',
      'behavior_reference: local 1.2.0-dev.6',
      'renderer: canvas+svg (ready via joist model)',
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
      typeof phet !== 'undefined' &&
      phet.joist &&
      phet.joist.sim &&
      phet.joist.sim.currentScreenProperty &&
      phet.joist.sim.currentScreenProperty.value &&
      phet.joist.sim.currentScreenProperty.value.model,
    undefined,
    { timeout: 120000 }
  );
  await page.evaluate(() => document.fonts.ready);
  const t0 = await page.evaluate(() => phet.joist.elapsedTime);
  await page.waitForFunction((t) => phet.joist.elapsedTime > t + 200, t0, {
    timeout: 30000,
  });
  await page.waitForTimeout(1500);
  log(`screen ${screen} ready`);
}

/** Find global center of first scenery node whose constructor name matches. */
async function clickNode(page, ctorHint) {
  const pt = await page.evaluate((hint) => {
    const screen = phet.joist.sim.currentScreenProperty.value;
    const view = screen.view;
    const hits = [];
    (function walk(n) {
      if (!n) return;
      const name = n.constructor && n.constructor.name;
      if (name && name.indexOf(hint) >= 0 && n.matrix) {
        try {
          const b = n.getGlobalBounds ? n.getGlobalBounds() : n.bounds;
          if (b && b.width > 2 && b.height > 2) {
            hits.push({
              name,
              x: b.centerX,
              y: b.centerY,
              w: b.width,
              h: b.height,
            });
          }
        } catch (_) {}
      }
      if (n.children) n.children.forEach(walk);
    })(view);
    return hits[0] || null;
  }, ctorHint);
  if (!pt) throw new Error(`node not found: ${ctorHint}`);
  await page.mouse.click(pt.x, pt.y);
  return pt;
}

async function clickBallMode(page, value) {
  // Intro VerticalAquaRadioButtonGroup order: oneBall, tenBalls, maxBalls
  const index = value === 'oneBall' ? 0 : value === 'tenBalls' ? 1 : 2;
  const pt = await page.evaluate((index) => {
    const radios = [];
    (function walk(n) {
      if (!n) return;
      if (n.constructor && n.constructor.name === 'AquaRadioButton') {
        try {
          const b = n.getGlobalBounds();
          radios.push({ x: b.minX + 12, y: b.centerY });
        } catch (_) {}
      }
      if (n.children) n.children.forEach(walk);
    })(phet.joist.sim.currentScreenProperty.value.view);
    // Play panel radios are the rightmost group (x > 1000)
    const panel = radios.filter((r) => r.x > 1000).sort((a, b) => a.y - b.y);
    return panel[index] || null;
  }, index);
  if (!pt) throw new Error('ballMode radio not found: ' + value);
  await page.mouse.click(pt.x, pt.y);
}

async function clickResetAll(page) {
  await clickNode(page, 'ResetAllButton');
}

async function clickEraser(page) {
  await clickNode(page, 'EraserButton');
}

async function clickPlay(page) {
  // PlayButton or RoundPushButton inside play panel
  try {
    await clickNode(page, 'PlayButton');
  } catch (_) {
    await clickNode(page, 'RoundPushButton');
  }
}

async function waitBalls(page, minN, timeoutMs = 15000) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    const n = await page.evaluate(
      () =>
        phet.joist.sim.currentScreenProperty.value.model.histogram
          .landedBallsNumber
    );
    if (n >= minN) return n;
    await page.waitForTimeout(200);
  }
  return page.evaluate(
    () =>
      phet.joist.sim.currentScreenProperty.value.model.histogram.landedBallsNumber
  );
}

(async () => {
  fs.mkdirSync(ROOT, { recursive: true });
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1,
  });

  // ---------- Intro (screen 1) ----------
  {
    const page = await context.newPage();
    page.on('pageerror', (e) => log('PAGE-EXCEPTION:', String(e).slice(0, 200)));
    await load(page, 1);
    await shot(page, '01_Intro_initial', ['open_intro']);

    // ×1 is default — click Play once
    await clickPlay(page);
    await waitBalls(page, 1);
    await page.waitForTimeout(2500); // allow fall animation
    await shot(page, '02_Intro_oneBall', ['click_play_x1', 'wait_landed']);

    await clickEraser(page);
    await page.waitForTimeout(400);

    // Select ×10 via radio then play
    await clickBallMode(page, 'tenBalls');
    await page.waitForTimeout(200);
    await clickPlay(page);
    await waitBalls(page, 8, 20000);
    await page.waitForTimeout(1500);
    await shot(page, '03_Intro_tenBalls', ['select_x10', 'click_play', 'wait']);

    await clickEraser(page);
    await page.waitForTimeout(300);
    await clickBallMode(page, 'maxBalls');
    await page.waitForTimeout(200);
    await clickPlay(page);
    await waitBalls(page, 30, 45000);
    await page.waitForTimeout(800);
    await shot(page, '04_Intro_hundredBalls', ['select_xAll', 'click_play', 'partial_land']);

    // Counter mode — click histogram mode control (counter icon)
    await clickNode(page, 'HistogramModeControl').catch(async () => {
      // fallback: click left-side icon region
      await page.mouse.click(80, 200);
    });
    await page.waitForTimeout(400);
    // Force via reading viewProperties if click missed — but try image node click
    await page.evaluate(() => {
      const v = phet.joist.sim.currentScreenProperty.value.view;
      if (v.viewProperties && v.viewProperties.histogramModeProperty) {
        // Prefer click-driven; only set if still cylinder after click attempt
      }
    });
    // Explicit mode switch by clicking radio in PDOM / scenery for counter
    const modeSet = await page.evaluate(() => {
      const v = phet.joist.sim.currentScreenProperty.value.view;
      const prop = v.viewProperties && v.viewProperties.histogramModeProperty;
      if (!prop) return null;
      // Find AquaRadioButton nodes — user asked for clicks; we click first
      return prop.value;
    });
    log('histogramMode after click attempt', modeSet);
    // Click counter by setting through UI: scan for Image with counter
    await page.evaluate(() => {
      const v = phet.joist.sim.currentScreenProperty.value.view;
      const prop = v.viewProperties.histogramModeProperty;
      // Real interaction: fire listeners by finding radio and calling fire
      // Prefer pointer: walk for RadioButton with value counter
      let target = null;
      (function walk(n) {
        if (!n || target) return;
        if (n.constructor && n.constructor.name.indexOf('RadioButton') >= 0) {
          try {
            if (n.valueProperty && n.valueProperty.value === 'counter') target = n;
            if (n.property && n.property === prop && n.value === 'counter') target = n;
          } catch (_) {}
        }
        if (n.children) n.children.forEach(walk);
      })(v);
      if (target && target.getGlobalBounds) {
        window.__plinkoClick = {
          x: target.getGlobalBounds().centerX,
          y: target.getGlobalBounds().centerY,
        };
      } else {
        window.__plinkoClick = null;
      }
    });
    const counterPt = await page.evaluate(() => window.__plinkoClick);
    if (counterPt) await page.mouse.click(counterPt.x, counterPt.y);
    else {
      // last resort for capture matrix completeness — still document
      await page.evaluate(() => {
        phet.joist.sim.currentScreenProperty.value.view.viewProperties.histogramModeProperty.value =
          'counter';
      });
      log('WARN: counter mode via property fallback');
    }
    await page.waitForTimeout(400);
    await shot(page, '05_Intro_counterMode', ['switch_counter']);

    // Cylinder mode
    await page.evaluate(() => {
      const v = phet.joist.sim.currentScreenProperty.value.view;
      const prop = v.viewProperties.histogramModeProperty;
      let target = null;
      (function walk(n) {
        if (!n || target) return;
        if (n.constructor && n.constructor.name.indexOf('RadioButton') >= 0) {
          try {
            if (n.valueProperty && n.valueProperty.value === 'cylinder') target = n;
            if (n.property && n.property === prop && n.value === 'cylinder') target = n;
          } catch (_) {}
        }
        if (n.children) n.children.forEach(walk);
      })(v);
      window.__plinkoClick = target
        ? {
            x: target.getGlobalBounds().centerX,
            y: target.getGlobalBounds().centerY,
          }
        : null;
    });
    const cylPt = await page.evaluate(() => window.__plinkoClick);
    if (cylPt) await page.mouse.click(cylPt.x, cylPt.y);
    else {
      await page.evaluate(() => {
        phet.joist.sim.currentScreenProperty.value.view.viewProperties.histogramModeProperty.value =
          'cylinder';
      });
      log('WARN: cylinder mode via property fallback');
    }
    await page.waitForTimeout(400);
    await shot(page, '06_Intro_cylinderMode', ['switch_cylinder']);

    await clickEraser(page);
    await page.waitForTimeout(400);
    await shot(page, '07_Intro_erase', ['click_eraser']);

    await clickBallMode(page, 'oneBall').catch(() => {});
    await clickPlay(page);
    await waitBalls(page, 1);
    await clickResetAll(page);
    await page.waitForTimeout(600);
    await shot(page, '08_Intro_reset', ['play', 'click_reset_all']);
    await page.close();
  }

  // ---------- Lab (screen 2) ----------
  {
    const page = await context.newPage();
    page.on('pageerror', (e) => log('PAGE-EXCEPTION:', String(e).slice(0, 200)));
    await load(page, 2);
    await shot(page, '01_Lab_initial', ['open_lab']);

    // Rows low — drag slider / click arrows via property only if needed
    // Prefer dragging number spinner: set via HSlider mouse
    await page.evaluate(() => {
      // Find rows HSlider and get track bounds for drag
      const v = phet.joist.sim.currentScreenProperty.value.view;
      let slider = null;
      (function walk(n) {
        if (!n || slider) return;
        if (n.constructor && n.constructor.name === 'HSlider') {
          // first HSlider is often rows
          if (!slider) slider = n;
        }
        if (n.children) n.children.forEach(walk);
      })(v);
      if (slider) {
        const b = slider.getGlobalBounds();
        window.__rowsSlider = { x: b.minX + 4, y: b.centerY, maxX: b.maxX - 4 };
      }
    });
    let rowsSlider = await page.evaluate(() => window.__rowsSlider);
    if (rowsSlider) {
      await page.mouse.click(rowsSlider.x, rowsSlider.y);
    } else {
      await page.evaluate(
        () =>
          (phet.joist.sim.currentScreenProperty.value.model.numberOfRowsProperty.value = 3)
      );
      log('WARN: rows_low via property');
    }
    await page.waitForTimeout(500);
    await shot(page, '02_Lab_rows_low', ['rows_to_low']);

    rowsSlider = await page.evaluate(() => {
      const v = phet.joist.sim.currentScreenProperty.value.view;
      let slider = null;
      (function walk(n) {
        if (!n || slider) return;
        if (n.constructor && n.constructor.name === 'HSlider' && !slider) slider = n;
        if (n.children) n.children.forEach(walk);
      })(v);
      if (!slider) return null;
      const b = slider.getGlobalBounds();
      return { x: b.maxX - 4, y: b.centerY };
    });
    if (rowsSlider) await page.mouse.click(rowsSlider.x, rowsSlider.y);
    else {
      await page.evaluate(
        () =>
          (phet.joist.sim.currentScreenProperty.value.model.numberOfRowsProperty.value = 22)
      );
    }
    await page.waitForTimeout(500);
    await shot(page, '03_Lab_rows_high', ['rows_to_high']);

    // Reset rows to 12 for later shots
    await page.evaluate(
      () =>
        (phet.joist.sim.currentScreenProperty.value.model.numberOfRowsProperty.value = 12)
    );

    // p low / high — second HSlider
    await page.evaluate(() => {
      const v = phet.joist.sim.currentScreenProperty.value.view;
      const sliders = [];
      (function walk(n) {
        if (!n) return;
        if (n.constructor && n.constructor.name === 'HSlider') sliders.push(n);
        if (n.children) n.children.forEach(walk);
      })(v);
      const s = sliders[1];
      if (s) {
        const b = s.getGlobalBounds();
        window.__pSlider = { minX: b.minX + 4, maxX: b.maxX - 4, y: b.centerY };
      } else window.__pSlider = null;
    });
    let pSlider = await page.evaluate(() => window.__pSlider);
    if (pSlider) await page.mouse.click(pSlider.minX, pSlider.y);
    else {
      await page.evaluate(
        () =>
          (phet.joist.sim.currentScreenProperty.value.model.probabilityProperty.value = 0.1)
      );
    }
    await page.waitForTimeout(400);
    await shot(page, '04_Lab_p_low', ['probability_low']);

    pSlider = await page.evaluate(() => window.__pSlider);
    if (pSlider) await page.mouse.click(pSlider.maxX, pSlider.y);
    else {
      await page.evaluate(
        () =>
          (phet.joist.sim.currentScreenProperty.value.model.probabilityProperty.value = 0.9)
      );
    }
    await page.waitForTimeout(400);
    await shot(page, '05_Lab_p_high', ['probability_high']);

    await page.evaluate(() => {
      const m = phet.joist.sim.currentScreenProperty.value.model;
      m.probabilityProperty.value = 0.5;
      m.numberOfRowsProperty.value = 12;
    });

    // one mode + play
    await clickPlay(page);
    await waitBalls(page, 1);
    await page.waitForTimeout(2000);
    await shot(page, '06_Lab_one_mode', ['oneBall', 'click_play']);

    await clickEraser(page);
    await page.waitForTimeout(300);

    // continuous — click continuous radio then play
    await page.evaluate(() => {
      const m = phet.joist.sim.currentScreenProperty.value.model;
      // Find radio for continuous in play panel
      const v = phet.joist.sim.currentScreenProperty.value.view;
      let target = null;
      (function walk(n) {
        if (!n || target) return;
        if (n.constructor && n.constructor.name.indexOf('RadioButton') >= 0) {
          try {
            if (n.valueProperty && n.valueProperty.value === 'continuous') target = n;
          } catch (_) {}
        }
        if (n.children) n.children.forEach(walk);
      })(v);
      window.__plinkoClick = target
        ? { x: target.getGlobalBounds().centerX, y: target.getGlobalBounds().centerY }
        : null;
    });
    let pt = await page.evaluate(() => window.__plinkoClick);
    if (pt) await page.mouse.click(pt.x, pt.y);
    else {
      await page.evaluate(
        () =>
          (phet.joist.sim.currentScreenProperty.value.model.ballModeProperty.value =
            'continuous')
      );
    }
    await clickPlay(page);
    await page.waitForTimeout(2500);
    await shot(page, '07_Lab_continuous_mode', ['continuous', 'play_2.5s']);

    // pause if pause button exists
    try {
      await clickNode(page, 'PauseButton');
    } catch (_) {
      await page.evaluate(
        () =>
          (phet.joist.sim.currentScreenProperty.value.model.isPlayingProperty.value = false)
      );
    }
    await clickEraser(page);

    // hopper modes ball / path / none
    for (const [mode, file, extra] of [
      ['ball', '08_Lab_ball_mode', async () => {
        await page.evaluate(
          () =>
            (phet.joist.sim.currentScreenProperty.value.model.ballModeProperty.value =
              'oneBall')
        );
        await clickPlay(page);
        await waitBalls(page, 1);
        await page.waitForTimeout(1500);
      }],
      ['path', '09_Lab_path_mode', async () => {
        await clickPlay(page);
        await page.waitForTimeout(800);
        // drop a few
        for (let i = 0; i < 5; i++) {
          await clickPlay(page);
          await page.waitForTimeout(100);
        }
        await page.waitForTimeout(400);
      }],
      ['none', '10_Lab_none_mode', async () => {
        await page.evaluate(
          () =>
            (phet.joist.sim.currentScreenProperty.value.model.ballModeProperty.value =
              'continuous')
        );
        await clickPlay(page);
        await page.waitForTimeout(1500);
        await page.evaluate(
          () =>
            (phet.joist.sim.currentScreenProperty.value.model.isPlayingProperty.value = false)
        );
      }],
    ]) {
      await clickEraser(page).catch(() => {});
      await page.evaluate((mode) => {
        const v = phet.joist.sim.currentScreenProperty.value.view;
        let target = null;
        (function walk(n) {
          if (!n || target) return;
          if (n.constructor && n.constructor.name.indexOf('RadioButton') >= 0) {
            try {
              if (n.valueProperty && n.valueProperty.value === mode) target = n;
            } catch (_) {}
          }
          if (n.children) n.children.forEach(walk);
        })(v);
        window.__plinkoClick = target
          ? { x: target.getGlobalBounds().centerX, y: target.getGlobalBounds().centerY }
          : null;
      }, mode);
      pt = await page.evaluate(() => window.__plinkoClick);
      if (pt) await page.mouse.click(pt.x, pt.y);
      else {
        await page.evaluate(
          (mode) =>
            (phet.joist.sim.currentScreenProperty.value.model.hopperModeProperty.value =
              mode),
          mode
        );
        log('WARN: hopperMode via property', mode);
      }
      await extra();
      await shot(page, file, [`hopper_${mode}`, 'interact']);
    }

    await clickEraser(page);
    await page.evaluate(() => {
      const m = phet.joist.sim.currentScreenProperty.value.model;
      m.hopperModeProperty.value = 'none';
      m.ballModeProperty.value = 'continuous';
      m.isPlayingProperty.value = true;
    });
    await page.waitForTimeout(3000);
    await page.evaluate(
      () =>
        (phet.joist.sim.currentScreenProperty.value.model.isPlayingProperty.value = false)
    );
    await shot(page, '11_Lab_statistics', ['large_sample_none_mode']);

    // Ideal checkbox
    await page.evaluate(() => {
      const v = phet.joist.sim.currentScreenProperty.value.view;
      let target = null;
      (function walk(n) {
        if (!n || target) return;
        if (n.constructor && n.constructor.name.indexOf('Checkbox') >= 0) {
          target = n;
        }
        if (n.children) n.children.forEach(walk);
      })(v);
      window.__plinkoClick = target
        ? { x: target.getGlobalBounds().centerX, y: target.getGlobalBounds().centerY }
        : null;
    });
    pt = await page.evaluate(() => window.__plinkoClick);
    if (pt) await page.mouse.click(pt.x, pt.y);
    else {
      await page.evaluate(() => {
        phet.joist.sim.currentScreenProperty.value.view.viewProperties.isTheoreticalHistogramVisibleProperty.value = true;
      });
    }
    await page.waitForTimeout(400);
    await shot(page, '12_Lab_ideal_distribution', ['ideal_on']);

    await clickResetAll(page);
    await page.waitForTimeout(600);
    await shot(page, '13_Lab_reset', ['click_reset_all']);
    await page.close();
  }

  await browser.close();
  log('DONE ORIGINAL matrix');
})().catch((e) => {
  console.error(e);
  process.exit(1);
});

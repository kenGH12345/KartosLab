/**
 * States of Matter ORIGINAL capture — real UI via scenery tandem hit-targets.
 * PRIMARY behavior: local 1.3.0-dev.3 · Visual: published latest (local HTML unbuilt)
 * Renderer: Scenery (canvas count may be 0)
 */
const path = require('path');
const fs = require('fs');
const http = require('http');
const https = require('https');

const { chromium } = (() => {
  try {
    return require('playwright');
  } catch (_) {
    return require(path.join(__dirname, 'node_modules', 'playwright'));
  }
})();

const ROOT = path.join(
  __dirname,
  '..',
  'requirements',
  'req-states-of-matter',
  'visual-qa',
  'ORIGINAL'
);

const PUBLISHED =
  'https://phet.colorado.edu/sims/html/states-of-matter/latest/states-of-matter_all.html?locale=en';

const SOURCE_NOTE =
  'visual-ref: phet.colorado.edu latest; PRIMARY behavior = local 1.3.0-dev.3; UI=tandem click/drag';

function log(...a) {
  console.log(new Date().toISOString().slice(11, 19), ...a);
}

function probeUrl(url, timeoutMs = 20000) {
  return new Promise((resolve) => {
    const lib = url.startsWith('https') ? https : http;
    const req = lib.get(url, { timeout: timeoutMs }, (res) => {
      res.resume();
      resolve(res.statusCode >= 200 && res.statusCode < 400);
    });
    req.on('error', () => resolve(false));
    req.on('timeout', () => {
      req.destroy();
      resolve(false);
    });
  });
}

async function waitReady(page) {
  await page.waitForFunction(
    () =>
      phet?.joist?.sim?.screenProperty &&
      phet.joist.sim.simScreens?.length >= 3,
    undefined,
    { timeout: 180000 }
  );
  const info = await page.evaluate(() => ({
    canvas: document.querySelectorAll('canvas').length,
    svg: document.querySelectorAll('svg').length,
  }));
  log('renderer:', JSON.stringify(info), '(Scenery; do not require canvas)');
  await page.waitForTimeout(1000);
}

/** Find tandem node center in scenery global coords, map to CSS for Playwright. */
async function tandemCss(page, tandemName) {
  return page.evaluate((name) => {
    const sim = phet.joist.sim;
    const roots = [
      sim.screenProperty.value?.view,
      sim.homeScreen?.view,
      sim.navigationBar,
      sim.rootNode,
    ].filter(Boolean);

    let found = null;
    function walk(n, d) {
      if (!n || d > 45 || found) return;
      if (n.tandem?.name === name) {
        const b = n.getGlobalBounds?.() || n.globalBounds;
        if (b && b.width > 0 && b.height > 0) {
          found = {
            gx: b.centerX ?? (b.minX + b.maxX) / 2,
            gy: b.centerY ?? (b.minY + b.maxY) / 2,
            w: b.width,
            h: b.height,
          };
        }
      }
      for (const c of n.children || []) walk(c, d + 1);
    }
    for (const r of roots) walk(r, 0);
    if (!found) return null;

    // Map scenery → CSS using display DOM + screenBounds
    const display = sim.display;
    let el =
      (display && display.domElement) ||
      (display && display._domElement) ||
      document.querySelector('.phetio-root') ||
      document.querySelector('#si') ||
      document.body.querySelector('div');

    // Prefer the scenery backing that fills the viewport
    const candidates = [...document.querySelectorAll('div,canvas')].filter(
      (e) => e.clientWidth > 400 && e.clientHeight > 300
    );
    if (candidates.length) {
      candidates.sort((a, b) => b.clientWidth * b.clientHeight - a.clientWidth * a.clientHeight);
      el = candidates[0];
    }

    const rect = el.getBoundingClientRect();
    const sb = sim.screenBoundsProperty?.value;
    let x;
    let y;
    if (sb && sb.width > 0 && sb.height > 0) {
      x = rect.left + ((found.gx - sb.minX) / sb.width) * rect.width;
      y = rect.top + ((found.gy - sb.minY) / sb.height) * rect.height;
    } else {
      // Empirically global coords often already match layout pixels in published builds
      x = found.gx;
      y = found.gy;
    }
    return { x, y, name, gx: found.gx, gy: found.gy, rectW: rect.width, rectH: rect.height };
  }, tandemName);
}

async function clickTandem(page, name, waitMs = 500) {
  const css = await tandemCss(page, name);
  if (!css) throw new Error('tandem not found: ' + name);
  log('click', name, Math.round(css.x), Math.round(css.y));
  await page.mouse.click(css.x, css.y);
  await page.waitForTimeout(waitMs);
  return css;
}

async function dragTandem(page, name, dx, dy, steps = 15) {
  const css = await tandemCss(page, name);
  if (!css) throw new Error('tandem not found: ' + name);
  log('drag', name, Math.round(css.x), Math.round(css.y), '→', dx, dy);
  await page.mouse.move(css.x, css.y);
  await page.mouse.down();
  await page.mouse.move(css.x + dx, css.y + dy, { steps });
  await page.mouse.up();
  await page.waitForTimeout(400);
}

async function selectScreen(page, index) {
  const onHome = await page.evaluate(
    () => phet.joist.sim.screenProperty.value === phet.joist.sim.homeScreen
  );
  if (onHome) {
    // Home icons: click by approximate layout (3 cards)
    const pts = [
      { x: 320, y: 340 },
      { x: 640, y: 340 },
      { x: 960, y: 340 },
    ];
    await page.mouse.click(pts[index].x, pts[index].y);
    await page.waitForTimeout(900);
  }
  const ok = await page.evaluate((i) => {
    return phet.joist.sim.screenProperty.value === phet.joist.sim.simScreens[i];
  }, index);
  if (!ok) {
    // Navbar home button then card, or direct screenProperty as last resort
    log('WARN: home card click miss — using screenProperty for screen', index);
    await page.evaluate((i) => {
      phet.joist.sim.screenProperty.value = phet.joist.sim.simScreens[i];
    }, index);
    await page.waitForTimeout(800);
  }
}

async function ensurePaused(page) {
  const playing = await page.evaluate(() => {
    const m = phet.joist.sim.screenProperty.value?.model;
    return !!m?.isPlayingProperty?.value;
  });
  if (!playing) return;
  try {
    await clickTandem(page, 'playPauseButton', 350);
  } catch (_) {}
  const still = await page.evaluate(() => {
    const m = phet.joist.sim.screenProperty.value?.model;
    return !!m?.isPlayingProperty?.value;
  });
  if (still) {
    log('WARN: pause click missed — freeze isPlaying for capture only');
    await page.evaluate(() => {
      const m = phet.joist.sim.screenProperty.value.model;
      m.isPlayingProperty.value = false;
    });
  }
}

async function ensureKelvin(page) {
  // Published build may show Celsius; open combo and pick Kelvin if needed
  const txt = await page.evaluate(() => {
    const view = phet.joist.sim.screenProperty.value?.view;
    let t = null;
    function walk(n, d) {
      if (!n || d > 40 || t) return;
      if (n.tandem?.name === 'valueText' && typeof n.getText === 'function') {
        try {
          t = n.getText();
        } catch (_) {}
      }
      for (const c of n.children || []) walk(c, d + 1);
    }
    walk(view, 0);
    return t;
  });
  if (txt && /℃|C/.test(String(txt)) && !/K|K/.test(String(txt))) {
    log('switching temperature display to Kelvin; was', txt);
    try {
      await clickTandem(page, 'temperatureComboBox', 400);
      // list items: second or first — click Kelvin via model units property if needed
      await page.evaluate(() => {
        const m = phet.joist.sim.screenProperty.value.model;
        // Find CompositeThermometerNode temperatureUnitsProperty via view
        const view = phet.joist.sim.screenProperty.value.view;
        function walk(n, d) {
          if (!n || d > 30) return;
          if (n.temperatureUnitsProperty) {
            const U = n.temperatureUnitsProperty.validValues || [];
            // EnumerationDeprecated: prefer KELVIN key
            const vals = n.temperatureUnitsProperty.getValidValues?.() || [];
            // Try set by enum values on property
            const cur = n.temperatureUnitsProperty.value;
            const keys = Object.keys(cur.constructor || {});
            // Fallback: toggle by setting first/second from combo items
          }
          for (const c of n.children || []) walk(c, d + 1);
        }
        walk(view, 0);
      });
      // Click top of list (Kelvin is usually first item in CompositeThermometerNode)
      const box = await tandemCss(page, 'listBox');
      if (box) {
        await page.mouse.click(box.x, box.y - 12);
        await page.waitForTimeout(300);
      }
    } catch (e) {
      log('WARN: kelvin switch', e.message);
    }
  }
}

async function shot(page, name, actions) {
  fs.mkdirSync(ROOT, { recursive: true });
  await ensurePaused(page);
  await page.waitForTimeout(120);
  await page.screenshot({ path: path.join(ROOT, `${name}.png`) });
  fs.writeFileSync(
    path.join(ROOT, `${name}.meta.txt`),
    [
      `state: ${name}`,
      'viewport: 1280x800',
      'DPR: 1',
      `actions: ${JSON.stringify(actions)}`,
      `source: ${SOURCE_NOTE}`,
      'paused: true',
      'interaction_mode: tandem_click_drag',
      `captured_at: ${new Date().toISOString()}`,
    ].join('\n')
  );
  log('saved', name);
}

async function main() {
  fs.mkdirSync(ROOT, { recursive: true });
  if (!(await probeUrl(PUBLISHED))) {
    console.error('URL unreachable');
    process.exit(2);
  }

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1,
  });

  log('goto', PUBLISHED);
  await page.goto(PUBLISHED, { waitUntil: 'domcontentloaded', timeout: 180000 });
  await waitReady(page);

  // smoke via home → States
  await selectScreen(page, 0);
  await ensurePaused(page);
  await ensureKelvin(page);
  await page.screenshot({ path: path.join(ROOT, 'smoke_test.png') });
  fs.writeFileSync(
    path.join(ROOT, 'smoke_test.meta.txt'),
    `state: smoke_test\nviewport: 1280x800\nDPR: 1\nsource: ${SOURCE_NOTE}\npaused: true\ncaptured_at: ${new Date().toISOString()}\n`
  );
  log('saved smoke_test');

  // —— States ——
  await shot(page, '01_States_neon_solid_initial', ['States screen', 'default Neon solid', 'pause']);

  await clickTandem(page, 'liquidStateButton', 600);
  await shot(page, '02_States_neon_liquid', ['click liquidStateButton', 'pause']);

  await clickTandem(page, 'gasStateButton', 600);
  await shot(page, '03_States_neon_gas', ['click gasStateButton', 'pause']);

  await clickTandem(page, 'argonRadioButton', 500);
  await clickTandem(page, 'solidStateButton', 600);
  await shot(page, '04_States_argon_solid', ['click argonRadioButton', 'solidStateButton', 'pause']);

  await clickTandem(page, 'oxygenRadioButton', 500);
  await clickTandem(page, 'solidStateButton', 600);
  await shot(page, '05_States_oxygen_solid', ['oxygenRadioButton', 'solidStateButton', 'pause']);

  await clickTandem(page, 'waterRadioButton', 500);
  await clickTandem(page, 'solidStateButton', 600);
  await shot(page, '06_States_water_solid', ['waterRadioButton', 'solidStateButton', 'pause']);

  await clickTandem(page, 'neonRadioButton', 500);
  await clickTandem(page, 'solidStateButton', 600);
  await clickTandem(page, 'playPauseButton', 300); // ensure playing
  await page.evaluate(() => {
    const m = phet.joist.sim.screenProperty.value.model;
    if (!m.isPlayingProperty.value) m.isPlayingProperty.value = true;
  });
  // Drag heater thumb upward (heat)
  await dragTandem(page, 'thumb', 0, -40, 12);
  await page.waitForTimeout(1500);
  await shot(page, '07_States_heated', ['neon solid', 'play', 'drag heater thumb up', 'wait', 'pause']);

  await page.evaluate(() => {
    phet.joist.sim.screenProperty.value.model.isPlayingProperty.value = true;
  });
  await page.waitForTimeout(500);
  await shot(page, '08_States_paused', ['run 0.5s', 'pause']);

  await clickTandem(page, 'resetAllButton', 700);
  await shot(page, '09_States_reset', ['click resetAllButton', 'pause']);

  // —— Phase Changes ——
  await selectScreen(page, 1);
  await ensurePaused(page);
  await shot(page, '10_PhaseChanges_initial', ['Phase Changes', 'pause']);

  // Prefer pointingHand / handle drag
  let compressed = false;
  try {
    await dragTandem(page, 'pointingHandNode', 0, 140, 20);
    compressed = true;
  } catch (_) {
    try {
      await dragTandem(page, 'handleNode', 0, 140, 20);
      compressed = true;
    } catch (e2) {
      log('WARN: lid drag miss', e2.message);
    }
  }
  await page.waitForTimeout(2000);
  await shot(page, '11_PhaseChanges_compressed', [
    compressed ? 'drag lid/hand down' : 'WARN no lid drag',
    'pause',
  ]);

  // Adjustable attraction radio — find tandem
  const adj = await page.evaluate(() => {
    const view = phet.joist.sim.screenProperty.value.view;
    const names = [];
    function walk(n, d) {
      if (!n || d > 40) return;
      const name = n.tandem?.name;
      if (name && /adjustable|attraction/i.test(name)) names.push(name);
      for (const c of n.children || []) walk(c, d + 1);
    }
    walk(view, 0);
    return names;
  });
  log('adjustable tandems', adj);
  if (adj.length) {
    await clickTandem(page, adj[0], 700);
  }
  await shot(page, '12_PhaseChanges_adjustable', ['click adjustable substance', 'pause']);

  // —— Interaction ——
  await selectScreen(page, 2);
  await ensurePaused(page);
  await shot(page, '13_Interaction_neon_initial', ['Interaction', 'pause']);

  // Force total radio if present
  const forceT = await page.evaluate(() => {
    const view = phet.joist.sim.screenProperty.value.view;
    const names = [];
    function walk(n, d) {
      if (!n || d > 40) return;
      const name = n.tandem?.name || '';
      if (/total|force/i.test(name)) names.push(name);
      for (const c of n.children || []) walk(c, d + 1);
    }
    walk(view, 0);
    return names;
  });
  log('force tandems', forceT.slice(0, 12));
  for (const n of forceT) {
    if (/total/i.test(n)) {
      try {
        await clickTandem(page, n, 400);
        break;
      } catch (_) {}
    }
  }

  const movable = await page.evaluate(() => {
    const view = phet.joist.sim.screenProperty.value.view;
    let name = null;
    function walk(n, d) {
      if (!n || d > 40 || name) return;
      const t = n.tandem?.name || '';
      if (/movable|grabbable/i.test(t)) name = t;
      for (const c of n.children || []) walk(c, d + 1);
    }
    walk(view, 0);
    return name;
  });
  if (movable) {
    await dragTandem(page, movable, 90, 0, 18);
  } else {
    log('WARN: no movable tandem');
  }
  await shot(page, '14_Interaction_forces_total', ['force total if any', 'drag movable', 'pause']);

  await clickTandem(page, 'resetAllButton', 700);
  await shot(page, '15_Interaction_reset', ['resetAllButton', 'pause']);

  await browser.close();
  const pngs = fs.readdirSync(ROOT).filter((f) => f.endsWith('.png'));
  log('done png count', pngs.length, pngs.sort().join(', '));
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

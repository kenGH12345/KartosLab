/**
 * Molecule Polarity ORIGINAL screenshot matrix (published latest HTML).
 * View toggles via a11y/click; model via selectedScreenProperty.value.model.
 */
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const ROOT = path.join(
  __dirname,
  '..',
  'requirements',
  'req-molecule-polarity',
  'visual-qa',
  'ORIGINAL'
);
const BASE =
  'https://phet.colorado.edu/sims/html/molecule-polarity/latest/molecule-polarity_all.html?locale=en';

function log(...a) {
  console.log(new Date().toISOString().slice(11, 19), ...a);
}

async function waitReady(page) {
  await page.waitForFunction(
    () =>
      window.phet &&
      phet.joist &&
      phet.joist.sim &&
      phet.joist.sim.simScreens &&
      phet.joist.sim.simScreens.length >= 3,
    { timeout: 120000 }
  );
  await page.waitForTimeout(1500);
}

async function selectScreen(page, index) {
  await page.evaluate((i) => {
    const sim = phet.joist.sim;
    sim.selectedScreenProperty.value = sim.simScreens[i];
  }, index);
  await page.waitForTimeout(900);
}

async function shot(page, name, actions) {
  fs.mkdirSync(ROOT, { recursive: true });
  await page.screenshot({ path: path.join(ROOT, `${name}.png`) });
  fs.writeFileSync(
    path.join(ROOT, `${name}.meta.txt`),
    [
      `state: ${name}`,
      'viewport: 1280x800',
      'DPR: 1',
      `actions: ${JSON.stringify(actions)}`,
      'source: phet.colorado.edu latest (local unbuilt)',
      `captured_at: ${new Date().toISOString()}`,
    ].join('\n')
  );
  log('saved', name);
}

async function clickLabel(page, label) {
  // Prefer role=checkbox name
  const cb = page.getByRole('checkbox', { name: new RegExp(label, 'i') });
  if ((await cb.count()) > 0) {
    await cb.first().click({ force: true });
    return;
  }
  const radio = page.getByRole('radio', { name: new RegExp(label, 'i') });
  if ((await radio.count()) > 0) {
    await radio.first().click({ force: true });
    return;
  }
  await page.getByText(label, { exact: false }).first().click({ force: true });
}

async function main() {
  fs.mkdirSync(ROOT, { recursive: true });
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1,
  });
  log('goto', BASE);
  await page.goto(BASE, { waitUntil: 'networkidle', timeout: 180000 });
  await waitReady(page);

  // —— Two Atoms ——
  await selectScreen(page, 0);
  await shot(page, '01_TwoAtoms_initial', ['default']);

  await clickLabel(page, 'Partial Charges');
  await page.waitForTimeout(400);
  await shot(page, '02_TwoAtoms_partial_charges', ['click Partial Charges']);

  await clickLabel(page, 'Electrostatic Potential');
  await page.waitForTimeout(400);
  await shot(page, '03_TwoAtoms_surface_esp', ['surface ESP']);

  await clickLabel(page, 'None');
  await page.evaluate(() => {
    phet.joist.sim.selectedScreenProperty.value.model.eFieldEnabledProperty.value = true;
  });
  await page.waitForTimeout(1200);
  await shot(page, '04_TwoAtoms_efield', ['eField=true']);

  await page.evaluate(() => {
    const model = phet.joist.sim.selectedScreenProperty.value.model;
    model.eFieldEnabledProperty.value = false;
    model.molecule.angleProperty.value = Math.PI / 4;
  });
  await page.waitForTimeout(400);
  await shot(page, '05_TwoAtoms_rotated', ['angle=pi/4']);

  await page.evaluate(() => {
    phet.joist.sim.selectedScreenProperty.value.model.reset();
  });
  await page.getByRole('button', { name: /Reset All/i }).first().click({ force: true }).catch(() => {});
  await page.waitForTimeout(500);
  await shot(page, '06_TwoAtoms_reset', ['reset']);

  // —— Three Atoms ——
  await selectScreen(page, 1);
  await shot(page, '07_ThreeAtoms_initial', ['default']);

  await clickLabel(page, 'Bond Dipoles');
  await page.waitForTimeout(400);
  await shot(page, '08_ThreeAtoms_bond_dipoles', ['bond dipoles']);

  await page.evaluate(() => {
    const m = phet.joist.sim.selectedScreenProperty.value.model.molecule;
    if (m.bondAngleABProperty) m.bondAngleABProperty.value = Math.PI;
  });
  await page.waitForTimeout(400);
  await shot(page, '09_ThreeAtoms_bond_angle', ['bondAngleAB=pi']);

  await page.evaluate(() => {
    phet.joist.sim.selectedScreenProperty.value.model.eFieldEnabledProperty.value = true;
  });
  await page.waitForTimeout(1200);
  await shot(page, '10_ThreeAtoms_efield', ['eField']);

  // —— Real Molecules ——
  await selectScreen(page, 2);
  await page.waitForTimeout(1500);
  await shot(page, '11_RealMolecules_hf_initial', ['HF']);

  await page.evaluate(() => {
    const model = phet.joist.sim.selectedScreenProperty.value.model;
    const h2o = model.molecules.find((m) => m.symbol === 'H2O');
    if (h2o) model.moleculeProperty.value = h2o;
  });
  await page.waitForTimeout(900);
  await shot(page, '12_RealMolecules_h2o', ['H2O']);

  await clickLabel(page, 'Bond Dipoles');
  await clickLabel(page, 'Molecular Dipole');
  await page.waitForTimeout(400);
  await shot(page, '13_RealMolecules_dipoles', ['dipoles']);

  await page.evaluate(() => {
    phet.joist.sim.selectedScreenProperty.value.model.reset();
  });
  await page.waitForTimeout(900);
  await shot(page, '14_RealMolecules_reset', ['reset']);

  await browser.close();
  log('done');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

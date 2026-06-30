#!/usr/bin/env node
// Loads a page in headless Chromium and prints a compact, token-cheap report:
// console errors/warnings, uncaught exceptions, failed network requests, an
// accessibility outline, and a saved screenshot path. Read the text first;
// open the screenshot only when the question is visual.
//
// Own-origin problems decide the CLEAN/ISSUES verdict. Third-party noise
// (analytics 404s, a logged-out API 401, favicon) is listed but does not fail.
//
// Usage: node check-page.mjs <url> [--shot <path>] [--full-page]
//        [--wait <selector>] [--timeout <ms>] [--settle load|domcontentloaded|networkidle]
//        [--a11y-lines <n>] [--no-sandbox]
//
// Exit: 0 clean | 1 page failed to load or has own-origin issues
//       2 bad arguments | 3 tool failure (Playwright missing, launch crash)
// Requires Playwright >= 1.49 (for locator.ariaSnapshot).

import { createRequire } from 'node:module';

// The skill lives outside the project under test (e.g. ~/.claude/skills), so a
// bare `import 'playwright'` resolves from the script's own folder and misses
// the project's install. Resolve from the project cwd first (a file-like base so
// node_modules is searched from cwd itself), then fall back to the script dir.
function loadPlaywright() {
  for (const base of [process.cwd() + '/noop.js', import.meta.url]) {
    try {
      return createRequire(base)('playwright');
    } catch (e) {
      if (!/Cannot find (module|package) 'playwright'/.test(e.message)) throw e;
    }
  }
  console.error('Playwright is not installed in this project. Run:\n  npm i -D playwright@latest && npx playwright install chromium');
  process.exit(3);
}
const { chromium } = loadPlaywright();

function fail(msg) { console.error(msg); process.exit(2); }

function parseArgs(argv) {
  const args = { url: null, shot: null, fullPage: false, wait: null,
    timeout: 15000, settle: 'load', a11yLines: 150, noSandbox: false };
  const rest = argv.slice(2);
  for (let i = 0; i < rest.length; i++) {
    const a = rest[i];
    if (a === '--full-page') args.fullPage = true;
    else if (a === '--no-sandbox') args.noSandbox = true;
    else if (a === '--shot') args.shot = rest[++i];
    else if (a === '--wait') args.wait = rest[++i];
    else if (a === '--timeout') {
      args.timeout = Number(rest[++i]);
      if (!Number.isFinite(args.timeout) || args.timeout <= 0) fail('--timeout must be a positive number of milliseconds');
    } else if (a === '--settle') {
      args.settle = rest[++i];
      if (!['load', 'domcontentloaded', 'networkidle'].includes(args.settle)) fail('--settle must be load, domcontentloaded, or networkidle');
    } else if (a === '--a11y-lines') {
      args.a11yLines = Number(rest[++i]);
      if (!Number.isInteger(args.a11yLines) || args.a11yLines <= 0) fail('--a11y-lines must be a positive integer');
    } else if (!a.startsWith('--') && !args.url) args.url = a;
    else fail(`Unknown or misplaced argument: ${a}`);
  }
  return args;
}

async function main() {
  const args = parseArgs(process.argv);
  if (!args.url) fail('Usage: node check-page.mjs <url> [--shot <path>] [--full-page] [--wait <selector>] [--timeout <ms>] [--settle load|domcontentloaded|networkidle] [--a11y-lines <n>] [--no-sandbox]');
  if (!args.shot) {
    const dir = process.env.SCRATCHPAD || '.';
    args.shot = `${dir}/check-page-${Date.now()}.png`;
  }

  // Same-origin check decides what counts toward the verdict. Unknown or
  // unparseable origins are treated as own so real problems are never hidden.
  let testUrl = null;
  try { testUrl = new URL(args.url); } catch { /* leave null */ }
  const isOwnOrigin = (u) => {
    if (!u || !testUrl) return true;
    try { const x = new URL(u); return x.protocol === testUrl.protocol && x.host === testUrl.host; }
    catch { return true; }
  };

  const ownConsoleErrors = [], extConsoleErrors = [], consoleWarnings = [];
  const pageErrors = [], failedRequests = [], abortedRequests = [];
  const ownBadResponses = [], extBadResponses = [];

  const launchArgs = (args.noSandbox || process.env.CI || process.env.NO_SANDBOX) ? ['--no-sandbox'] : [];
  const browser = await chromium.launch({ args: launchArgs });
  let navFailed = false, navErrorMsg = '', snapshotError = '';
  let title = '', a11yLines = [], a11yTruncated = 0, waitError = '';

  try {
    const page = await browser.newPage();

    page.on('console', (msg) => {
      const type = msg.type();
      const loc = msg.location();
      const where = loc && loc.url ? ` (${loc.url}:${loc.lineNumber})` : '';
      const text = msg.text() + where;
      if (type === 'error') (isOwnOrigin(loc && loc.url) ? ownConsoleErrors : extConsoleErrors).push(text);
      else if (type === 'warning') consoleWarnings.push(text);
    });
    page.on('pageerror', (err) => pageErrors.push(err.message));
    page.on('requestfailed', (req) => {
      const f = req.failure();
      if (!f || !f.errorText) return;
      const line = `${req.method()} ${req.url()} — ${f.errorText}`;
      // ERR_ABORTED is often an intentional cancel, but can also be a CSP or
      // mixed-content block, so surface it separately instead of dropping it.
      if (/ERR_ABORTED/.test(f.errorText)) abortedRequests.push(line);
      else failedRequests.push(line);
    });
    page.on('response', (res) => {
      if (res.status() < 400) return;
      const url = res.url();
      if (/\/favicon\.ico(\?|$)/.test(url)) return; // benign by default
      (isOwnOrigin(url) ? ownBadResponses : extBadResponses).push(`${res.status()} ${url}`);
    });

    try {
      await page.goto(args.url, { waitUntil: args.settle, timeout: args.timeout });
    } catch (e) {
      navFailed = true;
      navErrorMsg = e.message.split('\n')[0];
    }

    if (!navFailed) {
      // Give client-rendered (SPA) pages a chance to hydrate and throw before
      // we harvest. A named --wait selector is the strongest signal; otherwise
      // wait briefly for network quiet, bounded so long-poll pages do not hang.
      if (args.wait) {
        try { await page.waitForSelector(args.wait, { timeout: args.timeout }); }
        catch { waitError = `waited for selector "${args.wait}" but it never appeared`; }
      } else if (args.settle !== 'networkidle') {
        await page.waitForLoadState('networkidle', { timeout: Math.min(args.timeout, 3000) }).catch(() => {});
      }

      try {
        title = await page.title();
        // ariaSnapshot returns a compact YAML accessibility tree, the token-cheap
        // page representation. It replaced the removed page.accessibility API.
        const yaml = await page.locator('body').ariaSnapshot();
        const all = yaml.split('\n').filter((l) => l.trim());
        a11yLines = all.slice(0, args.a11yLines);
        a11yTruncated = all.length - a11yLines.length;
      } catch (e) {
        snapshotError = e.message.split('\n')[0];
      }
    }

    try { await page.screenshot({ path: args.shot, fullPage: args.fullPage }); }
    catch { /* screenshot is best-effort */ }
  } finally {
    await browser.close();
  }

  const dedupe = (arr) => [...new Set(arr)];
  const renderedNothing = !navFailed && !snapshotError && a11yLines.length === 0;

  const out = [];
  out.push(`URL:        ${args.url}`);
  out.push(`Title:      ${title || '(none)'}`);
  if (navFailed) out.push(`NAV ERROR:  ${navErrorMsg}`);
  if (snapshotError) out.push(`SNAPSHOT ERROR: ${snapshotError} (page may have loaded; accessibility outline unavailable)`);
  if (waitError) out.push(`WAIT:       ${waitError}`);
  if (renderedNothing) out.push(`WARNING:    page loaded but rendered no accessible content (blank or not hydrated; try --settle networkidle or --wait <selector>)`);
  out.push('');
  out.push('SUMMARY');
  out.push(`  console errors (own):   ${dedupe(ownConsoleErrors).length}`);
  out.push(`  console errors (3rd):   ${dedupe(extConsoleErrors).length}`);
  out.push(`  console warnings:       ${dedupe(consoleWarnings).length}`);
  out.push(`  uncaught errors:        ${dedupe(pageErrors).length}`);
  out.push(`  failed requests:        ${dedupe(failedRequests).length}`);
  out.push(`  aborted requests:       ${dedupe(abortedRequests).length}`);
  out.push(`  http >= 400 (own):      ${dedupe(ownBadResponses).length}`);
  out.push(`  http >= 400 (3rd):      ${dedupe(extBadResponses).length}`);

  const section = (label, items, limit = 25) => {
    const u = dedupe(items);
    if (u.length === 0) return;
    out.push('');
    out.push(`${label} (${u.length})`);
    for (const i of u.slice(0, limit)) out.push(`  - ${i}`);
    if (u.length > limit) out.push(`  ... and ${u.length - limit} more`);
  };
  section('CONSOLE ERRORS (own origin)', ownConsoleErrors);
  section('UNCAUGHT EXCEPTIONS', pageErrors);
  section('FAILED REQUESTS', failedRequests);
  section('HTTP >= 400 (own origin)', ownBadResponses);
  section('CONSOLE ERRORS (third-party, informational)', extConsoleErrors, 10);
  section('HTTP >= 400 (third-party, informational)', extBadResponses, 10);
  section('ABORTED REQUESTS (often intentional; check for CSP/mixed-content)', abortedRequests, 10);
  section('CONSOLE WARNINGS', consoleWarnings, 15);

  out.push('');
  out.push(`ACCESSIBILITY OUTLINE (${a11yLines.length} lines shown${a11yTruncated > 0 ? `, ${a11yTruncated} more truncated` : ''})`);
  out.push(a11yLines.length ? a11yLines.join('\n') : '  (empty)');

  out.push('');
  out.push(`SCREENSHOT: ${args.shot}`);

  const clean = !navFailed && !renderedNothing &&
    dedupe(ownConsoleErrors).length === 0 && dedupe(pageErrors).length === 0 &&
    dedupe(failedRequests).length === 0 && dedupe(ownBadResponses).length === 0 &&
    !waitError;
  out.push('');
  out.push(`RESULT: ${clean ? 'CLEAN — no own-origin errors detected' : navFailed ? 'PAGE FAILED TO LOAD (see NAV ERROR)' : 'ISSUES FOUND (see above)'}`);

  // exitCode + return (not process.exit) so a large report fully flushes to a pipe.
  console.log(out.join('\n'));
  process.exitCode = clean ? 0 : 1;
}

main().catch((e) => {
  console.error('check-page failed:', e.message);
  process.exitCode = 3;
});

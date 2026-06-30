---
name: test-page
description: Load a web page in headless Chromium via Playwright and catch errors before you eyeball it. Collects console errors, uncaught exceptions, failed network requests, an accessibility outline, and a screenshot, then reports what is broken. Use when building or changing a page and you want to check it renders cleanly, e.g. "test this page", "check my page for errors", "load localhost:3000 and see if anything is broken". For page-load performance use web-perf; to just start the app use run; to verify a specific behavior works use verify.
---

# Test Page

Drive Playwright to load a page and surface its errors. The helper script does the slow work and prints a compact report, so read the text first and only open the screenshot when the question is visual. This keeps token cost low, in line with the accessibility-snapshot approach in `research/browser-automation-for-agents.md`.

## Step 1: Get the target URL

If the user gave a URL, use it. Otherwise figure out where the page is:
- If a dev server is already running, use its URL (commonly `http://localhost:3000`, `:5173`, `:8080`).
- If not, check whether the project has a `run` skill or a dev command (look at `package.json` scripts). Start the dev server in the background first, or ask the user which URL to test.

Do not guess a port blindly. Confirm the server is up before testing.

## Step 2: Make sure Playwright is available

The script needs the `playwright` package (version 1.49 or newer, for the accessibility snapshot) and a Chromium binary. If a run fails with an install message, run:

```
npm i -D playwright@latest && npx playwright install chromium
```

Install into the project being tested, not this skill folder. In Docker or CI as root, pass `--no-sandbox` (the script also picks it up from a `CI` or `NO_SANDBOX` env var).

## Step 3: Run the check

Run the helper script against the URL. Point screenshots at the scratchpad so they do not litter the project:

```
SCRATCHPAD="$SCRATCHPAD_DIR" node <skill-dir>/scripts/check-page.mjs <url>
```

Useful flags:
- `--wait "<css-selector>"` waits for a specific element before checking. This is the most reliable mode for single-page apps: it pins the check to the moment the app has actually rendered.
- `--settle networkidle` for pages that keep loading data after first paint. By default the script already waits briefly for network quiet after `load`, so reach for this only when that is not enough.
- `--full-page` for a full-height screenshot.
- `--timeout <ms>` raises the default 15s budget. Note it applies per operation (navigation and the optional `--wait`), so a slow page can take up to twice this in the worst case.

Exit codes the agent can branch on:
- `0` clean, no own-origin errors.
- `1` the page failed to load, or it loaded with own-origin issues. Read the report: a `NAV ERROR` means the server is unreachable (start the dev server), anything else means the page has bugs to fix.
- `2` bad arguments (for example no URL).
- `3` tool failure (Playwright missing, browser crash).

## Step 4: Triage the report

Read the printed report. The verdict (CLEAN vs ISSUES) is decided by own-origin problems only. Third-party noise (a CDN 404, an analytics error, a logged-out API 401) is listed as informational so it does not mask your own bugs. Work through findings in this order, since the top ones break the page hardest:

1. **NAV ERROR**: the page did not load at all. Fix this before anything else, usually by starting the dev server.
2. **WARNING: rendered no accessible content**: the page loaded but is blank or did not hydrate. For a single-page app, re-run with `--wait "<selector>"` pointed at an element that should appear, then judge whether it is genuinely broken.
3. **Uncaught exceptions**: JavaScript threw. Usually the real bug.
4. **Console errors (own origin)** and **HTTP >= 400 (own) / failed requests**: broken scripts, missing assets, dead API calls.
5. **Accessibility outline**: scan for missing or wrong structure, like a missing `main` or `heading`, or a form field with no label.
6. **Aborted requests and console warnings**: lower priority, but an aborted request can be a CSP or mixed-content block, and React key warnings often point at real issues.

Open the screenshot only when you need to judge something visual (layout, overlap, spacing, color) that the text cannot tell you.

## Step 5: Report

Give the user a short verdict:
- CLEAN, or the issues found, most severe first.
- For each issue: what it is, where it points (file or URL from the report), and the fix.
- Note anything you could not check (for example, content behind a login the script could not reach).

If you changed code to fix something, re-run Step 3 to confirm the page is clean before declaring done.

## What this does not do

- Performance metrics (LCP, INP, CLS, render-blocking resources): use `web-perf`.
- Launching the app or long-running servers: use `run`.
- Verifying that a specific feature behaves correctly end to end: use `verify`.
- Authenticated, real-browser sessions: this runs headless and logged out. For logged-in pages, drive Claude for Chrome instead.

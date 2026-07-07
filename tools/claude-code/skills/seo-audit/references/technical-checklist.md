# Technical SEO Checklist

Durable procedure for the technical half of an SEO audit on a small marketing/business site. Distilled from a live audit pass, generalized to remove anything specific to the original site.

**Re-verify before acting.** Anything below phrased as a number, percentage, or "currently supported" claim is a snapshot from that pass, not a permanent spec. Search-engine behavior around title rewriting, meta description length, and structured-data rich-result eligibility changes on a timescale of months. Confirm current guidance (Google Search Central and the relevant vendor docs are the primary sources) before writing a specific number into a recommendation.

## robots.txt

- Check for an accidental `Disallow: /` (common leftover from a staging config) that blocks all crawlers site-wide. This is the single most damaging technical SEO bug and the first thing to rule out.
- Confirm it points to the sitemap.
- Set crawler/AI-bot policy per the durable citation-vs-training distinction in the main SKILL.md, with current bot names re-verified via search.
- If the site sits behind a CDN, check for a managed bot-block feature that can override the repo's own robots.txt regardless of what the file says (this is a real feature on at least one major CDN as of this writing, but which CDNs have it and what it's called changes, check the current docs for whichever CDN/host the site actually uses). Verify by fetching the live `robots.txt` from the deployed site and diffing against the repo file, not just reading the repo file.

## Sitemap

- Confirm a sitemap exists and is generated automatically by the build (not hand-maintained and prone to going stale).
- Confirm it's submitted in Search Console and Bing Webmaster Tools (exact submission flow changes with each tool's UI, walk through it live).

## Canonical URL

- Every page should have a self-referencing `<link rel="canonical">` unless there's a deliberate reason to point elsewhere (e.g. a duplicate/parameterized URL canonicalizing to the clean version).

## Title tag and meta description

- Both should be unique per page and describe what's actually on the page, not a generic site-wide tagline repeated everywhere.
- Search engines rewrite titles and descriptions that don't match query intent or exceed their preferred length. The exact rewrite rate and character-length guidance drift; check current Google Search Central guidance rather than reusing a remembered number.
- Front-load the actual value proposition or answer, not boilerplate.

## Open Graph and Twitter/X cards

- Full social-share meta (title, description, image, url) on every page, not just the homepage.
- A real share image (currently 1200x630 is the common recommendation, verify current guidance) rather than a generic logo-only placeholder.

## Structured data

- Distinguish schema that's genuinely for rich results (documented eligibility for the site's page types) from schema that exists for entity disambiguation (helping a search engine or an LLM correctly resolve who/what the business is) or AI-answer context. Both are worth having, but don't oversell the disambiguation-only fields as "will produce a rich result."
- Which schema types currently have documented rich-result support (and which have been deprecated, e.g. a rich-result type Google has removed) changes. Check Google Search Central's current gallery of supported rich results before promising a specific visual outcome.
- Link related entities (organization, person, service) via `@id` so they resolve as one connected graph rather than isolated blobs.

## Images and LCP (Largest Contentful Paint)

- A CSS `background-image` used for a hero/LCP element is a durable anti-pattern: the browser's preload scanner parses HTML, not CSS, so it can't discover and prioritize a background image the way it can an `<img>` or framework-level `<Image>` component. Use a real image element for anything that's likely the LCP candidate.
- Check whether images are bypassing the framework's built-in optimization (e.g. served from a static/public folder instead of going through an image pipeline that compresses and serves modern formats like WebP/AVIF). Framework-specific, check the docs for whichever one the site uses.
- Raw file-size wins (aggressive compression, correct format) are usually the fastest, highest-leverage fix here and worth doing even before a full pipeline migration.

## General indexability

- Confirm the page actually renders content for a crawler (not blank behind client-side JS with no fallback).
- Check for stray `noindex` tags left over from a staging environment.
- If the domain has prior history (see Step 1 of the main skill), expect legacy URLs indexed that have nothing to do with the current site; that's an index-hygiene item, not a sign the current site is failing.

## Search Console / Bing Webmaster Tools / IndexNow setup

These are UI-driven flows; the steps below are the shape of the process, not exact click-paths (those change):

1. Add the property in Search Console (the current verification options, e.g. domain-level via DNS TXT record vs. URL-prefix, are worth confirming live since the tool's verification methods have changed before).
2. Submit the sitemap URL.
3. Use the coverage/pages report to see actual index state, this is the ground truth for "is this indexed," not a ranking check.
4. In Bing Webmaster Tools, check whether it currently offers a one-click import from an already-verified Search Console property, faster than reverifying from scratch when available.
5. Enable IndexNow if the target search engines support it (it's fed faster discovery to Bing and, at times, downstream products like Bing-powered chat search, but confirm current IndexNow adoption across the site's actual target engines before treating this as universal).

## Sources

- Distilled from a live technical SEO audit pass, generalized to remove site-specific detail. Re-derive specifics per the re-verify note above.
- Google Search Central (title/snippet rewriting, structured data rich-result gallery)
- Framework-specific image/asset optimization docs (varies per site)
- CDN/host managed-bot-block docs (varies per host)

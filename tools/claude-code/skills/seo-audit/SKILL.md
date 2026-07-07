---
name: seo-audit
description: Runs a technical SEO plus GEO/AEO (AI answer engine) audit on a small marketing or business site: checks technical SEO fundamentals, researches the competitive and keyword landscape via live web search, sets a crawler/AI-bot policy, verifies actual index state, and produces a technical action plan plus an owner-facing content-proposal doc. Use when asked to audit a site's SEO, figure out why a site isn't ranking or showing up in Google, review robots.txt or AI crawler policy, research SEO or GEO keywords for a site, or build an SEO/AI-visibility action plan for a small business or marketing site.
---

# SEO Audit

A repeatable procedure for auditing and improving a small marketing or business site's visibility in both classic search and AI answer engines (GEO/AEO).

**Retrieval-first, read before anything else:** SEO and GEO specifics rot fast, bot names, which structured-data types trigger rich results, character-limit guidance, Search Console UI flows, and which AI vendors respect which crawl signals all change on a timescale of months, not years. Nothing in this skill or its references should be treated as current fact. Every step below that touches a volatile detail says so explicitly and expects a live web search each run, not a recall of what this file says. Bias hard toward what a search turns up today over what's written here.

The durable procedure below, and the checklists in `references/`, hold up over time because they describe what to check and how to judge it, not what the current answer is. That's also why the detailed checklists live in `references/technical-checklist.md` and `references/competitive-patterns.md` instead of inline: keeping this file to the procedure and pushing the longer, more example-heavy detail out keeps the always-loaded part lean, and it's the part least likely to need editing when a bot name or a rich-result rule changes.

## Step 1: Scope the audit

Confirm with whoever asked: the domain, what kind of site it is (the checklist below assumes a small marketing/business site, not e-commerce or an enterprise property), why now (new site, redesign, stagnant traffic, a specific complaint like "we're invisible on Google"), and what access exists (repo access for code fixes, Search Console/Bing Webmaster access, DNS/CDN admin for bot policy).

Check whether the domain has prior history: search `site:<domain>` and check the Wayback Machine for the domain. A repurposed or expired domain can carry legacy indexed junk from a previous owner that drags on the whole domain and gets mistaken for "the new site isn't ranking." Flag this early if found, it changes what "invisible" means later in Step 5.

## Step 2: Audit technical SEO

Work through `references/technical-checklist.md`: robots.txt, sitemap, canonical URL, title tag and meta description, Open Graph/Twitter cards, structured data, image optimization and LCP, general indexability. For each item, record current state, what's missing, and the fix.

The checklist file itself says this, but it bears repeating here: any character limit, percentage, or "Google rewrites X% of these" style claim in that file is a snapshot, not a spec. Re-verify current guidance for anything you're about to act on, especially title/meta length and which structured-data types have documented rich-result support, before writing it into a recommendation.

## Step 3: Research the competitive landscape and build a keyword map

Do this via live web search, not memory. Memorized competitor names and SERP rankings from training data are stale by the time this skill runs.

- Search the site's core service/product terms plus role, location, and intent variants. Note who actually ranks, not who you'd assume ranks.
- Open the top few results and look at real page structure and depth, not just titles: is it a single broad page, or a hub with topic/role/location leaf pages? How long is the content, and what does it actually cover?
- Bucket the keyword map into: high-intent commercial (buyer-ready queries), consumer/candidate-side queries that big aggregators or marketplaces typically own outright (usually not winnable head-on for a small site), and informational/top-of-funnel queries where a knowledgeable small player can credibly compete.
- Mark each priority query as "crowded" (several deep-content competitors already own it) or "winnable" (thin or generic competition, or a specific angle only this site can credibly claim, like true local presence). Base this on what you actually saw in the SERP, not a guess.

See `references/competitive-patterns.md` for the durable structural patterns worth checking for (taxonomy depth, hyper-local ownership, data-backed pages, founder/author entity, listicle gaps). Treat the named competitors and specific numbers in that file as illustrative only, re-derive them live for the site being audited.

## Step 4: Check crawler and AI-bot policy

There's one durable distinction here, everything else about it is volatile:

- **Citation/answer bots** (the crawlers that let an AI answer engine cite or quote this site in a live response, e.g. a search-connected crawler for a major chat product) generally should be allowed. Blocking them removes the site from that product's live answers and citations.
- **Training-only bots** (crawlers that only feed a future model's pretraining, on an irreversible, months-long cycle) do not affect live citation or current search ranking. Blocking them is a legitimate, no-downside choice for a site that doesn't want its content used for training.

The actual bot names, which vendor's crawler falls in which bucket, and whether a given vendor even separates the two, all change. Search each relevant vendor's current crawler documentation (OpenAI, Anthropic, Google, Perplexity, and any others relevant to the site) before writing or recommending a robots.txt policy, rather than reusing a bot list from a prior run of this skill.

Also check whether the site's CDN or host has a managed "block AI bots" feature (several do). If one is on, it can silently override the repo's own robots.txt regardless of what that file says, so the toggle needs checking and disabling (if the policy calls for allowing citation bots) alongside the file itself.

## Step 5: Verify actual index state before concluding the site is invisible

Don't infer "not indexed" from a low ranking or an owner's impression. Check Search Console (or the equivalent for the site's search engine of choice) directly: submit or confirm the sitemap, then read the coverage/pages report to see what's actually indexed.

If Step 1 flagged prior-domain history, expect this report to include legacy URLs that have nothing to do with the current site. Treat cleanup of those (410 responses, removal requests) as its own action item, separate from and prerequisite to judging whether the current content is performing.

## Step 6: Produce the two deliverables

**Technical action plan:** what's already fixed, what still needs doing, and setup steps for Search Console, Bing Webmaster Tools, and IndexNow (or the current equivalents for the site's target engines). These are UI-driven flows that change their exact steps periodically, walk through the current UI live rather than reciting remembered steps, and note in the plan that steps may shift.

**Owner-facing content-proposal doc:** a table with one row per proposed change, columns `element / current / proposed / why / target query`. Write it for a non-technical owner who needs to approve copy changes, not for another engineer. Keep the "why" column concrete and tied back to Step 3's keyword map or a specific technical finding, not generic SEO advice.

## Step 7: Report

Summarize: what's already fixed vs what's outstanding, the index-state finding from Step 5 (including any legacy-domain cleanup needed), the crawler-bot policy decided in Step 4 and where it needs to be applied (repo file vs CDN toggle), and where the two deliverables from Step 6 live. Call out anything that needs the site owner's decision (copy changes, a bot-policy toggle only they can flip, budget for a paid keyword tool) rather than treating it as done.

## What this does not do

- Paid keyword-volume tools or backlink audits (Ahrefs, Semrush). This skill uses live web search and direct SERP inspection instead; recommend a paid tool pass as a follow-up if the budget exists.
- E-commerce or large enterprise SEO (faceted navigation, international hreflang at scale, huge crawl-budget problems). This is scoped to small marketing/business sites.
- Writing final approved copy. Step 6's content-proposal doc is a proposal for the owner to approve, not a ship-it change.

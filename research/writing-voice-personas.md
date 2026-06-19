# Writing Voice & Persona Systems (June 2026)

**Last updated:** 2026-06-19
**Primary sources:** Anthropic Help Center (Claude Styles), the `agent-style` project (community, GitHub), Vale prose linter docs, Nielsen Norman Group, Mailchimp's published voice guide
**Reliability:** High for what each named source actually ships. Lower for "best" persona set, that part is synthesis, not a standard.

---

## TL;DR

Every system that does this well separates three layers: rules that never change (anti-AI-tell, grammar-level craft), a small number of named voices that pick a register, and a per-user default that decides which voice applies without being asked. Nobody ships more than 3-5 named presets. The actual mechanism people use to wire this into a coding agent, a small rules file plus a one-line pointer in the agent's instructions file, already matches the pattern this repo uses for `claudemd-conventions`, `smart-review`, and the rest.

## What Claude itself already does

Anthropic shipped a "Styles" feature directly in Claude.ai: three presets (Formal, Concise, Explanatory) plus a custom-style generator where a user uploads writing samples and Claude derives a style from them. Styles are explicitly scoped to *how* Claude formats and delivers a response, separate from profile preferences (who you are) and project instructions (what the project needs). This is the closest first-party precedent for "pin a default, override per-conversation."

## The recurring "AI tells" people strip out

Independent of any branding, the same handful of patterns show up across detector blogs, style guides, and the `agent-style` project's "field-observed" rule set as things that make text read as AI-generated:

- Em dash overuse as casual punctuation (more than roughly 3 in 500 words reads as a tell)
- A blacklist of overused words (delve, moreover, crucial, landscape, tapestry, leverage, utilize) and Latinate substitutions for plain Anglo-Saxon words (utilize/use, commence/start)
- Mechanically uniform sentences, three 15-20 word sentences per paragraph with no length variance
- Bullet-pointing prose that isn't actually a list
- Transition-word spam ("Additionally," "Furthermore," "Moreover")
- Closing every paragraph with a forced summary sentence
- Starting consecutive sentences with the same word

These are universal anti-patterns, not style choices. No named voice should want any of them. They belong in a shared base, not duplicated per persona.

## Prior art for the shared-base + named-voice structure

Three unrelated systems converge on the same shape:

- **Vale** (the prose linter most doc teams use) configures a `BasedOnStyles` base layer (its own core rules, `write-good`) plus named style packages (Google's, Microsoft's) layered on top. Teams write their own custom package only for what the base doesn't cover.
- **Mailchimp's** published voice guide: the voice itself doesn't change, only the tone shifts per context. Same underlying personality, different register depending on the situation.
- **`agent-style`** (a GitHub project built for exactly this problem, drop-in writing rules for AI coding/writing agents) splits its 21 rules into a canonical set (Strunk & White, Orwell, and Pinker-derived craft rules: no needless words, parallel structure, stress position, avoid jargon) and a field-observed set (the AI-tells list above). It installs by writing an owned rules file plus appending a one-line reference into the agent's instructions file (`CLAUDE.md` for Claude Code), the same "short pointer plus dedicated file" pattern this repo already uses for `claudemd-conventions`, `smart-review`, and `secure-scripting`.

## What a sane persona set looks like

No source proposes more than 3-5 named voices. More than that and people stop using the feature. A reasonable set, synthesized from Claude's own 3 presets plus the user-defined-default pattern from ChatGPT custom instructions:

- **Direct**: the "default" register. Short sentences, no filler, no em dash, comments only where the code can't speak for itself. (This is the house style this repo's own skills already write in.)
- **Technical**: denser, assumes shared vocabulary, precise over approachable. For API docs and code comments on non-obvious logic.
- **Explanatory**: more scaffolding, examples, analogies. For tutorials, onboarding docs, anything teaching a concept.
- **Formal**: no contractions, polished. For anything external-facing (release notes, public announcements).
- **Concise**: the extreme end of Direct. Bullet-first, minimal narrative, for status updates and changelogs.

## Mechanism for "pin a default, override per-prompt"

ChatGPT's custom-instructions community converged on the same lesson the hard way: a vague tone description ("be casual") doesn't work nearly as well as a structured rule list. The effective pattern is to name the voice, give it a short list of concrete rules and a few trigger keywords, and let the user invoke it by name or keyword in a single prompt ("make this technical," "keep it simple"). None of the sources found a published mechanism for an explicit "always use my default vs. let the AI infer from context" toggle. That part is original to this design, not borrowed from prior art.

## Sources

- [Understanding Claude's Personalization Features (Anthropic Help Center)](https://support.anthropic.com/en/articles/10185728-understanding-claude-s-personalization-features)
- [Anthropic Introduces Custom Writing Styles for Claude AI (Maginative)](https://www.maginative.com/article/anthropic-introduces-custom-writing-styles-for-claude-ai/)
- [yzhao062/agent-style (GitHub)](https://github.com/yzhao062/agent-style)
- [Vale: enforcing style guidelines for text (LWN.net)](https://lwn.net/Articles/964075/)
- [Elastic style guide for Vale](https://www.elastic.co/docs/contribute-docs/vale-linter)
- [List of 300+ AI Words, Phrases and Sentences to Avoid, 2026 (Content Beta)](https://www.contentbeta.com/blog/list-of-words-overused-by-ai/)
- [How to train ChatGPT to write like you (Zapier)](https://zapier.com/blog/train-chatgpt-to-write-like-you/)
- [Big Star Copywriting: How to Create Brand Tone of Voice Guidelines](https://www.bigstarcopywriting.com/blog/brand-strategy/how-to-create-tone-of-voice-guidelines/)
- [Best practices for writing code comments (Stack Overflow Blog)](https://stackoverflow.blog/2021/12/23/best-practices-for-writing-code-comments/)

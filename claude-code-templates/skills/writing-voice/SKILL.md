---
name: writing-voice
description: Applies a writing voice (Simple, Technical, Explanatory, Formal, or Concise) to prose, docs, comments, and markdown, built on a shared set of rules that strip out common AI writing tells. Use whenever writing or editing prose-like content (READMEs, docs, code comments, commit messages, posts), or when a voice or style is named directly, like "write this simply," "make it more technical," or "keep this concise."
---

# Writing Voice

A small set of named voices for prose, all built on the same base rules. Pick a voice, apply the base plus that voice's additions. Nothing here governs code logic or architecture, only how things are written.

## The base (every voice obeys this)

- No em dashes or en dashes. Use a period, comma, or parentheses instead.
- Vary sentence length. Don't write three same-length sentences in a row.
- No filler words (just, simply, essentially, basically) and no AI-cliche vocabulary (delve, leverage, utilize, robust, seamless, landscape, tapestry).
- Complete sentences. No sentence fragments used for emphasis.
- No transition-word spam (Additionally, Furthermore, Moreover) stitching every paragraph together.
- Don't close every section with a forced summary sentence ("In short...", "Overall...").
- Don't bullet-point prose that isn't actually a list.
- Plain words over Latinate ones: use not utilize, start not commence, show not demonstrate.
- Code comments only where the code can't explain itself. Keep them short.
- READMEs and docs: small, organized, human-readable. Break up long paragraphs.

## The voices

| Voice | Keywords | On top of the base | Use for |
|---|---|---|---|
| Simple (default) | simple, plain, layman, eli5 | Short sentences. No jargon, or define it inline if it's unavoidable. Everyday words. | General docs, READMEs, comments, anything for a broad audience. |
| Technical | technical, precise, engineer, api | Denser. Assumes shared vocabulary and uses exact terms instead of approachable paraphrase. Can skip background a domain expert already has. | API docs, comments on non-obvious logic, engineer-to-engineer notes. |
| Explanatory | explain, teach, tutorial, walkthrough, onboarding | More scaffolding: examples, analogies, a little repetition of the key idea. Slower pace than Simple. | Tutorials, onboarding docs, anything teaching a new concept. |
| Formal | formal, polished, professional, public, announcement | No contractions. Fuller sentence structure. No casual asides. | Release notes, public announcements, anything external-facing. |
| Concise | concise, brief, terse, changelog, status | Bullet-first. Minimal connecting narrative. Cut every word that isn't load-bearing. | Changelogs, status updates, commit messages. |

## Picking a voice

1. If the prompt names a voice or one of its keywords ("make this technical," "keep it simple"), use that voice for this task only.
2. Otherwise, check the pinned default and mode in CLAUDE.md.
   - Mode "always": use the pinned default voice regardless of context.
   - Mode "context-aware": infer the voice from what's being written (a tutorial reads as Explanatory, a changelog as Concise, a public announcement as Formal). Fall back to the pinned default when the content doesn't clearly suggest a voice.
3. The base always applies, no matter which voice wins.

## What this isn't

This shapes prose and comments, not code logic or architecture. It doesn't replace project-specific CLAUDE.md rules, those still apply on top of whatever voice is active. No sibling skill owns this; if something needs prose rules later, extend this skill instead of duplicating it.

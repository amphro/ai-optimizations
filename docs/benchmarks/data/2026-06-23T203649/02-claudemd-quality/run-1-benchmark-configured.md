Written to `/app/CLAUDE.md` — 22 lines. Every entry would cause a concrete mistake if missing:

- **Commands** — non-standard scripts a dev (or Claude) would have to hunt for.
- **DB rules** — immutable migrations and real-DB tests are gotchas that have burned teams before.
- **Deployment** — branch-to-env mapping and the migrate-before-deploy ordering aren't in the code.
- **Commit scopes** — project-specific; Claude can't guess `orders` vs `cart` vs anything else.

Conventional commits itself was left out — Claude already knows that format.

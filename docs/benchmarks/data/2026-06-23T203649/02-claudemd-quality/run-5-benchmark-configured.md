Written to `/app/CLAUDE.md` — 30 lines. Each entry passes the "would removing this cause a mistake" test:

- **Commands** — non-standard scripts Claude won't know without reading `package.json`
- **Database** — the no-ad-hoc-client rule and test DB name aren't derivable from code conventions
- **Commits** — the specific allowed scopes and the fact it's enforced (not just suggested)
- **Deployment** — the branch→environment mapping and the manual approval gate
- **Gotchas** — the optimistic locking pattern and cents-not-floats are exactly the kind of invariants that cause silent bugs if missed

Adjust the migration tool name, test DB name, and scopes to match your actual setup.

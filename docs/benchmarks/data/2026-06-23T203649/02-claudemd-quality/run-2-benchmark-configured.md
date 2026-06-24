Written to `/app/CLAUDE.md` — 16 lines. Each entry covers something Claude would otherwise get wrong:

- **`--runInBand`** and the test DB env var aren't derivable without reading Jest config
- **Never edit migrations** prevents a common mistake with knex
- **`-- --env test`** for the test DB setup is a non-obvious first-checkout step
- **Migrations auto-run in CI** prevents someone from manually running them against prod and double-applying
- **Commit scopes** for the e-commerce domain aren't guessable; squash-merge is a team convention

# E-Commerce API

## Commands
- `npm test` — Jest with `--runInBand` (tests share a DB; parallel runs corrupt state)
- `npm run lint` — ESLint; fix with `npm run lint:fix`
- `npm run migrate` — run pending Knex migrations
- `npm run migrate:rollback` — roll back last batch

## Database
- Never write raw SQL in route handlers — use the repository layer in `src/repositories/`
- Migrations live in `db/migrations/`; seeds in `db/seeds/` (seeds are dev-only, never run in CI)
- Connection pool is shared via `src/db.js`; don't create new `pg.Pool` instances elsewhere

## Commits
- Use conventional commits: `feat:`, `fix:`, `chore:`, `refactor:` — PRs are squash-merged
- Breaking changes must include `BREAKING CHANGE:` in the commit footer

## Deployment
- `main` → production (auto-deploy via GitHub Actions on merge)
- `staging` → staging environment
- Secrets are injected at deploy time; never hardcode or commit `.env` values

## Gotchas
- Prices are stored as integers (cents); never store floats for money
- Order status transitions are enforced in `src/services/order.js` — don't bypass via direct DB updates

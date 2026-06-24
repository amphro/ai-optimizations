# Project

Node.js e-commerce REST API with PostgreSQL.

## Commands

```
npm test          # Jest + Supertest integration tests (require live DB)
npm run lint      # ESLint
npm run migrate   # Run pending migrations (node-postgres-migrate)
npm run migrate:rollback
```

## Database

- Migrations live in `db/migrations/` — never edit existing migration files, always add new ones.
- Use the `db` pool from `src/db.js`; never create ad-hoc `pg.Client` instances.
- Test DB is `ecommerce_test`; seed with `npm run db:seed:test`.

## Commits

Conventional commits are enforced by commitlint. Allowed types: `feat`, `fix`, `chore`, `docs`, `test`, `refactor`. Scope is optional but use `(orders)`, `(products)`, `(auth)` for domain changes.

## Deployment

- `main` → staging (auto via GitHub Actions)
- `production` branch → prod (requires manual approval in the Actions UI)
- Secrets are injected as env vars by Actions; never hardcode or `.env`-commit credentials.

## Gotchas

- Orders use optimistic locking on `version` column — increment it on every update or you'll corrupt inventory.
- Prices are stored as integers (cents); never use floats.

# CLAUDE.md

## Commands
```
npm test          # Jest + supertest integration tests (requires local PG)
npm run lint      # ESLint
npm run migrate   # Run pending DB migrations (knex)
npm run migrate:rollback
```

## Database
- Migrations live in `db/migrations/` — never edit existing migration files, add new ones.
- Tests run against a real database (`TEST_DATABASE_URL`), not mocks.
- Seed data: `npm run seed` (dev only, never run against staging/prod).

## Deployment
- `main` → production, `staging` → staging; both deploy automatically via GitHub Actions on push.
- Migrations run automatically in CI before the app starts — do not merge schema changes without a corresponding migration.

## Commits
- Follow conventional commits. Project scopes: `api`, `db`, `auth`, `orders`, `payments`, `ci`.
- Breaking changes in `payments` or `auth` require a `!` suffix and a note in the PR description.

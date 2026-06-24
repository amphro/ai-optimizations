# E-commerce API

## Setup
- Local dev requires `.env` (see `.env.example`); PostgreSQL must be running on `localhost:5432`
- `npm run db:migrate` before first test run

## Code
- Conventional commits required; GitHub Actions blocks non-compliant PRs
- Database changes: add migrations to `migrations/` with timestamp prefix (e.g. `20260624_add_orders_table.sql`); migrations run automatically on deploy
- Payment processing never logs card data; test with mock provider in dev

## Tests
- `npm test` runs all suites; integration tests need DB. Use `npm run test:unit` for unit-only
- Add database tests in `tests/integration/`; seed data in `tests/fixtures/`

## CI/Deploy
- GitHub Actions on push to `main` runs tests, lints, and deploys to staging
- Releases: tag commits as `v*` on `main` to deploy to production
- Env vars: staging uses `.github/workflows/staging.env`; prod secrets stored in GitHub Secrets

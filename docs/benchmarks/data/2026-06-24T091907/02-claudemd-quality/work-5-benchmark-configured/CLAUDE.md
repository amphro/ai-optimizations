# E-Commerce API

## Setup
- `npm install && npm run migrate` — runs pending database migrations
- `npm test` runs tests; `npm run lint` for code style
- Tests require a clean `test` database; CI will reset it

## Database
- Migrations use raw SQL in `migrations/` with timestamps; run via migration tool
- Foreign key constraints are enforced; delete operations must handle cascades or soft deletes
- `created_at` and `updated_at` are added automatically to all tables via triggers

## GitHub Actions
- Push to any branch runs tests and lint; must pass to merge to `main`
- `main` branch deployments are automatic to production
- Rollback: revert the commit on main; Actions will redeploy the previous version

## API Patterns
- Entity routes use `/api/v1/{resource}` naming
- Validation errors return 400 with `{ errors: [...] }`; must check request shape before DB calls
- Auth uses JWT in `Authorization: Bearer` header; refresh tokens stored in httpOnly cookies

## Deployment
- Environment variables: copy `.env.example` to `.env` (or `.env.local` for local overrides)
- Secrets managed in GitHub; never commit real `.env` files

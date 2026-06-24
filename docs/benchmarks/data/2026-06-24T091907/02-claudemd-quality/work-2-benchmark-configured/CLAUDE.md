# E-commerce API

## Commands
- `npm test` — run Jest tests with coverage
- `npm run lint` — ESLint + Prettier check
- `npm run db:migrate` — apply pending migrations (Knex)
- `npm start` — run server (NODE_ENV=production)
- `npm run dev` — run with nodemon (development)

## Database
- Migrations are SQL files in `migrations/` applied via Knex
- Always run migrations before deploying; CI runs them before tests
- Schema: orders, products, users, payments (refer to `schema.sql` for authoritative structure)
- Use transactions for multi-table updates (order creation, payment processing)

## API conventions
- Monetary amounts: stored as integers (cents), returned in `price_cents` fields
- Timestamps: UTC ISO 8601 in `_at` suffixed fields
- IDs: UUIDs for users/orders, serial integers for products
- Errors: 400 (validation), 404 (not found), 409 (conflict), 500 only for bugs

## Commits
Conventional commits required; CI checks on PR. Scope is module (`order:`, `payment:`, `auth:`, etc.).
- `feat(order): ...` — changelog worthy
- `fix(payment): ...` — bug fixes
- `chore:` — tooling, deps (not in changelog)

## GitHub Actions
- Pushes to `main` deploy automatically via `deploy.yml`
- PR checks: lint, tests, migrations-up-to-date
- Secrets: `DATABASE_URL`, `API_KEY` (read from GitHub org settings)

## Order state machine
Orders: `pending` → `confirmed` → `shipped` → `delivered` or `pending` → `cancelled`
State is authoritative; avoid read-modify-write patterns, use idempotent transitions.

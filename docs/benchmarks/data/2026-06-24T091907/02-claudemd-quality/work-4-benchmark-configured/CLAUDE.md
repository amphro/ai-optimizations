# Node.js E-Commerce API

## Setup
- Copy `.env.example` to `.env` (requires `DATABASE_URL`, `STRIPE_KEY`, `JWT_SECRET`)
- `npm install && npm run migrate` to set up database

## Build and test
- `npm run build` — TypeScript compilation
- `npm test` — unit and integration tests (requires test DB)
- `npm run lint` — ESLint + Prettier check
- `npm run dev` — start dev server with auto-reload

## Critical behaviors
- **Transactions**: Orders wrapped in DB transactions; payment processing is separate and retried on failure, never rolled back mid-payment
- **Idempotency**: All payment mutations require idempotency keys; invoice generation is idempotent
- **Inventory**: Stock reserved at checkout, released if payment fails; sync with warehouse system via webhooks
- **Migrations**: Always test down/up locally; breaking changes require data backfill runs before deploy

## GitHub Actions
- PRs run tests and lint; blocks merge on failure
- Pushes to main deploy to staging, then require manual approval for production
- Secrets configured in org settings (never commit)

## Conventions
- Conventional commits required (enforced by pre-commit hook)
- API routes in `src/routes/`, handlers in `src/handlers/`
- Tests colocated with source (`*.test.ts` adjacent to `.ts`)

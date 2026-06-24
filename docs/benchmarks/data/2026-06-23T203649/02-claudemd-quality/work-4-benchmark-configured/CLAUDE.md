# E-Commerce API

## Commands
```
npm test          # Jest (unit + integration)
npm run lint      # ESLint
npm run migrate   # Run pending DB migrations
npm run migrate:rollback  # Roll back last migration
```

## Database
- Migrations live in `db/migrations/` — never edit existing migration files, always add new ones.
- Integration tests require a live Postgres instance; set `DATABASE_URL` in `.env.test`.

## Commits
- Follow Conventional Commits (`feat:`, `fix:`, `chore:`, etc.) — CI uses them to generate releases and changelogs via semantic-release.
- A `feat:` triggers a minor version bump; `fix:` triggers a patch; `feat!:` or `BREAKING CHANGE:` triggers a major.

## Deployment
- Merging to `main` deploys to **production** via GitHub Actions. There is no staging gate — be careful.
- Secrets (`STRIPE_SECRET_KEY`, `DATABASE_URL`, etc.) must be set in GitHub repo settings before a new environment can deploy.

## E-Commerce Gotchas
- Payment amounts are stored and processed in **cents** (integer), never floats.
- Stripe webhook handlers must respond with HTTP 200 before doing any async work, or Stripe will retry.

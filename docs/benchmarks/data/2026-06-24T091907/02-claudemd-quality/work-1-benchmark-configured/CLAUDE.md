# Node.js E-commerce API

## Build & Test
```bash
npm run build    # Compile TypeScript
npm test         # Run test suite
npm run lint     # ESLint + Prettier check
npm run migrate  # Run pending database migrations
```

## Database & Migrations
- PostgreSQL migrations live in `db/migrations/` with sequential naming: `001_create_users.sql`
- Migrations run automatically on deploy via GitHub Actions — no manual step needed
- Rollback: edit the migration number in `schema_version` table, then re-run migrations
- Always write idempotent migrations (use `IF NOT EXISTS`, `IF EXISTS`, etc.)

## Deployment
- GitHub Actions runs on commits to `main` — triggered by conventional commits only (see below)
- Workflow file: `.github/workflows/deploy.yml`
- Deploys include: `npm run migrate` → build → test → push to registry

## Conventional Commits
- Use `type(scope): description` format: `feat(orders): add refund endpoint`
- Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`
- Only `feat` and `fix` trigger auto-deploy to staging/production
- Scope is optional but recommended for API endpoints

## Key Architecture
- Order operations are event-driven via a message queue (`bull` Redis queue)
- Payment processing is async — webhook handlers confirm payment state, don't block the endpoint
- Cart operations must invalidate product inventory cache after changes
- User authentication uses JWT with 24h expiry; refresh tokens stored in PostgreSQL

## Testing
- Unit tests cover business logic; integration tests hit a real test PostgreSQL database
- Mock external services (payment gateway, email) — never call production APIs in tests
- Use descriptive test names: `should return 400 when payment amount exceeds cart total`

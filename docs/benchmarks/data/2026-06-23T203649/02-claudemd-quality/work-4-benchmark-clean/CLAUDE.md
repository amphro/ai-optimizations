# CLAUDE.md

Node.js e-commerce API backed by PostgreSQL. Deploys via GitHub Actions and follows the Conventional Commits spec.

## Tech Stack

- **Runtime:** Node.js
- **Database:** PostgreSQL
- **CI/CD:** GitHub Actions
- **Commits:** Conventional Commits

## Commands

```bash
npm install        # Install dependencies
npm run dev        # Start the API locally with reloading
npm start          # Start the API in production mode
npm test           # Run the test suite
npm run lint       # Lint the codebase
npm run migrate    # Apply database migrations
```

> Adjust the above to match the actual scripts in `package.json`.

## Database

- PostgreSQL is the system of record. Connection settings come from environment variables (e.g. `DATABASE_URL`) — never hardcode credentials.
- Schema changes go through migrations. Add a new migration rather than editing an applied one.
- Run `npm run migrate` after pulling changes that touch the schema.

## Deployment

- Deployment is automated through **GitHub Actions**. Pushing/merging to the default branch triggers the pipeline.
- CI runs lint and tests on pull requests; keep both green before merging.
- Workflow definitions live in `.github/workflows/`.

## Commit Conventions

This project follows **Conventional Commits**. Format:

```
<type>(<optional scope>): <description>
```

Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`.

Examples:

```
feat(cart): add coupon code support
fix(checkout): prevent double charge on retry
chore(deps): bump pg to 8.x
```

Use `feat:` and `fix:` to reflect user-facing changes, and a `!` suffix or `BREAKING CHANGE:` footer for breaking changes.

## Conventions

- Validate and sanitize all request input; never trust client data.
- Keep secrets in environment variables and out of version control.
- Return consistent JSON error shapes and appropriate HTTP status codes.
- Write tests for new endpoints and business logic.

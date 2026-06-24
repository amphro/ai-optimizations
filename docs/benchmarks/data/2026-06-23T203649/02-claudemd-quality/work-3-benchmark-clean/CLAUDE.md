# CLAUDE.md

Guidance for working in this repository.

## Project

Node.js e-commerce API backed by PostgreSQL. Exposes REST endpoints for products, carts, orders, and checkout.

## Tech stack

- **Runtime:** Node.js
- **Database:** PostgreSQL (accessed via the connection configured in `DATABASE_URL`)
- **CI/CD:** GitHub Actions

## Common commands

```bash
npm install          # install dependencies
npm run dev          # start the API locally with reload
npm start            # start the API
npm test             # run the test suite
npm run lint         # lint the codebase
npm run migrate      # apply database migrations
```

> Adjust the script names above to match `package.json` if they differ.

## Database

- All schema changes go through migrations — never edit the schema by hand.
- Add a new migration for every change to tables, indexes, or constraints, and make migrations reversible where possible.
- Keep queries parameterized; never interpolate user input into SQL.

## Testing

- Add or update tests for any behavior change.
- Run `npm test` and ensure it passes before committing.
- Prefer testing against a real PostgreSQL instance (or an equivalent test database) over mocking the data layer.

## Commits

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>
```

Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`.

Examples:

```
feat(cart): add coupon code support
fix(orders): prevent duplicate charge on retry
chore(deps): bump pg to 8.x
```

Use `feat!:` or a `BREAKING CHANGE:` footer for breaking changes.

## Deployment

- Deploys run through GitHub Actions (see `.github/workflows/`).
- CI must be green before merging; the pipeline lints, tests, and deploys.
- Never commit secrets — configuration comes from environment variables and CI/repository secrets.

## Conventions

- Validate and sanitize all incoming request data.
- Return appropriate HTTP status codes and consistent JSON error shapes.
- Keep business logic out of route handlers; put it in service/domain modules.

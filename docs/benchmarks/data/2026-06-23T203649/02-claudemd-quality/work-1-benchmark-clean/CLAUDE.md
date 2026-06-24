# CLAUDE.md

Guidance for working in this repository.

## Project

Node.js e-commerce REST API backed by PostgreSQL. Deployed via GitHub Actions.

## Tech Stack

- **Runtime:** Node.js
- **Database:** PostgreSQL
- **CI/CD:** GitHub Actions
- **VCS conventions:** Conventional Commits

## Common Commands

```bash
npm install        # install dependencies
npm run dev        # start the API locally with hot reload
npm start          # start the API (production mode)
npm test           # run the test suite
npm run lint       # lint the codebase
npm run migrate    # apply database migrations
```

> Confirm the exact script names in `package.json` before relying on them — adjust this section if they differ.

## Database

- PostgreSQL is the system of record. Connection settings come from environment variables (e.g. `DATABASE_URL`); never hardcode credentials.
- Schema changes go through migrations. Add a new migration rather than editing an applied one.
- Use parameterized queries — never interpolate user input into SQL.

## Deployment

- Deploys run through GitHub Actions; see `.github/workflows/`.
- Merges to the default branch trigger the pipeline. Do not deploy by hand.
- Keep CI green: lint and tests must pass before merge.

## Commit Conventions

This repo follows [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <description>
```

Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`.

Examples:

```
feat(orders): add bulk checkout endpoint
fix(payments): handle declined card retry
chore(deps): bump pg to 8.13
```

Use `feat!:` or a `BREAKING CHANGE:` footer for breaking changes.

## Conventions

- Validate and sanitize all request input; return appropriate HTTP status codes.
- Keep secrets in environment variables, out of source control.
- Add or update tests alongside behavior changes.

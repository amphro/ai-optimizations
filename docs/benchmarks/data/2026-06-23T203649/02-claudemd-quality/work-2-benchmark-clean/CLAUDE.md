# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Project Overview

Node.js e-commerce API. Server-side REST API backed by PostgreSQL, deployed via GitHub Actions.

## Tech Stack

- **Runtime:** Node.js
- **Database:** PostgreSQL
- **CI/CD:** GitHub Actions
- **Commit convention:** Conventional Commits

## Common Commands

```bash
npm install        # Install dependencies
npm run dev        # Start the API locally with hot reload
npm start          # Start the API in production mode
npm test           # Run the test suite
npm run lint       # Lint the codebase
npm run migrate    # Apply database migrations
```

> Adjust these to match the actual scripts in `package.json` if they differ.

## Database

- Uses PostgreSQL. Connection settings come from environment variables (e.g. `DATABASE_URL`) — never hardcode credentials.
- Schema changes go through migrations. Create a new migration rather than editing existing ones, and run `npm run migrate` to apply.
- Keep migrations reversible where possible.

## Deployment

- Deployment runs through **GitHub Actions**; the workflow definitions live in `.github/workflows/`.
- CI runs lint, tests, and migrations on pull requests. Make sure these pass before merging.
- Do not deploy manually — let the pipeline handle releases.

## Commit Conventions

This project follows [Conventional Commits](https://www.conventionalcommits.org/). Use the format:

```
<type>(<optional scope>): <description>
```

Common types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `ci`.

Examples:

```
feat(cart): add support for promo codes
fix(orders): prevent duplicate order submission on retry
chore(deps): bump pg to latest minor version
```

## Conventions & Guidelines

- Validate and sanitize all incoming request data before it reaches the database.
- Use parameterized queries; never build SQL with string concatenation.
- Keep secrets in environment variables and out of source control.
- Add or update tests alongside any behavior change.
- Match the existing code style; run `npm run lint` before committing.

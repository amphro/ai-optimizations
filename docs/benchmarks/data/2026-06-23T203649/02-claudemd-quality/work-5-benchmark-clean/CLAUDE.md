# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

Node.js e-commerce API backed by PostgreSQL. Deployed via GitHub Actions. Commits follow Conventional Commits.

## Commands

```bash
npm install            # install dependencies
npm run dev            # run the API locally with reload
npm start              # run the API in production mode
npm test               # run the test suite
npm run lint           # lint the codebase
npm run migrate        # apply pending database migrations
npm run migrate:make   # create a new migration
```

Run a single test file with `npm test -- <path>`. Adjust the script names above if `package.json` differs.

## Database

- PostgreSQL is the system of record. The connection string comes from `DATABASE_URL` (see `.env` / environment).
- All schema changes go through migrations — never edit the database by hand. Create a migration, review the generated SQL, then run `npm run migrate`.
- Keep migrations forward-only and reversible where practical; never edit a migration that has already shipped.

## Conventions

- **Commits** follow [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): summary` (e.g. `feat(orders): add refund endpoint`, `fix(auth): reject expired tokens`). Common types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `ci`. These types drive versioning and the changelog, so choose them deliberately.
- Match the style, naming, and structure of surrounding code.
- Validate and sanitize all request input; never trust client-supplied data.
- Keep secrets out of the repo — use environment variables.

## CI/CD

GitHub Actions workflows live in `.github/workflows/`. CI runs lint, tests, and migration checks on pull requests; deploys run on merge to the default branch. Make sure `npm run lint` and `npm test` pass locally before pushing — they gate the pipeline.

## Notes

This file was scaffolded before code was added. As the project grows, update the commands, directory layout, and any project-specific conventions so this stays accurate.

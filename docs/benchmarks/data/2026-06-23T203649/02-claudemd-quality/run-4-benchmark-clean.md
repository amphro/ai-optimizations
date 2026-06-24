Created `/app/CLAUDE.md`. It covers:

- **Tech stack** — Node.js, PostgreSQL, GitHub Actions, Conventional Commits
- **Commands** — common npm scripts (with a note to align them to your actual `package.json`)
- **Database** — env-based config, migration discipline
- **Deployment** — GitHub Actions pipeline triggered on the default branch, workflows in `.github/workflows/`
- **Commit conventions** — Conventional Commits format with type list and examples
- **General conventions** — input validation, secrets handling, error shapes, tests

A couple of spots are intentionally generic since I don't have the repo contents: the `npm run` scripts and the migration command. If you point me at your `package.json` (or the actual directory structure), I can tighten those to match exactly.

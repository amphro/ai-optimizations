Created `CLAUDE.md` for your Node.js e-commerce API project. It covers:

- **Project overview** — Node.js REST API on PostgreSQL, deployed via GitHub Actions
- **Tech stack** and **common commands** (with a note to align them to your actual `package.json`)
- **Database** — env-based config, migration workflow, no hardcoded credentials
- **Deployment** — GitHub Actions pipeline in `.github/workflows/`, CI gating on PRs
- **Commit conventions** — Conventional Commits format with type list and examples
- **General guidelines** — input validation, parameterized queries, secrets handling, tests, linting

A few sections (command names, `DATABASE_URL`) are reasonable defaults — tweak them if your scripts or env var names differ.

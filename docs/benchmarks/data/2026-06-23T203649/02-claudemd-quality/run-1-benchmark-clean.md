Created `CLAUDE.md` at the project root. It covers:

- **Project + tech stack** — Node.js e-commerce API, PostgreSQL, GitHub Actions, Conventional Commits
- **Common commands** — flagged to verify against `package.json` since I don't know your actual script names
- **Database** — migrations, parameterized queries, env-based credentials
- **Deployment** — GitHub Actions pipeline, no manual deploys, keep CI green
- **Commit conventions** — Conventional Commits format with types and concrete examples

Two things worth a quick check: the npm script names under **Common Commands** are conventional guesses — adjust them to match your `package.json`. Likewise update the `.github/workflows/` reference if your workflow files live elsewhere.

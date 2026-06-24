Created `/app/CLAUDE.md`.

Note: `/app` was empty — no existing code, `package.json`, or git repo to inspect — so I wrote this from the stack you described rather than from the codebase. A few things worth knowing:

- **Command names are assumed** (`npm run dev`, `npm run migrate`, etc.). Once you have a `package.json`, reconcile the Commands section with its actual scripts.
- It documents the three things you specified: PostgreSQL (migration-driven schema, `DATABASE_URL`), GitHub Actions (`.github/workflows/`, lint+test gating), and Conventional Commits (with the type list and why types matter).
- There's a closing note flagging that it was scaffolded pre-code, so future-you knows to keep it in sync.

If you'd like, I can tailor it further once you tell me the framework (Express/Fastify/NestJS?), ORM/query builder (Prisma/Knex/TypeORM?), or test runner you're using.

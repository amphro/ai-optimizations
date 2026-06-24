Done. I've created a 31-line CLAUDE.md that covers the essentials for your e-commerce API:

- **Commands**: test, lint, DB migrations, dev/prod startup
- **Database**: Knex migrations workflow, schema reference, transaction patterns for critical operations
- **API conventions**: cents-based pricing, timestamp format, ID types, error codes
- **Commits**: conventional commits with module scopes
- **CI/CD**: GitHub Actions deploy trigger and secrets
- **Domain logic**: order state machine to prevent invalid transitions

Each line answers "would removing this cause a mistake?" Yes — because database migration timing, monetary precision, and order state are project-specific gotchas that aren't obvious from reading code.

Done! I've created a CLAUDE.md file with 37 substantive lines covering:

- **Build/test commands** — non-standard commands for this project
- **Database patterns** — migration strategy, idempotency gotchas, and rollback approach
- **Deployment triggers** — how GitHub Actions and conventional commits connect
- **Architectural decisions** — async payments, event-driven orders, caching, and auth strategy
- **Testing approach** — real test DB, mocked externals, naming conventions

The file includes only implicit knowledge that Claude couldn't derive from reading the code—things that have caused mistakes before or represent project-specific architectural decisions. It stays well under the 40-line limit and follows the quality rules (each line passes the "would removing this cause a mistake?" test).

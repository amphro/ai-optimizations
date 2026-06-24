Done. I've created a CLAUDE.md with only the non-obvious, project-specific details that would cause mistakes if missing:

- **Setup**: Local dependencies (`.env`, PostgreSQL config) and initial migration command
- **Code**: Conventional commit enforcement, database migration pattern, payment data safety rule
- **Tests**: How to run different test types, where integration tests and fixtures go
- **CI/Deploy**: GitHub Actions flow, release tagging for production, secret management

The file is 16 lines and passes the "would removing this cause a mistake?" test for every line. It avoids standard Node.js/PostgreSQL conventions Claude can infer from reading the code.

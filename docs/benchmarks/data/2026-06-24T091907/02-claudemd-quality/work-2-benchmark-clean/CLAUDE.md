# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Start

### Common Commands
- **Install dependencies**: `npm install`
- **Run development server**: `npm run dev`
- **Build for production**: `npm run build`
- **Run tests**: `npm test`
- **Run a single test file**: `npm test -- src/path/to/test.test.js`
- **Run tests with coverage**: `npm run test:coverage`
- **Lint code**: `npm run lint`
- **Format code**: `npm run format`
- **Check for type errors**: `npm run type-check` (if using TypeScript)

### Database
- **Run migrations**: `npm run migrate`
- **Rollback migration**: `npm run migrate:rollback`
- **Create a new migration**: `npm run migrate:create <migration-name>`
- **Seed database**: `npm run seed` (if applicable)

## Architecture Overview

### Project Structure
```
src/
├── api/              # API route handlers and middleware
├── models/           # Database models and schemas
├── services/         # Business logic and external integrations
├── middleware/       # Request processing middleware
├── utils/            # Utility functions and helpers
├── config/           # Configuration and environment setup
├── migrations/       # Database migrations
└── types/            # TypeScript type definitions (if applicable)
```

### Key Technical Decisions

**Express.js API**: RESTful API built with Express for HTTP request handling and middleware support.

**PostgreSQL Database**: Relational database for data persistence. Uses migrations (likely via Knex.js or similar) to manage schema changes in a version-controlled way.

**Conventional Commits**: Project follows [Conventional Commits](https://www.conventionalcommits.org/) format for commit messages (`feat:`, `fix:`, `docs:`, `test:`, etc.). This enables automated changelog generation and semantic versioning.

**GitHub Actions CI/CD**: Automated testing and deployment pipeline triggered on commits. Check `.github/workflows/` for deployment configuration. Deployments are automated; avoid manual deploys.

### Data Flow
1. HTTP requests → Express middleware → Route handlers (in `api/`)
2. Route handlers → Services (in `services/`) for business logic
3. Services → Database models (in `models/`) for data access
4. PostgreSQL handles persistence and relationships

## Database Notes

- Migrations are version-controlled in `src/migrations/`; never modify old migrations
- Models define table schemas and relationships
- Connection pooling is configured in `config/` to optimize PostgreSQL connections
- Transactions should wrap multi-step operations to maintain consistency

## Deployment & Environments

- **GitHub Actions** automatically runs tests and deploys on push to main/release branches
- Environment variables are managed via GitHub secrets (check `.github/workflows/` for what's configured)
- Database migrations run automatically as part of the deployment pipeline
- Deployments follow a conventional commit format for release notes generation

## Testing Strategy

- Unit tests for services and utilities
- Integration tests for API endpoints with a test database
- Avoid mocking the database in integration tests; use transactions to rollback changes
- Run full test suite before committing to ensure CI doesn't catch regressions

## Code Style & Quality

- Follow the linter rules configured in ESLint (or equivalent)
- Format code with Prettier before committing
- Use conventional commit messages for all commits
- Write meaningful commit messages that explain the *why*

## Environment Setup

Create a `.env` file in the root directory with:
```
DATABASE_URL=postgres://user:password@localhost:5432/ecommerce_dev
NODE_ENV=development
PORT=3000
```

Ensure PostgreSQL is running locally for development:
```bash
# Start PostgreSQL (if using Docker)
docker run -e POSTGRES_PASSWORD=password -p 5432:5432 postgres:15
```

## Important Notes

- Avoid committing `.env` files; use `.env.example` as a template
- Database credentials should never appear in code
- All schema changes must go through migrations, never direct database modifications
- Check GitHub Actions logs for deployment failures

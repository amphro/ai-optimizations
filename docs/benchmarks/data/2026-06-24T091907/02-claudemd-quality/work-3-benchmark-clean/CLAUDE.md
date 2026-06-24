# E-Commerce API - Project Guide

## Overview

Node.js REST API for e-commerce operations. Built with Express.js, PostgreSQL, and automated CI/CD via GitHub Actions.

## Architecture

```
src/
├── routes/          # Express route handlers
├── controllers/     # Business logic
├── services/        # Data access and external integrations
├── middleware/      # Auth, validation, error handling
├── models/          # Sequelize/TypeORM database models
├── migrations/      # Database migrations
├── config/          # Environment and database config
└── utils/           # Helpers and constants
```

## Development Setup

### Prerequisites
- Node.js 18+
- PostgreSQL 12+
- Git

### Initial Setup
```bash
npm install
cp .env.example .env
npm run db:migrate
npm run dev
```

### Environment Variables
```
DATABASE_URL=postgresql://user:pass@localhost:5432/ecommerce
NODE_ENV=development
API_PORT=3000
JWT_SECRET=<secret>
```

## Database

- **Driver**: PostgreSQL
- **ORM**: [Sequelize or TypeORM - specify yours]
- **Migrations**: Located in `src/migrations/`

### Common Commands
```bash
npm run db:migrate        # Run pending migrations
npm run db:migrate:undo   # Rollback last migration
npm run db:seed           # Seed database with test data
npm run db:reset          # Drop and recreate database (dev only)
```

## Git Conventions

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style (no logic changes)
- `refactor`: Refactor without feature/fix
- `perf`: Performance improvement
- `test`: Test additions/changes
- `chore`: Build, deps, CI/CD

**Examples**:
```
feat(orders): add order cancellation endpoint
fix(auth): prevent expired token acceptance
docs(api): update authentication section
test(products): add price calculation tests
```

### Branch Naming
`<type>/<scope>-<description>` (lowercase, hyphens)
- `feat/orders-cancellation`
- `fix/auth-token-expiry`

## Deployment

### GitHub Actions Workflow
- **Trigger**: Push to `main` or PR to `main`
- **Steps**:
  1. Run linting and tests
  2. Build the application
  3. Run database migrations (main only)
  4. Deploy to production (main only)

**Workflow file**: `.github/workflows/deploy.yml`

### Deployment Environments
- **Staging**: Automatic on PR merge
- **Production**: Requires manual approval or auto on tag push

### Rollback
Redeploy previous commit or tag via GitHub Actions UI.

## Common Tasks

### Add a New API Endpoint
1. Create controller in `src/controllers/`
2. Add service logic in `src/services/`
3. Add route in `src/routes/`
4. Write tests in `tests/`
5. Commit with `feat(scope): description`

### Database Migration
```bash
npm run db:create-migration -- --name=AddColumnToTable
# Edit src/migrations/[timestamp]-AddColumnToTable.js
npm run db:migrate
```

### Running Tests
```bash
npm test              # Run all tests
npm run test:watch    # Watch mode
npm run test:coverage # Coverage report
```

## Code Style

- **Linter**: ESLint
- **Formatter**: Prettier (run via `npm run format`)
- **Pre-commit**: Husky (runs linting automatically)

Run before committing:
```bash
npm run lint
npm run format
```

## Important Files

| File | Purpose |
|------|---------|
| `src/config/database.js` | Database connection config |
| `.env.example` | Environment template |
| `package.json` | Dependencies and scripts |
| `.github/workflows/` | CI/CD definitions |
| `tests/` | Test suite |

## Debugging

### Enable Verbose Logging
```bash
DEBUG=app:* npm run dev
```

### Database Queries
```bash
NODE_OPTIONS='--inspect' npm run dev
# Connect debugger to chrome://inspect
```

## Troubleshooting

**Port already in use**: Kill process on port 3000 or change `API_PORT` in `.env`

**Database connection failed**: Verify `DATABASE_URL` and PostgreSQL is running

**Migrations stuck**: Check `SequelizeMeta` or `typeorm_migrations` table; manually edit if needed

## Resources

- [Express.js Docs](https://expressjs.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions](https://docs.github.com/en/actions)

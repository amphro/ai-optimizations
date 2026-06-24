# E-Commerce API – Project Guide

## Overview

This is a Node.js e-commerce API built with Express.js and PostgreSQL. It provides RESTful endpoints for managing products, orders, users, and payments. The project follows industry best practices for API design, database migrations, and CI/CD pipelines.

**Tech Stack:**
- Runtime: Node.js (v18+)
- Framework: Express.js
- Database: PostgreSQL
- ORM/Query Builder: [Sequelize/Prisma/TypeORM/Knex — specify which is used]
- Testing: Jest / Mocha
- Deployment: GitHub Actions → [AWS/Heroku/DigitalOcean — specify target]

## Project Structure

```
.
├── src/
│   ├── models/           # Database models / schemas
│   ├── controllers/      # Route handlers
│   ├── routes/           # API route definitions
│   ├── middleware/       # Express middleware (auth, validation, etc.)
│   ├── services/         # Business logic layer
│   ├── utils/            # Helper functions & utilities
│   ├── config/           # Configuration (database, env, etc.)
│   └── index.js          # App entry point
├── migrations/           # Database migration files
├── tests/                # Test files (mirror src/ structure)
├── .github/workflows/    # GitHub Actions CI/CD pipelines
├── .env.example          # Environment variables template
├── package.json
├── CLAUDE.md             # This file
└── README.md
```

## Development Setup

### Prerequisites
- Node.js v18+ and npm/yarn
- PostgreSQL 12+
- Git

### Local Setup

```bash
# Install dependencies
npm install

# Create .env from template and fill in local values
cp .env.example .env

# Run database migrations
npm run migrate

# Seed development database (optional)
npm run seed

# Start development server (port 3000)
npm run dev
```

### Environment Variables

See `.env.example` for the full template. Critical variables:

- `DATABASE_URL`: PostgreSQL connection string
- `NODE_ENV`: `development`, `staging`, or `production`
- `JWT_SECRET`: For signing authentication tokens
- `PORT`: Server port (default: 3000)
- `PAYMENT_API_KEY`: Payment processor credentials (Stripe/PayPal/etc.)

## Database

**Provider:** PostgreSQL

**Migrations:**
- Migrations are in `/migrations` and use [Knex/Sequelize/Prisma migrations — specify which]
- Run migrations: `npm run migrate`
- Rollback last migration: `npm run migrate:rollback`
- Create new migration: `npm run migrate:create <name>`

**Key Tables:**
- `users` — customer accounts (email, password hash, profile)
- `products` — product catalog (name, price, description, stock)
- `orders` — customer orders (total, status, timestamps)
- `order_items` — order line items (product_id, quantity, price)
- `payments` — payment transactions (order_id, status, amount)

**Seeding:**
- Development seed data: `npm run seed`
- This creates sample users, products, and orders

## Code Conventions

### Commit Messages

Follow **Conventional Commits** (https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`

**Examples:**
```
feat(auth): add JWT token refresh endpoint
fix(orders): correct tax calculation for international orders
docs(api): update product endpoint documentation
chore(deps): upgrade express to 4.18.0
ci(workflows): add performance test to pre-deploy checks
```

### Code Style

- **Language:** JavaScript (ES2020+) or TypeScript (if configured)
- **Linting:** ESLint (run `npm run lint`, fix with `npm run lint:fix`)
- **Formatting:** Prettier (run `npm run format`)
- **Naming:** camelCase for variables/functions, PascalCase for classes/models, UPPER_SNAKE_CASE for constants
- **Comments:** Minimal — prefer clear naming. Only comment *why*, not *what*.

### API Responses

Standard response format:

```json
{
  "success": true,
  "data": { /* result */ },
  "error": null,
  "timestamp": "2026-06-24T10:30:00Z"
}
```

Error responses:

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "INVALID_REQUEST",
    "message": "User-friendly error message"
  },
  "timestamp": "2026-06-24T10:30:00Z"
}
```

## Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run specific test file
npm test -- auth.test.js

# Watch mode
npm run test:watch
```

Test files should mirror the source structure (e.g., `tests/services/order.service.test.js` for `src/services/order.service.js`).

## Deployment

### GitHub Actions Workflows

Located in `.github/workflows/`:

- **`ci.yml`**: Runs on every push to `main`, `develop`, and PRs
  - Installs dependencies, runs linting, runs tests, checks coverage
  - Fails if tests fail or coverage drops below threshold
  
- **`deploy.yml`**: Runs on merge to `main`
  - Builds Docker image (if applicable)
  - Runs database migrations
  - Deploys to production
  - Runs smoke tests post-deploy

### Deployment Checklist

Before merging to `main`:
- [ ] All tests passing locally and in CI
- [ ] No unresolved lint warnings
- [ ] Database migrations run without error in staging
- [ ] PR reviewed and approved
- [ ] Commit messages follow Conventional Commits format

### Rollback

If production deployment fails:
1. Check GitHub Actions logs for error details
2. Fix the issue locally and push to `main` again, OR
3. Revert the last commit: `git revert <commit-hash>` and push

## Common Tasks

### Add a New API Endpoint

1. Create route in `/src/routes/` (e.g., `products.js`)
2. Create controller in `/src/controllers/` (e.g., `productController.js`)
3. Create service in `/src/services/` (e.g., `productService.js`) for business logic
4. Mount route in `/src/index.js`
5. Add tests in `/tests/routes/` or `/tests/controllers/`
6. Commit: `feat(products): add endpoint to list products by category`

### Add a Database Table

1. Create migration: `npm run migrate:create add_reviews_table`
2. Define schema in migration file
3. Create model/schema in `/src/models/`
4. Run migration: `npm run migrate`
5. Add corresponding repository/service methods
6. Commit: `feat(reviews): add reviews table and service`

### Debug an Issue

```bash
# Enable debug logging
DEBUG=* npm run dev

# Or set NODE_DEBUG
NODE_DEBUG=http npm run dev

# Check database with psql
psql $DATABASE_URL
```

## Architecture Notes

- **Layered Architecture:** Routes → Controllers → Services → Models/Database
- **Separation of Concerns:** Controllers handle HTTP, services handle business logic, models handle data
- **Error Handling:** Centralized error middleware catches and formats errors
- **Authentication:** JWT tokens stored in Authorization header (`Bearer <token>`)
- **Rate Limiting:** Implemented on public endpoints to prevent abuse
- **Logging:** Structured logging with timestamps and request IDs for tracing

## Key Files to Know

- `/src/index.js` — Server setup, middleware configuration
- `/src/config/database.js` — Database connection and configuration
- `/src/middleware/auth.js` — JWT authentication middleware
- `/src/middleware/errorHandler.js` — Error handling and formatting
- `.github/workflows/ci.yml` — CI pipeline configuration
- `package.json` — Dependencies and npm scripts

## Resources

- API Documentation: [Link to Swagger/Postman/API docs if available]
- PostgreSQL docs: https://www.postgresql.org/docs/
- Express.js docs: https://expressjs.com/
- Conventional Commits: https://www.conventionalcommits.org/
- GitHub Actions: https://docs.github.com/en/actions

## Getting Help

- Check existing code for patterns in similar implementations
- Review commit history (`git log --oneline`) for context on architectural decisions
- Check GitHub Actions logs for deployment issues
- Ask team members via [Slack/Discord/etc.] for domain-specific questions

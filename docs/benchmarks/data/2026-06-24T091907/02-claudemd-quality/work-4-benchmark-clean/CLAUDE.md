# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Commands

### Development
- **Install dependencies**: `npm install`
- **Start dev server**: `npm run dev` (with auto-reload via nodemon)
- **Run linter**: `npm run lint` (ESLint)
- **Fix linting issues**: `npm run lint:fix`
- **Format code**: `npm run format` (Prettier)

### Testing
- **Run all tests**: `npm test`
- **Run tests in watch mode**: `npm test -- --watch`
- **Run a single test file**: `npm test -- path/to/test.js`
- **Run tests with coverage**: `npm test -- --coverage`

### Database
- **Run migrations**: `npm run migrate`
- **Rollback last migration**: `npm run migrate:rollback`
- **Create a new migration**: `npm run migrate:create -- migration_name`
- **Seed database**: `npm run seed`

### Build & Deployment
- **Build for production**: `npm run build`
- **Start production server**: `npm start`
- **Docker build**: `docker build -t ecommerce-api .`

## Project Architecture

### Overview
This is a Node.js Express e-commerce API with PostgreSQL as the primary data store. The application follows a layered architecture:
- **Routes/Controllers**: HTTP endpoint handlers (src/routes, src/controllers)
- **Services**: Business logic layer (src/services)
- **Models/Repositories**: Data access layer (src/models)
- **Middleware**: Request processing (src/middleware)
- **Utils**: Helper functions (src/utils)

### Key Directories
- **src/**: Application source code
- **migrations/**: PostgreSQL migration files (generated from src/migrations)
- **tests/**: Unit and integration tests
- **config/**: Environment-based configuration
- **.github/workflows/**: CI/CD pipeline definitions

### Database Architecture
- PostgreSQL database with connection pooling (pg)
- Migration tool: Knex.js for schema management
- Migrations stored in `/migrations` directory, run on deployment
- Database transactions for multi-step operations (orders, payments)
- Connection strings via environment variables (DATABASE_URL)

### API Design
- RESTful endpoints organized by resource (products, orders, users, payments)
- Request validation at the controller layer (express-validator or joi)
- Error handling with consistent JSON error responses
- Authentication: JWT tokens (stored in Authorization header)
- Rate limiting on public endpoints

### Core Features (typical e-commerce API)
- **Product Management**: CRUD operations, categories, inventory tracking
- **Shopping Cart**: Session-based or user-based carts
- **Orders**: Order creation, status tracking, order history
- **Payments**: Integration with payment processors (Stripe, PayPal)
- **User Management**: Registration, authentication, profiles

## Conventions

### Git & Commits
- Follow **Conventional Commits** format: `type(scope): description`
  - Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`
  - Examples: `feat(orders): add order cancellation`, `fix(cart): correct quantity calculation`
- Commit messages should be clear and link to issues when applicable
- Squash commits before merging (one commit = one logical change)

### Code Style
- ESLint configuration enforced (see .eslintrc.js)
- Prettier for code formatting (automatic on save if configured)
- CamelCase for variables/functions, PascalCase for classes/models
- Async/await for asynchronous operations (avoid callback chains)

### Testing
- Unit tests for services and utilities (*.test.js or *.spec.js)
- Integration tests for API endpoints using supertest
- Mock external services (payment providers, email) in tests
- Aim for >80% coverage on critical paths
- Use fixtures/factories for test data setup

### Database Migrations
- One logical change per migration file
- Migrations are immutable once deployed (create new migrations for changes)
- Always include rollback logic in migrations
- Migration naming: `YYYYMMDDHHMMSS_description.js`

## Deployment

### GitHub Actions CI/CD
The project uses GitHub Actions for automated testing and deployment:
- **Triggers**: Push to main, pull requests
- **Pipeline**:
  1. Install dependencies
  2. Run linter & formatter checks
  3. Run test suite
  4. Build Docker image (on main branch)
  5. Deploy to staging/production (main branch only)

Workflows are defined in `.github/workflows/`:
- `lint-test.yml`: Linting and testing on all PRs
- `deploy.yml`: Build and deploy on main branch merge

### Environment Setup
- Local: `.env` file (copy from `.env.example`)
- CI: Secrets stored in GitHub Settings > Secrets
- Required variables: `DATABASE_URL`, `JWT_SECRET`, `API_PORT`, payment provider keys

## Key Dependencies

| Package | Purpose |
|---------|---------|
| express | HTTP server framework |
| pg | PostgreSQL client |
| knex | Query builder & migration tool |
| jsonwebtoken | JWT authentication |
| joi / express-validator | Request validation |
| dotenv | Environment variable management |
| jest | Testing framework |
| nodemon | Development auto-reload |

## Common Patterns

### Service Layer Pattern
Services encapsulate business logic. Controllers call services, services call repositories:
```
Controller → Service → Repository → Database
```

### Error Handling
Use custom error classes that extend Error. Services throw domain-specific errors; controllers catch and format as HTTP responses (500, 400, 404, etc.).

### Database Transactions
For operations spanning multiple tables (e.g., creating an order and updating inventory):
```javascript
await db.transaction(async trx => {
  await OrderService.create(orderData, trx);
  await InventoryService.update(items, trx);
});
```

### Request Validation
Validate early in middleware or at the controller entry point. Return 400 with validation error details for client issues.

### JWT Authentication
Routes requiring auth should use `authMiddleware` to verify JWT from Authorization header. Store user info in `req.user`.

## Debugging & Troubleshooting

### Common Issues
- **Database connection failures**: Check DATABASE_URL format and credentials
- **Migration failures**: Ensure database exists and migrations are idempotent
- **JWT errors**: Verify JWT_SECRET is set and consistent across environments
- **Port already in use**: Change API_PORT or kill the process using the port

### Debugging Tools
- Enable debug logs: Set `DEBUG=app:*` environment variable
- Use Node debugger: `node --inspect src/index.js`, open chrome://inspect
- Check logs in `.github/workflows/` for CI/CD failures

## Pull Request Guidelines

When reviewing or creating PRs:
- One logical feature or fix per PR
- Ensure all tests pass locally before pushing
- Follow conventional commit message format in PR title
- Request reviews from team members familiar with the affected area
- Migrations must be included for any schema changes

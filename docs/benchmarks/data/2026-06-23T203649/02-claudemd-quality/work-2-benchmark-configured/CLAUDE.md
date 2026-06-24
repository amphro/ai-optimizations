# E-commerce API

## Commands
- `npm run dev` — start with hot reload
- `npm test` — runs Jest with `--runInBand`; requires `DATABASE_URL_TEST` pointing to a separate test DB
- `npm run migrate` — apply pending knex migrations
- `npm run lint` — eslint + prettier check

## Database
- Never edit existing migration files — always add a new one
- Fresh checkout: create a test DB and run `npm run migrate -- --env test` before running tests

## Deployment
- Migrations run automatically before app restart in the CI pipeline — do not run manually against prod

## Commits
- Conventional commits required; valid scopes: `orders`, `cart`, `products`, `payments`, `auth`, `infra`
- PRs are squash-merged to keep `main` linear

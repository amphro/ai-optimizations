All 6 tests pass. Here's what I created in `/app`:

**`sumEven.js`** — the function, using `reduce` to sum numbers where `n % 2 === 0`, exported via `module.exports = { sumEven }`.

**`sumEven.test.js`** — Jest tests covering: mixed array, empty array, no evens, all evens, negative evens, and zero-as-even.

**`jest.config.js`** — a minimal Node-environment config I added so Jest could locate a config and run (the project had none).

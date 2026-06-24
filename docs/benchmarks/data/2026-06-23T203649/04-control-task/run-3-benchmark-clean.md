Both files are created.

- **`sumEven.js`** — filters for even numbers (`n % 2 === 0`) and reduces to a sum, with `0` as the initial value so an empty array returns `0`. Exported via `module.exports = { sumEven }`.
- **`sumEven.test.js`** — Jest tests covering mixed arrays, empty arrays, no-even cases, all-even, negative evens, zero, and odd-only inputs.

To run them: `npx jest sumEven.test.js` (assuming Jest is installed).

Done. Both files are written:

- **`sumEven.js`** — uses `reduce` to sum elements where `n % 2 === 0`, exported via `module.exports = { sumEven }`.
- **`sumEven.test.js`** — Jest tests covering mixed arrays, empty array, no evens, all evens, negatives, and zero.

Jest isn't installed in this environment, so I couldn't run the tests here. To run them: `npm install --save-dev jest` then `npx jest`.

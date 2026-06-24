Done! I've created both files:

**sumEven.js** — The function uses `reduce()` to iterate through the array and sum all even numbers (identified by `num % 2 === 0`).

**sumEven.test.js** — Jest test suite with 8 test cases covering:
- Mixed arrays (even and odd)
- Arrays with no even numbers
- Arrays of all even numbers
- Empty arrays
- Zero (treated as even)
- Negative even numbers
- Single-element arrays

You can run the tests with `npm test` or `jest sumEven.test.js`.

// Correctness checker for task 04. Run inside node:20-slim with work dir mounted at /app.
// exit 0 = pass, exit 1 = fail/error
try {
  const { sumEven } = require('/app/sumEven.js');
  const cases = [
    { input: [1, 2, 3, 4], expected: 6 },
    { input: [], expected: 0 },
    { input: [1, 3, 5], expected: 0 },
    { input: [2, 4, 6], expected: 12 },
    { input: [-2, -4, 1], expected: -6 },
    { input: [0, 1], expected: 0 },
  ];
  let ok = true;
  for (const { input, expected } of cases) {
    const got = sumEven(input);
    if (got !== expected) {
      console.error(`FAIL sumEven(${JSON.stringify(input)}) = ${got}, want ${expected}`);
      ok = false;
    }
  }
  if (ok) { console.log('PASS'); process.exit(0); }
  else process.exit(1);
} catch (e) {
  console.error('ERROR:', e.message);
  process.exit(1);
}

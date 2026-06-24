const { sumEven } = require('./sumEven');

test('sums even numbers', () => {
  expect(sumEven([1, 2, 3, 4, 5, 6])).toBe(12);
});

test('returns 0 for empty array', () => {
  expect(sumEven([])).toBe(0);
});

test('returns 0 when no even numbers', () => {
  expect(sumEven([1, 3, 5])).toBe(0);
});

test('handles all even numbers', () => {
  expect(sumEven([2, 4, 6])).toBe(12);
});

test('handles negative even numbers', () => {
  expect(sumEven([-2, -4, 3])).toBe(-6);
});

test('handles zero', () => {
  expect(sumEven([0, 1, 2])).toBe(2);
});

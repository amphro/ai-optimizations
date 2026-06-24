const { sumEven } = require('./sumEven');

describe('sumEven', () => {
  test('returns sum of even numbers', () => {
    expect(sumEven([1, 2, 3, 4, 5, 6])).toBe(12);
  });

  test('returns 0 for array with no even numbers', () => {
    expect(sumEven([1, 3, 5, 7])).toBe(0);
  });

  test('returns 0 for empty array', () => {
    expect(sumEven([])).toBe(0);
  });

  test('returns sum when all numbers are even', () => {
    expect(sumEven([2, 4, 6, 8])).toBe(20);
  });

  test('handles negative even numbers', () => {
    expect(sumEven([-2, -1, 0, 1, 2])).toBe(0);
  });

  test('handles zero', () => {
    expect(sumEven([0, 1, 2])).toBe(2);
  });
});

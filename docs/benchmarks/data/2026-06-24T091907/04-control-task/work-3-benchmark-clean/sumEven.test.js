const { sumEven } = require('./sumEven');

describe('sumEven', () => {
  test('returns the sum of even numbers', () => {
    expect(sumEven([1, 2, 3, 4, 5, 6])).toBe(12);
  });

  test('returns 0 for an empty array', () => {
    expect(sumEven([])).toBe(0);
  });

  test('returns 0 when there are no even numbers', () => {
    expect(sumEven([1, 3, 5, 7])).toBe(0);
  });

  test('handles negative even numbers', () => {
    expect(sumEven([-2, -1, 0, 1, 2])).toBe(0);
  });

  test('returns the correct sum for all even numbers', () => {
    expect(sumEven([2, 4, 6, 8])).toBe(20);
  });
});

const { sumEven } = require('./sumEven');

describe('sumEven', () => {
  test('returns 0 for an empty array', () => {
    expect(sumEven([])).toBe(0);
  });

  test('returns 0 when no even numbers are present', () => {
    expect(sumEven([1, 3, 5, 7])).toBe(0);
  });

  test('sums all even numbers', () => {
    expect(sumEven([2, 4, 6, 8])).toBe(20);
  });

  test('sums even numbers from a mixed array', () => {
    expect(sumEven([1, 2, 3, 4, 5, 6])).toBe(12);
  });

  test('handles negative even numbers', () => {
    expect(sumEven([-2, -4, 2, 4])).toBe(0);
  });

  test('handles zero', () => {
    expect(sumEven([0, 1, 2, 3])).toBe(2);
  });

  test('handles single even number', () => {
    expect(sumEven([42])).toBe(42);
  });

  test('handles single odd number', () => {
    expect(sumEven([41])).toBe(0);
  });
});

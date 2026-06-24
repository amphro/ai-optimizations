const { sumEven } = require('./sumEven');

describe('sumEven', () => {
  test('returns sum of even numbers', () => {
    expect(sumEven([1, 2, 3, 4, 5, 6])).toBe(12);
  });

  test('returns 0 for empty array', () => {
    expect(sumEven([])).toBe(0);
  });

  test('returns 0 when no even numbers', () => {
    expect(sumEven([1, 3, 5, 7])).toBe(0);
  });

  test('handles negative even numbers', () => {
    expect(sumEven([-2, -4, 2, 4])).toBe(0);
  });

  test('handles array with single even number', () => {
    expect(sumEven([10])).toBe(10);
  });

  test('handles array with single odd number', () => {
    expect(sumEven([5])).toBe(0);
  });

  test('handles large even numbers', () => {
    expect(sumEven([100, 200, 300])).toBe(600);
  });

  test('handles mixed positive and negative even numbers', () => {
    expect(sumEven([2, -4, 6, -8, 10])).toBe(6);
  });
});

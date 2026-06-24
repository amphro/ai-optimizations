const { sumEven } = require('./sumEven');

describe('sumEven', () => {
  test('returns sum of even numbers from mixed array', () => {
    expect(sumEven([1, 2, 3, 4, 5, 6])).toBe(12); // 2 + 4 + 6
  });

  test('returns 0 when array has no even numbers', () => {
    expect(sumEven([1, 3, 5, 7])).toBe(0);
  });

  test('returns sum when all numbers are even', () => {
    expect(sumEven([2, 4, 6, 8])).toBe(20);
  });

  test('returns 0 for empty array', () => {
    expect(sumEven([])).toBe(0);
  });

  test('treats zero as even', () => {
    expect(sumEven([0, 1, 2])).toBe(2); // 0 + 2
  });

  test('handles negative even numbers', () => {
    expect(sumEven([-2, -1, 0, 1, 2])).toBe(0); // -2 + 0 + 2
  });

  test('handles single even number', () => {
    expect(sumEven([4])).toBe(4);
  });

  test('handles single odd number', () => {
    expect(sumEven([5])).toBe(0);
  });
});

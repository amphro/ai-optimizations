const { sumEven } = require('./sumEven');

describe('sumEven', () => {
  test('returns 0 for an empty array', () => {
    expect(sumEven([])).toBe(0);
  });

  test('returns the sum of all even numbers', () => {
    expect(sumEven([2, 4, 6, 8])).toBe(20);
  });

  test('returns 0 for an array with only odd numbers', () => {
    expect(sumEven([1, 3, 5, 7])).toBe(0);
  });

  test('returns the sum of even numbers in a mixed array', () => {
    expect(sumEven([1, 2, 3, 4, 5, 6])).toBe(12);
  });

  test('includes zero in the sum', () => {
    expect(sumEven([0, 1, 2, 3])).toBe(2);
  });

  test('handles negative even numbers', () => {
    expect(sumEven([-2, -1, 0, 1, 2])).toBe(0);
  });

  test('handles negative even numbers in a larger array', () => {
    expect(sumEven([-4, -3, -2, 1, 2, 3, 4])).toBe(0);
  });
});

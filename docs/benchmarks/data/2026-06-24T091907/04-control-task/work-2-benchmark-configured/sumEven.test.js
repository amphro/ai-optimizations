const { sumEven } = require('./sumEven');

describe('sumEven', () => {
  test('returns 0 for an empty array', () => {
    expect(sumEven([])).toBe(0);
  });

  test('returns 0 when array contains no even numbers', () => {
    expect(sumEven([1, 3, 5, 7])).toBe(0);
  });

  test('returns the sum of all even numbers', () => {
    expect(sumEven([2, 4, 6, 8])).toBe(20);
  });

  test('sums even numbers from a mixed array', () => {
    expect(sumEven([1, 2, 3, 4, 5, 6])).toBe(12);
  });

  test('handles negative even numbers', () => {
    expect(sumEven([-2, -4, 3, 5])).toBe(-6);
  });

  test('includes zero as an even number', () => {
    expect(sumEven([0, 1, 2, 3])).toBe(2);
  });

  test('handles large numbers', () => {
    expect(sumEven([1000, 2000, 3000])).toBe(6000);
  });

  test('handles array with single even number', () => {
    expect(sumEven([42])).toBe(42);
  });

  test('handles array with single odd number', () => {
    expect(sumEven([7])).toBe(0);
  });

  test('handles mixed positive and negative even numbers', () => {
    expect(sumEven([-2, 4, -6, 8])).toBe(4);
  });
});

const { sumEven } = require('./sumEven');

describe('sumEven', () => {
  test('sums even numbers in a mixed array', () => {
    expect(sumEven([1, 2, 3, 4, 5, 6])).toBe(12);
  });

  test('returns 0 for an empty array', () => {
    expect(sumEven([])).toBe(0);
  });

  test('returns 0 when there are no even numbers', () => {
    expect(sumEven([1, 3, 5, 7])).toBe(0);
  });

  test('sums all elements when all are even', () => {
    expect(sumEven([2, 4, 6, 8])).toBe(20);
  });

  test('handles negative even numbers', () => {
    expect(sumEven([-2, -4, 3])).toBe(-6);
  });

  test('treats zero as even', () => {
    expect(sumEven([0, 1])).toBe(0);
  });
});

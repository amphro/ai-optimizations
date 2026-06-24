function sumEven(numbers) {
  return numbers.reduce((sum, n) => (n % 2 === 0 ? sum + n : sum), 0);
}

module.exports = { sumEven };

require 'spec_helper'
require_relative '../lib/data_ingres'

describe 'Data Ingres' do
  tests = [
    { input: '0', expected: '0.00' },
    { input: '3500', expected: '3500.00' },
    { input: '3500.', expected: '3500.00' },
    { input: '3500.0', expected: '3500.00' },
    { input: '3500.1', expected: '3500.10' },
    { input: '3500.00', expected: '3500.00' },
    { input: '3500.000', expected: '3500.00' },
    { input: '3500.100', expected: '3500.10' },
    { input: '3500.01', expected: '3500.01' },
    { input: '3500.11', expected: '3500.11' },
    { input: '3500.0012', expected: '3500.00' },
    { input: '3500.004999', expected: '3500.00' },
    { input: '3499.996', expected: '3500.00' },
    { input: 0, expected: '0.00' },
    { input: 3500, expected: '3500.00' },
    { input: 3500.0, expected: '3500.00' },
    { input: 3500.1, expected: '3500.10' },
    { input: 3500.00, expected: '3500.00' },
    { input: 3500.000, expected: '3500.00' },
    { input: 3500.100, expected: '3500.10' },
    { input: 3500.01, expected: '3500.01' },
    { input: 3500.11, expected: '3500.11' },
    { input: 3500.0012, expected: '3500.00' },
    { input: 3500.004999, expected: '3500.00' },
    { input: 3499.996, expected: '3500.00' }
  ]

  tests.each do |test|
    it "returns a number with two decimal places when given a kind of #{test[:input].class} with the value of #{test[:input]}" do
      h = { a: { value: test[:input] } }
      actual = DataIngres.cell_value(h, :a, 'amount')
      expect(actual).to eq(test[:expected])
    end
  end
end
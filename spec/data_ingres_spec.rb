require 'spec_helper'
require_relative '../lib/data_ingres'

describe 'Data Ingres' do
  tests = {
    string_with_no_decimals: '3500',
    string_with_one_zero: '3500.0',
    string_with_two_zeroes: '3500.00',
    string_with_three_zeroes: '3500.000',
    string_with_zero_one: '3500.01',
    string_with_one_one: '3500.11',
    string_with_two_zeroes_and_following_low_value_non_zeroes: '3500.0012',
    string_with_two_zeroes_and_following_high_value_non_zeroes: '3500.004999',
    string_with_lower_value_rounding_up: '3499.996',
    integer: 3500,
    float_with_one_zero: 3500.0,
    float_with_two_zeroes: 3500.00,
    float_with_three_zeroes: 3500.000,
    float_with_zero_one: 3500.01,
    float_with_one_one: 3500.11,
    float_with_two_zeroes_and_following_low_value_non_zeroes: 3500.0012,
    float_with_two_zeroes_and_following_high_value_non_zeroes: 3500.004999,
    float_with_lower_value_rounding_up: 3499.996
  }

  tests.each do |title, value|
    it "returns a number with two decimal places when given a #{title.to_s.gsub('_', ' ')}" do
      h = { a: { value: value } }
      actual = DataIngres.cell_value(h, :a, 'amount')
      expect(actual).to eq('3500.00')
    end
  end
end
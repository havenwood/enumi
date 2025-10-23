# frozen_string_literal: true

require_relative 'test_helper'

class PatternMatchingTest < Minitest::Test
  def setup
    enum :Color do
      value :Red
      value :Yellow
      value :Blue
    end

    enum :Status do
      value :Pending
      value :Active
      value :Complete
    end
  end

  def teardown
    Object.send(:remove_const, :Color) if Object.const_defined?(:Color)
    Object.send(:remove_const, :Status) if Object.const_defined?(:Status)
  end

  def test_match_variant
    result = case Color::Red
             when Color::Red then 'red'
             when Color::Yellow then 'yellow'
             else 'unknown'
             end

    assert_equal 'red', result
  end

  def test_match_integer_against_variant
    value = 1
    result = case value
             when Color::Red then 'red'
             when Color::Yellow then 'yellow'
             else 'unknown'
             end

    assert_equal 'yellow', result
  end

  def test_enum_matches_variant
    assert_operator Color, :===, Color::Red
    assert_operator Color, :===, Color::Yellow
  end

  def test_enum_matches_integer
    assert_operator Color, :===, 0
    assert_operator Color, :===, 1
  end

  def test_enum_rejects_invalid
    refute_operator Color, :===, 99
    refute_operator Color, :===, 'foo'
  end

  def test_variant_matches_self = assert_operator(Color::Red, :===, Color::Red)

  def test_variant_matches_value = assert_operator(Color::Red, :===, 0)

  def test_variant_rejects_other
    refute_operator Color::Red, :===, Color::Yellow
    refute_operator Color::Red, :===, 1
  end

  def test_in_pattern_with_full_hash = assert_pattern { Color::Red in {name: 'Red', value: 0} }

  def test_in_pattern_with_partial_key = assert_pattern { Color::Yellow in {name: 'Yellow'} }

  def test_in_pattern_with_value_only = assert_pattern { Color::Blue in {value: 2} }

  def test_in_pattern_rejects_mismatch
    result = case Color::Red
             in {name: 'Blue'}
               true
             else
               false
             end

    refute result
  end

  def test_deconstruct_keys_pattern_matching = assert_pattern { Status::Complete in {name: 'Complete', value: 2} }

  def test_deconstruct_keys_partial_match = assert_pattern { Status::Pending in {name: 'Pending'} }
end

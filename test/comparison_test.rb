# frozen_string_literal: true

require_relative 'test_helper'

class ComparisonTest < Minitest::Test
  def setup
    enum :Priority do
      value :Low
      value :Medium
      value :High
    end
  end

  def teardown
    Object.send(:remove_const, :Priority) if Object.const_defined?(:Priority)
  end

  def test_less_than
    assert_operator Priority::Low, :<, Priority::High
    assert_operator Priority::Low, :<, Priority::Medium
  end

  def test_greater_than
    assert_operator Priority::High, :>, Priority::Low
    assert_operator Priority::Medium, :>, Priority::Low
  end

  def test_less_than_or_equal
    assert_operator Priority::Low, :<=, Priority::Low
    assert_operator Priority::Low, :<=, Priority::High
  end

  def test_greater_than_or_equal
    assert_operator Priority::High, :>=, Priority::Low
    assert_operator Priority::High, :>=, Priority::High
  end

  def test_spaceship_operator
    assert_equal(-1, Priority::Low <=> Priority::High)
    assert_equal 0, Priority::Medium <=> Priority::Medium
    assert_equal 1, Priority::High <=> Priority::Low
  end

  def test_sorting
    unsorted = [Priority::High, Priority::Low, Priority::Medium]
    sorted = unsorted.sort

    assert_equal [Priority::Low, Priority::Medium, Priority::High], sorted
  end

  def test_spaceship_with_string_returns_nil = assert_nil(Priority::Low <=> 'string')

  def test_spaceship_with_integer_returns_nil = assert_nil(Priority::Low <=> 5)

  def test_spaceship_with_nil_returns_nil = assert_nil(Priority::Low <=> nil)

  def test_comparison_with_non_enum_raises_error = assert_raises(ArgumentError) { Priority::Low < 'string' }
end

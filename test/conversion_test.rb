# frozen_string_literal: true

require_relative 'test_helper'

class ConversionTest < Minitest::Test
  def setup
    enum :Color do
      value :Red
      value :Yellow
      value :Blue
    end

    enum :Priority, flags: true do
      value :Low
      value :Medium
      value :High
    end
  end

  def teardown
    Object.send(:remove_const, :Color) if Object.const_defined?(:Color)
    Object.send(:remove_const, :Priority) if Object.const_defined?(:Priority)
  end

  def test_to_s
    assert_equal 'Red', Color::Red.to_s
    assert_equal 'Yellow', Color::Yellow.to_s
  end

  def test_to_i
    assert_equal 0, Color::Red.to_i
    assert_equal 1, Color::Yellow.to_i
  end

  def test_to_int
    assert_equal 0, Color::Red.to_int
    assert_equal 2, Color::Blue.to_int
  end

  def test_inspect_variant
    assert_match(/Red\(0\)/, Color::Red.inspect)
    assert_match(/Yellow\(1\)/, Color::Yellow.inspect)
  end

  def test_inspect_enum
    result = Color.inspect

    assert_match(/Enum/, result)
    assert_match(/Red/, result)
    assert_match(/Yellow/, result)
  end

  def test_from_value
    assert_equal Color::Red, Color.from_value(0)
    assert_equal Color::Yellow, Color.from_value(1)
  end

  def test_from_value_raises_on_invalid
    error = assert_raises(ArgumentError) { Color.from_value(99) }

    assert_match(/Unknown enum Color value: 99/, error.message)
  end

  def test_new_creates_anonymous_variants
    # Crystal allows creating enums from any integer (like C interop)
    result = Color.new(99)

    assert_equal 99, result.value
    assert_equal '99', result.to_s
  end

  def test_new_alias
    assert_equal Color::Red, Color.new(0)
    assert_equal Color::Blue, Color.new(2)
  end

  def test_to_h
    assert_equal({name: 'Red', value: 0}, Color::Red.to_h)
    assert_equal({name: 'Low', value: 1}, Priority::Low.to_h)
  end

  def test_deconstruct_keys
    assert_equal({name: 'Yellow', value: 1}, Color::Yellow.deconstruct_keys(nil))
    assert_equal({name: 'High', value: 4}, Priority::High.deconstruct_keys(nil))
  end
end

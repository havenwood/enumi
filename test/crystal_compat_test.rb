# frozen_string_literal: true

require_relative 'test_helper'

class CrystalCompatTest < Minitest::Test
  def setup
    enum :Color do
      value :Red
      value :Green
      value :Blue
    end

    enum :HttpStatus do
      value :OK, 200
      value :NotFound, 404
    end

    enum :Priority, flags: true do
      value :Low
      value :Medium
      value :High
    end

    enum :SpecEnum2 do
      value :FortyTwo
      value :FORTY_FOUR
    end
  end

  def teardown
    Object.send(:remove_const, :Color) if Object.const_defined?(:Color)
    Object.send(:remove_const, :HttpStatus) if Object.const_defined?(:HttpStatus)
    Object.send(:remove_const, :Priority) if Object.const_defined?(:Priority)
    Object.send(:remove_const, :SpecEnum2) if Object.const_defined?(:SpecEnum2)
  end

  # .names method

  def test_names_for_simple_enum
    assert_equal %w[Red Green Blue], Color.names
  end

  def test_names_for_flags_enum
    assert_equal %w[Low Medium High], Priority.names
  end

  # .from_value? method

  def test_from_value_safe_for_simple_enum
    assert_equal Color::Red, Color.from_value?(0)
    assert_equal Color::Green, Color.from_value?(1)
    assert_equal Color::Blue, Color.from_value?(2)
    assert_nil Color.from_value?(3)
  end

  def test_from_value_safe_for_flags_enum
    assert_equal Priority::None, Priority.from_value?(0)
    assert_equal Priority::Low, Priority.from_value?(1)
    assert_equal Priority::Medium, Priority.from_value?(2)
    combined = Priority.from_value?(3)

    assert_equal 3, combined.value
  end

  def test_from_value_safe_with_non_integer
    assert_nil Color.from_value?('string')
    assert_nil Color.from_value?(nil)
  end

  # .valid? method

  def test_valid_for_simple_enum
    assert Color.valid?(Color::Red)
    assert Color.valid?(Color::Green)
    assert Color.valid?(Color::Blue)
    refute Color.valid?(Color.new(99))
  end

  def test_valid_for_flags_enum
    assert Priority.valid?(Priority::Low)
    assert Priority.valid?(Priority::Medium)
    assert Priority.valid?(Priority::Low | Priority::Medium)
  end

  def test_valid_for_flags_none_and_all
    assert Priority.valid?(Priority::None)
    assert Priority.valid?(Priority::All)
    refute Priority.valid?(Priority.new(128))
  end

  def test_valid_with_invalid_input
    refute Color.valid?('string')
    refute Color.valid?(nil)
    refute Color.valid?(123)
  end

  # .parse and .parse? methods

  def test_parse_exact_match
    assert_equal Color::Red, Color.parse('Red')
    assert_equal Color::Green, Color.parse('Green')
  end

  def test_parse_case_insensitive
    assert_equal Color::Red, Color.parse('red')
    assert_equal Color::Red, Color.parse('RED')
    assert_equal Color::Red, Color.parse('ReD')
  end

  def test_parse_with_underscores
    assert_equal SpecEnum2::FortyTwo, SpecEnum2.parse('FortyTwo')
    assert_equal SpecEnum2::FortyTwo, SpecEnum2.parse('forty_two')
    assert_equal SpecEnum2::FortyTwo, SpecEnum2.parse('FORTY_TWO')
  end

  def test_parse_with_dashes
    assert_equal SpecEnum2::FORTY_FOUR, SpecEnum2.parse('FORTY-FOUR')
    assert_equal SpecEnum2::FORTY_FOUR, SpecEnum2.parse('forty-four')
  end

  def test_parse_multiple_underscores
    assert_equal SpecEnum2::FORTY_FOUR, SpecEnum2.parse('FORTY___FOUR')
  end

  def test_parse_raises_on_unknown
    error = assert_raises(ArgumentError) { Color.parse('Purple') }

    assert_match(/Unknown enum Color value: Purple/, error.message)
  end

  def test_parse_safe_returns_nil
    assert_nil Color.parse?('Purple')
    assert_nil Color.parse?('Invalid')
  end

  def test_parse_safe_success
    assert_equal Color::Blue, Color.parse?('Blue')
    assert_equal Color::Blue, Color.parse?('blue')
  end

  # .new with symbol

  def test_new_with_symbol
    assert_equal Color::Red, Color.new(:red)
    assert_equal Color::Green, Color.new(:green)
    assert_equal Color::Blue, Color.new(:blue)
  end

  def test_new_with_symbol_case_insensitive
    assert_equal Color::Red, Color.new(:Red)
    assert_equal Color::Red, Color.new(:RED)
  end

  def test_new_with_symbol_underscore
    assert_equal SpecEnum2::FortyTwo, SpecEnum2.new(:forty_two)
  end

  def test_new_with_symbol_raises_on_unknown
    error = assert_raises(ArgumentError) { Color.new(:purple) }

    assert_match(/Unknown enum Color member/, error.message)
  end

  # Arithmetic operators

  def test_plus_operator
    assert_equal Color::Green, Color::Red + 1
    assert_equal Color::Blue, Color::Red + 2
  end

  def test_minus_operator
    assert_equal Color::Green, Color::Blue - 1
    assert_equal Color::Red, Color::Blue - 2
  end

  def test_arithmetic_with_custom_values
    assert_equal HttpStatus::NotFound, HttpStatus::OK + 204
    assert_equal 404, (HttpStatus::OK + 204).value
  end

  def test_arithmetic_creates_anonymous_variants
    result = Color::Red + 10

    assert_equal 10, result.value
  end

  # from_value vs from_value? vs new

  def test_from_value_raises_on_invalid_simple_enum
    error = assert_raises(ArgumentError) { Color.from_value(99) }

    assert_match(/Unknown enum Color value: 99/, error.message)
  end

  def test_from_value_raises_on_invalid_flag_combination
    error = assert_raises(ArgumentError) { Priority.from_value(128) }

    assert_match(/Unknown enum Priority value: 128/, error.message)
  end

  def test_from_value_returns_valid_flag_combination
    result = Priority.from_value(3)

    assert_equal 3, result.value
    assert_predicate result, :low?
    assert_predicate result, :medium?
  end

  def test_new_creates_anonymous_for_any_integer
    result = Color.new(99)

    assert_equal 99, result.value
  end

  # Type conversion methods

  def test_to_i8 = assert_equal(0, Color::Red.to_i8)

  def test_to_i16 = assert_equal(1, Color::Green.to_i16)

  def test_to_i32 = assert_equal(2, Color::Blue.to_i32)

  def test_to_i64 = assert_equal(0, Color::Red.to_i64)

  def test_to_u8 = assert_equal(1, Color::Green.to_u8)

  def test_to_u16 = assert_equal(2, Color::Blue.to_u16)

  def test_to_u32 = assert_equal(0, Color::Red.to_u32)

  def test_to_u64 = assert_equal(1, Color::Green.to_u64)

  # .hash method

  def test_hash_different_for_different_variants
    refute_equal Color::Red.hash, Color::Blue.hash
    refute_equal Color::Green.hash, Color::Blue.hash
  end

  def test_hash_same_for_same_variant
    assert_equal Color::Red.hash, Color::Red.hash
  end

  def test_hash_works_in_hash_structure
    hash_map = {Color::Red => 'red', Color::Blue => 'blue'}

    assert_equal 'red', hash_map[Color::Red]
    assert_equal 'blue', hash_map[Color::Blue]
  end

  # .clone method

  def test_clone_returns_same_object
    assert_same Color::Red, Color::Red.clone
    assert_equal Color::Red, Color::Red.clone
  end

  # .[] and .flags methods

  def test_brackets_with_no_args
    assert_nil Color[]
    assert_nil Priority.flags
  end

  def test_brackets_with_single_symbol
    assert_equal Color::Red, Color[:Red]
    assert_equal Priority::Low, Priority[:Low]
  end

  def test_brackets_with_single_integer
    assert_equal Color::Green, Color[1]
    assert_equal Priority::Medium, Priority[2]
  end

  def test_brackets_with_multiple_symbols
    result = Priority[:Low, :High]

    assert_equal 5, result.value
    assert_predicate result, :low?
    assert_predicate result, :high?
  end

  def test_brackets_with_mixed_types
    result = Priority[:Low, 2]

    assert_equal 3, result.value
  end

  def test_flags_method
    result = Priority.flags(:Low, :Medium)

    assert_equal 3, result.value
  end

  def test_brackets_with_string
    assert_equal Color::Blue, Color['Blue']
  end

  # .each with (name, value) pairs

  def test_each_yields_variant_and_value
    keys = []
    values = []

    Color.each do |variant, value|
      keys << variant
      values << value
    end

    assert_equal [Color::Red, Color::Green, Color::Blue], keys
    assert_equal [0, 1, 2], values
  end

  def test_each_without_block_returns_enumerator
    enum = Color.each

    assert_instance_of Enumerator, enum
  end

  def test_each_for_flags_enum
    keys = []
    values = []

    Priority.each do |variant, value|
      keys << variant
      values << value
    end

    assert_equal [Priority::Low, Priority::Medium, Priority::High], keys
    assert_equal [1, 2, 4], values
  end

  # Instance .each for flags

  def test_instance_each_on_none_yields_nothing
    yielded = false
    Priority::None.each { yielded = true }

    refute yielded
  end

  def test_instance_each_on_single_flag
    keys = []
    values = []

    Priority::Low.each do |variant, value|
      keys << variant
      values << value
    end

    assert_equal [Priority::Low], keys
    assert_equal [1], values
  end

  def test_instance_each_on_combined_flags
    keys = []
    values = []

    combined = Priority::Low | Priority::High
    combined.each do |variant, value|
      keys << variant
      values << value
    end

    assert_equal [Priority::Low, Priority::High], keys
    assert_equal [1, 4], values
  end

  def test_instance_each_on_all
    keys = []
    values = []

    Priority::All.each do |variant, value|
      keys << variant
      values << value
    end

    assert_equal [Priority::Low, Priority::Medium, Priority::High], keys
    assert_equal [1, 2, 4], values
  end

  def test_instance_each_on_non_flags_does_nothing
    yielded = false
    Color::Red.each { yielded = true }

    refute yielded
  end

  # .map method

  def test_map_method
    names = Color.map(&:to_s)

    assert_equal %w[Red Green Blue], names
  end

  # Bitwise NOT operator

  def test_bitwise_not_on_flags
    result = ~Priority::Low

    # ~1 in two's complement
    assert_equal(-2, result.value)
  end

  def test_bitwise_not_returns_enum_instance
    result = ~Priority::Low

    assert_respond_to result, :value
    assert_respond_to result, :includes?
  end

  def test_bitwise_not_on_combined_flags
    combined = Priority::Low | Priority::Medium
    result = ~combined

    # ~3 in two's complement
    assert_equal(-4, result.value)
  end
end

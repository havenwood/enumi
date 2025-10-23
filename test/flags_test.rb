# frozen_string_literal: true

require_relative 'test_helper'

class FlagsTest < Minitest::Test
  def setup
    enum :Permission, flags: true do
      value :Read
      value :Write
      value :Execute
    end

    enum :IOMode, flags: true do
      value :Read
      value :Write
      value :Async
    end

    enum :FileMode, flags: true do
      value :Read
      value :Write
      value :Execute
    end

    enum :Color do
      value :Red
      value :Yellow
    end

    enum :SimpleEnum do
      value :One
      value :Two
    end
  end

  def teardown
    Object.send(:remove_const, :Permission) if Object.const_defined?(:Permission)
    Object.send(:remove_const, :IOMode) if Object.const_defined?(:IOMode)
    Object.send(:remove_const, :FileMode) if Object.const_defined?(:FileMode)
    Object.send(:remove_const, :Color) if Object.const_defined?(:Color)
    Object.send(:remove_const, :SimpleEnum) if Object.const_defined?(:SimpleEnum)
  end

  def test_flag_values_are_powers_of_two
    assert_equal 1, Permission::Read.value
    assert_equal 2, Permission::Write.value
    assert_equal 4, Permission::Execute.value
  end

  def test_flags_attribute
    assert_predicate Permission, :flags?
    refute_predicate Color, :flags?
  end

  def test_bitwise_or
    result = Permission::Read | Permission::Write

    assert_equal 3, result.value
    assert_equal 5, (Permission::Read | Permission::Execute).value
  end

  def test_bitwise_and
    result = Permission::Read & Permission::Write

    assert_equal 0, result.value
    combined = Permission::Read | Permission::Write

    assert_equal 1, (combined & Permission::Read).value
  end

  def test_bitwise_xor
    assert_equal 3, (Permission::Read ^ Permission::Write).value
    assert_equal 6, (Permission::Write ^ Permission::Execute).value
  end

  def test_combine_multiple_flags
    result = Permission.combine(Permission::Read, Permission::Execute)

    assert_equal 5, result.value
    assert result.includes?(Permission::Read)
    assert result.includes?(Permission::Execute)
  end

  def test_combine_all_flags
    result = Permission.combine(Permission::Read, Permission::Write, Permission::Execute)

    assert_equal Permission::All, result
  end

  def test_combine_on_non_flags_returns_nil = assert_nil(Color.combine(Color::Red, Color::Yellow))

  def test_combine_with_empty_arguments
    result = Permission.combine

    assert_equal Permission::None, result
  end

  def test_combine_with_single_flag
    result = Permission.combine(Permission::Read)

    assert_equal Permission::Read, result
  end

  def test_combine_with_integer_values
    result = Permission.combine(Permission::Read, Permission::Write)

    assert_equal 3, result.value
    assert result.includes?(Permission::Read)
    assert result.includes?(Permission::Write)
  end

  def test_regular_enum_lacks_bitwise_or = assert_raises(NoMethodError) { Color::Red | Color::Yellow }

  def test_regular_enum_lacks_bitwise_and = assert_raises(NoMethodError) { Color::Red & Color::Yellow }

  def test_regular_enum_lacks_bitwise_xor = assert_raises(NoMethodError) { Color::Red ^ Color::Yellow }

  def test_none_constant_exists = assert_equal(0, Permission::None.value)

  def test_all_constant_exists = assert_equal(7, Permission::All.value)

  def test_all_includes_all_flags
    assert Permission::All.includes?(Permission::Read)
    assert Permission::All.includes?(Permission::Write)
    assert Permission::All.includes?(Permission::Execute)
  end

  def test_none_includes_nothing = refute(Permission::None.includes?(Permission::Read))

  def test_none_and_all_not_in_values
    refute_includes Permission.values, Permission::None
    refute_includes Permission.values, Permission::All
  end

  def test_non_flag_enum_has_no_none_or_all
    refute SimpleEnum.const_defined?(:None)
    refute SimpleEnum.const_defined?(:All)
  end

  def test_none_to_s = assert_equal('None', Permission::None.to_s)

  def test_all_to_s = assert_equal('Read, Write, Execute', Permission::All.to_s)

  def test_single_flag_to_s
    assert_equal 'Read', IOMode::Read.to_s
    assert_equal 'Write', IOMode::Write.to_s
  end

  def test_combined_flags_to_s
    combined = IOMode::Read.value | IOMode::Write.value
    result = IOMode.parse_flags(combined).join(', ')

    assert_equal 'Read, Write', result
  end

  def test_all_flags_to_s
    assert_match(/Read/, IOMode::All.to_s)
    assert_match(/Write/, IOMode::All.to_s)
    assert_match(/Async/, IOMode::All.to_s)
  end

  def test_parse_flags_with_zero = assert_equal(['None'], IOMode.parse_flags(0))

  def test_parse_flags_with_negative = assert_equal(%w[Read Write Async], IOMode.parse_flags(-1))

  def test_parse_flags_with_value_larger_than_all = assert_equal(%w[Read Write Async], IOMode.parse_flags(999))

  def test_variant_includes
    assert FileMode::Read.includes?(FileMode::Read)
    refute FileMode::Read.includes?(FileMode::Write)
  end

  def test_combined_includes
    combined = FileMode::Read.value | FileMode::Write.value

    assert FileMode.includes?(combined, FileMode::Read)
    assert FileMode.includes?(combined, FileMode::Write)
    refute FileMode.includes?(combined, FileMode::Execute)
    assert FileMode.includes?(combined, 1)
    assert FileMode.includes?(combined, 2)
  end

  def test_none_and_all_includes
    refute FileMode::None.includes?(FileMode::Read)
    assert FileMode::All.includes?(FileMode::Read)
    assert FileMode::All.includes?(FileMode::Write)
    assert FileMode::All.includes?(FileMode::Execute)
  end

  def test_non_flag_enum_includes = refute(SimpleEnum.includes?(1, SimpleEnum::One))

  def test_includes_with_zero_value = refute(FileMode.includes?(0, FileMode::Read))

  def test_includes_with_none_constant
    refute FileMode::None.includes?(FileMode::Read)
    refute FileMode::None.includes?(FileMode::Write)
  end

  def test_includes_with_integer_flag_value
    combined = FileMode::Read.value | FileMode::Write.value

    assert FileMode.includes?(combined, 1)
    assert FileMode.includes?(combined, 2)
  end

  # Crystal-compatible behavior tests

  def test_bitwise_ops_return_enum_instances
    result = Permission::Read | Permission::Write

    assert_respond_to result, :value
    assert_respond_to result, :read?
    assert_equal 3, result.value
  end

  def test_predicate_methods_on_combined_flags
    combined = Permission::Read | Permission::Write

    assert_predicate combined, :read?
    assert_predicate combined, :write?
    refute_predicate combined, :execute?
  end

  def test_chained_bitwise_operations
    result = (Permission::Read | Permission::Write) & Permission::Read

    assert_equal 1, result.value
    assert_predicate result, :read?
  end

  def test_none_bitwise_operations
    result = Permission::None | Permission::Read

    assert_equal 1, result.value
    assert_predicate result, :read?
  end

  def test_all_bitwise_operations
    result = Permission::All & Permission::Read

    assert_equal 1, result.value
    assert_predicate result, :read?
  end

  def test_combined_flag_to_s
    combined = Permission::Read | Permission::Write

    assert_equal 'Read, Write', combined.to_s
  end

  def test_combined_flag_inspect
    combined = Permission::Read | Permission::Write

    assert_match(/Permission\(3\)/, combined.inspect)
    assert_match(/Read, Write/, combined.inspect)
  end
end

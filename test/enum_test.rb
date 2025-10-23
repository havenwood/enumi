# frozen_string_literal: true

require_relative 'test_helper'

class EnumTest < Minitest::Test
  def setup
    enum :Color do
      value :Red
      value :Yellow
      value :Blue
    end

    enum :HttpStatus do
      value :OK, 200
      value :NotFound, 404
    end

    enum :Status do
      value :Pending
      value :Active
      value :Complete
    end

    enum :Flavor do
      value :Vanilla
      value :Chocolate
      value :StrawberrySwirl
    end
  end

  def teardown
    Object.send(:remove_const, :Color) if Object.const_defined?(:Color)
    Object.send(:remove_const, :HttpStatus) if Object.const_defined?(:HttpStatus)
    Object.send(:remove_const, :Status) if Object.const_defined?(:Status)
    Object.send(:remove_const, :Flavor) if Object.const_defined?(:Flavor)
    Object.send(:remove_const, :Duplicate) if Object.const_defined?(:Duplicate)
    Object.send(:remove_const, :Invalid) if Object.const_defined?(:Invalid)
    Object.send(:remove_const, :Invalid2) if Object.const_defined?(:Invalid2)
  end

  def test_enum_is_class = assert_instance_of(Class, Color)

  def test_variant_is_class = assert_instance_of(Class, Color::Red)

  def test_sequential_values
    assert_equal 0, Color::Red.value
    assert_equal 1, Color::Yellow.value
    assert_equal 2, Color::Blue.value
  end

  def test_custom_values
    assert_equal 200, HttpStatus::OK.value
    assert_equal 404, HttpStatus::NotFound.value
  end

  def test_variant_identity
    assert_same Color::Red, Color::Red
    assert_same Color::Yellow, Color::Yellow
  end

  def test_variant_equality
    assert_equal Color::Red, Color::Red
    refute_equal Color::Red, Color::Yellow
  end

  def test_values_returns_all_variants
    assert_equal 3, Color.values.size
    assert_includes Color.values, Color::Red
    assert_includes Color.values, Color::Yellow
    assert_includes Color.values, Color::Blue
  end

  def test_each_iterates_variants
    colors = Color.map { |color| color }

    assert_equal 3, colors.size
    assert_includes colors, Color::Red
  end

  def test_count = assert_equal(3, Color.count)

  def test_value_check_true
    assert Color.value?(0)
    assert Color.value?(1)
    assert Color.value?(2)
  end

  def test_value_check_false
    refute Color.value?(99)
    refute Color.value?(-1)
  end

  def test_find_by_string
    assert_equal Status::Pending, Status.find('Pending')
    assert_nil Status.find('NonExistent')
  end

  def test_find_by_symbol
    assert_equal Status::Active, Status.find(:Active)
    assert_nil Status.find(:Unknown)
  end

  def test_find_by_integer
    assert_equal Status::Complete, Status.find(2)
  end

  def test_find_by_integer_creates_anonymous
    # Crystal allows creating enums from any integer via .new
    result = Status.find(999)

    assert_equal 999, result.value
  end

  def test_find_with_invalid_type = assert_nil(Status.find([]))

  # Predicate methods

  def test_predicate_returns_true_for_self
    assert_predicate Flavor::Vanilla, :vanilla?
    assert_predicate Flavor::Chocolate, :chocolate?
  end

  def test_predicate_returns_false_for_others
    refute_predicate Flavor::Vanilla, :chocolate?
    refute_predicate Flavor::Chocolate, :vanilla?
  end

  def test_predicate_with_multi_word_name
    assert_predicate Flavor::StrawberrySwirl, :strawberry_swirl?
    refute_predicate Flavor::Vanilla, :strawberry_swirl?
  end

  def test_all_variants_have_all_predicates
    assert_respond_to Flavor::Vanilla, :vanilla?
    assert_respond_to Flavor::Vanilla, :chocolate?
    assert_respond_to Flavor::Vanilla, :strawberry_swirl?
  end

  # Error handling

  def test_duplicate_constant_error
    error = assert_raises(ArgumentError) do
      enum :Duplicate do
        value :Foo
        value :Foo
      end
    end
    assert_match(/already defined/, error.message)
  end

  def test_raises_on_string_constant_name
    error = assert_raises(ArgumentError) do
      enum :Invalid do
        value 'NotASymbol'
      end
    end
    assert_match(/must be a Symbol/, error.message)
  end

  def test_raises_on_integer_constant_name
    error = assert_raises(ArgumentError) do
      enum :Invalid2 do
        value 123
      end
    end
    assert_match(/must be a Symbol/, error.message)
  end
end

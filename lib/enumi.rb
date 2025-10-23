# frozen_string_literal: true

require_relative 'enumi/version'

# Crystal-like enums for Ruby with pattern matching, flags, and bitwise operations.
module Kernel
  def Enumi(const, flags: false, &)
    enum_class = Class.new do
      @flags = flags
      @value_counter = flags ? 1 : 0
      @variants = []

      class << self
        def flags?
          @flags
        end

        def values = @variants

        def names = @variants.map(&:to_s)

        def from_value?(value)
          return nil unless value.is_a?(Integer)

          # Check for exact match first
          existing = values.find { |variant| variant.value == value }
          return existing if existing

          # For flags enums, check None/All constants and valid combinations
          if @flags
            return const_get(:None) if value.zero? && const_defined?(:None)
            return const_get(:All) if const_defined?(:All) && value == const_get(:All).value

            # Check if it's a valid combination of flags
            all_flags = values.reduce(0) { |acc, variant| acc | variant.value }
            return create_anonymous_variant(value) if all_flags.allbits?(value)
          end

          nil
        end

        def from_value(value)
          return from_value(parse_symbol_value(value)) if value.is_a?(Symbol)

          result = from_value?(value)
          return result if result

          raise ArgumentError, "Unknown enum #{name} value: #{value}"
        end

        def new(value)
          return from_value(parse_symbol_value(value)) if value.is_a?(Symbol)

          existing = values.find { |variant| variant.value == value }
          return existing if existing

          create_anonymous_variant(value)
        end

        def valid?(enum_value)
          return false unless enum_value.respond_to?(:value)

          val = enum_value.value

          # Check if it's an exact match
          return true if values.any? { |variant| variant.value == val }

          # For flags enums, check None and All
          if @flags
            return true if val.zero? # None is always valid
            return true if const_defined?(:All) && val == const_get(:All).value

            # Check if it's a valid combination of flags
            all_flags = values.reduce(0) { |acc, variant| acc | variant.value }
            return all_flags.allbits?(val)
          end

          false
        end

        private

        def parse_symbol_value(symbol)
          const_name = symbol.to_s.split('_').map(&:capitalize).join.to_sym
          return const_get(const_name).value if const_defined?(const_name)

          # Try exact match (case-insensitive)
          values.each do |variant|
            return variant.value if variant.to_s.downcase == symbol.to_s.downcase
          end

          raise ArgumentError, "Unknown enum #{name} member: #{symbol}"
        end

        def create_anonymous_variant(value_int)
          is_flags = @flags
          enum_class_name = name

          value_class = Class.new do
            @value = value_int
            @is_flags = is_flags
            @enum_class_name = enum_class_name

            class << self
              attr_reader :value

              def to_s
                return value.to_s unless @is_flags

                flags = Object.const_get(@enum_class_name).parse_flags(value)
                return value.to_s if flags.empty?

                flags.join(', ')
              end

              def to_i = value
              alias to_int to_i

              def <=>(other) = other.respond_to?(:value) ? value <=> other.value : nil
              include Comparable

              def +(other)
                Object.const_get(@enum_class_name).new(value + other)
              end

              def -(other)
                Object.const_get(@enum_class_name).new(value - other)
              end

              def ~
                Object.const_get(@enum_class_name).new(~value)
              end

              def hash = value.hash

              def clone = self

              def inspect
                enum_name = Object.const_get(@enum_class_name).name
                flag_info = @is_flags && value != 0 && value.anybits?(value - 1) ? " (#{self})" : ''
                "#{enum_name}(#{value})#{flag_info}"
              end

              def includes?(flag)
                return false unless @is_flags

                flag_value = flag.respond_to?(:value) ? flag.value : flag
                value.anybits?(flag_value)
              end

              def each(&block)
                return unless @is_flags
                return if value.zero? # None yields nothing

                enum_class = Object.const_get(@enum_class_name)
                enum_class.values.each do |variant|
                  next unless value.anybits?(variant.value)

                  block.call(variant, variant.value)
                end
              end

              def to_h = {name: to_s, value: value}

              def deconstruct_keys(_keys) = to_h

              def ===(other) = self == other || value == (other.respond_to?(:value) ? other.value : other)
            end
          end

          if is_flags
            %i[| & ^].each do |op|
              value_class.singleton_class.define_method(op) do |other|
                result = value.public_send(op, other.value)
                Object.const_get(@enum_class_name).from_value(result)
              end
            end
          end

          enum_class = Object.const_get(enum_class_name)
          enum_class.values.each do |variant|
            method_name = "#{enum_class.send(:underscore, variant.to_s)}?"
            value_class.singleton_class.define_method(method_name) do
              is_flags ? includes?(variant) : self == variant
            end
          end

          value_class
        end

        public

        def each(&block)
          return values.each unless block

          values.each { |variant| block.call(variant, variant.value) }
        end

        def map(&) = values.map(&)

        def count = values.size

        def value?(int) = values.any? { |variant| variant.value == int }

        def ===(other)
          values.any? { |variant| variant == other || variant.value == other }
        end

        def inspect = "#<Enum #{name} [#{values.map(&:to_s).join(', ')}]>"

        def combine(*variants)
          return unless @flags

          result = variants.reduce(0) { |acc, variant| acc | variant.value }
          from_value(result)
        end

        def parse_flags(value)
          return [] unless @flags
          return ['None'] if value.zero?

          values.filter_map do |variant|
            variant.name.rpartition('::').last if value.anybits?(variant.value)
          end
        end

        def includes?(value, flag)
          return false unless @flags

          flag_value = flag.respond_to?(:value) ? flag.value : flag
          value.anybits?(flag_value)
        end

        def find(key)
          case key
          when String, Symbol
            const_name = key.to_sym
            const_defined?(const_name) ? const_get(const_name) : nil
          when Integer
            new(key)
          end
        end

        def parse?(string)
          normalized = normalize_string(string.to_s)

          values.find do |variant|
            normalize_string(variant.to_s) == normalized
          end
        end

        def parse(string)
          parse?(string) || raise(ArgumentError, "Unknown enum #{name} value: #{string}")
        end

        def [](*members)
          return nil if members.empty?

          result = members.map do |member|
            case member
            when Symbol
              const_name = member.to_s.split('_').map(&:capitalize).join.to_sym
              const_defined?(const_name) ? const_get(const_name) : nil
            when Integer
              from_value(member)
            when String
              find(member)
            else
              member
            end
          end.compact

          return nil if result.empty?
          return result.first if result.size == 1

          result.reduce { |acc, variant| acc | variant }
        end
        alias_method :flags, :[]

        private

        def normalize_string(str)
          # Just remove all non-alphanumeric chars and downcase for comparison
          str.gsub(/[^a-zA-Z0-9]/, '').downcase
        end

        def underscore(str)
          str
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .downcase
        end

        def define_predicate_methods
          values.each do |variant|
            method_name = "#{underscore(variant.to_s)}?"

            values.each do |current_variant|
              current_variant.singleton_class.define_method(method_name) do
                @is_flags ? includes?(variant) : self == variant
              end
            end
          end
        end

        def value(value_const, value_counter = @value_counter) = define_variant(value_const, value_counter)

        def define_variant(value_const, value_counter = @value_counter)
          unless value_const.is_a?(Symbol)
            raise ArgumentError, "Constant name must be a Symbol, got #{value_const.class}: #{value_const.inspect}"
          end

          raise ArgumentError, "Constant #{value_const} already defined in #{name}" if const_defined?(value_const)

          @value_counter = @flags ? value_counter * 2 : value_counter + 1
          is_flags = @flags
          enum_class_name = name

          value_class = Class.new do
            @value = value_counter
            @is_flags = is_flags
            @enum_class_name = enum_class_name

            class << self
              attr_reader :value

              def to_s
                return name.rpartition('::').last unless @is_flags

                flags = Object.const_get(@enum_class_name).parse_flags(value)
                return name.rpartition('::').last if flags.size <= 1

                flags.join(', ')
              end

              def to_i = value
              alias to_int to_i

              def <=>(other) = other.respond_to?(:value) ? value <=> other.value : nil
              include Comparable

              def +(other)
                Object.const_get(@enum_class_name).new(value + other)
              end

              def -(other)
                Object.const_get(@enum_class_name).new(value - other)
              end

              def ~
                Object.const_get(@enum_class_name).new(~value)
              end

              def hash = value.hash

              def clone = self

              def inspect
                flag_info = @is_flags && value != 0 && value.anybits?(value - 1) ? " (#{self})" : ''
                "#{name}(#{value})#{flag_info}"
              end

              def includes?(flag)
                return false unless @is_flags

                flag_value = flag.respond_to?(:value) ? flag.value : flag
                value.anybits?(flag_value)
              end

              def each(&block)
                return unless @is_flags
                return if value.zero? # None yields nothing

                enum_class = Object.const_get(@enum_class_name)
                enum_class.values.each do |variant|
                  next unless value.anybits?(variant.value)

                  block.call(variant, variant.value)
                end
              end

              def to_h = {name: to_s, value: value}

              def deconstruct_keys(_keys) = to_h

              def ===(other) = self == other || value == (other.respond_to?(:value) ? other.value : other)
            end
          end

          if is_flags
            %i[| & ^].each do |op|
              value_class.singleton_class.define_method(op) do |other|
                result = value.public_send(op, other.value)
                Object.const_get(@enum_class_name).from_value(result)
              end
            end
          end

          const_set value_const, value_class
          @variants << value_class
        end

        def create_flag_constant(const_name, flag_value, enum_class_name, &)
          flag_class = Class.new do
            @value = flag_value
            @is_flags = true
            @enum_class_name = enum_class_name

            class << self
              attr_reader :value

              def to_i = value
              alias to_int to_i
            end
          end

          %i[| & ^].each do |op|
            flag_class.singleton_class.define_method(op) do |other|
              result = @value.public_send(op, other.value)
              Object.const_get(@enum_class_name).from_value(result)
            end
          end

          flag_class.singleton_class.class_eval(&)
          const_set const_name, flag_class
        end

        def create_flag_constants
          return unless @flags
          return if const_defined?(:None)

          enum_class_name = name

          create_flag_constant(:None, 0, enum_class_name) do
            def to_s = 'None'
            def inspect = "#{name}(0)"
            def includes?(_flag) = false

            # None yields nothing
            def each(&) = nil
          end

          all_value = @variants.reduce(0) { |acc, variant| acc | variant.value }
          create_flag_constant(:All, all_value, enum_class_name) do
            def to_s
              flags = Object.const_get(@enum_class_name).parse_flags(value)
              flags.join(', ')
            end

            def inspect = "#{name}(#{value}) (#{self})"

            def includes?(flag)
              flag_value = flag.respond_to?(:value) ? flag.value : flag
              value.anybits?(flag_value)
            end

            def each(&block)
              enum_class = Object.const_get(@enum_class_name)
              enum_class.values.each do |variant|
                block.call(variant, variant.value)
              end
            end
          end
        end
      end
    end

    Object.const_set(const.name, enum_class)
    enum_class.module_eval(&)

    enum_class.send(:create_flag_constants)
    enum_class.send(:define_predicate_methods)

    enum_class
  end
end

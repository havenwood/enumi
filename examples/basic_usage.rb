# frozen_string_literal: true

require_relative '../lib/enumi/enum'

# ============================================================================
# Basic Enum
# ============================================================================

enum :Color do
  value :Red
  value :Yellow
  value :Blue
end

puts '=== Basic Enum Creation ==='
puts "Color::Red.value: #{Color::Red.value}"         # => 0
puts "Color::Yellow.value: #{Color::Yellow.value}"   # => 1
puts "Color::Blue.value: #{Color::Blue.value}"       # => 2
puts

puts '=== Accessing Variants ==='
puts "All values: #{Color.values.map(&:to_s).join(', ')}"
puts "Count: #{Color.count}"
puts "Find by name: #{Color.find(:Red)}"
puts "Find by value: #{Color.from_value(1)}"
puts "Value exists? #{Color.value?(1)}"
puts

# Predicate methods are automatically generated for each variant
puts '=== Predicate Methods ==='
puts "Color::Red.red?: #{Color::Red.red?}"     # => true
puts "Color::Red.blue?: #{Color::Red.blue?}"   # => false
puts

# Variants implement Comparable based on their values
puts '=== Comparison & Sorting ==='
puts "Red < Blue: #{Color::Red < Color::Blue}"
puts "Yellow == Yellow: #{Color::Yellow == Color::Yellow}"
sorted = [Color::Blue, Color::Red, Color::Yellow].sort
puts "Sorted: #{sorted.map(&:to_s).join(', ')}"
puts

puts '=== Pattern Matching (case/when) ==='
color = Color::Red
result = case color
         when Color::Red
           'It is red'
         when Color::Yellow
           'It is yellow'
         when Color::Blue
           'It is blue'
         end
puts result
puts

puts '=== Pattern Matching (in) ==='
case Color::Yellow
in name: 'Yellow', value: 1
  puts 'Matched Yellow with value 1'
end
puts

puts '=== Enumeration ==='
Color.each do |color|
  puts "  #{color} (value: #{color.value}, red?: #{color.red?})"
end
puts

# Custom values can be any integers
enum :HttpStatus do
  value :OK, 200
  value :NotFound, 404
  value :ServerError, 500
end

# Helper function using endless method syntax
def success_status?(status) = status.value >= 200 && status.value < 300

puts '=== Custom Values ==='
puts "HttpStatus::OK.value: #{HttpStatus::OK.value}"
puts "HttpStatus::NotFound.value: #{HttpStatus::NotFound.value}"
puts "Find by custom value: #{HttpStatus.from_value(404)}"
puts "Is OK a success? #{success_status?(HttpStatus::OK)}"
puts "Is NotFound a success? #{success_status?(HttpStatus::NotFound)}"
puts

# Flag enums use powers of 2 for bitwise operations
enum :Permission, flags: true do
  value :Read
  value :Write
  value :Execute
end

puts '=== Flag Enum (Powers of 2) ==='
puts "Read: #{Permission::Read.value}"     # => 1
puts "Write: #{Permission::Write.value}"   # => 2
puts

# None and All constants are automatically created for flag enums
puts '=== Flag Constants ==='
puts "None: #{Permission::None.value}"   # => 0
puts "All: #{Permission::All}"           # => "Read, Write, Execute"
puts

puts '=== Bitwise Operations ==='
read_write = Permission::Read | Permission::Write
puts "Read | Write = #{read_write}"
puts "combine(Read, Execute) = #{Permission.combine(Permission::Read, Permission::Execute)}"
puts

puts '=== Flag Checking ==='
permissions_value = Permission::Read.value | Permission::Write.value
puts "Includes Read? #{Permission.includes?(permissions_value, Permission::Read)}"
puts "Includes Execute? #{Permission.includes?(permissions_value, Permission::Execute)}"
puts

puts '=== Hash Representation ==='
puts "Color::Red.to_h: #{Color::Red.to_h.inspect}"
puts

puts '✅ All basic features demonstrated!'

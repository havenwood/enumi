# Enumi

Crystal-like enums for Ruby with pattern matching, flags and bitwise operations.

## Installation

```sh
gem install enumi
```

## Usage

```ruby
require 'enumi/enum'

enum :Color do
  value :Red
  value :Yellow
  value :Blue
end

Color::Red.value     #=> 0
Color::Yellow.value  #=> 1
Color::Blue.value    #=> 2

Color::Red.red?      #=> true
Color.values.count   #=> 3
```

### Variant methods

```ruby
Color::Red.red?      #=> true
Color::Red.yellow?   #=> false

Color::Red < Color::Blue   #=> true
Color::Red.to_i            #=> 0
Color::Red.to_s            #=> "Red"
Color::Red.to_h            #=> {name: "Red", value: 0}
```

### Enum methods

```ruby
Color.values        #=> [Color::Red(0), Color::Yellow(1), Color::Blue(2)]
Color.count         #=> 3
Color.find(:Red)    #=> Color::Red(0)
Color.find('Blue')  #=> Color::Blue(2)
Color.find(1)       #=> Color::Yellow(1)
Color.each { |color| puts color }
```

### Custom values

Override automatic numbering:

```ruby
enum :Priority do
  value :Low, 1
  value :Medium, 5
  value :High, 10
end

Priority::Low.value      #=> 1
Priority::High.value     #=> 10
Priority.find(5)         #=> Priority::Medium(5)
```

## Matching

```ruby
# Pattern matching
case Color::Yellow
in name: 'Yellow', value: 1
  puts "yellow matches"
end

# Match against integer values
case 1
when Color::Yellow
  "yellow matches"
end

case Color::Red
in Color::Red
  "red matches"
in Color::Blue
  "blue matches"
end
```

## Flag enums

Use `flags: true` for bitwise operations with powers of 2:

```ruby
enum :Permission, flags: true do
  value :Read      # 1
  value :Write     # 2
  value :Execute   # 4
end
```

### Automatic constants

```ruby
Permission::None.value  #=> 0
Permission::All.value   #=> 7
Permission::All.to_s    #=> "Read, Write, Execute"
```

### Bitwise operations

```ruby
Permission::Read | Permission::Write  #=> Permission(3) (Read, Write)
Permission::Read & Permission::Write  #=> Permission::None(0)
(Permission::Read | Permission::Write) ^ Permission::Read  #=> Permission::Write(2)

Permission.combine(Permission::Read, Permission::Execute)  #=> Permission(5) (Read, Execute)
```

### Checking flags

```ruby
Permission::Read.includes?(Permission::Read)   #=> true
Permission::Read.includes?(Permission::Write)  #=> false

combined = Permission::Read.value | Permission::Write.value
Permission.includes?(combined, Permission::Read)  #=> true
Permission.parse_flags(3)  #=> ["Read", "Write"]
```

## More examples

### State machine

```ruby
enum :OrderStatus do
  value :Pending
  value :Processing
  value :Shipped
  value :Delivered
end

class Order
  def initialize
    @status = OrderStatus::Pending
  end

  def process!
    @status = OrderStatus::Processing if @status.pending?
  end

  def can_cancel? = @status < OrderStatus::Shipped
end
```

### HTTP response handler

```ruby
enum :HttpStatus do
  value :OK, 200
  value :Created, 201
  value :BadRequest, 400
  value :NotFound, 404
  value :ServerError, 500
end

def handle_response(status)
  case status.value
  when 200..299 then "Success"
  when 400..499 then "Client error"
  when 500..599 then "Server error"
  end
end
```

## Without Kernel enum

The capitalized `Enumi` is also available without the `enum` alias, with the same behavior:

```ruby
require 'enumi'

Enumi :Color do
  value :Red
  value :Yellow
end
```

## API reference

### Enum methods

| Method | Description |
|--------|-------------|
| `.values` | Array of all variants |
| `.find(key)` | Find by string, symbol, or integer |
| `.from_value(int)` | Find by integer value (raises if not found) |
| `.each { }` | Iterate variants |
| `.count` | Number of variants |
| `.value?(int)` | Check if value exists |

**Flags only:**

| Method | Description |
|--------|-------------|
| `.combine(*variants)` | Combine flags with bitwise OR |
| `.parse_flags(value)` | Extract flag names from integer |
| `.includes?(value, flag)` | Check if flag is set in value |

### Variant methods

| Method | Description |
|--------|-------------|
| `.value` | Integer value |
| `.to_i`, `.to_int` | Integer conversion |
| `.to_h` | Hash representation |
| `.to_s` | String name |
| `.inspect` | Debug representation |
| `.<=>` | Comparison operator (enables sorting) |
| `.variant_name?` | Predicate method (dynamically generated) |

**Flags only:**

| Method | Description |
|--------|-------------|
| `.\|`, `.&`, `.^` | Bitwise OR, AND, XOR operators |
| `.includes?(flag)` | Check if flag is set |

## Requirements

Ruby >= 3.4

## License

MIT License

## Inspiration

[Crystal Enums](https://crystal-lang.org/reference/syntax_and_semantics/enum.html)

# frozen_string_literal: true

require_relative '../lib/enumi/enum'

# ============================================================================
# Real-World Example 1: HTTP Request Handler
# ============================================================================

puts '=== HTTP Request Handler ==='

enum :HttpMethod do
  value :GET
  value :POST
  value :PUT
  value :DELETE
  value :PATCH
end

def handle_request(method, path)
  case method
  when HttpMethod::GET
    "Fetching #{path}"
  when HttpMethod::POST
    "Creating resource at #{path}"
  when HttpMethod::PUT, HttpMethod::PATCH
    "Updating #{path}"
  when HttpMethod::DELETE
    "Deleting #{path}"
  end
end

puts handle_request(HttpMethod::GET, '/users')
puts handle_request(HttpMethod::POST, '/users')
puts

# ============================================================================
# Real-World Example 2: State Machine
# ============================================================================

puts '=== Order State Machine ==='

enum :OrderStatus do
  value :Pending
  value :Processing
  value :Shipped
  value :Delivered
  value :Cancelled
end

# Demonstrates state machine pattern with enum-based status tracking
class Order
  attr_reader :status, :id

  def initialize(id)
    @id = id
    @status = OrderStatus::Pending
  end

  def process!
    return unless @status == OrderStatus::Pending

    @status = OrderStatus::Processing
    puts "Order #{@id}: #{@status}"
  end

  def ship!
    return unless @status == OrderStatus::Processing

    @status = OrderStatus::Shipped
    puts "Order #{@id}: #{@status}"
  end

  def deliver!
    return unless @status == OrderStatus::Shipped

    @status = OrderStatus::Delivered
    puts "Order #{@id}: #{@status}"
  end

  def cancel!
    return if @status == OrderStatus::Delivered

    @status = OrderStatus::Cancelled
    puts "Order #{@id}: #{@status}"
  end
end

order = Order.new(123)
order.process!
order.ship!
order.deliver!
puts

# ============================================================================
# Real-World Example 3: File Permissions System
# ============================================================================

puts '=== File Permissions System ==='

enum :FilePermission, flags: true do
  value :Read
  value :Write
  value :Execute
end

# Demonstrates flag-based permissions system with bitwise operations
class FileEntry
  attr_reader :name, :permissions

  def initialize(name, *permissions)
    @name = name
    @permissions = FilePermission.combine(*permissions)
  end

  # Endless method syntax for permission checks
  def readable? = FilePermission.includes?(@permissions, FilePermission::Read)

  def writable? = FilePermission.includes?(@permissions, FilePermission::Write)

  def executable? = FilePermission.includes?(@permissions, FilePermission::Execute)

  def grant(*permissions)
    permissions.each do |permission|
      @permissions |= permission.value
    end
  end

  def revoke(*permissions)
    permissions.each do |permission|
      @permissions &= ~permission.value
    end
  end

  def to_s
    flags = FilePermission.parse_flags(@permissions)
    "#{@name} [#{flags.join(', ')}]"
  end
end

file = FileEntry.new('script.sh', FilePermission::Read, FilePermission::Execute)
puts file
puts "Readable? #{file.readable?}"
puts "Writable? #{file.writable?}"

file.grant(FilePermission::Write)
puts "\nAfter granting Write permission:"
puts file
puts "Writable? #{file.writable?}"
puts

# ============================================================================
# Real-World Example 4: Logging System
# ============================================================================

puts '=== Logging System ==='

enum :LogLevel do
  value :DEBUG, 0
  value :INFO, 1
  value :WARN, 2
  value :ERROR, 3
  value :FATAL, 4
end

# Demonstrates custom values and Comparable for level-based filtering
class Logger
  def initialize(min_level = LogLevel::INFO)
    @min_level = min_level
  end

  def log(level, message)
    return unless level >= @min_level

    prefix = case level
             when LogLevel::DEBUG then '🔍'
             when LogLevel::INFO then 'ℹ️'
             when LogLevel::WARN then '⚠️'
             when LogLevel::ERROR then '❌'
             when LogLevel::FATAL then '💀'
             end

    puts "#{prefix} [#{level}] #{message}"
  end

  # Endless method syntax for convenience methods
  def debug(message) = log(LogLevel::DEBUG, message)

  def info(message) = log(LogLevel::INFO, message)

  def warn(message) = log(LogLevel::WARN, message)

  def error(message) = log(LogLevel::ERROR, message)

  def fatal(message) = log(LogLevel::FATAL, message)
end

logger = Logger.new(LogLevel::INFO)
logger.debug('This will not appear')
logger.info('Application started')
logger.warn('Low memory')
logger.error('Connection failed')
puts

puts '✅ All practical examples completed!'

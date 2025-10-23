# frozen_string_literal: true

require_relative '../enumi'

# Extension to provide lowercase enum alias.
module Kernel
  alias enum Enumi
end

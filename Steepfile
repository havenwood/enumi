# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  signature 'sig'

  check 'lib'

  library 'pathname'

  configure_code_diagnostics(D::Ruby.strict)
end

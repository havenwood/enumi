# frozen_string_literal: true

require_relative 'lib/enumi/version'

Gem::Specification.new do |spec|
  spec.name = 'enumi'
  spec.version = Enumi::VERSION
  spec.authors = ['Shannon Skipper']
  spec.email = ['shannonskipper@gmail.com']

  spec.summary = 'Crystal-like enums for Ruby'
  spec.description = 'Enum support with Crystal-like semantics: pattern matching, flags, and bitwise operations'
  spec.homepage = 'https://github.com/havenwood/enumi'
  spec.required_ruby_version = '>= 3.4.0'
  spec.license = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/releases"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['documentation_uri'] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'sig/**/*.rbs', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']
end

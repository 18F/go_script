# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'go_script/version'

Gem::Specification.new do |s|
  s.name          = 'go_script'
  s.version       = GoScript::VERSION
  s.authors       = ['Mike Bland']
  s.email         = ['michael.bland@gsa.gov']
  s.summary       = './go script: a unified development environment interface'
  s.description   = (
    'Abstracts common functionality used in the `./go` scripts of several ' \
    '18F projects, and provides a `./go` script generator for new projects.'
  )
  s.homepage      = 'https://github.com/18F/go_script'
  s.license       = 'CC0'

  s.files         = `git ls-files -z *.md bin lib`.split("\x0") + [
  ]
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }

  s.add_runtime_dependency 'bundler', '~> 1.10'
  s.add_runtime_dependency 'safe_yaml', '~> 1.0'
  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'rubocop'

  # We need Jekyll and guides_style_18f for _test/bundler_test.rb
  s.add_development_dependency 'jekyll'
  s.add_development_dependency 'guides_style_18f'
end

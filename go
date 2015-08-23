#! /usr/bin/env ruby

require 'English'

begin
  require_relative 'lib/go_script'
rescue LoadError
  puts 'Installing go_script gem...'
  exit $CHILD_STATUS.exitstatus unless system 'gem install go_script'
end

GoScript::Version.check_ruby_version '2.2.3'

extend GoScript

BASEDIR = File.dirname(__FILE__)
command_group :dev, 'Development commands'

def_command :init, 'Set up the development environment' do
  install_bundle
end

def_command :update_gems, 'Update Ruby gems' do |gems|
  update_gems gems
end

def_command :test, 'Execute automated tests' do |args|
  exec_cmd "bundle exec rake test #{args.join ' '}"
end

def_command :lint, 'Run style-checking tools' do |files|
  files = files.group_by { |f| File.extname f }
  lint_ruby files['.rb']
end

def_command :ci_build, 'Execute continuous integration build' do
  test []
  exec_cmd 'bundle exec rake build'
end

def_command :release, 'Test, build, and release a new gem' do
  test []
  exec_cmd 'bundle exec rake release'
end

execute_command ARGV

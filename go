#! /usr/bin/env ruby

require 'English'

Dir.chdir File.dirname(__FILE__)

require_relative 'lib/go_script'

extend GoScript
check_ruby_version '2.2.3'

BASEDIR = File.dirname(__FILE__)
command_group :dev, 'Development commands'

def_command :update_gems, 'Update Ruby gems' do |gems|
  update_gems gems
end

def_command :test, 'Execute automated tests' do |args|
  exec_cmd "bundle exec rake test #{args_to_string args}"
end

def_command :lint, 'Run style-checking tools' do |files|
  lint_ruby files
end

def_command :ci_build, 'Execute continuous integration build' do
  test
  exec_cmd 'bundle exec rake build'
end

def_command :release, 'Test, build, and release a new gem' do
  test
  exec_cmd 'bundle exec rake release'
end

execute_command ARGV

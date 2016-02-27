#! /usr/bin/env ruby

require 'English'

Dir.chdir File.dirname(__FILE__)

def try_command_and_restart(command)
  exit $CHILD_STATUS.exitstatus unless system command
  env = {}.merge(ENV)
  env.delete('RUBYOPT')
  exec(env, RbConfig.ruby, *[$PROGRAM_NAME].concat(ARGV))
end

begin
  require 'bundler/setup'
rescue LoadError
  try_command_and_restart 'gem install bundler'
rescue SystemExit
  try_command_and_restart 'bundle install'
end

require_relative 'lib/go_script'

extend GoScript
check_ruby_version '2.3.0'

command_group :dev, 'Development commands'

def_command :update_gems, 'Update Ruby gems' do |gems|
  update_gems gems
end

def_command :test, 'Execute automated tests' do |args|
  exec_cmd "rake test #{args_to_string args}"
end

def_command :lint, 'Run style-checking tools' do |files|
  lint_ruby files
end

def_command :build, 'Test and build the gem' do
  test
  exec_cmd 'rake build'
end

def_command :release, 'Test, build, and release a new gem' do
  test
  exec_cmd 'rake release'
end

execute_command ARGV

#! /usr/bin/env ruby

require 'English'

Dir.chdir File.dirname(__FILE__)

require_relative 'lib/go_script'

extend GoScript
check_ruby_version '2.2.3'

BASEDIR = File.dirname(__FILE__)
dev_commands = GoScript::CommandGroup.add_group 'Development commands'

def_command :update_gems, dev_commands, 'Update Ruby gems' do |gems|
  update_gems gems
end

def_command :test, dev_commands, 'Execute automated tests' do |args|
  exec_cmd "bundle exec rake test #{args.join ' '}"
end

def_command :lint, dev_commands, 'Run style-checking tools' do |files|
  files = files.group_by { |f| File.extname f }
  lint_ruby files['.rb']
end

def_command :ci_build, dev_commands, 'Execute continuous integration build' do
  test []
  exec_cmd 'bundle exec rake build'
end

def_command :release, dev_commands, 'Test, build, and release a new gem' do
  test []
  exec_cmd 'bundle exec rake release'
end

execute_command ARGV

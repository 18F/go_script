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
dev_commands = GoScript::CommandGroup.add_group 'Development commands'

def_command :init, dev_commands, 'Set up the development environment' do
  install_bundle
end

def_command :update_gems, dev_commands, 'Update Ruby gems' do |gems|
  update_gems gems
end

def_command :update_js, dev_commands, 'Update JavaScript components' do
  update_node_modules
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

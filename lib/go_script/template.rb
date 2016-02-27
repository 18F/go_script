module GoScript
  class Template
    # rubocop:disable MethodLength
    def self.preamble
      <<END_OF_PREAMBLE
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
  require 'bundler/setup' if File.exist? 'Gemfile'
rescue LoadError
  try_command_and_restart 'gem install bundler'
rescue SystemExit
  try_command_and_restart 'bundle install'
end

begin
  require 'go_script'
rescue LoadError
  try_command_and_restart 'gem install go_script' unless File.exist? 'Gemfile'
  abort "Please add \\\"gem 'go_script'\\\" to your Gemfile"
end

extend GoScript
check_ruby_version '#{RUBY_VERSION}'

END_OF_PREAMBLE
    end
    # rubocop:enable MethodLength

    # rubocop:disable MethodLength
    def self.standard_dev_commands
      <<END_STANDARD_DEV_COMMANDS
command_group :dev, 'Development commands'

def_command :init, 'Set up the development environment' do
end

def_command :update_gems, 'Update Ruby gems' do |gems|
  update_gems gems
end

def_command :update_js, 'Update JavaScript components' do
  update_node_modules
end

def_command :test, 'Execute automated tests' do |args|
  exec_cmd "rake test \#{args_to_string args}"
end

def_command :lint, 'Run style-checking tools' do |files|
  lint_ruby files  # uses rubocop
  lint_javascript Dir.pwd, files  # uses node_modules/eslint
end

END_STANDARD_DEV_COMMANDS
    end
    # rubocop:enable MethodLength

    def self.end
      "execute_command ARGV\n"
    end
  end
end

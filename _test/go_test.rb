# @author Mike Bland (michael.bland@gsa.gov)

require_relative 'test_helper'
require_relative '../lib/go_script/go'

require 'minitest/autorun'
require 'stringio'

module GoScript
  class ModuleTest < ::Minitest::Test
    include GoScript

    def self.command_group
      @command_group ||= CommandGroup.add_group 'Test commands'
    end

    def test_exec_cmd
      exec_cmd 'test -n "this is not an empty string"'
    end

    def test_exec_cmd_exits_on_failure
      assert_raises(SystemExit) do
        exec_cmd 'test -z "this is not an empty string"'
      end
    end

    def test_def_command
      result = nil
      def_command :test_cmd, ModuleTest.command_group, 'Test command' do |args|
        result = args.join ' '
      end
      test_cmd %w(test cmd args)
      assert_equal 'test cmd args', result
    end

    def test_execute_command
      result = nil
      def_command(:test_cmd2, ModuleTest.command_group,
        'Second test command') do |moar, args|
        result = [moar, args]
      end
      execute_command %w(test_cmd2 moar args)
      assert_equal %w(moar args), result
    end

    def test_execute_command_fail_with_usage_message_if_command_is_nil
      orig_stderr, $stderr = $stderr, StringIO.new
      # Ensure the 'Test commands' group exists
      ModuleTest.command_group
      exception = assert_raises(SystemExit) { execute_command [] }
      assert_equal 1, exception.status
      assert $stderr.string.start_with? "Usage: #{$PROGRAM_NAME}"
      assert_includes $stderr.string, 'Test commands'
    ensure
      $stderr = orig_stderr
    end

    def test_execute_command_show_usage_message_when_help_option_specified
      orig_stdout, $stdout = $stdout, StringIO.new
      # Ensure the 'Test commands' group exists
      ModuleTest.command_group
      exception = assert_raises(SystemExit) { execute_command %w(-h) }
      assert_equal 0, exception.status
      assert $stdout.string.start_with? "Usage: #{$PROGRAM_NAME}"
      assert_includes $stdout.string, 'Test commands'
    ensure
      $stdout = orig_stdout
    end
  end
end

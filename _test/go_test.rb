# @author Mike Bland (michael.bland@gsa.gov)

require_relative 'test_helper'
require_relative '../lib/go_script/go'

require 'minitest/autorun'
require 'stringio'

module GoScript
  class ModuleTest < ::Minitest::Test
    attr_accessor :command_group

    def setup
      extend GoScript
      @command_group = CommandGroup.add_group 'Test commands'
    end

    def teardown
      CommandGroup.groups.pop
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
      def_command :test_cmd, command_group, 'Test command' do
        result = 'success'
      end
      test_cmd
      assert_equal 'success', result
    end

    def test_invoke_command_with_optional_argument
      result = nil
      def_command(:test_cmd, command_group,
        'Test command') do |optional_argv = []|
        result = 'success ' + optional_argv.join(' ')
      end
      test_cmd %w(foo bar)
      assert_equal 'success foo bar', result
    end

    def test_invoke_command_without_optional_argument
      result = nil
      def_command(:test_cmd, command_group,
        'Test command') do |optional_argv = []|
        result = 'success ' + optional_argv.join(' ')
      end
      test_cmd
      assert_equal 'success ', result
    end

    def test_execute_command
      result = nil
      def_command :test_cmd, command_group, 'Test command' do |moar, args|
        result = [moar, args]
      end
      execute_command %w(test_cmd moar args)
      assert_equal %w(moar args), result
    end

    def test_execute_command_fail_with_usage_message_if_command_is_nil
      orig_stderr, $stderr = $stderr, StringIO.new
      exception = assert_raises(SystemExit) { execute_command [] }
      assert_equal 1, exception.status
      assert $stderr.string.start_with? "Usage: #{$PROGRAM_NAME}"
      assert_includes $stderr.string, 'Test commands'
    ensure
      $stderr = orig_stderr
    end

    def test_execute_command_show_usage_message_when_help_option_specified
      orig_stdout, $stdout = $stdout, StringIO.new
      exception = assert_raises(SystemExit) { execute_command %w(-h) }
      assert_equal 0, exception.status
      assert $stdout.string.start_with? "Usage: #{$PROGRAM_NAME}"
      assert_includes $stdout.string, 'Test commands'
    ensure
      $stdout = orig_stdout
    end
  end
end

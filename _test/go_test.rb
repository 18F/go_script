# @author Mike Bland (michael.bland@gsa.gov)

require_relative 'test_helper'
require_relative '../lib/go_script/go'
require_relative '../lib/go_script/command_group'

require 'minitest/autorun'
require 'stringio'

module GoScript
  class ModuleTest < ::Minitest::Test
    def setup
      extend GoScript
      command_group :test, 'Test commands'
    end

    def teardown
      CommandGroup.groups.delete :test
    end

    def test_exec_cmd
      exec_cmd 'test -n "this is not an empty string"'
    end

    def test_exec_cmd_exits_on_failure
      assert_raises(SystemExit) do
        exec_cmd 'test -z "this is not an empty string"'
      end
    end

    def test_command_group_aborts_if_defined_a_second_time
      orig_stderr, $stderr = $stderr, StringIO.new
      exception = assert_raises(SystemExit) do
        command_group :test, 'Test commands'
      end
      assert_equal 1, exception.status
      assert_includes $stderr.string, 'Command group "test" already defined at'
    ensure
      $stderr = orig_stderr
    end

    def test_def_command
      result = nil
      def_command :test_cmd, 'Test command' do
        result = 'success'
      end
      test_cmd
      assert_equal 'success', result
    end

    def test_invoke_command_with_optional_argument
      result = nil
      def_command :test_cmd, 'Test command' do |optional_argv = []|
        result = 'success ' + optional_argv.join(' ')
      end
      test_cmd %w(foo bar)
      assert_equal 'success foo bar', result
    end

    def test_invoke_command_without_optional_argument
      result = nil
      def_command :test_cmd, 'Test command' do |optional_argv = []|
        result = 'success ' + optional_argv.join(' ')
      end
      test_cmd
      assert_equal 'success ', result
    end

    def test_execute_command
      result = nil
      def_command :test_cmd, 'Test command' do |moar, args|
        result = [moar, args]
      end
      execute_command %w(test_cmd moar args)
      assert_equal %w(moar args), result
    end

    def test_def_command_aborts_if_defined_a_second_time
      def_command(:conflict, 'Conflicting command') {}
      orig_stderr, $stderr = $stderr, StringIO.new
      command_group :test_group_2, 'Commands should conflict across groups'
      exception = assert_raises(SystemExit) do
        def_command(:conflict, 'Conflicting instance') {}
      end
      assert_equal 1, exception.status
      assert_includes $stderr.string, 'Command "conflict" already defined at'
    ensure
      $stderr = orig_stderr
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

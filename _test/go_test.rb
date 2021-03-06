# @author Mike Bland (michael.bland@gsa.gov)

require_relative 'test_helper'
require_relative '../lib/go_script/go'
require_relative '../lib/go_script/command_group'

require 'minitest/autorun'
require 'stringio'

module GoScript
  class ModuleTest < ::Minitest::Test
    TEST_DIR = File.dirname(__FILE__).freeze

    def setup
      extend GoScript
      command_group :test, 'Test commands'
    end

    def teardown
      CommandGroup.groups.delete :test
    end

    def test_exec_cmd
      exec_cmd "ruby \"#{File.join(TEST_DIR, 'exit_success.rb')}\""
    end

    def test_exec_cmd_exits_on_failure
      assert_raises(SystemExit) do
        exec_cmd "ruby \"#{File.join(TEST_DIR, 'exit_failure.rb')}\""
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

    def test_execute_command_show_unknown_command_message
      orig_stderr, $stderr = $stderr, StringIO.new
      exception = assert_raises(SystemExit) { execute_command %w(do_foo) }
      assert_equal 1, exception.status
      assert $stderr.string.start_with? 'Unknown option or command: do_foo'
      assert_includes $stderr.string, "Usage: #{$PROGRAM_NAME}"
      assert_includes $stderr.string, 'Test commands'
    ensure
      $stderr = orig_stderr
    end
  end

  class UtilityTest < ::Minitest::Test
    def setup
      extend GoScript
    end

    def test_args_to_string_from_nil
      assert_equal '', args_to_string(nil)
    end

    def test_args_to_string_from_empty_array
      assert_equal '', args_to_string([])
    end

    def test_args_to_string_from_array
      assert_equal 'foo bar baz', args_to_string(%w(foo bar baz))
    end

    def test_args_to_string_from_string
      assert_equal 'foo bar baz', args_to_string('foo bar baz')
    end

    def test_file_args_by_extension_from_nil
      assert_equal '', file_args_by_extension(nil, nil)
    end

    def test_file_args_by_extension_from_string
      assert_equal 'foo bar baz', file_args_by_extension('foo bar baz', nil)
    end

    def test_file_args_by_extension_from_empty_array
      assert_equal '', file_args_by_extension([], nil)
    end

    def test_file_args_by_extension_from_array
      files = %w(quux.js foo.rb xyzzy.py bar.rb plugh.go baz.rb)
      assert_equal 'foo.rb bar.rb baz.rb', file_args_by_extension(files, '.rb')
    end
  end
end

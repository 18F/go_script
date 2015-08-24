# @author Mike Bland (michael.bland@gsa.gov)

require_relative 'test_helper'
require_relative '../lib/go_script/go'

require 'minitest/autorun'
require 'stringio'

module GoScript
  class VersionTest < ::Minitest::Test
    def setup
      extend GoScript
    end

    def test_current_version_ok
      check_ruby_version RUBY_VERSION
    end

    def test_current_version_fails
      orig_stderr, $stderr = $stderr, StringIO.new
      exception = assert_raises(SystemExit) do
        check_ruby_version "#{RUBY_VERSION}.1"
      end

      assert_equal 1, exception.status
      assert_includes($stderr.string,
        "Ruby version #{RUBY_VERSION}.1 or greater is required")
    ensure
      $stderr = orig_stderr
    end
  end
end

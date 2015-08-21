# @author Mike Bland (michael.bland@gsa.gov)

require_relative 'test_helper'
require_relative '../lib/go_script/version'

require 'minitest/autorun'
require 'stringio'

module GoScript
  class VersionTest < ::Minitest::Test
    def test_current_version_ok
      Version.check_ruby_version RUBY_VERSION
    end

    def test_current_version_fails
      orig_stderr, $stderr = $stderr, StringIO.new
      assert_raises(SystemExit) do
        Version.check_ruby_version "#{RUBY_VERSION}.1"
      end
      assert_includes($stderr.string,
        "Ruby version #{RUBY_VERSION}.1 or greater is required")
    ensure
      $stderr = orig_stderr
    end
  end
end

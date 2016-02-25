require_relative 'test_helper'
require_relative '../lib/go_script'

require 'fileutils'
require 'minitest/autorun'

module GoScript
  class BundleTest < ::Minitest::Test
    attr_reader :testdir, :go_script, :gemfile, :this_gem, :env

    def setup
      @testdir = Dir.mktmpdir
      @go_script = File.join(testdir, 'go')
      @gemfile = File.join(testdir, 'Gemfile')
      @this_gem = File.dirname(File.dirname(__FILE__))
      @env = {
        'BUNDLE_BIN_PATH' => nil,
        'BUNDLE_GEMFILE' => nil,
        'RUBYOPT' => nil,
      }

      File.write(gemfile, [
        'source \'https://rubygems.org\'',
        'gem \'jekyll\'',
        "gem 'go_script', path: '#{this_gem}'\n",
      ].join("\n"))
    end

    def teardown
      FileUtils.remove_entry(testdir)
    end

    def create_script(commands)
      open(go_script, 'w') do |script|
        script.puts(GoScript::Template.preamble)
        script.puts(commands)
        script.puts(GoScript::Template.end)
      end
      FileUtils.chmod(0700, go_script)
    end

    def create_jekyll_script
      create_script([
        'command_group :dev, \'Development commands\'',
        'def_command :build, \'Build the site\' do |args|',
        '  build_jekyll(args)',
        'end',
      ].join("\n"))
    end

    def test_create_script
      create_script('')
      assert(system(env, go_script, '-h', out: '/dev/null'))
    end

    def test_bundler
      create_jekyll_script
      assert(system(env, go_script, 'build', '--help', out: '/dev/null'))
    end

    def test_bundler_with_path_argument
      system(env, "cd #{testdir} && bundle install --path=vendor/bundle")
      create_jekyll_script
      assert(system(env, go_script, 'build', '--help'))
    end
  end
end

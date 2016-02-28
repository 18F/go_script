require_relative 'test_helper'
require_relative '../lib/go_script'

require 'fileutils'
require 'minitest/autorun'

module GoScript
  class BundleTest < ::Minitest::Test
    TEST_SOURCE_DIR = File.dirname(__FILE__)

    attr_reader :testdir, :go_script, :gemfile, :this_gem, :env

    # rubocop:disable MethodLength
    def setup
      @testdir = Dir.mktmpdir
      FileUtils.cp_r(File.join(TEST_SOURCE_DIR, 'test-site', '.'), testdir)
      @go_script = File.join(testdir, 'go')
      @gemfile = File.join(testdir, 'Gemfile')
      @this_gem = File.dirname(TEST_SOURCE_DIR)
      @env = {
        'BUNDLE_BIN_PATH' => nil,
        'BUNDLE_GEMFILE' => nil,
        'RUBYOPT' => nil,
      }

      File.write(gemfile, [
        'source \'https://rubygems.org\'',
        'gem \'jekyll\'',
        'group :jekyll_plugins do',
        '  gem \'guides_style_18f\'',
        'end',
        "gem 'go_script', path: '#{this_gem}'\n",
      ].join("\n"))
    end
    # rubocop:enable MethodLength

    def teardown
      FileUtils.rm_rf(testdir, secure: true)
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

    def exec_go_script(arg, **options)
      if ENV['COMSPEC']
        system(env, "ruby #{go_script} #{arg}")
      else
        system(env, go_script, arg, options)
      end
    end

    def test_create_script
      create_script('')
      assert(File.exist?(go_script), "#{go_script} does not exist")
      assert(exec_go_script('-h', out: '/dev/null'))
    end

    def test_bundler
      create_jekyll_script
      assert(exec_go_script('build'))
    end

    def test_bundler_with_path_argument
      system(env, "cd #{testdir} && bundle install --path=vendor/bundle")
      create_jekyll_script
      assert(exec_go_script('build'))
    end
  end
end

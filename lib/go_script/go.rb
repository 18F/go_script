# Author: Mike Bland <michael.bland@gsa.gov>

require_relative './command_group'
require_relative './version'
require 'English'

module GoScript
  def check_ruby_version(min_version)
    Version.check_ruby_version min_version
  end

  def def_command(id, command_group, description, &command_block)
    abort "Command ID must be a symbol: #{id}" unless id.instance_of? Symbol
    self.class.send :define_method, id, ->(argv) { command_block.call argv }
    command_group.commands[id] = description
  end

  def execute_command(argv)
    command = argv.shift
    CommandGroup.usage exitstatus: 1 if command.nil?
    CommandGroup.usage if ['-h', '--help', '-help', 'help'].include? command
    send version if ['-v', '--version', 'version'].include? command
    send CommandGroup.command(command.to_sym), argv
  end

  def version
    puts "go_script version #{VERSION}"
    exit 0
  end

  def exec_cmd(cmd)
    exit $CHILD_STATUS.exitstatus unless system cmd
  end

  def install_bundle
    begin
      require 'bundler'
    rescue LoadError
      puts 'Installing Bundler gem...'
      exec_cmd 'gem install bundler'
      puts 'Bundler installed; installing gems'
    end
    exec_cmd 'bundle install'
  end

  def update_gems(gems)
    exec_cmd "bundle update #{gems}"
    exec_cmd 'git add Gemfile.lock'
  end

  def update_node_modules
    abort 'Install npm to update JavaScript components: ' \
      'http://nodejs.org/download/' unless system 'which npm > /dev/null'

    exec_cmd 'npm update'
    exec_cmd 'npm install'
  end

  JEKYLL_BUILD_CMD = 'bundle exec jekyll build --trace'
  JEKYLL_SERVE_CMD = 'bundle exec jekyll serve -w --trace'

  def serve_jekyll(extra_args)
    exec "#{JEKYLL_SERVE_CMD} #{extra_args}"
  end

  def build_jekyll(extra_args)
    exec_cmd "#{JEKYLL_BUILD_CMD} #{extra_args}"
  end

  def git_sync_and_deploy(commands)
    exec_cmd 'git stash'
    exec_cmd 'git pull'
    commands.each { |command| exec_cmd command }
  end

  def lint_ruby(files)
    files ||= []
    exec_cmd "bundle exec rubocop #{files.join ' '}"
  end

  def lint_javascript(basedir, files)
    files ||= []
    exec_cmd "#{basedir}/node_modules/jshint/bin/jshint #{files.join ' '}"
  end
end

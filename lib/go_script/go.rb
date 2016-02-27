# Author: Mike Bland <michael.bland@gsa.gov>

require_relative './command_group'
require_relative './version'
require 'English'

module GoScript
  attr_reader :current_group

  def check_ruby_version(min_version)
    Version.check_ruby_version min_version
  end

  def command_group(group_symbol, description)
    location = caller_locations(1, 1).first
    CommandGroup.add_group(group_symbol, description,
      location.path, location.lineno)
    @current_group = group_symbol
  end

  def def_command(id, description, &command_block)
    abort "#{$PROGRAM_NAME}: No command_groups defined" unless current_group
    abort "Command ID must be a symbol: #{id}" unless id.instance_of? Symbol
    self.class.send :define_method, id, ->(*argv) { command_block.call(*argv) }
    path, lineno = command_block.source_location
    CommandGroup.add_command id, @current_group, description, path, lineno
  end

  def execute_command(argv)
    command = argv.shift
    CommandGroup.usage exitstatus: 1 if command.nil?
    CommandGroup.usage if ['-h', '--help', '-help', 'help'].include? command
    send :version if ['-v', '--version', 'version'].include? command
    send CommandGroup.command(command.to_sym), argv
  end

  def version
    puts "go_script version #{VERSION}"
    exit 0
  end

  def exec_cmd(cmd)
    env = {}.merge(ENV)
    env.delete('RUBYOPT')
    status = system(env, cmd, err: :out)
    if $CHILD_STATUS.exitstatus.nil?
      $stderr.puts "could not run command: #{cmd}"
      $stderr.puts '(Check syslog for possible `Out of memory` error?)'
      exit 1
    else
      exit $CHILD_STATUS.exitstatus unless status
    end
  end

  def update_gems(gems = '')
    exec_cmd "bundle update #{args_to_string gems}"
    exec_cmd 'git add Gemfile.lock'
  end

  def update_node_modules
    abort 'Install npm to update JavaScript components: ' \
      'http://nodejs.org/download/' unless system 'which npm > /dev/null'

    exec_cmd 'npm update'
    exec_cmd 'npm install'
  end

  JEKYLL_BUILD_CMD = 'jekyll build --trace'
  JEKYLL_SERVE_CMD = 'jekyll serve -w --trace'

  def args_to_string(args)
    args ||= ''
    (args.instance_of? Array) ? args.join(' ') : args
  end

  def file_args_by_extension(file_args, extension)
    if file_args.instance_of? Array
      files_by_extension = file_args.group_by { |f| File.extname f }
      args_to_string files_by_extension[extension]
    else
      args_to_string file_args
    end
  end

  def serve_jekyll(extra_args = '')
    exec "#{JEKYLL_SERVE_CMD} #{args_to_string extra_args}"
  end

  def build_jekyll(extra_args = '')
    exec_cmd "#{JEKYLL_BUILD_CMD} #{args_to_string extra_args}"
  end

  def git_sync_and_deploy(commands, branch: nil)
    exec_cmd 'git fetch origin #{branch}'
    exec_cmd 'git clean -f'
    exec_cmd "git reset --hard #{branch.nil? ? 'HEAD' : 'origin/' + branch}"
    exec_cmd 'git submodule --sync --recursive'
    exec_cmd 'git submodule update --init --recursive'
    commands.each { |command| exec_cmd command }
  end

  def lint_ruby(files)
    exec_cmd "rubocop #{file_args_by_extension files, '.rb'}"
  end

  def lint_javascript(basedir, files)
    files = file_args_by_extension files, '.js'
    exec_cmd "#{basedir}/node_modules/.bin/eslint #{files}"
  end
end

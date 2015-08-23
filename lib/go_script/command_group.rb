# Author: Mike Bland <michael.bland@gsa.gov>

require 'English'
require 'pathname'

module GoScript
  class Command
    attr_reader :description, :path, :lineno

    def initialize(description, path, lineno)
      @description = description
      @path = path
      @lineno = lineno
    end
  end

  # Groups a set of commands by common function.
  class CommandGroup
    attr_reader :description, :path, :lineno
    attr_accessor :commands
    private_class_method :new

    def initialize(description, path, lineno)
      @description = description
      @path = path
      @lineno = lineno
      @commands = {}
    end

    def to_s
      padding = (commands.keys.max_by(&:size) || '').size + 2
      command_descriptions = commands.map do |name, command|
        format "  %-#{padding}s#{command.description}", name
      end
      ["\n#{@description}"].concat(command_descriptions).join("\n")
    end

    def include_command?(command_symbol)
      commands.keys.include? command_symbol
    end

    class <<self
      def groups
        @groups ||= {}
      end

      def location_path(target_path)
        @base_path ||= Pathname.new(
          File.dirname(File.expand_path $PROGRAM_NAME))
        Pathname.new(File.expand_path target_path).relative_path_from @base_path
      end

      def check_not_defined(collection, label, key, path, lineno)
        return unless (existing = collection[key])
        previous = location_path existing.path
        current = location_path path
        prefix = previous == current ? 'line ' : previous + ':'
        abort "#{current}:#{lineno}: #{label} \"#{key}\" " \
          "already defined at #{prefix}#{existing.lineno}"
      end

      def add_group(group_symbol, description, path, lineno)
        check_not_defined groups, 'Command group', group_symbol, path, lineno
        groups[group_symbol] = new description, path, lineno
      end

      def command_defined?(command)
        groups.values.each { |g| return true if g.include_command? command }
      end

      def add_command(command, group_symbol, description, path, lineno)
        groups.values.each do |group|
          check_not_defined group.commands, 'Command', command, path, lineno
        end
        groups[group_symbol].commands[command] = Command.new(
          description, path, lineno)
      end

      def command(command_sym)
        return command_sym if command_defined? command_sym
        $stderr.puts "Unknown option or command: #{command_sym}"
        usage exitstatus: 1
      end

      def usage(exitstatus: 0)
        output_stream = exitstatus == 0 ? $stdout : $stderr
        output_stream.puts <<END_OF_USAGE
Usage: #{$PROGRAM_NAME} [option|command] [optional command arguments...]

options:
  -h,--help     Show this help
  -v,--version  Show the version of the go_script gem
END_OF_USAGE
        (groups.values || []).each { |group| output_stream.puts group }
        exit exitstatus
      end
    end
  end
end

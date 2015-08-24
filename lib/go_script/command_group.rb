# Author: Mike Bland <michael.bland@gsa.gov>

module GoScript
  # Groups a set of commands by common function.
  class CommandGroup
    attr_accessor :description, :commands
    private_class_method :new

    # @param description [String] short description of the group
    def initialize(description)
      @description = description
      @commands = {}
    end

    def to_s
      padding = (commands.keys.max_by(&:size) || '').size + 2
      command_descriptions = commands.map do |name, desc|
        format "  %-#{padding}s#{desc}", name
      end
      ["\n#{@description}"].concat(command_descriptions).join("\n")
    end

    class <<self
      attr_accessor :groups
      def add_group(description)
        (@groups ||= []).push(new(description)).last
      end

      def command(command_sym)
        if (groups || []).flat_map { |g| g.commands.keys }.include? command_sym
          return command_sym
        end
        puts "Unknown option or command: #{command_sym}"
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
        (groups || []).each { |group| output_stream.puts group }
        exit exitstatus
      end
    end
  end
end

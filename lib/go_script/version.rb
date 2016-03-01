# @author Mike Bland (michael.bland@gsa.gov)

module GoScript
  VERSION = '0.1.9'

  class Version
    def self.check_ruby_version(min_version)
      unless RUBY_VERSION >= min_version
        abort <<END_OF_ABORT_MESSAGE

*** ABORTING: Unsupported Ruby version ***

Ruby version #{min_version} or greater is required, but this Ruby is version
#{RUBY_VERSION}. Consider using a version manager such as rbenv
(https://github.com/sstephenson/rbenv) or rvm (https://rvm.io/) to install a
Ruby version specifically for development.

END_OF_ABORT_MESSAGE
      end
    end
  end
end

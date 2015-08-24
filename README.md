## The `./go` script: a unified development environment interface.

A `./go` script aims to abstract away all of the steps needed to develop (and
sometimes deploy) a software project. It is a replacement for READMEs and
other documents that may become out-of-date, and when maintained properly,
should provide a cohesive and discoverable interface for common project tasks.

This gem abstracts common functionality used in the Ruby-based `./go` scripts
of several 18F projects, and provides a `./go` script generator for new
projects.

This gem was inspired by the blog articles [In Praise of the ./go Script -
Part I](http://www.thoughtworks.com/insights/blog/praise-go-script-part-i) and
[In Praise of the ./go Script - Part
II](http://www.thoughtworks.com/insights/blog/praise-go-script-part-ii) by
Pete Hodgson.

**Note:** Not to be confused with the [Go programming
language](https://golang.org). This convention is completely unrelated,
though it does bear a great deal of resemblance to the Go language's `go`
command.

### Everyone: install Ruby

Install [the Ruby programming language](https://www.ruby-lang.org/) if it
isn't already present on your system. We recommend using a Ruby version
manager such as [rbenv](https://github.com/sstephenson/rbenv) or
[rvm](https://rvm.io/) to do this.

### Project authors: creating a `./go` script

Install the `go_script` gem via `gem install go_script`.

To ensure version consistency for all developers, install
[Bundler](http://bundler.io/) via `gem install bundler` and add `gem
'go_script'` to your project's [`Gemfile`](http://bundler.io/gemfile.html).

To create a fresh new `./go` script for your project, run:

```shell
$ cd path/to/the/project/repository

$ go-script-template > ./go

# Alternately, if you installed go_script using Bundler:
$ bundle exec go-script-template > ./go

# Make the script executable:
$ chmod 700 ./go
```

As a bonus, if the project only needs to initialize itself by installing Ruby
gems from a `Gemfile`, there is no need to define an `init` command. The
`./go` script will automatically install Bundler and run `bundle install`.

### Project contributors: bootstrapping

If the project already has a `./go` script, you do not need to install
anything first other than Ruby. Just run the `./go` script. It will
automatically install the `go_script` gem, either via Bundler (if a `Gemfile`
is present) or directly using `gem install`.

### Listing commands

To see the list of available commands for a script: run `./go help` (or one of
the common variations thereon, such as `./go -h` or `./go --help`). For
example, the output of `./go help` for this repository's `./go` script is:

```
Usage: ./go [option|command] [optional command arguments...]

options:
  -h,--help     Show this help
  -v,--version  Show the version of the go_script gem

Development commands
  update_gems  Update Ruby gems
  test         Execute automated tests
  lint         Run style-checking tools
  ci_build     Execute continuous integration build
  release      Test, build, and release a new gem
```

### Defining commands

The `def_command` directive defines the individual `./go` commands that
comprise the `./go` script interface. Its arguments are:

- *id*: A [Ruby symbol](http://ruby-doc.org/core-2.2.3/Symbol.html)
  (basically, a string starting with `:` with no quotes around it) defining
  the name of the command.
- *description*: A very brief description of the command that appears in the
  usage text.

These `def_command` definitions often use the `exec_cmd` directive
that runs a shell command and exits on error. There are also additional
directives from [`lib/go_script/go.rb`](lib/go_script/go.rb) that may be used
to define commands, and commands may be built up from other commands defined
in the `./go` script itself.

**Note:** Command names must be unique. Defining a command with a name already
used elsewhere will cause the `./go` script to exit with an error message.

#### Command groups

Each `command_group` invocation marks the beginning of a set of related
commands. These groupings organize how commands are displayed in the
help/usage message.

`go-script-template` generates a default `command_group` called `:dev`. You
are free to edit this definition, or to add additional `command_group`
definitions.

**Note:** Command group names must be unique, and command groups cannot be
re-opened after their initial definition. Defining a command group with a name
already used elsewhere will cause the `./go` script to exit with an error
message.

Also, command names must be unique across all command groups. Defining a
command with the same name as that in another command group will also cause
the `./go` script to exit with an error message.

#### Command arguments

Commands may take command-line arguments, which are passed in as block
variables. In the following example, the `./go init` command takes no
arguments, and the `./go test` command takes an argument list that is appended
as additional command line arguments to `rake test`. For example, `./go test`
runs `bundle exec rake test` without any further arguments, while running
`./go test TEST=_test/go_test.rb` ultimately runs `bundle exec rake test
TEST=_test/go_test.rb`.

```ruby
command_group :dev, 'Development commands'

def_command :init, 'Set up the development environment' do
end

def_command :test, 'Execute automated tests' do |args = []|
  exec_cmd "bundle exec rake test #{args.join ' '}"
end
```

Command blocks may take more than one parameter, corresponding to a specific
number of additional command line arguments for a specific command.

### Contributing

1. Fork the repo (or just clone it if you're an 18F team member)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Feel free to ping [@mbland](https://github.com/mbland) with any questions you
may have, especially if the current documentation should've addressed your
needs, but didn't.

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in
[CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright
> and related rights in the work worldwide are waived through the
> [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication.
> By submitting a pull request, you are agreeing to comply with this waiver of
> copyright interest.

# -*- coding: utf-8 -*-
require "base_script/version"

# A base class for implementing CLI scripts.
# ARGV and in/out IO's are injected, so can be mocked & tested.
# Basic signal handling by calling exit_on_signals inside work loops etc.
# Requires Ruby 2.0.0+ for keyword args etc.
class BaseScript

  EXIT_SUCCESS = 0
  INDENT = "  "

  def initialize(argv, stdin: $stdin, stdout: $stdout, stderr: $stderr)
    @argv = argv

    @input = stdin
    @output = stdout
    @error_output = stderr
    sync_io!

    @indentation = 0
  end

  private

  # I/O
  attr_reader :input
  attr_reader :output
  attr_reader :error_output

  # Set I/O streams as unbuffered if they support it.
  def sync_io!
    [input, output, error_output].each do |io|
      io.sync = true if io.respond_to?(:sync=)
    end
  end

  ##
  # Argument handling.

  def args
    @_args ||= @argv.reduce({}) do |memo, argument|
      key, value = argument.split("=", 2)
      option = key.gsub(/\A-+/, "") # strip leading hyphens.
      memo[option] = value || true # store as true for value-less options.
      memo
    end
  end

  # Fetch a --key or --key=value argument.
  # Returns the provided default if not set.
  def arg(key, default = nil)
    args.fetch(key.to_s, default)
  end

  # Like #arg, but raises KeyError if missing.
  def arg!(key)
    args.fetch(key.to_s) do
      raise KeyError, "--#{key} argument required"
    end
  end

  def verbose?; arg("v") end

  ##
  # Logging.

  def log(message)
    message += "\n" unless message[-1] == ?\n
    output << indent_string(message)
  end

  def vlog(message)
    log(message) if verbose?
  end

  def indented
    @indentation += 1
    yield
  ensure
    @indentation -= 1
  end

  def indent_string(content)
    spaces = INDENT * @indentation
    content.each_line.map {|line| "#{spaces}#{line}" }.join
  end

  # Colorize text if output is a tty.
  def colorize(text, code)
    if output.respond_to?(:tty?) && output.tty?
      "\033[#{code}m#{text}\033[0m"
    else
      text
    end
  end

  # A green tick.
  def tick; colorize("✔", 32) end

  # A red cross.
  def cross; colorize("✘", 31) end

  ##
  # Signal handling.

  # Call this method prior to doing work inside a loop.
  # Alternatively, call at start of script to install handlers, and
  # then at safe-exit points throughout script.
  # Don't set up signal handlers (first call) and then fail to call again.
  def exit_on_signals
    install_signal_handlers unless defined?(@_signal)

    if @_signal
      log "Exiting due to SIG#{@_signal}"
      exit(1)
    end
  end

  def install_signal_handlers
    @_signal = nil
    @_previous_signal_handlers = {}
    %w{INT TERM}.each do |signal|
      log "Installing #{signal} handler" if verbose?
      @_previous_signal_handlers[signal] = Signal.trap(signal) do
        log "Received SIG#{signal}, will exit at next opportunity"
        @_signal = signal
        Signal.trap(signal, @_previous_signal_handlers[signal])
      end
    end
  end

  ##
  # Dry run support

  def dry?; arg("dry-run") end

  # Execute block unless dry run
  def unless_dry_run(message)
    if dry?
      log "Skipping #{message} due to dry run"
    else
      yield
    end
  end

end

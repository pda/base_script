# BaseScript

Small base for CLI scripts; signal handling, indented logging, colors
ticks/crosses, injectable args/IO.

It was kicking around the `lib/` directory of various Rails projects I've
built. Now it's a gem with a [version number][semver].


## Installation

With bundler:

    $ echo 'gem "base_script"' >> Gemfile
    $ bundle

Manually:

    $ gem install base_script

## Usage

```ruby
require "base_script"

class HelloScript < BaseScript

  def run
    if arg("lunar")
      log "hello moon"
    else
      log "hello world"
    end

    log "Doing some work, ctrl-c to cleanly interrupt.."
    indented do
      100.times do |i|
        exit_on_signals
        vlog "Step #{i}"
        do_some_work() unless dry?
      end
    end
  end

end
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/base_script/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Author: [Paul Annesley][pda]


[semver]: http://semver.org/
[pda]: https://twitter.com/pda

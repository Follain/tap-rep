tap-rep
========

## A [singer.io](http://singer.io) tap to extract data from [Rep](http://rep.ai) and load into any Singer target, like Stitch or CSV

# Configuration

    {
      "token":"bearer-token-from-rep"
    }

# Usage (with [Stitch target](https://github.com/singer-io/target-stitch))

    > bundle exec tap-rep
    Usage: tap-rep [options]
        -c, --config config_file         Set config file (json)
        -s, --state state_file           Set state file (json)
        -h, --help                       Displays help
        -v, --verbose                    Enables verbose logging to STDERR

    > pip install target-stitch
    > gem install tap-rep
    > bundle exec tap-rep -c config.rep.json -s state.json | target-stitch --config config.stitch.json | tail -1 > state.new.json

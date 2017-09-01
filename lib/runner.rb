# frozen_string_literal: true

require 'concurrent'
require 'optparse'

require_relative 'client'
require_relative 'schema'
require_relative 'models/base'
require_relative 'models/session'

module TapRep
  # Kicks off tap-rep process
  class Runner
    attr_reader :config_filename
    attr_reader :state_filename
    attr_reader :stream
    attr_reader :verbose

    def initialize(argv, stream: $stderr, config: nil, state: nil)
      @stream = stream
      @config = config
      @state = state
      parser.parse! argv
    end

    def perform
      return stream.puts(parser) if config.keys.empty?
      output_schemata
      process_models
    end

    def config
      @config ||= read_json(config_filename)
    end

    def state
      @state ||= read_json(state_filename)
    end

    private

    def output_schemata
      TapRep::Models::Base.subclasses.each do |model|
        client.output model.schema
      end
    end

    def process_models
      TapRep::Models::Base.subclasses.each do |model|
        client.process model
      end
    end

    def client
      @client ||= TapRep::Client.new(
        token: config['token'],
        verbose: verbose,
        state: Concurrent::Hash.new.merge!(state_minus_3_days),
        stream: stream
      )
    end

    # Per Rep, include a "buffer" when we kick off our process
    # In other words, end_time != session modification time. As a result, just
    # maintaining a high watermark has the potential to miss certain sessions,
    # and the probability of missing sessions increases if there's a big gap
    # between the time of last message in the session and the time it is closed
    # out by an agent (like, on weekends).
    #
    # For example, if you most recently queried all sessions up until time T1,
    # then set start_time to T1 - 3 days on the next run (and dedupe sessions
    # based on encrypted_id, which is guaranteed to be unique). This should
    # account for sessions that happened over the weekend, etc.
    def state_minus_3_days
      return state unless state['sessions']
      state.merge(
        'sessions' => DateTime.parse(state['sessions']).prev_day(3).iso8601
      )
    end

    def read_json(filename)
      return JSON.parse(File.read(filename)) if filename
      {}
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
        opts.on('-c', '--config filename', 'Set config file (json)') do |config|
          @config_filename = config
        end

        opts.on('-s', '--state filename', 'Set state file (json)') do |state|
          @state_filename = state
        end

        opts.on('-v', '--verbose', 'Enables verbose logging to STDERR') do
          @verbose = true
        end
      end
    end
  end
end

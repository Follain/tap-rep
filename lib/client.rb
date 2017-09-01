# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'json'
require 'logger'

module TapRep
  DEFAULT_START_TIME = '0001-01-01T00:00:00+00:00'
  LIMIT = 50
  BASE_URL = 'https://app.rep.ai'

  # rubocop:disable Metrics/BlockLength
  Client = Struct.new(:token, :verbose, :state, :stream) do
    def initialize(**kwargs)
      super(*members.map { |k| kwargs[k] })
    end

    def process(model)
      records = get(model)
      return unless records.any?

      output_records model, records
      output_state model, records.last['end_time']
      process model
    end

    def output(hash)
      stream.puts JSON.generate(hash)
    end

    private

    def output_records(model, records)
      records.each do |record|
        model.new(record, self).records.flatten.each do |model_record|
          output model_record
        end
      end
    end

    def output_state(model, value)
      state[model.stream] = value
      output type: :STATE, value: state
    end

    def get(model)
      start_time = state[model.stream] || DEFAULT_START_TIME

      Array(
        connection.get(
          "/api/v1.0/reporting/#{model.path}",
          start_time: start_time,
          limit: LIMIT
        ).body
      )
    end

    def connection
      @connection ||= Faraday::Connection.new do |conn|
        conn.authorization :Bearer, token
        conn.headers['Accept-Encoding'] = 'application/json'
        conn.response :json
        conn.url_prefix = BASE_URL
        conn.response :logger, ::Logger.new(STDERR), bodies: true if verbose
        conn.adapter Faraday.default_adapter
      end
    end
  end
end


# frozen_string_literal: true

require './lib/client'
require './lib/models/session'

RSpec.describe TapRep::Client do
  let(:verbose) { false }
  let(:state) { {} }
  let(:token) { 'rep-ai-token' }
  let(:stream) { StringIO.new }

  let(:client) do
    described_class.new token: token, verbose: verbose,
                        state: state, stream: stream
  end

  describe 'initialize' do
    it 'sets token, verbose, state, stream' do
      expect(client.token).to eq token
      expect(client.verbose).to eq verbose
      expect(client.state).to eq state
      expect(client.stream).to eq stream
    end
  end

  describe '#output' do
    it 'serializes JSON of the hash to its stream' do
      client.output foo: 1
      client.output bar: 2

      expect(stream.string)
        .to eq "#{JSON.generate(foo: 1)}\n#{JSON.generate(bar: 2)}\n"
    end
  end

  describe '#process' do
    let(:pages) do
      Array.new(3) do |page|
        Array.new(3) do |record|
          {
            encrypted_id: "00#{page}-00#{record}",
            end_time: "end-time-00#{page}-00#{record}"
          }
        end
      end
    end

    before do
      stub_get_sessions TapRep::DEFAULT_START_TIME => pages[0],
                        pages[0].last[:end_time] => pages[1],
                        pages[1].last[:end_time] => []
    end

    it 'fetches all pages of sessions and outputs to its stream' do
      client.process(TapRep::Models::Session)

      outputs = stream.string.split.map { |line| JSON.parse(line) }
      expect(outputs.size).to eq 8

      expect(outputs[0]['type']).to eq 'RECORD'
      expect(outputs[0]['record']['encrypted_id']).to eq('000-000')

      expect(outputs[1]['type']).to eq 'RECORD'
      expect(outputs[1]['record']['encrypted_id']).to eq('000-001')

      expect(outputs[2]['type']).to eq 'RECORD'
      expect(outputs[2]['record']['encrypted_id']).to eq('000-002')

      expect(outputs[3]['type']).to eq 'STATE'
      expect(outputs[3]['value']).to eq 'sessions' => 'end-time-000-002'

      expect(outputs[4]['type']).to eq 'RECORD'
      expect(outputs[4]['record']['encrypted_id']).to eq('001-000')

      expect(outputs[5]['type']).to eq 'RECORD'
      expect(outputs[5]['record']['encrypted_id']).to eq('001-001')

      expect(outputs[6]['type']).to eq 'RECORD'
      expect(outputs[6]['record']['encrypted_id']).to eq('001-002')

      expect(outputs[7]['type']).to eq 'STATE'
      expect(outputs[7]['value']).to eq 'sessions' => 'end-time-001-002'
    end

    def stub_get_sessions(pages)
      url = 'https://app.rep.ai/api/v1.0/reporting/sessions'
      pages.each do |start_time, page|
        stub_request(:get, url)
          .with(
            headers: { 'Authorization' => "Bearer #{token}" },
            query: {
              limit: ::TapRep::LIMIT,
              start_time: start_time
            }
          )
          .to_return(status: 200, body: JSON.generate(page))
      end
    end
  end
end

# frozen_string_literal: true

require './lib/runner.rb'

RSpec.describe TapRep::Runner do
  let(:argv) { ['-c', config_filename,  '-s', state_filename, '--verbose'] }
  let(:config_filename) { 'config.json' }
  let(:state_filename) { 'state.json' }
  let(:stream) { StringIO.new }
  let(:config) { nil }
  let(:state) { nil }

  let(:runner) do
    TapRep::Runner.new argv, stream: stream, config: config, state: state
  end

  describe '#initialize' do
    it 'initializes a TapRep::Runner with the given argv' do
      expect(runner.config_filename).to eq config_filename
      expect(runner.state_filename).to eq state_filename
      expect(runner.verbose).to be true
    end
  end

  %i[config state].each do |attribute|
    describe "##{attribute}" do
      context "with no #{attribute} file" do
        let(:argv) { [] }
        it 'returns an empty hash' do
          expect(runner.send(attribute)).to eq({})
        end
      end

      context "with a #{attribute} file" do
        let(:hash) { { 'foo' => 1 } }

        let("#{attribute}_filename") { file.path }
        let(:file) do
          Tempfile.new("#{attribute}.json").tap do |file|
            file << JSON.generate(hash)
            file.close
          end
        end

        it "assigns the config file JSON contents to `#{attribute}`" do
          expect(runner.send(attribute)).to eq hash
        end
      end
    end
  end

  describe '#perform' do
    context 'with no config' do
      let(:argv) { [] }
      it 'prints usage info' do
        runner.perform
        expect(stream.string).to include('Usage:')
      end
    end

    context 'with config and state' do
      let(:config) { { 'token' => 'test-token' } }
      let(:state) { { 'sessions' => '2016-03-01T00:00:00+00:00' } }
      let(:state_minus_3_days) { { 'sessions' => '2016-02-27T00:00:00+00:00' } }
      let(:mock_client) do
        instance_double TapRep::Client, output: nil, process: nil
      end

      before do
        allow(TapRep::Client).to receive(:new).and_return mock_client
        runner.perform
      end

      it 'builds a client' do
        expect(TapRep::Client).to have_received(:new).once.with(
          token: 'test-token',
          verbose: true,
          state: state_minus_3_days,
          stream: stream
        )
      end

      it 'outputs a schema for Session records' do
        expect(mock_client).to have_received(:output)
          .with(TapRep::Models::Session.schema).once
      end

      it 'process records from the Session model' do
        expect(mock_client).to have_received(:process)
          .with(TapRep::Models::Session).once
      end
    end
  end
end

# frozen_string_literal: true

require './lib/models/session'

RSpec.describe TapRep::Models::Session do
  it { is_expected.to be_a TapRep::Models::Base }

  describe '#path' do
    subject(:path) { described_class.path }
    it { is_expected.to eq 'sessions' }
  end

  describe '#stream' do
    subject(:stream) { described_class.stream }
    it { is_expected.to eq 'sessions' }
  end

  describe '.schema' do
    subject(:schema) { described_class.schema }
    it { is_expected.to be_a Hash }

    it 'returns the correct model schema for a session' do
      expect(schema.dig :key_properties).to eq %i[encrypted_id]
      expect(schema.dig :stream).to eq 'sessions'
      expect(schema.dig :type).to eq :SCHEMA

      types = ::TapRep::Schema::Types

      properties = schema[:schema][:properties]
      expect(properties[:encrypted_id]).to eq types.string(:not_null)
      expect(properties[:first_customer_message_at]).to eq types.datetime
      expect(properties[:end_time]).to eq types.datetime
      expect(properties[:duration]).to eq types.number
      expect(properties[:responder]).to eq types.string
      expect(properties[:start_time]).to eq types.datetime
      expect(properties[:channel_name]).to eq types.string
      expect(properties[:customer]).to eq types.object
      expect(properties[:channel_type]).to eq types.string
      expect(properties[:categories]).to eq types.array
      expect(properties[:notes]).to eq types.string
      expect(properties[:first_agent_message_at]).to eq types.datetime
      expect(properties[:time_to_first_response]).to eq types.number
    end
  end
end

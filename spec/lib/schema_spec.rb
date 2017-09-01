# frozen_string_literal: true

require './lib/schema'

RSpec.describe TapRep::Schema::Types do
  %i[string number object array].each do |type|
    describe '##{type}' do
      it 'returns the correct hash' do
        expect(described_class.send type).to eq(type: [type, :null])
        expect(described_class.send type, :not_null).to eq(type: type)
      end
    end
  end

  describe '#datetime' do
    it 'returns the correct hash' do
      expect(described_class.datetime)
        .to eq(type: %i[string null], format: 'date-time')

      expect(described_class.datetime(:not_null))
        .to eq(type: :string, format: 'date-time')
    end
  end
end

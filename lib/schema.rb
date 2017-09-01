
# frozen_string_literal: true

module TapRep
  # Models a JSON Schema required for Singer taps
  class Schema
    attr_reader :stream, :key_property

    def initialize(stream, key_property)
      @stream = stream
      @key_property = key_property
    end

    # Models JSON Schema types
    class Types
      def self.method_missing(method, *args)
        return super unless %I[
          array
          number
          object
          string
        ].include?(method)

        types = [method.to_sym]
        types << :null unless args.include?(:not_null)

        {
          type: types.one? ? types.first : types
        }.tap do |hash|
          hash[:format] = 'date-time' if args.include?(:datetime)
        end
      end

      def self.respond_to_missing?(_method, *_args)
        true
      end

      def self.datetime(*args)
        args << :datetime
        string(*args)
      end
    end

    %i[string number array object datetime].each do |type|
      define_method type do |name, *options|
        properties[name.to_sym] = Types.send(type, *options)
      end
    end

    def properties
      @properties ||= {}
    end

    def to_hash
      {
        type: :SCHEMA,
        stream: stream,
        key_properties: [key_property],
        schema: {
          properties: properties
        }
      }
    end
  end
end

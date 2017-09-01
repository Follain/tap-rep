# frozen_string_literal: true

require 'active_support/inflector'
require_relative '../schema'

module TapRep
  module Models
    Base = Struct.new(:data, :client) do # rubocop:disable Metrics/BlockLength
      def self.subclasses
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def self.path
        name.demodulize.tableize
      end

      def self.stream
        name.demodulize.tableize
      end

      def self.key_property
        :id
      end

      def self.schema(&block)
        @schema ||= ::TapRep::Schema.new(stream, key_property)
        @schema.instance_eval(&block) if block_given?
        @schema.to_hash
      end

      def transform
        data.dup
      end

      def base_record
        {
          type: 'RECORD',
          stream: self.class.stream,
          record: transform
        }
      end

      def extra_records
        []
      end

      def records
        [base_record] + extra_records.map(&:records)
      end
    end
  end
end

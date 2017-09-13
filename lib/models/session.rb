# frozen_string_literal: true

require_relative 'base'

module TapRep
  module Models
    # Models a Rep Session
    class Session < Base
      def self.key_property
        :encrypted_id
      end

      def self.path
        'sessions'
      end

      def self.stream
        'sessions'
      end

      schema do
        string :encrypted_id, :not_null
        datetime :first_customer_message_at
        datetime :end_time
        number :duration
        string :responder
        datetime :start_time
        string :channel_name
        object :customer
        string :channel_type
        array :categories
        string :notes
        datetime :first_agent_message_at
        number :time_to_first_response
      end
    end
  end
end

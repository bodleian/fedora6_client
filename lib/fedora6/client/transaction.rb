# frozen_string_literal: true

module Fedora6
  class Client
    # Fedora6::Client::Transaction
    class Transaction < Client
      attr_reader :uri, :config

      def initialize(config = nil)
        @config = Fedora6::Client::Config.new(config).config
        response = Transaction.start_transaction(@config)
        validate_response(response)
        @uri = response["Location"]
      end

      { get: 'get_transaction',
        keep_alive: 'keep_transaction_alive',
        commit: 'commit_transaction',
        rollback: 'rollback_transaction'
      }.each do |key, value|
        define_method(key) do
          response = Transaction.send(value, config, uri)
          validate_response(response, uri, config)
          true
        end
      end
 
      # Class methods

      def self.start_transaction(config)
        perform_request(config, "#{config[:base]}/fcr:tx", 'Post')
      end

      def self.get_transaction(config, uri)
        perform_request(config, uri, 'Get')
      end

      def self.keep_transaction_alive(config, uri)
        perform_request(config, uri, 'Post')
      end

      def self.commit_transaction(config, uri)
        perform_request(config, uri, 'Put')
      end

      def self.rollback_transaction(config, uri)
        perform_request(config, uri, 'Delete')
      end

      def self.perform_request(config, uri, request_type)
        read_timeout = 60
        if request_type == 'Put'
          # Transactions for large objects can take a long while
          # to close, so set a read timeout to 30 minutes 
          read_timeout = 1800
        end
        url = URI.parse(uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https", read_timeout: read_timeout) do |http|
          req = Object.const_get("Net::HTTP::#{request_type}").new(url)
          req.basic_auth(config[:user], config[:password])
          http.request(req)
        end
      end
    end
  end
end

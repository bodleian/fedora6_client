# frozen_string_literal: true

module Fedora6
  module Client
    # Fedora6::Client::Transaction
    class Transaction < Client
      attr_reader :tx_uri

      def initialize(config = nil)
        ## Returns tx_id: the transaction uri
        super
        response = Client::Transaction.start_transaction(@config)
        validate_response(response)
        @tx_uri = response["Location"]
      end

      def get
        response = Client::Transaction.get_transaction(@config, @tx_uri)
        validate_response(response)
        true
      end

      def keep_alive
        response = Client::Transaction.keep_transaction_alive(@config, @tx_uri)
        validate_response(response)
        true
      end

      def commit
        response = Client::Transaction.commit_transaction(@config, @tx_uri)
        validate_response(response)
        true
      end

      def rollback
        response = Client::Transaction.rollback_transaction(@config, @tx_uri)
        validate_response(response)
        true
      end

      def validate_response(response)
        return if %w[201 204].include? response.code

        raise Fedora6::APIError.new(response.code, response.body)
      end

      # Class methods

      def self.start_transaction(config)
        # Returns a transaction ID
        url = URI.parse("#{config[:base]}/fcr:tx")
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Post.new url
          req.basic_auth(config[:user], config[:password])
          http.request(req)
        end
      end

      def self.get_transaction(config, tx_uri)
        # Returns a transaction ID
        url = URI.parse(tx_uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Get.new url
          req.basic_auth(config[:user], config[:password])
          http.request(req)
        end
      end

      def self.keep_transaction_alive(config, tx_uri)
        # keeps a transaction that's > 3 minutes long alive
        url = URI.parse(tx_uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Post.new url
          req.basic_auth(config[:user], config[:password])
          http.request(req)
        end
      end

      def self.commit_transaction(config, tx_uri)
        # keeps a transaction that's > 3 minutes long alive
        url = URI.parse(tx_uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Put.new url
          req.basic_auth(config[:user], config[:password])
          http.request(req)
        end
      end

      def self.rollback_transaction(config, tx_uri)
        url = URI.parse(tx_uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Delete.new url
          req.basic_auth(config[:user], config[:password])
          http.request(req)
        end
      end
    end
  end
end

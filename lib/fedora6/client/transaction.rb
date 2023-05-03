# frozen_string_literal: true

module Fedora6
  class Client
    # Fedora6::Client::Transaction
    class Transaction < Client
      attr_reader :uri

      def initialize(config = nil)
        ## Returns tx_id: the transaction uri
        @config = Fedora6::Client::Config.new(config).config
        response = Client::Transaction.start_transaction(@config)
        validate_response(response)
        @uri = response["Location"]
      end

      def get
        response = Client::Transaction.get_transaction(@config, @uri)
        validate_response(response, @uri, @config)
        true
      end

      def keep_alive
        response = Client::Transaction.keep_transaction_alive(@config, @uri)
        validate_response(response, @uri, @config)
        true
      end

      def commit
        response = Client::Transaction.commit_transaction(@config, @uri)
        validate_response(response, @uri, @config)
        true
      end

      def rollback
        response = Client::Transaction.rollback_transaction(@config, @uri)
        validate_response(response, @uri, @config)
        true
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

      def self.get_transaction(config, uri)
        # Returns a transaction ID
        url = URI.parse(uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Get.new url
          req.basic_auth(config[:user], config[:password])
          http.request(req)
        end
      end

      def self.keep_transaction_alive(config, uri)
        # keeps a transaction that's > 3 minutes long alive
        url = URI.parse(uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Post.new url
          req.basic_auth(config[:user], config[:password])
          http.request(req)
        end
      end

      def self.commit_transaction(config, uri)
        # keeps a transaction that's > 3 minutes long alive
        url = URI.parse(uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Put.new url
          req.basic_auth(config[:user], config[:password])
          http.request(req)
        end
      end

      def self.rollback_transaction(config, uri)
        url = URI.parse(uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Delete.new url
          req.basic_auth(config[:user], config[:password])
          http.request(req)
        end
      end
    end
  end
end

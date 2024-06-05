# frozen_string_literal: true
require 'date'
require "net/http"
require "uri"

require_relative "client/module_version"
require_relative "client/binary"
require_relative "client/config"
require_relative "client/container"
require_relative "client/transaction"
require_relative "client/version"


module Fedora6
  # Fedora6::Client::APIError
  # An error was returned by the Fedora6 API
  class APIError < StandardError
    def initialize(code, message, transaction_uri = nil, config = nil)

      # rollback transaction if one is in progress
      if transaction_uri
        rollback_message = rollback_transaction(config, transaction_uri)
        message = [message, rollback_message].join(' ')
      end
      if message && message != ""
        super("#{code}: #{message}")
      else
        super(code.to_s)
      end
    end

    def rollback_transaction(config, transaction_uri)
      response = Fedora6::Client::Transaction.rollback_transaction(config, transaction_uri)
      if response.code == "204"
        return "Transaction #{transaction_uri} rolled back."
      elsif response.code == "404"
        return "Transaction #{transaction_uri} not found."
      elsif response.code == "410"
        return "Transaction #{transaction_uri} already expired."
      else
        return "Unspecified error occured rolling back #{transaction_uri}"
      end
    end
  end

  # Fedora6::Client
  # Class for Core Fedora6 Client operations
  class Client
    class Error < StandardError; end

    attr_reader :config

    def initialize(config = nil)
      @config = Fedora6::Client::Config.new(config).config
    end

    def ocfl_identifier
      uri.gsub("#{@config[:base]}", 'info:fedora')
    end

    def ocfl_object_path
      id_digest = Digest::SHA2.new(256).hexdigest ocfl_identifier
      object_path = "#{id_digest[0,3]}/#{id_digest[3,3]}/#{id_digest[6,3]}/#{id_digest}"
      return File.join(config[:ocfl_root], object_path)
    end

    def exists?
      response = head(config, uri)
      if %w[200 204].include? response.code
        true
      else
        false
      end
    end

    def tombstone?
      # Test that an object has been tombstoned
      response = head(config, uri)
      if %w[410].include? response.code
        true
      else
        false
      end
    end


    ### TODO: rewrite to detect child type. binary metadata uses get_binary_metadata

    def metadata(timestamp: nil)
      response = get(@config, @uri, timestamp: timestamp)
      # requests for versioned object metadata will often return 302
      # and the correct link will be in the response location
      if timestamp.present? && response.code == "302"
        response = get(@config, response['location'])
      end
      validate_response(response)
      json = JSON.parse(response.body)
      return json.first
    end

    def new_version(transaction_uri: nil)
      response = Fedora6::Client::Version.create_version(config, uri, transaction_uri: transaction_uri)
      validate_response(response)
      Fedora6::Client::Version.new(config, response['Location'])
    end

    def versions
      versions_uri = uri + "/fcr:versions"
      response = get(config, versions_uri)
      validate_response(response)
      json_versions = JSON.parse(response.body).first
      version_uris = json_versions["http://www.w3.org/ns/ldp#contains"].map{|f| f['@id']}
      versions = version_uris.map do |v|
        Fedora6::Client::Version.new(@config, v)
      end
      versions.sort_by{|v| DateTime.parse(v.memento)}
    end

    def children(timestamp: nil)
      object_metadata = metadata(timestamp: timestamp)
      children = object_metadata['http://www.w3.org/ns/ldp#contains'].map{|f| f['@id']}
      return children
    end

    def delete_tombstone(transaction_uri = nil)
      tombstone_uri = uri + '/fcr:tombstone'
      response = Fedora6::Client.delete_object(config, tombstone_uri, transaction_uri: transaction_uri)
      validate_response(response)
      true
    end
    
    def delete(transaction_uri = nil)
      response = Fedora6::Client.delete_object(config, uri, transaction_uri: transaction_uri)
      validate_response(response)
      true
    end

    def purge(transaction_uri = nil)
      delete(transaction_uri)
      delete_tombstone(transaction_uri)
    end

    def head(config, uri)
      url = URI.parse(uri.to_s)
      Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
        req = Net::HTTP::Head.new url
        req.basic_auth(config[:user], config[:password])
        http.request(req)
      end
    end

    def get(config, uri, timestamp: nil)
      fedora_timestamp = Fedora6::Client.rfc1132_timestamp(timestamp)
      url = URI.parse(uri.to_s)
      Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
        req = Net::HTTP::Get.new url
        req.basic_auth(config[:user], config[:password])
        req['Accept'] = "application/ld+json"
        req['Accept-Datetime'] = fedora_timestamp if fedora_timestamp
        http.request(req)
      end
    end

    def self.rfc1132_timestamp(timestamp)
      # Take a date string or ruby datetime object and output an RFC-1123 date
      return false unless timestamp
      return false if timestamp.to_s.empty?
      
      datetime_object = DateTime.parse(timestamp.to_s)
      datetime_object.getgm.strftime("%a, %d %b %Y %H:%M:%S GMT")
    end

    def self.delete_object(config, uri, transaction_uri: nil)
      url = URI.parse(uri)
      Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
        req = Net::HTTP::Delete.new url
        req.basic_auth(config[:user], config[:password])
        req["Atomic-ID"] = transaction_uri if transaction_uri
        http.request(req)
      end        
    end

    def validate_response(response, transaction_uri = nil, config = nil)
      # Calls to get object level versions return 302 responses
      return if %w[200 201 204].include? response.code

      raise Fedora6::APIError.new(response.code, response.body, transaction_uri, config)
    end
  end
end

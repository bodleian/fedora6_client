require "net/http"
require "uri"
# frozen_string_literal: true

require_relative "client/version"
require_relative 'config'
require_relative 'binary'
require_relative 'transaction'
require_relative 'container' 

module Fedora6
  class Client
    class Error < StandardError; end

    def initialize(config:nil)
      @config = Fedora6::Client::Config.new(config)
    end

    def exists? (uri)
      response = self.head(self.config, uri) 
      if ['200', '204'].include? response.code
          return true
      else
          return false
      end
    end

    def self.head(config, binary_uri)
      url = URI.parse("#{binary_uri}/fcr:metadata")
      response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
          req = Net::HTTP::Head.new url
          req.basic_auth(config[:user], config[:password])
          http.request(req)
      end
      return response
    end

    # Your code goes here...
  end
end

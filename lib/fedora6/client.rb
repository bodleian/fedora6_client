# frozen_string_literal: true

require "net/http"
require "uri"
# frozen_string_literal: true

require_relative "client/module_version"
require_relative "client/config"
require_relative "client/binary"
require_relative "client/transaction"
require_relative "client/container"

module Fedora6
  class Error < StandardError; end

  # Fedora6::Client::APIError
  # An error was returned by the Fedora6 API
  class APIError < StandardError
    def initialize(code, message)
      if message && message != ""
        super("#{code}: #{message}")
      else
        super(code.to_s)
      end
    end
  end

  # Fedora6::Client
  # Class for Core Fedora6 Client operations
  class Client
    attr_reader :config

    def initialize(config = nil)
      @config = Fedora6::Client::Config.new(config).config
    end

    def exists?(uri)
      response = head(config, uri)
      if %w[200 204].include? response.code
        true
      else
        false
      end
    end

    def head(config, uri)
      url = URI.parse(uri.to_s)
      Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
        req = Net::HTTP::Head.new url
        req.basic_auth(config[:user], config[:password])
        http.request(req)
      end
    end

    def validate_response(response)
      return if %w[201 204].include? response.code

      raise Fedora6::APIError.new(response.code, response.body)
    end
  end
end

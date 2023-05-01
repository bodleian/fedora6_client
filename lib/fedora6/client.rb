require "net/http"
require "uri"
# frozen_string_literal: true

require_relative "client/module_version"
require_relative 'client/config'
require_relative 'client/binary'
require_relative 'client/transaction'
require_relative 'client/container' 

module Fedora6
    class Error < StandardError; end

    class APIError < StandardError
        attr_reader :code, :message
        def initialize(code, message)
            super
            @code = code
            @message = message
        end
    end

    class Client
        attr_reader :config

        def initialize(config=nil)
            @config = Fedora6::Client::Config.new(config).config
        end
      
        def exists? (uri)
            response = self.head(self.config, uri) 
            if ['200', '204'].include? response.code
                return true
            else
                return false
            end
        end
    
        def head(config, binary_uri)
            url = URI.parse("#{binary_uri}/fcr:metadata")
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
                req = Net::HTTP::Head.new url
                req.basic_auth(config[:user], config[:password])
                http.request(req)
            end
            return response
        end
    end
end

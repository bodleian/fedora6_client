# frozen_string_literal: true

module Fedora6
  class Client
    # Fedora6::Client::Container
    # Class for managing Fedora6 RDF Container
    class Container < Client
      ARCHIVAL_GROUP = "<http://fedora.info/definitions/v4/repository#ArchivalGroup>;rel=\"type\""
      attr_reader :config, :identifier, :uri

      def initialize(config = nil, identifier = nil)
        @config = Fedora6::Client::Config.new(config).config
        @identifier = identifier
        @uri = "#{@config[:base].to_s}/#{identifier}"
      end

      def save(archival_group: false, transaction_uri: false)
        response = Fedora6::Client::Container.create_container(
          @config, @identifier, archival_group, transaction_uri: transaction_uri
        )
        validate_response(response, transaction_uri, @config)
        # Return new URI
        true
      end

      def metadata
        response = Fedora6::Client::Container.get_container(@config, @uri)
        validate_response(response)
        response.body
      end

      # Class methods

      def self.get_container(config, uri)
        url = URI.parse(uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Get.new url
          req.basic_auth(config[:user], config[:password])
          req['Accept'] = "application/ld+json"
          http.request(req)
        end
      end

      def self.create_container(config, identifier, archival_group, transaction_uri: false)
        # create OCFL object
        url = URI.parse((config[:base]).to_s)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Post.new url
          req.basic_auth(config[:user], config[:password])
          req["Atomic-ID"] = transaction_uri if transaction_uri.present?
          req["Slug"] = identifier if identifier.present?
          req["Link"] = ARCHIVAL_GROUP if archival_group
          req.content_type = "text/turtle"
          http.request(req)
        end
      end
    end
  end
end

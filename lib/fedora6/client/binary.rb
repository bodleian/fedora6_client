# frozen_string_literal: true

require "json"

module Fedora6
  class Client
    # Fedora6::Client::Binary
    # Class for interacting with Binary (Non-RDF binary resources)

    EXTERNAL_CONTENT_REL = "rel=\"http://fedora.info/definitions/fcrepo#ExternalContent\"; handling=\"copy\"; type=\"application/octet-stream\""

    class Binary < Client
      attr_reader :config, :parent_uri, :binary_identifier, :uri

      def initialize(config = nil, parent_uri = nil, binary_identifier = nil, binary_uri = nil)
        @config = Fedora6::Client::Config.new(config).config
        @parent_uri = parent_uri
        @binary_identifier = binary_identifier
        @uri = parent_uri && binary_identifier ? "#{parent_uri}/#{binary_identifier}" : binary_uri
      end

      def metadata
        metadata_uri = "#{uri}/fcr:metadata"
        response = get(config, metadata_uri)
        json = JSON.parse(response.body)
        json.first
      end

      def save(binary_data, filename, transaction_uri: nil)
        if exists?
          response = Fedora6::Client::Binary.update_binary(config, uri, filename,
                                                           binary_data, transaction_uri: transaction_uri)
          validate_response(response, transaction_uri, config)
          true
        else
          response = Fedora6::Client::Binary.create_binary(config, parent_uri, binary_identifier,
                                                           filename, binary_data, transaction_uri: transaction_uri)
          validate_response(response, transaction_uri, config)
          @uri = response.body
        end
      end

      def save_by_reference(file_path, transaction_uri: nil)
        if exists?
          response = Fedora6::Client::Binary.update_binary_by_reference(config, @uri,
                                                                        file_path, transaction_uri: transaction_uri)
          validate_response(response, transaction_uri, config)
          true
        else
          response = Fedora6::Client::Binary.create_binary_by_reference(config, parent_uri, @binary_identifier,
                                                                        file_path, transaction_uri: transaction_uri)
          validate_response(response, transaction_uri, config)
          @uri = response.body
        end
      end

      # Class methods

      def self.create_binary(config, parent_uri, file_identifier, filename, binary_data, transaction_uri: nil)
        # upload a file by sending a data binary

        args = {
          body: binary_data,
          file_identifier: file_identifier,
          transaction_uri: transaction_uri,
          content_disposition: "attachment; filename=\"#{filename}\""
        }

        perform_request(config, parent_uri, Net::HTTP::Post, args)
      end

      def self.update_binary(config, binary_uri, filename, binary_data, transaction_uri: nil)
        # update a file by sending a data binary
        args = {
          body: binary_data,
          transaction_uri: transaction_uri,
          content_disposition: "attachment; filename=\"#{filename}\""
        }

        perform_request(config, binary_uri, Net::HTTP::Put, args)
      end

      def self.create_binary_by_reference(config, parent_uri, file_identifier, file_path, transaction_uri: nil)
        # upload a file by sending a data binary by reference
        args = {
          file_identifier: file_identifier,
          transaction_uri: transaction_uri,
          link: "<file://#{file_path}>; #{EXTERNAL_CONTENT_REL}"
        }

        perform_request(config, parent_uri, Net::HTTP::Post, args)
      end

      def self.update_binary_by_reference(config, binary_uri, file_identifier, file_path, transaction_uri: nil)
        # update a file by sending a data binary by reference
        args = {
          transaction_uri: transaction_uri,
          link: "<file://#{file_path}>; #{EXTERNAL_CONTENT_REL}"
        }

        perform_request(config, binary_uri, Net::HTTP::Put, args)
      end

      def self.perform_request(config, uri, http_request, args={})
        url = URI.parse(uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = http_request.new url
          req.basic_auth(config[:user], config[:password])
          req.body = args[:body] if args[:body]
          req["Link"] = args[:link] if args[:link]
          req["Slug"] = args[:file_identifier] if args[:file_identifier]
          req["Atomic-ID"] = args[:transaction_uri] if args[:transaction_uri]
          req["Content-Disposition"] = args[:content_disposition] if args[:content_disposition]
          http.request(req)
        end
      end
    end
  end
end

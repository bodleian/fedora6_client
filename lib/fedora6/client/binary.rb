# frozen_string_literal: true

require "json"

module Fedora6
  class Client
    # Fedora6::Client::Binary
    # Class for interacting with Binary (Non-RDF binary resources)

    EXTERNAL_CONTENT_REL = "rel=\"http://fedora.info/definitions/fcrepo#ExternalContent\"; handling=\"copy\"; type=\"application/octet-stream\""

    class Binary < Client
      attr_reader :config, :parent_uri, :binary_identifier, :uri, :in_archival_group

      def initialize(config = nil, parent_uri = nil, binary_identifier = nil, binary_uri = nil, in_archival_group = true)
        @config = Fedora6::Client::Config.new(config).config
        @parent_uri = parent_uri
        @binary_identifier = binary_identifier
        @uri = parent_uri && binary_identifier ? "#{parent_uri}/#{binary_identifier}" : binary_uri
        @in_archival_group = in_archival_group
      end

      def metadata(timestamp: nil)
        metadata_uri = "#{uri}/fcr:metadata"
        response = get(config, metadata_uri, timestamp: timestamp)
        json = JSON.parse(response.body)
        json.first
      end

      def save(binary_data, filename, transaction_uri: nil)
        if exists? or (tombstone? and in_archival_group)
          response = Fedora6::Client::Binary.update_binary(config, uri, filename,
                                                           binary_data, transaction_uri: transaction_uri,
                                                           overwrite_tombstone: tombstone?)
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
        if exists? or (tombstone? and in_archival_group)
          response = Fedora6::Client::Binary.update_binary_by_reference(config, @uri,
                                                                        file_path, transaction_uri: transaction_uri,
                                                                        overwrite_tombstone: tombstone?)
          validate_response(response, transaction_uri, config)
          true
        else
          response = Fedora6::Client::Binary.create_binary_by_reference(config, parent_uri, @binary_identifier,
                                                                        file_path, transaction_uri: transaction_uri)
          validate_response(response, transaction_uri, config)
          @uri = response.body
        end
      end

      def save_by_stream(file_path, transaction_uri: nil, mime_type: "application/octet-stream")
        if exists? or (tombstone? and in_archival_group)
          response = Fedora6::Client::Binary.update_binary_by_stream(config, @uri, file_path,
                                                                     transaction_uri: transaction_uri,
                                                                     mime_type: mime_type,
                                                                     overwrite_tombstone: tombstone?)
          validate_response(response, transaction_uri, config)
          true
        else
          response = Fedora6::Client::Binary.create_binary_by_stream(config, parent_uri, @binary_identifier,
                                                                     file_path,
                                                                     transaction_uri: transaction_uri,
                                                                     mime_type: mime_type)
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

      def self.update_binary(config, binary_uri, filename, binary_data, transaction_uri: nil, overwrite_tombstone: false)
        # update a file by sending a data binary
        args = {
          body: binary_data,
          transaction_uri: transaction_uri,
          content_disposition: "attachment; filename=\"#{filename}\"",
          overwrite_tombstone: overwrite_tombstone
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

      def self.update_binary_by_reference(config, binary_uri, file_path, transaction_uri: nil, overwrite_tombstone: false)
        # update a file by sending a data binary by reference
        args = {
          transaction_uri: transaction_uri,
          link: "<file://#{file_path}>; #{EXTERNAL_CONTENT_REL}",
          overwrite_tombstone: overwrite_tombstone
        }

        perform_request(config, binary_uri, Net::HTTP::Put, args)
      end

      def self.create_binary_by_stream(config, parent_uri, file_identifier, file_path, transaction_uri: nil, mime_type: "application/octet-stream")
        # upload a file by sending a data binary by reference
        args = {
          file_identifier: file_identifier,
          transaction_uri: transaction_uri,
          body_stream: file_path,
          mime_type: mime_type
        }

        perform_request(config, parent_uri, Net::HTTP::Post, args)
      end

      def self.update_binary_by_stream(config, binary_uri, file_path, transaction_uri: nil, mime_type: "application/octet-stream", overwrite_tombstone: false)
        # update a file by sending a data binary by reference
        args = {
          transaction_uri: transaction_uri,
          body_stream: file_path,
          mime_type: mime_type,
          overwrite_tombstone: overwrite_tombstone
        }

        perform_request(config, binary_uri, Net::HTTP::Put, args)
      end

      def self.perform_request(config, uri, http_request, args={})
        url = URI.parse(uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = http_request.new url
          req.basic_auth(config[:user], config[:password])
          if args[:body]
            req.body = args[:body]
          elsif args[:body_stream] and File.exists?(args[:body_stream])
            req.body_stream = File.open(args[:body_stream])
            req.content_length = File.size(args[:body_stream])
            req.content_type = args[:mime_type]
          end

          req["Link"] = args[:link] if args[:link]
          req["Slug"] = args[:file_identifier] if args[:file_identifier]
          req["Atomic-ID"] = args[:transaction_uri] if args[:transaction_uri]
          req["Content-Disposition"] = args[:content_disposition] if args[:content_disposition]
          req["Overwrite-Tombstone"] = args[:overwrite_tombstone].to_s if args[:overwrite_tombstone]
          http.request(req)
        end
      end

      def get(config, uri, file_path, timestamp: nil)
        fedora_timestamp = rfc1132_timestamp(timestamp)
        url = URI.parse(uri.to_s)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Get.new url
          req.basic_auth(config[:user], config[:password])
          req['Accept-Datetime'] = fedora_timestamp if fedora_timestamp
          http.request(req) do |res|
            validate_response(res)
            open(file_path, 'wb') do |f|
              res.read_body do |chunk|
                f.write chunk
              end
            end
          end
        end
      end

    end
  end
end

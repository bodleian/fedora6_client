# frozen_string_literal: true

module Fedora6
  class Client
    # Fedora6::Client::Binary
    # Class for interacting with Binary (Non-RDF binary resources)
    class Binary < Client
      attr_reader :config, :parent_uri, :binary_identifier, :binary_uri

      def initialize(config = nil, parent_uri = nil, binary_identifier = nil, binary_uri = nil)
        @config = Fedora6::Client::Config.new(config).config
        @parent_uri = parent_uri
        @binary_identifier = binary_identifier
        @uri = if binary_uri
                 binary_uri
               elsif parent_uri && binary_identifier
                 "#{parent_uri}/#{binary_identifier}"
               else
                 nil
               end
      end

      def save(binary_data, filename, transaction_uri: nil)
        if exists?
          response = Fedora6::Client::Binary.update_binary(@config, @uri, filename,
            binary_data, transaction_uri: transaction_uri)
          validate_response(response)
          return true
        else
          response = Fedora6::Client::Binary.create_binary(@config, @parent_uri, @binary_identifier,
            filename, binary_data, transaction_uri: transaction_uri)
          validate_response(response)
          @uri = response.body
        end
      end

      def save_by_reference(filename, file_path, transaction_uri: nil)
        if exists?
          response = Fedora6::Client::Binary.update_binary_by_reference(@config, @binary_uri, filename,
            file_path, transaction_uri: transaction_uri)
          validate_response(response)
          return true
        else
          response = Fedora6::Client::Binary.create_binary_by_reference(@config, @parent_uri, binary_identifier,
            filename, file_path, transaction_uri: transaction_uri)
            validate_response(response)
            @uri = response.body
        end
      end

      # Class methods

      def self.get_binary_metadata(config, binary_uri)
        url = URI.parse("#{binary_uri}/fcr:metadata")
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Get.new url
          req.basic_auth(config[:user], config[:password])
          http.request(req)
        end
      end

      def self.get_binary_versions(config, binary_uri)
        url = URI.parse("#{binary_uri}/fcr:versions")
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Get.new url
          req.basic_auth(config[:user], config[:password])
          http.request(req)
        end
      end

      def self.create_binary(config, parent_uri, file_identifier, filename, binary_data, transaction_uri: nil)
        # upload a file by sending a data binary
        url = URI.parse(parent_uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Post.new url
          req.basic_auth(config[:user], config[:password])
          req["Atomic-ID"] = transaction_uri if transaction_uri
          req["Slug"] = file_identifier
          req["Content-Disposition"] = "attachment; filename=\"#{filename}\""
          req.body = binary_data
          http.request(req)
        end
      end

      def self.update_binary(config, binary_uri, filename, binary_data, transaction_uri: nil)
        # update a file by sending a data binary
        url = URI.parse(binary_uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Put.new url
          req.basic_auth(config[:user], config[:password])
          req["Atomic-ID"] = transaction_uri if transaction_uri
          req["Content-Disposition"] = "attachment; filename=\"#{filename}\""
          req.body = binary_data
          http.request(req)
        end
      end

      def self.create_binary_by_refrerence(config, parent_uri, file_identifier, file_path, transaction_uri: nil)
        # upload a file by sending a data binary by reference
        link = "file://#{file_path}; rel=\"http://fedora.info/definitions/fcrepo#ExternalContent\"; handling=\"copy\";"
        url = URI.parse(parent_uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Post.new url
          req.basic_auth(config[:user], config[:password])
          req["Atomic-ID"] = transaction_uri if transaction_uri
          req["Slug"] = file_identifier
          req["Link"] = link
          http.request(req)
        end
      end

      def self.update_binary_by_refrerence(config, binary_uri, file_identifier, file_path, transaction_uri: nil)
        # update a file by sending a data binary by reference
        link = "file://#{file_path}; rel=\"http://fedora.info/definitions/fcrepo#ExternalContent\"; handling=\"copy\";"
        url = URI.parse(binary_uri)
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Put.new url
          req.basic_auth(config[:user], config[:password])
          req["Atomic-ID"] = transaction_uri if transaction_uri
          req["Slug"] = file_identifier
          req["Link"] = link
          http.request(req)
        end
      end
    end
  end
end

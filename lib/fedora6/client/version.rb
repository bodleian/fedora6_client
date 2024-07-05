# frozen_string_literal: true

module Fedora6
  class Client
    # Fedora6::Client::Version
    # Class for managing Fedora6 RDF Version(s)
    class Version < Client
      attr_reader :config, :uri
      attr_accessor :memento

      def initialize(config = nil, uri = nil)
        @config = Fedora6::Client::Config.new(config).config
        @uri = uri
        @memento = set_memento
      end

      def set_memento
        # The only metadata we need here is in a header, a good thing, because
        # the get call to the version for a binary file downloads the file
        version_metadata = head(config, uri)
        version_metadata["Memento-Datetime"]
      end

      # Class methods

      # Create a new version for a resource. Returns a version uri in the body
      def self.create_version(config, uri, transaction_uri: nil)
        # upload a file by sending a data binary
        url = URI.parse("#{uri}/fcr:versions")
        Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
          req = Net::HTTP::Post.new url
          req.basic_auth(config[:user], config[:password])
          req["Atomic-ID"] = transaction_uri if transaction_uri
          http.request(req)
        end
      end
    end
  end
end

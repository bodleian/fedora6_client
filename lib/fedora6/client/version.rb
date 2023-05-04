# frozen_string_literal: true

module Fedora6
    class Client
      # Fedora6::Client::Version
      # Class for managing Fedora6 RDF Version
      class Version < Client
        attr_reader :config, :identifier, :uri
  
        def initialize(config = nil, parent_uri = nil, identifier = nil)
          @config = Fedora6::Client::Config.new(config).config
          @identifier = identifier
          @uri = "#{parent_uri}/fcr:versions/#{identifier}"
        end
  
  
        def metadata
          response = get(@config, @uri)
          validate_response(response)
          response.body
        end
  
        # Class methods

        # Add methods to create new versions
  
      end
    end
  end
  
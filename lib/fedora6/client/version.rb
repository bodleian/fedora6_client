# frozen_string_literal: true

module Fedora6
    class Client
      # Fedora6::Client::Version
      # Class for managing Fedora6 RDF Version(s)
      class Version < Client
        attr_reader :config, :memento, :uri
  
        def initialize(config = nil, uri = nil)
          @config = config || Fedora6::Client::Config.new.config
          @uri = uri
          @memento = memento
        end

        def memento
          # The only metadata we need here is in a header, a good thing, because
          # the get call to the version for a binary file downloads the file
          version_metadata = head(@config, @uri)
          return version_metadata["Memento-Datetime"]
        end
  
        # Class methods

        # Add methods to create new versions
  
      end
    end
  end
  
# frozen_string_literal: true

module Fedora6
  # Fedora6::Client configuration class
  class Client
    # Fedora6::Client configuration class
    class Config
      attr_reader :config

      def default_config
        password = "orapass"
        user = "ora"
        server = "ora4-qa-dps-witness.bodleian.ox.ac.uk"
        port = "443"
        ocfl_root = "/data/ocfl/ocfl-root/"
        {
          user: user,
          password: password,
          base: "https://#{server}:#{port}/fcrepo/rest",
          ocfl_root: ocfl_root
        }
      end

      def initialize(configuration = nil)
        @config = configuration || default_config
      end
    end
  end
end

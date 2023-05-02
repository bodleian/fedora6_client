# frozen_string_literal: true

module Fedora6
  module Client
    # Fedora6::Client configuration class
    class Config
      attr_reader :config

      def default_config
        password = "orapass"
        user = "ora"
        server = "ora4-qa-dps-witness.bodleian.ox.ac.uk"
        port = "443"
        file_root = "/tmp/"
        {
          user: user,
          password: password,
          base: "https://#{server}:#{port}/fcrepo/rest",
          upload_file_root: file_root
        }
      end

      def initialize(configuration = nil)
        @config = configuration || default_config
      end
    end
  end
end

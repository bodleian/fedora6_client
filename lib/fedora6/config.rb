module Fedora6
    module Client
      # Your code goes here...
      class Config
        attr_reader :default_config
        def default_config
            password = 'orapass'
            user = 'ora'
            server = 'ora4-qa-dps-witness.bodleian.ox.ac.uk'
            port = '443'
            file_root = '/tmp/'
            return {
                user: user,
                password: password,
                base: "https://#{server}:#{port}/fcrepo/rest",
                upload_file_root: file_root
            }
        end

        def initialize(configuration: default_config)
            self.config = configuration
        end
      end

    end
end
  
 
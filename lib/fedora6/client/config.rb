module Fedora6
      # Your code goes here...
      class Client::Config
        attr_reader :default_config, :config
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

        def initialize(configuration = nil)
            @config = configuration || self.default_config
        end
      end

end
  
 
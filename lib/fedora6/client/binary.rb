module Fedora6
      # Your code goes here...
      class Client::Binary < Client
        attr_reader :config, :parent_uri, :binary_identifier, :binary_uri
        def initialize(config=nil, parent_uri=nil, binary_identifier=nil, binary_uri=nil)
            @config = Fedora6::Client::Config.new(config).config
            @parent_uri = parent_uri
            @binary_identifier = binary_identifier
            if binary_uri
                @binary_uri = binary_uri
            elsif parent_uri && binary_identifier
                @binary_uri = "#{parent_uri}/#{binary_identifier}"
            else
                @binary_uri = nil
            end
        end

        def save(binary_data, filename, transaction_uri: false)
          if exists? (self.binary_uri)
            Fedora6::Client::Binary.update_binary(self.config, self.binary_uri, filename, binary_data, transaction_uri: transaction_uri)
          else
            Fedora6::Client::Binary.create_binary(self.config, self.parent_uri, self.binary_identifier, filename, binary_data, transaction_uri: transaction_uri)
          end
        end

        def save_by_reference(filename, file_path, transaction_uri: false)
            if exists? (self.binary_uri)
                Fedora6::Client::Binary.update_binary_by_reference(self.config, self.binary_uri, filename, file_path, transaction_uri: transaction_uri)
            else
                Fedora6::Client::Binary.create_binary_by_reference(self.config, self.parent_uri, self.binary_identifier, filename, file_path, transaction_uri: transaction_uri)
            end
        end

        # Class methods

        def self.get_binary_metadata(config, binary_uri)
            url = URI.parse("#{binary_uri}/fcr:metadata")
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
                req = Net::HTTP::Get.new url
                req.basic_auth(config[:user], config[:password])
                http.request(req)
            end
            return response
        end
        
        def self.get_binary_versions(config, binary_uri)
            url = URI.parse("#{binary_uri}/fcr:versions")
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
                req = Net::HTTP::Get.new url
                req.basic_auth(config[:user], config[:password])
                http.request(req)
            end
            return response
        end

        def self.create_binary(config, parent_uri, file_identifier, filename, binary_data, transaction_uri: nil)
          # upload a file by sending a data binary
          # curl -X POST -u ${AUTH} --data-binary @${FILE} -H "Slug: ${file_identifier}" -H "Atomic-ID:${TX1}" -H -"Content-Disposition: attachment; filename=\"${filename}\"" ${BASE}/${UUID}
          url = URI.parse(parent_uri)
          response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
            req = Net::HTTP::Post.new url
            req.basic_auth(config[:user], config[:password])
            if transaction_uri
              req['Atomic-ID'] = transaction_uri
            end
            req['Slug'] = file_identifier
            req['Content-Disposition'] = "attachment; filename=\"#{filename}\""
            req.body = binary_data
            http.request(req)
          end
          return response
        end

        def self.update_binary(config, binary_uri, filename, binary_data, transaction_uri: nil)
          # update a file by sending a data binary #TODO rewrite with link
          # curl -X PUT -u ${AUTH} --data-binary @${FILE} -H "Slug: ${file_identifier}" -H "Atomic-ID:${TX1}" -H -"Content-Disposition: attachment; filename=\"${filename}\"" ${BASE}/${UUID}
          url = URI.parse(binary_uri)
          response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
            req = Net::HTTP::Put.new url
            req.basic_auth(config[:user], config[:password])
            if transaction_uri
              req['Atomic-ID'] = transaction_uri
            end
            req['Content-Disposition'] = "attachment; filename=\"#{filename}\""
            req.body = binary_data
            http.request(req)
          end
          return response
        end

        def self.create_binary_by_refrerence(config, parent_uri, file_identifier, filename, file_path, transaction_uri: nil)
            # upload a file by sending a data binary by reference
            link= "file://#{file_path}; rel=\"http://fedora.info/definitions/fcrepo#ExternalContent\"; handling=\"copy\";"
            url = URI.parse(parent_uri)
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
                req = Net::HTTP::Post.new url
                req.basic_auth(config[:user], config[:password])
                if transaction_uri
                    req['Atomic-ID'] = transaction_uri
                end
                req['Slug'] = file_identifier
                req['Link'] = link
                http.request(req)
            end
            return response            
        end

        def self.create_binary_by_refrerence(config, parent_uri, file_identifier, filename, file_path, transaction_uri: nil)
          # update a file by sending a data binary by reference
          link= "file://#{file_path}; rel=\"http://fedora.info/definitions/fcrepo#ExternalContent\"; handling=\"copy\";"
          url = URI.parse(parent_uri)
          response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
            req = Net::HTTP::Put.new url
            req.basic_auth(config[:user], config[:password])
            if transaction_uri
              req['Atomic-ID'] = transaction_uri
            end
            req['Slug'] = file_identifier
            req['Link'] = link
            http.request(req)
          end
          return response
        end
      end
end
module Fedora6
    module Client
      # Your code goes here...
      class Binary < Fedora6::Client

        def upload(file_identifier, filename, file_path, parent_uri, transaction_uri: false)
            if exists? ("#{parent_uri}/#{file_identifier}")
                self.update_binary(self.config, parent_uri, file_identifier, filename, file_path, transaction_uri: transaction_uri)
            else
                self.create_binary(self.config, parent_uri, file_identifier, filename, file_path, transaction_uri: transaction_uri)
            end
        end

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

        def self.create_binary(config, parent_uri, file_identifier, filename, file_path, transaction_uri: nil)
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
                req.body = File.read(file_path)
                http.request(req)
            end
            return response            
        end

        def self.update_binary(config, parent_uri, file_identifier, filename, file_path, transaction_uri: nil)
            # update a file by sending a data binary
            # curl -X PUT -u ${AUTH} --data-binary @${FILE} -H "Slug: ${file_identifier}" -H "Atomic-ID:${TX1}" -H -"Content-Disposition: attachment; filename=\"${filename}\"" ${BASE}/${UUID}
            url = URI.parse("#{parent_uri}/#{file_identifier}")
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
                req = Net::HTTP::Put.new url
                req.basic_auth(config[:user], config[:password])
                if transaction_uri
                    req['Atomic-ID'] = transaction_uri
                end
                req['Content-Disposition'] = "attachment; filename=\"#{filename}\""
                req.body = File.read(file_path)
                http.request(req)
            end
            return response           
        end
      end

    end
end
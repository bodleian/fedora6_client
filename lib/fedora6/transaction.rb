module Fedora6
    module Client
      # Your code goes here...
      class Transaction < Fedora6::Client
        super

        def initialize
          super
          @identifier = self.start_transaction(self.config)
        end

        def keep_alive
          return self.keep_transaction_alive(@config, @identifier)
        end

        def commit
          return self.commit_transaction(@config, @identifier)
        end

        def rollback
          return self.rollback_transaction(@config, @identifier)
        end



        def self.start_transaction(config)
          # Returns a transaction ID
          url = URI.parse("#{config[:base]}/fcr:tx")
          response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
            req = Net::HTTP::Post.new url
            req.basic_auth(config[:user], config[:password])
            http.request(req)
          end
          return result['Location']
        end

        def self.keep_transaction_alive(config, transaction_uri)
          # keeps a transaction that's > 3 minutes long alive
          url = URI.parse(transaction_uri)
          response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
            req = Net::HTTP::Post.new url
            req.basic_auth(config[:user], config[:password])
            http.request(req)
          end
        end

        def self.commit_transaction(config, transaction_uri)
            # keeps a transaction that's > 3 minutes long alive
            url = URI.parse(transaction_uri)
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
            req = Net::HTTP::Put.new url
            req.basic_auth(config[:user], config[:password])
            http.request(req)
          end
        end

        def self.rollback_transaction(config, transaction_uri)
            url = URI.parse(transaction_uri)
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
            req = Net::HTTP::Delete.new url
            req.basic_auth(config[:user], config[:password])
            http.request(req)
          end
        end        

      end

    end
end
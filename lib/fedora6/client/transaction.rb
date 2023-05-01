module Fedora6
      # Your code goes here...
      class Client::Transaction < Client

        attr_reader :tx_id

        def initialize(config = nil)
          super
          #require 'byebug'; byebug
          create_transaction = Client::Transaction.start_transaction(self.config)
          if create_transaction.code == '201'
            @tx_id = create_transaction['Location']
          else 
            raise Fedora6::Client::Error
          end
        end

        def keep_alive
          return Client::Transaction.keep_transaction_alive(@config, @tx_id)
        end

        def commit
          return Client::Transaction.commit_transaction(@config, @tx_id)
        end

        def rollback
          return Client::Transaction.rollback_transaction(@config, @tx_id)
        end



        def self.start_transaction(config)
          # Returns a transaction ID
          url = URI.parse("#{config[:base]}/fcr:tx")
          response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
            req = Net::HTTP::Post.new url
            req.basic_auth(config[:user], config[:password])
            http.request(req)
          end
          return response
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
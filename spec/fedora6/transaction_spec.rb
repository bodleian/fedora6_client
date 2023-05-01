# frozen_string_literal: true

RSpec.describe Fedora6::Client::Transaction do

    it "new transactions are created on init" do
        transaction = Fedora6::Client::Transaction.new({base: 'https://test_transaction.com/base'})
        expect(transaction.config).not_to be nil
        expect(transaction.tx_id).to eq '12345678'
    end

    it "has get method" do 
        transaction = Fedora6::Client::Transaction.new({base: 'https://test_transaction.com/base'})
        expect(transaction.get.code).to eq '204'
    end

    it "has keep_alive method" do 
        transaction = Fedora6::Client::Transaction.new({base: 'https://test_transaction.com/base'})
        expect(transaction.keep_alive.code).to eq '204'
    end

    it "has commit method" do 
        transaction = Fedora6::Client::Transaction.new({base: 'https://test_transaction.com/base'})
        expect(transaction.commit.code).to eq '204'
    end

    it "has rollback method" do 
        transaction = Fedora6::Client::Transaction.new({base: 'https://test_transaction.com/base'})
        expect(transaction.rollback.code).to eq '204'
    end

    it "returns 404 when transaction not found" do
        transaction = Fedora6::Client::Transaction.new({base: 'https://test_transaction.com/missing'})
        expect{transaction.get}.to raise_error(Fedora6::APIError)
        #expect(transaction.code).to eq '404'
    end

    it "returns 409 on conflict" do 
        transaction = Fedora6::Client::Transaction.new({base: 'https://test_transaction.com/conflict'})
        expect{transaction.get}.to raise_error(Fedora6::APIError)
        #expect(transaction.code).to eq '409'

    end

    it "returns 410 when transaction expired" do 
        transaction = Fedora6::Client::Transaction.new({base: 'https://test_transaction.com/expired'})
        expect{transaction.get}.to raise_error(Fedora6::APIError)
        #expect(transaction.code).to eq '410'
    end


end
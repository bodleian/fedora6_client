# frozen_string_literal: true

RSpec.describe Fedora6::Client::Transaction do
    it "blank transactions are successful" do
        transaction = Fedora6::Client::Transaction.new({base: 'https://test_transaction.com/base'})
        expect(transaction.config).not_to be nil
        expect(transaction.tx_id).to eq '12345678'
    end
end
# frozen_string_literal: true

RSpec.describe Fedora6::Client::Transaction do
    it "it inherits configuration" do
        transaction = Fedora6::Client::Transaction.new  
        expect(transaction.config).not_to be nil
    end
end
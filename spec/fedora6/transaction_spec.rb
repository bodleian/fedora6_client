# frozen_string_literal: true

RSpec.describe Fedora6::Client::Transaction do
  it "new transactions are created on init" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test_transaction.com/base" })
    expect(transaction.config).not_to be nil
    expect(transaction.tx_uri).to eq "https://test_transaction.com/base/fcr:tx/12345678"
  end

  it "has get method" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test_transaction.com/base" })
    expect(transaction.get).to eq true
  end

  it "has keep_alive method" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test_transaction.com/base" })
    expect(transaction.keep_alive).to eq true
  end

  it "has commit method" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test_transaction.com/base" })
    expect(transaction.commit).to eq true
  end

  it "has rollback method" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test_transaction.com/base" })
    expect(transaction.rollback).to eq true
  end

  it "returns 404 when transaction not found" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test_transaction.com/missing" })
    expect { transaction.get }.to raise_error(Fedora6::APIError, "404")
  end

  it "returns 409 on conflict" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test_transaction.com/conflict" })
    expect { transaction.commit }.to raise_error(Fedora6::APIError, "409")
  end

  it "returns 410 when transaction expired" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test_transaction.com/expired" })
    expect { transaction.get }.to raise_error(Fedora6::APIError, "410")
  end
end

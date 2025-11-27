# frozen_string_literal: true
require "fedora6/client"

RSpec.describe Fedora6::Client::Transaction do
  it "new transactions are created on init" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test.com/base" })
    expect(transaction.config).not_to be nil
    expect(transaction.uri).to eq "https://test.com/base/fcr:tx/12345678"
  end

  it "has get method" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test.com/base" })
    expect(transaction.get).to eq true
  end

  it "has keep_alive method" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test.com/base" })
    expect(transaction.keep_alive).to eq true
  end

  it "has commit method" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test.com/base" })
    expect(transaction.commit).to eq true
  end

  it "has rollback method" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test.com/base" })
    expect(transaction.rollback).to eq true
  end

  it "returns 404 when transaction not found" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test.com/missing" })
    expect { transaction.get }.to raise_error(Fedora6::APIError, "404:  Transaction https://test.com/missing/fcr:tx/12345678 not found.")
  end

  it "returns 409 on conflict" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test.com/conflict" })
    expect { transaction.commit }.to raise_error(Fedora6::APIError, "409:  Transaction https://test.com/conflict/fcr:tx/12345678 rolled back.")
  end

  it "returns 410 when transaction expired" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test.com/expired" })
    expect { transaction.get }.to raise_error(Fedora6::APIError, "410:  Transaction https://test.com/expired/fcr:tx/12345678 already expired.")
  end
end

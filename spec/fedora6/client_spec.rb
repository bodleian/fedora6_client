# frozen_string_literal: true

require 'date'

RSpec.describe Fedora6::Client do
  it "has a Version" do
    expect(Fedora6::Client::VERSION).not_to be nil
  end

  it "it provides an object's file path" do
    config = Fedora6::Client::Config.new.config
    container = Fedora6::Client::Container.new(config, 'uuid_12345678-1234-1234-1234-12345678abcd')
    expect(container.ocfl_object_path).to eq '/data/ocfl/ocfl-root/8ce/19a/80f/8ce19a80ff7611110d9a1c07a4ff36bd1e3b5bbf2cc60e89bcdbbc10a0600b55'
  end

  it "it provides an object's ocfl identifier" do
    config = Fedora6::Client::Config.new.config
    container = Fedora6::Client::Container.new(config, 'uuid_12345678-1234-1234-1234-12345678abcd')
    expect(container.ocfl_identifier).to eq 'info:fedora/uuid_12345678-1234-1234-1234-12345678abcd'
  end

  it "has purge function" do 
    transaction = Fedora6::Client::Transaction.new({ base: "https://test_transaction.com/base" })
    container = Fedora6::Client::Container.new({ base: "https://test_transaction.com/base" }, 'uuid_12345678-1234-1234-1234-12345678abcd')
    expect(container.purge(transaction.uri)).to eq true
  end

  it "has delete function" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test_transaction.com/base" })
    container = Fedora6::Client::Container.new({ base: "https://test_transaction.com/base" }, 'uuid_12345678-1234-1234-1234-12345678abcd')
    expect(container.delete(transaction.uri)).to eq true
  end

  it "has delete tomstone function" do
    transaction = Fedora6::Client::Transaction.new({ base: "https://test_transaction.com/base" })
    container = Fedora6::Client::Container.new({ base: "https://test_transaction.com/base" }, 'uuid_12345678-1234-1234-1234-12345678abcd')
    expect(container.delete_tombstone(transaction.uri)).to eq true
  end

  it "parses dates" do 
    input_date = "2022-05-05T13:50"
    expected_date_string = "Thu, 05 May 2022 13:50:00 +00:00"
    datetime_object = DateTime.parse(input_date)
    # Test both strings and DateTime objects
    [input_date, datetime_object].map do |d|
      expect(Fedora6::Client.rfc1132_timestamp(d)).to eq expected_date_string
    end
    # Test nil inputs return false
    expect(Fedora6::Client.rfc1132_timestamp(false)).to eq false
    expect(Fedora6::Client.rfc1132_timestamp('')).to eq false

  end
end

# frozen_string_literal: true

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
end

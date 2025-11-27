# frozen_string_literal: true
require "fedora6/client"

RSpec.describe Fedora6::Client::Config do
  it "it has configuration" do
    test = Fedora6::Client::Config.new({ user: "testuser" }).config
    expect(test[:user]).to eq "testuser"
  end

  it "it has default configuration" do
    test = Fedora6::Client::Config.new.config
    expect(test[:user]).to eq "ora"
  end
end

# frozen_string_literal: true
require "fedora6/client"

RSpec.describe Fedora6::Client::Container do
  it "it inherits configuration" do
    container = Fedora6::Client::Container.new
    expect(container.config).not_to be nil
  end
end

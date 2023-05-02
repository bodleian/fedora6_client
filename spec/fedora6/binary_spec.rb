# frozen_string_literal: true

RSpec.describe Fedora6::Client::Binary do
  it "it inherits configuration" do
    binary = Fedora6::Client::Binary.new
    expect(binary.config).not_to be nil
  end
end

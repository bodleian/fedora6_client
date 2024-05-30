# frozen_string_literal: true

RSpec.describe Fedora6::Client::Binary do
  it "it inherits configuration" do
    binary = Fedora6::Client::Binary.new
    expect(binary.config).not_to be nil
  end

  it "understands archival groups" do
    binary = Fedora6::Client::Binary.new(
      { base: "https://test.com/base" }, 'https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd', 'tombstoned_file', nil)
    expect(binary.in_archival_group).to eq true
    binary = Fedora6::Client::Binary.new(
      { base: "https://test.com/base" }, 'https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd', 'tombstoned_file', nil, false)    
    expect(binary.in_archival_group).to eq false
  end
end

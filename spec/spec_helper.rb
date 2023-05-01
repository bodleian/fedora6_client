# frozen_string_literal: true

require "fedora6/client"
require 'webmock/rspec'


RSpec.configure do |config|
    # Enable flags like --only-failures and --next-failure
    config.example_status_persistence_file_path = ".rspec_status"

    # Disable RSpec exposing methods globally on `Module` and `main`
    config.disable_monkey_patching!

    config.expect_with :rspec do |c|
        c.syntax = :expect
    end

    config.before(:each) do
    ### Transaction stubs

    # Create transaction
    stub_request(:post, "https://test_transaction.com/base/fcr:tx").
        to_return(status: 201, headers: {Location: '12345678'}, body: nil)
    end
end

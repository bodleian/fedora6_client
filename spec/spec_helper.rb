# frozen_string_literal: true

require "fedora6/client"
require "webmock/rspec"

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
    stub_request(:post, "https://test_transaction.com/base/fcr:tx")
      .to_return(status: 201, headers: { Location: "https://test_transaction.com/base/fcr:tx/12345678" }, body: nil)
    stub_request(:post, "https://test_transaction.com/missing/fcr:tx")
      .to_return(status: 201, headers: { Location: "https://test_transaction.com/missing/fcr:tx/12345678" }, body: nil)
    stub_request(:post, "https://test_transaction.com/conflict/fcr:tx")
      .to_return(status: 201, headers: { Location: "https://test_transaction.com/conflict/fcr:tx/12345678" }, body: nil)
    stub_request(:post, "https://test_transaction.com/expired/fcr:tx")
      .to_return(status: 201, headers: { Location: "https://test_transaction.com/expired/fcr:tx/12345678" }, body: nil)

    # Get transaction status
    stub_request(:get, "https://test_transaction.com/base/fcr:tx/12345678")
      .to_return(status: 204, body: nil)
    stub_request(:get, "https://test_transaction.com/missing/fcr:tx/12345678")
      .to_return(status: 404, body: nil)
    stub_request(:get, "https://test_transaction.com/expired/fcr:tx/12345678")
      .to_return(status: 410, body: nil)

    # Keep transaction alive
    stub_request(:post, "https://test_transaction.com/base/fcr:tx/12345678")
      .to_return(status: 204, body: nil)
    stub_request(:post, "https://test_transaction.com/missing/fcr:tx/12345678")
      .to_return(status: 404, body: nil)
    stub_requ.est(:post, "https://test_transaction.com/expired/fcr:tx/12345678")
             .to_return(status: 410, body: nil)

    # Commit transaction
    stub_request(:put, "https://test_transaction.com/base/fcr:tx/12345678")
      .to_return(status: 204, body: nil)
    stub_request(:put, "https://test_transaction.com/missing/fcr:tx/12345678")
      .to_return(status: 404, body: nil)
    stub_request(:put, "https://test_transaction.com/conflict/fcr:tx/12345678")
      .to_return(status: 409, body: nil)
    stub_request(:put, "https://test_transaction.com/expired/fcr:tx/12345678")
      .to_return(status: 410, body: nil)

    # Rollback transaction
    stub_request(:delete, "https://test_transaction.com/base/fcr:tx/12345678")
      .to_return(status: 204, body: nil)
    stub_request(:post, "https://test_transaction.com/missing/fcr:tx/12345678")
      .to_return(status: 404, body: nil)
    stub_request(:post, "https://test_transaction.com/expired/fcr:tx/12345678")
      .to_return(status: 410, body: nil)
  end
end

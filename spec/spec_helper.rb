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

  versions_list = """[{
    \"@id\":\"https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/fcr:versions\",
    \"@type\":[\"http://www.w3.org/ns/ldp#RDFSource\",\"http://www.w3.org/ns/ldp#Container\",\"http://www.w3.org/ns/ldp#Resource\"],
    \"http://www.w3.org/ns/ldp#contains\":
      [
        {\"@id\":\"https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/fcr:versions/20230428141819\"},
        {\"@id\":\"https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/fcr:versions/20230428141753\"},
        {\"@id\":\"https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/fcr:versions/20230428140019\"}
        ],
    \"@ModifiedBy\":[{\"@value\":\"ora\"}],
    \"http://mementoweb.org/ns#original\":[{\"@id\":\"https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd\"}],
    \"http://fedora.info/definitions/v4/repository#createdBy\":[{\"@value\":\"ora\"}],
    \"http://fedora.info/definitions/v4/repository#created\":[{\"@value\":\"2023-04-28T13:59:02.467364Z\",\"@type\":\"http://www.w3.org/2001/XMLSchema#dateTime\"}],
    \"http://fedora.info/definitions/v4/repository#lastModified\":[{\"@value\":\"2023-04-28T13:59:02.467364Z\",\"@type\":\"http://www.w3.org/2001/XMLSchema#dateTime\"}]
    }]
    \n
"""
  object_metadata = """[{
     \"@id\":\"https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/\",
     \"http://www.w3.org/ns/ldp#contains\":
         [{\"@id\":\"https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/uuid_12345678-1234-1234-1234-12345678abcd.metadata.ora.v2.json\"},
          {\"@id\":\"https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/fileset1\"}
     ],
     \"@type\":[\"http://www.w3.org/ns/ldp#Container\",\"http://www.w3.org/ns/ldp#RDFSource\",\"http://fedora.info/definitions/v4/repository#Container\",\"http://www.w3.org/ns/ldp#Resource\",\"http://www.w3.org/ns/ldp#BasicContainer\",\"http://fedora.info/definitions/v4/repository#Resource\"],
     \"http://fedora.info/definitions/v4/repository#created\":[{\"@value\":\"2023-05-09T11:36:24.762663Z\",\"@type\":\"http://www.w3.org/2001/XMLSchema#dateTime\"}],
     \"http://fedora.info/definitions/v4/repository#lastModified\":[{\"@value\":\"2023-05-09T11:36:24.762663Z\",\"@type\":\"http://www.w3.org/2001/XMLSchema#dateTime\"}],
     \"http://fedora.info/definitions/v4/repository#createdBy\":[{\"@value\":\"ora\"}],
     \"http://fedora.info/definitions/v4/repository#lastModifiedBy\":[{\"@value\":\"ora\"}]}]
\n
"""


  config.before(:each) do



    ### Container stubs
    stub_request(:get, "https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd")
      .to_return(status: 200, body: object_metadata)
    stub_request(:delete, "https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd")
      .to_return(status: 204, body: nil)

    # Tombstone delete
    stub_request(:delete, "https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/fcr:tombstone")
      .to_return(status: 204, body: nil)

    # Versions list
    stub_request(:get, "https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/fcr:versions")
      .to_return(status: 200, body: versions_list)


    ### Transaction stubs

    # Create transaction
    stub_request(:post, "https://test.com/base/fcr:tx")
      .to_return(status: 201, headers: { Location: "https://test.com/base/fcr:tx/12345678" }, body: nil)
    stub_request(:post, "https://test.com/missing/fcr:tx")
      .to_return(status: 201, headers: { Location: "https://test.com/missing/fcr:tx/12345678" }, body: nil)
    stub_request(:post, "https://test.com/conflict/fcr:tx")
      .to_return(status: 201, headers: { Location: "https://test.com/conflict/fcr:tx/12345678" }, body: nil)
    stub_request(:post, "https://test.com/expired/fcr:tx")
      .to_return(status: 201, headers: { Location: "https://test.com/expired/fcr:tx/12345678" }, body: nil)

    # Get transaction status
    stub_request(:get, "https://test.com/base/fcr:tx/12345678")
      .to_return(status: 204, body: nil)
    stub_request(:get, "https://test.com/missing/fcr:tx/12345678")
      .to_return(status: 404, body: nil)
    stub_request(:get, "https://test.com/expired/fcr:tx/12345678")
      .to_return(status: 410, body: nil)

    # Keep transaction alive
    stub_request(:post, "https://test.com/base/fcr:tx/12345678")
      .to_return(status: 204, body: nil)
    stub_request(:post, "https://test.com/missing/fcr:tx/12345678")
      .to_return(status: 404, body: nil)
    stub_request(:post, "https://test.com/expired/fcr:tx/12345678")
      .to_return(status: 410, body: nil)

    # Commit transaction
    stub_request(:put, "https://test.com/base/fcr:tx/12345678")
      .to_return(status: 204, body: nil)
    stub_request(:put, "https://test.com/missing/fcr:tx/12345678")
      .to_return(status: 404, body: nil)
    stub_request(:put, "https://test.com/conflict/fcr:tx/12345678")
      .to_return(status: 409, body: nil)
    stub_request(:put, "https://test.com/expired/fcr:tx/12345678")
      .to_return(status: 410, body: nil)

    # Rollback transaction
    stub_request(:delete, "https://test.com/base/fcr:tx/12345678")
      .to_return(status: 204, body: nil)
    stub_request(:delete, "https://test.com/missing/fcr:tx/12345678")
      .to_return(status: 404, body: nil)
    stub_request(:delete, "https://test.com/conflict/fcr:tx/12345678")
      .to_return(status: 204, body: nil)
    stub_request(:delete, "https://test.com/expired/fcr:tx/12345678")
      .to_return(status: 410, body: nil)

    ### Version stubs
    stub_request(:get, "https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/fcr:versions")
      .to_return(status: 200, body: versions_list)
    stub_request(:get, "https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/fcr:versions/20230428141819")
      .to_return(status: 200, headers: {"Memento-Datetime" => 'Fri, 28 Apr 2023 13:59:09 GMT'}, body: "[]")
    stub_request(:head, "https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/fcr:versions/20230428141819")
      .to_return(status: 200, headers: {"Memento-Datetime" => 'Fri, 28 Apr 2023 13:59:09 GMT'}, body: "[]")
    stub_request(:head, "https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/fcr:versions/20230428141753")
      .to_return(status: 200, headers: {"Memento-Datetime" => 'Sat, 29 Apr 2023 14:59:09 GMT'}, body: "[]")
    stub_request(:head, "https://test.com/base/uuid_12345678-1234-1234-1234-12345678abcd/fcr:versions/20230428140019")
      .to_return(status: 200, headers: {"Memento-Datetime" => 'Sun, 23 Apr 2023 15:59:09 GMT'}, body: "[]")
  end
end

"[{\"@id\":\"https://ora4-qa-dps-witness.bodleian.ox.ac.uk/fcrepo/rest/uuid_e029104a-fced-49c9-b038-147bd62068bf/fcr:versions\",\"@type\":[\"http://www.w3.org/ns/ldp#RDFSource\",\"http://www.w3.org/ns/ldp#Container\",\"http://www.w3.org/ns/ldp#Resource\"],\"http://www.w3.org/ns/ldp#contains\":[{\"@id\":\"https://ora4-qa-dps-witness.bodleian.ox.ac.uk/fcrepo/rest/uuid_e029104a-fce
45\"},{\"@id\":\"https://ora4-qa-dps-witness.bodleian.ox.ac.uk/fcrepo/rest/uuid_e029104a-fced-49c9-b038-147bd62068bf/fcr:versions/20230428141819\"},
{\"@id\":\"https://ora4-qa-dps-witness.bodleian.ox.ac.uk/fcrepo/rest/uuid_e029104a-fced-49c9-b038-147bd62068bf/fcr:versions/20230428141753\"},{\"@id\":\"https://ora4-qa-dps-witness.bodleian.ox.ac.uk/fcrepo/rest/uuid_e029104a-fced-49c9-b038-147bd62068bf/fcr:versions/20230428140019\"},{\"@id\":\"https://ora4-qa-dps-witness.bodleian.ox.ac.uk/fcrepo/rest/uuid_e029104a-fced-49c9-b038-147bd62068bf/fcr:versions/20230428135903\"},{\
ModifiedBy\":[{\"@value\":\"ora\"}],\"http://mementoweb.org/ns#original\":[{\"@id\":\"https://ora4-qa-dps-witness.bodleian.ox.ac.uk/fcrepo/rest/uuid_e029104a-fced-49c9-b038-147bd62068bf\"}],\"http://fedora.info/definitions/v4/repository#createdBy\":[{\"@value\":\"ora\"}],\"http://fedora.info/definitions/v4/repository#created\":[{\"@value\":\"2023-04-28T13:59:02.467364Z\",\"@type\":\"http://www.w3.org/2001/XMLSchema#dateTime\"}],\"http://fedora.info/definitions/v4/repository#lastModified\":[{\"@value\":\"2023-04-28T13:59:02.467364Z\",\"@type\":\"http://www.w3.org/2001/XMLSchema#dateTime\"}]}]\n"

# frozen_string_literal: true

RSpec.describe Fedora6::Client::Version do
    it "has get method" do
        ocfl_object = Fedora6::Client::Container.new({ base: "https://test.com/base" }, "uuid_12345678-1234-1234-1234-12345678abcd")
        version = Fedora6::Client::Version.new(nil, "#{ocfl_object.uri}/fcr:versions/20230428141819")
        expect(version.get(version.config, version.uri).code).to eq '200'
    end

    it "has get memento timestamp" do
        ocfl_object = Fedora6::Client::Container.new({ base: "https://test.com/base" }, "uuid_12345678-1234-1234-1234-12345678abcd")
        version = Fedora6::Client::Version.new(nil, "#{ocfl_object.uri}/fcr:versions/20230428141819")
        expect(version.memento).to eq 'Fri, 28 Apr 2023 13:59:09 GMT'
    end

    it "can create new versions" do
        ocfl_object = Fedora6::Client::Container.new({ base: "https://test.com/base" }, "uuid_12345678-1234-1234-1234-12345678abcd")
        version = ocfl_object.new_version
        expect(version.memento).to eq 'Sat, 30 Apr 2023 13:59:09 GMT'
    end



end